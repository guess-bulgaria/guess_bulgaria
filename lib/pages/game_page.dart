import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guess_bulgaria/components/badge.dart';
import 'package:guess_bulgaria/components/controllers/timer_controller.dart';
import 'package:guess_bulgaria/components/drawer.dart';
import 'package:guess_bulgaria/components/loader.dart';
import 'package:guess_bulgaria/components/open_drawer_button.dart';
import 'package:guess_bulgaria/components/timer.dart';
import 'package:guess_bulgaria/configs/player_colors.dart';
import 'package:guess_bulgaria/dialogs/end_game_dialog.dart';
import 'package:guess_bulgaria/dialogs/leave_game_confirmation_dialog.dart';
import 'package:guess_bulgaria/services/game/i_game_service.dart';
import 'package:guess_bulgaria/services/ws_service.dart';
import 'package:guess_bulgaria/storage/user_data.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:guess_bulgaria/components/player_list.dart';
import 'package:photo_view/photo_view.dart';

class GamePage extends StatefulWidget {
  final IGameService gameService;
  final dynamic gameData;

  const GamePage(this.gameService, {Key? key, this.gameData}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late MapboxMapController _mapController;
  late TimerController _timerController;
  late Color _playerColor;
  dynamic _roundData;
  LatLng? _selectedLocation;
  List<dynamic> _players = [];
  late Image _image;
  bool _hasRoundEnded = false;
  bool _hasLocked = false;
  bool _hasEnded = false;
  int _startTime = 0;
  int _endTime = 0;
  int _currentRound = 1;

  _onMapCreated(MapboxMapController controller) {
    widget.gameService.onMapCreated(controller);
    _mapController = controller;
  }

  _onStyleLoadedCallback() async {
    final Uint8List list =
        (await rootBundle.load("assets/icons/marker.png")).buffer.asUint8List();
    await _mapController.addImage("pin", list, true);
  }

  void _onMapClickCallback(Point<double> point, LatLng coordinates) {
    if (_hasLocked) return;
    _mapController.clearSymbols();
    _mapController.addSymbol(
      SymbolOptions(
        geometry: coordinates,
        iconImage: "pin",
        iconColor: _playerColor.toHexStringRGB(),
        textSize: 20,
        iconOpacity: 1.0,
        iconSize: 1.02,
      ),
    );
    _selectedLocation = coordinates;
  }

  void onMessageReceived(String type, dynamic message) async {
    switch (type) {
      case 'player-leave':
        setState(() {
          _players = message['players'];
        });
        break;
      case "end-game":
        _players = message['players'];
        _hasEnded = true;
        break;
      case "start-round":
        _timerController.reset();
        loadRound(message['currentRound']);
        break;
      case "stats-update":
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) => EndGameDialog(_players, message),
        ).then((value) {
          print("ASDDSA $value");
          value == true
              ? Navigator.of(context).pop(true)
              : Navigator.of(context).pop();
        });
        //todo we can simply update the stats from the message, but I am too lazy to do it now :)
        UserData().loadStatistics();
        break;
      case "player-answer":
        setState(() {
          for (final player in _players) {
            if (player['id'] == message['id']) {
              player['hasAnswered'] = true;
            }
          }
        });
        break;
      case "end-round":
        _hasRoundEnded = true;
        _timerController.pause();
        widget.gameService.setEndRoundSymbols(
            message['players'], message['currentRound']['coordinates']);
        _players = message['players'];
        setState(() {});
    }
  }

  void _lockAnswer() {
    if (_selectedLocation == null) return;
    widget.gameService.lockAnswer(_selectedLocation!);

    setState(() {
      _hasLocked = true;
    });
  }

  @override
  void initState() {
    WSService.changeCallback(onMessageReceived);

    if (widget.gameData != null) {
      _roundData = widget.gameData['currentRound'];
      _players = widget.gameData['players'];
      _endTime = widget.gameData["settings"]?["answerTimeInSeconds"] ?? 0;

      if (_roundData['image'] != null) {
        _image = Image.memory(base64Decode(_roundData['image']));
      }
    }
    _timerController = TimerController(_startTime, _endTime, timerEndCallback);

    _playerColor = PlayerColors.color(
      _players.firstWhere((p) => p['id'] == UserData.userId,
          orElse: () => {'color': UserData.defaultColor})['color'],
    );

    super.initState();
  }

  @override
  void dispose() {
    _timerController.stop();
    super.dispose();
  }

  void timerEndCallback() {
    _selectedLocation ??= const LatLng(0, 0);
    _lockAnswer();
  }

  bool isCreator() {
    return _players.firstWhere((p) => p['isCreator'] == true)['id'] ==
        UserData.userId;
  }

  final _buttonStyle = ButtonStyle(
    foregroundColor: MaterialStateProperty.resolveWith<Color>(
      (Set<MaterialState> states) {
        if (states.contains(MaterialState.pressed)) {
          return Colors.white.withOpacity(0.5);
        } else if (states.contains(MaterialState.disabled)) {
          return Colors.white24;
        }
        return (Colors.white);
      },
    ),
  );

  Future<bool> onBackButton() async {
    if (_hasEnded) return true;
    showDialog(
        context: context,
        builder: (_) => const LeaveGameConfirmationDialog()).then((value) {
      if (value == true) {
        Navigator.of(context).pop(true);
      }
    });
    return false;
  }

  void loadRound(dynamic roundData) {
    setState(() {
      _hasRoundEnded = false;
      _mapController.clearSymbols();
      _mapController.clearLines();
      _roundData = roundData;
      _currentRound++;
      if (roundData?['image'] != null) {
        _image = Image.memory(base64Decode(roundData?['image']));
      }
      for (var p in _players) {
        p['hasAnswered'] = false;
      }
      _mapController.animateCamera(CameraUpdate.newCameraPosition(
          widget.gameService.initialCameraPosition));
      _selectedLocation = null;
      _hasLocked = false;
      _startTime = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    var player =
        _players.firstWhere((element) => element["id"] == UserData.userId);
    int totalPoints = player["points"];
    int points = player["roundPoints"] ?? 0;
    int totalPlayers = _players.where((p) => p['isConnected'] == true).length;
    int answeredPlayers = _players
        .where((p) => p['hasAnswered'] == true && p['isConnected'] == true)
        .length;
    int totalRounds = widget.gameData["settings"]?["maxRounds"] ?? 0;
    return WillPopScope(
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          body: Builder(
              builder: (context) => Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Flex(
                        direction: Axis.vertical,
                        children: [
                          Expanded(
                            flex: 3,
                            child: _roundData?['image'] != null
                                ? PhotoView(
                                    backgroundDecoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary),
                                    basePosition: Alignment.center,
                                    imageProvider: _image.image,
                                    minScale: PhotoViewComputedScale.contained,
                                    gaplessPlayback: true,
                                    maxScale: 3.5)
                                : const GbLoader(),
                          ),
                          Expanded(
                            flex: 2,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).backgroundColor,
                                border: Border.symmetric(
                                    horizontal: BorderSide(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .inversePrimary,
                                  width: 4,
                                )),
                              ),
                              child: Column(
                                children: [
                                    Badge(
                                      textCenter: true,
                                      text: _roundData['name'] ?? '',
                                    ),
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Badge(
                                            title: 'Рунд',
                                            text:
                                            '$_currentRound${totalRounds > 0 ? '/$totalRounds' : ''}',
                                            icon: Icons.gamepad_outlined,
                                            center: true,
                                          ),
                                        ),
                                        if (!widget.gameService.isSingle())
                                          Expanded(
                                            child: Badge(
                                              title: 'Отговорили играчи',
                                              text:
                                              '$answeredPlayers/$totalPlayers',
                                              icon: Icons
                                                  .person_pin_circle_outlined,
                                              center: true,
                                            ),
                                          ),
                                        Expanded(
                                          child: Column(mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              Container(
                                                alignment: Alignment.bottomCenter,
                                                child: const FittedBox(
                                                  fit: BoxFit.cover,
                                                  child: Text(
                                                    'Точки',
                                                    style:
                                                    TextStyle(fontSize: 14),
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                margin:
                                                const EdgeInsets.symmetric(
                                                    vertical: 5,
                                                    horizontal: 10),
                                                height: 30,
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondary,
                                                  borderRadius:
                                                  BorderRadius.circular(10.0),
                                                  border: Border.all(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .secondary,
                                                    width: 4,
                                                  ),
                                                ),
                                                child: Align(
                                                  alignment: Alignment.centerLeft,
                                                  child: FittedBox(
                                                    fit: BoxFit.scaleDown,
                                                    child: Row(
                                                      children: [
                                                        Container(
                                                          child: Icon(
                                                            Icons.star,
                                                            color: Theme.of(
                                                                context)
                                                                .secondaryHeaderColor,
                                                          ),
                                                          margin: const EdgeInsets
                                                              .symmetric(
                                                              horizontal: 3),
                                                        ),
                                                        TweenAnimationBuilder<
                                                            double>(
                                                          tween: Tween<double>(
                                                              begin: 0,
                                                              end: totalPoints
                                                                  .toDouble()),
                                                          duration:
                                                          const Duration(
                                                              milliseconds:
                                                              750),
                                                          builder: (BuildContext
                                                          context,
                                                              double value,
                                                              Widget? child) {
                                                            return Text(
                                                                '${value.toInt()}');
                                                          },
                                                        ),
                                                        Text(
                                                          points > 0
                                                              ? ' +$points'
                                                              : '',
                                                          style: const TextStyle(
                                                              fontSize: 10),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (_endTime > 0)
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 4),
                                      child: Timer(_timerController),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: Stack(
                              children: [
                                MapboxMap(
                                  //Out of the box logo w/ info that crashes the app on click
                                  logoViewMargins: const Point(15000, 15000),
                                  attributionButtonMargins:
                                      const Point(15000, 15000),
                                  styleString:
                                      "mapbox://styles/zealbg/cl23l4amx000m14nvowuqneao",
                                  accessToken:
                                      "pk.eyJ1IjoiemVhbGJnIiwiYSI6ImNsMjNsMTFydzFxYngzaW10ZnR6Mmp5cXIifQ.-sw5o3XCLxMoSjUhs3li2A",
                                  onMapCreated: _onMapCreated,
                                  rotateGesturesEnabled: false,
                                  tiltGesturesEnabled: false,
                                  trackCameraPosition: true,
                                  onMapClick: _onMapClickCallback,
                                  initialCameraPosition:
                                      widget.gameService.initialCameraPosition,
                                  minMaxZoomPreference:
                                      const MinMaxZoomPreference(5.4, 16),
                                  cameraTargetBounds: CameraTargetBounds(
                                    LatLngBounds(
                                        northeast: const LatLng(44.213, 28.609),
                                        southwest: const LatLng(41.235, 22.36)),
                                  ),
                                  onStyleLoadedCallback: _onStyleLoadedCallback,
                                ),
                                Align(
                                  alignment: FractionalOffset.bottomRight,
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                        bottom: 10, right: 10, left: 10),
                                    child: Stack(
                                      children: [
                                        if (isCreator())
                                          Align(
                                            alignment: Alignment.bottomLeft,
                                            child: ElevatedButton(
                                              style: _buttonStyle,
                                              onPressed: _hasRoundEnded
                                                  ? widget.gameService.nextRound
                                                  : null,
                                              child: FittedBox(
                                                child: SizedBox(
                                                    height: 45,
                                                    child: Row(
                                                      children: const [
                                                        Text(
                                                          "Следващ рунд",
                                                        ),
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 4),
                                                          child: Icon(
                                                              Icons
                                                                  .arrow_circle_right_outlined,
                                                              size: 20),
                                                        ),
                                                      ],
                                                    )),
                                              ),
                                            ),
                                          ),
                                        Align(
                                          alignment: Alignment.bottomRight,
                                          child: ElevatedButton(
                                            style: _buttonStyle,
                                            child: FittedBox(
                                              child: SizedBox(
                                                height: 45,
                                                child: Row(
                                                  children: const [
                                                    Text(
                                                      "Избери",
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 4),
                                                      child: Icon(Icons.lock,
                                                          size: 17),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            onPressed: !_hasLocked
                                                ? _lockAnswer
                                                : null,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                      if (!widget.gameService.isSingle())
                        OpenDrawerButton(
                          isEnd: true,
                          clickCallback: () =>
                              Scaffold.of(context).openEndDrawer(),
                          icon: Icons.people,
                        ),
                    ],
                  )),
          onEndDrawerChanged: (isOpen) {},
          endDrawerEnableOpenDragGesture: false,
          endDrawer: GbDrawer(
            isEnd: true,
            heightFactor: 1.5,
            topMarginFactor: 8,
            width: MediaQuery.of(context).size.width / 1.5,
            buttonWidthScale: 1.12,
            buttonTop: 1.936,
            children: [
              const Text("Играчи",
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
              const Divider(
                thickness: 0.45,
              ),
              SizedBox(
                height: (MediaQuery.of(context).size.height / 1.5) - 140,
                child: PlayerList(_players, PlayerListType.scoreboard),
              ),
              const Divider(
                thickness: 0.45,
              ),
            ],
            icon: Icons.people,
          ),
        ),
        onWillPop: onBackButton);
  }
}
