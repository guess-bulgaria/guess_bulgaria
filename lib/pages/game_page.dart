import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:expandable/expandable.dart';
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
import 'package:guess_bulgaria/dialogs/game_starting_dialog.dart';
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

class _GamePageState extends State<GamePage>
    with SingleTickerProviderStateMixin {
  late MapboxMapController _mapController;
  late TimerController _timerController;
  final ExpandableController _expandableController = ExpandableController();
  final ScrollController _descriptionScrollController = ScrollController();
  late AnimationController _rotationController;
  late Color _playerColor;
  dynamic _roundData;
  LatLng? _selectedLocation;
  List<dynamic> _players = [];
  Image? _image;
  Image? _cachedImage;
  bool _hasRoundEnded = false;
  bool _hasLocked = false;
  bool _hasGameEnded = false;
  int _startTime = 0;
  int _endTime = 0;
  int _currentRound = 1;
  String? _description;
  String? _hiddenName;
  List<int?>? _hiddenNameIndexes;
  int? _timer;

  @override
  void initState() {
    WSService.changeCallback(onMessageReceived);
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _playerColor = PlayerColors.color(
      _players.firstWhere((p) => p['id'] == UserData.userId,
          orElse: () => {'color': UserData.defaultColor})['color'],
    );

    if (widget.gameData != null) {
      _roundData = widget.gameData['currentRound'];
      _players = widget.gameData['players'];
      _endTime = widget.gameData['settings']?['answerTimeInSeconds'] ?? 0;
    }
    _timerController = TimerController(_startTime, _endTime, timerEndCallback);

    if (_roundData['image'] != null) {
      _cachedImage = Image.memory(base64Decode(_roundData['image']));
    }
    WSService.roundLoaded(widget.gameData['roomId']);
    Future.delayed(Duration.zero).then((_) => showDialog(
        context: context,
        builder: (BuildContext context) => GameStartingDialog(timer: _timer),
        barrierDismissible: false));
    super.initState();
  }

  @override
  void dispose() {
    _timerController.dispose();
    _mapController.dispose();
    _expandableController.dispose();
    _descriptionScrollController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

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
    setState(() {
      _selectedLocation = coordinates;
    });
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
        _hasGameEnded = true;
        break;
      case "start-round":
        loadRound(message['currentRound']);
        setState(() {
          _description = null;
        });
        showDialog(
            context: context,
            builder: (BuildContext context) =>
                GameStartingDialog(timer: _timer),
            barrierDismissible: false);
        WSService.roundLoaded(message['roomId']);
        break;
      case "timer-start":
        setState(() {
          _image = null;
          _timer = message['timer'];
        });
        break;
      case "timer-end":
        if (ModalRoute.of(context)?.isCurrent != true) {
          Navigator.of(context).pop();
        }
        setHiddenName();
        _timerController.reset(timerEndCallback);
        _expandableController.value = false;
        _rotationController.animateTo(_expandableController.expanded ? 1 : 0);
        _showImage();
        break;
      case "stats-update":
        await UserData().loadStatistics(endGameStats: message['overall']);
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) =>
              EndGameDialog(_players, message['statsChanges']),
        ).then((value) => Navigator.of(context).pop(value));
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
        setState(() {
          _hasRoundEnded = true;
          _hiddenNameIndexes = [];
          _timerController.pause();
          _descriptionScrollController.animateTo(0,
              duration: const Duration(milliseconds: 1), curve: Curves.linear);
          widget.gameService.setEndRoundSymbols(
              message['players'], message['currentRound']['coordinates']);

          _description = message['currentRound']['description'];
          _players = message['players'];
          _hiddenName = _roundData['name'];
        });
    }
  }

  void _lockAnswer() {
    if (_selectedLocation == null) return;
    widget.gameService.lockAnswer(_selectedLocation!);

    setState(() {
      _hasLocked = true;
    });
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
    if (_hasGameEnded) return true;
    showDialog(
        context: context,
        builder: (_) => const LeaveGameConfirmationDialog()).then((value) {
      if (value == true) {
        Navigator.of(context).pop(true);
      }
    });
    return false;
  }

  void setHiddenName() async {
    setState(() {
      _hasRoundEnded = false;
      _hiddenName = _roundData['name'];
      if (_endTime == 0) return;
      _hiddenName = _hiddenName!.replaceAll(
          RegExp( 
              r'[АБВГДЕЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЬЮЯабвгдежзийклмнопрстуфхцчшщъьюяA-Za-z0-9]'),
          '_');
      _hiddenNameIndexes = [];
      for (int i = 0; i < _hiddenName!.length; i++) {
        if (_hiddenName![i] != ' ') _hiddenNameIndexes!.add(i);
      }
    });

    if (_endTime == 0) return;
    var endInMillis = _endTime * 1000;
    int duration = ((endInMillis) / _hiddenNameIndexes!.length).floor();
    while (_hiddenNameIndexes!.isNotEmpty) {
      await Future.delayed(Duration(milliseconds: duration));
      if (_hasRoundEnded) return;
      showLetter();
    }
  }

  void showLetter() {
    if (_hiddenNameIndexes?.isEmpty ?? true) return;
    setState(() {
      //use the image for a random letter to ensure everyone gets the same letter at the same time
      var index = (_roundData['image'].codeUnitAt(
              _currentRound * _endTime + _hiddenNameIndexes!.length) as int) %
          _hiddenNameIndexes!.length;
      var letterIndex = _hiddenNameIndexes!.removeAt(index);
      _hiddenName = _hiddenName!.replaceRange(letterIndex ?? 0,
          (letterIndex ?? 0) + 1, _roundData['name'][letterIndex]);
    });
  }

  void loadRound(dynamic roundData) {
    setState(() {
      _mapController.clearSymbols();
      _mapController.clearLines();
      _roundData = roundData;
      _currentRound++;
      if (roundData?['image'] != null) {
        _cachedImage = Image.memory(base64Decode(roundData?['image']));
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

  _showImage() {
    setState(() => _image = _cachedImage);
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
                            child: Stack(
                              children: [
                                _image != null
                                    ? PhotoView(
                                        backgroundDecoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary),
                                        basePosition: Alignment.center,
                                        imageProvider: _image!.image,
                                        minScale:
                                            PhotoViewComputedScale.contained,
                                        gaplessPlayback: true,
                                        maxScale: 3.5)
                                    : const GbLoader(),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
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
                                  CustomBadge(
                                    textCenter: true,
                                    text: _hiddenName ?? '',
                                    letterSpacing: 1.2,
                                  ),
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: CustomBadge(
                                            title: 'Рунд',
                                            text:
                                                '$_currentRound${totalRounds > 0 ? '/$totalRounds' : ''}',
                                            icon: Icons.gamepad_outlined,
                                            center: true,
                                          ),
                                        ),
                                        if (!widget.gameService.isSingle())
                                          Expanded(
                                            child: CustomBadge(
                                              title: 'Отговорили играчи',
                                              text:
                                                  '$answeredPlayers/$totalPlayers',
                                              icon: Icons
                                                  .person_pin_circle_outlined,
                                              center: true,
                                            ),
                                          ),
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Container(
                                                alignment:
                                                    Alignment.bottomCenter,
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
                                                      BorderRadius.circular(
                                                          10.0),
                                                  border: Border.all(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .secondary,
                                                    width: 4,
                                                  ),
                                                ),
                                                child: Align(
                                                  alignment:
                                                      Alignment.centerLeft,
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
                                                          margin:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      3),
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
                                                          style:
                                                              const TextStyle(
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
                                      southwest: const LatLng(41.235, 22.36),
                                    ),
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
                                                        Text("Следващ рунд"),
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
                                                    Text("Избери"),
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
                                            onPressed: !_hasLocked &&
                                                    _selectedLocation != null
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
                      SizedBox(
                        width: double.infinity,
                        child: LayoutBuilder(
                          builder: (context, BoxConstraints constraints) {
                            return ExpandableNotifier(
                              controller: _expandableController,
                              child: ScrollOnExpand(
                                child: Column(
                                  children: [
                                    Expandable(
                                      collapsed:
                                          Container(width: double.infinity),
                                      expanded: Container(
                                        padding: const EdgeInsets.all(10),
                                        width: double.infinity,
                                        height:
                                            MediaQuery.of(context).size.height /
                                                3.4,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                          borderRadius: const BorderRadius.only(
                                            bottomLeft: Radius.circular(20.0),
                                            bottomRight: Radius.circular(20.0),
                                          ),
                                        ),
                                        child: SingleChildScrollView(
                                          controller:
                                              _descriptionScrollController,
                                          scrollDirection:
                                              Axis.vertical, //.horizontal
                                          child: Column(
                                            children: [
                                              Text(
                                                _roundData['name'] ?? '',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .secondaryHeaderColor,
                                                    fontSize: 20),
                                              ),
                                              const Divider(),
                                              Text(
                                                _description ?? '',
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.zero,
                                            height: 30,
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary,
                                              borderRadius:
                                                  const BorderRadius.only(
                                                bottomLeft:
                                                    Radius.circular(40.0),
                                                bottomRight:
                                                    Radius.circular(40.0),
                                              ),
                                            ),
                                            child: RotationTransition(
                                              turns: Tween(begin: 1.0, end: 0.5)
                                                  .animate(_rotationController),
                                              child: IconButton(
                                                  padding: EdgeInsets.zero,
                                                  constraints:
                                                      const BoxConstraints(),
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                  iconSize: 30,
                                                  icon: const Icon(Icons
                                                      .arrow_drop_down_circle_outlined),
                                                  onPressed:
                                                      _description == null
                                                          ? null
                                                          : () {
                                                              _expandableController
                                                                  .toggle();
                                                              _rotationController
                                                                  .animateTo(
                                                                      _expandableController
                                                                              .expanded
                                                                          ? 1
                                                                          : 0);
                                                            }),
                                            ),
                                          )
                                        ]),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
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
