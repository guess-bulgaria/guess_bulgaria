import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guess_bulgaria/components/color_picker.dart';
import 'package:guess_bulgaria/components/drawer.dart';
import 'package:guess_bulgaria/components/loader.dart';
import 'package:guess_bulgaria/components/navigation_button.dart';
import 'package:guess_bulgaria/components/open_drawer_button.dart';
import 'package:guess_bulgaria/components/player_list.dart';
import 'package:guess_bulgaria/components/scrolling_background.dart';
import 'package:guess_bulgaria/pages/game_page.dart';
import 'package:guess_bulgaria/services/game/multiplayer_game_service.dart';
import 'package:guess_bulgaria/services/ws_service.dart';
import 'dart:async';

import 'package:guess_bulgaria/storage/user_data.dart';

// ignore: must_be_immutable
class LobbyPage extends StatefulWidget {
  dynamic joinData;

  LobbyPage({Key? key, this.joinData}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LobbyPageState();
}

class _LobbyPageState extends State<LobbyPage> {
  Timer? _debounce;
  bool _isCreator = true;
  int roomId = 0;
  int color = UserData.defaultColor;
  List<dynamic> players = [];
  List<int> usedColors = [];
  bool isBackgroundPaused = false;

  int rounds = 10;
  int roundTime = 30;

  bool _isRoomPublic = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _roundsController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  void _sendSettings() async {
    if (!_isCreator) return;
    // debounce so it won't activate on each number type
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 700), () {
      WSService.changeSettings(
          roomId,
          rounds,
          roundTime,
          _isRoomPublic, []);
    });
    await UserData().setLobbySettings(rounds, roundTime, _isRoomPublic);
  }

  @override
  void initState() {
    super.initState();
    if (widget.joinData == null) {
      WSService.createGame(onMessageReceived, settings: UserData.lobbySettings);
    } else {
      setupJoinData();
      _isCreator = false;
    }
  }

  Future<bool> leave() async {
    WSService.changeCallback(null);
    WSService.leave(roomId);
    Navigator.pop(context);
    return false;
  }

  void onMessageReceived(String type, dynamic message) {
    switch (type) {
      case 'current-data':
        setRoomData(message);
        break;
      case 'settings-change':
        setSettings(message);
        break;
      case 'color-change':
        setState(() {
          usedColors = [];
          for (final player in players) {
            if (player['id'] == message['id']) {
              player['color'] = message['color'];
              if (player['id'] == UserData.userId) color = player['color'];
            }
            usedColors.add(player['color']);
          }
        });
        break;
      case 'start-round':
        setState(() {
          isBackgroundPaused = true;
        });
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => GamePage(
                      MultiplayerGameService(message['roomId']),
                      gameData: message,
                    ))).then(
          (value) {
            setState(() {
              isBackgroundPaused = false;
            });
            if (value == true) leave();
          },
        );
        break;
      case 'player-join':
      case 'player-leave':
        setState(() {
          players = message['players'];
          usedColors = [];
          for (final player in players) {
            if (player['id'] == UserData.userId) {
              _isCreator = player['isCreator'];
            }
            usedColors.add(player['color']);
          }
        });
        break;
    }
  }

  void setupJoinData() {
    setRoomData(widget.joinData);
    WSService.changeCallback(onMessageReceived);
  }

  void setRoomData(message) {
    setState(() {
      roomId = message['roomId'];
      _isRoomPublic = message['settings']['isPublic'] ?? true;
      setSettings(message['settings']);
      players = message['players'];
      usedColors = [];
      for (var player in players) {
        if (player['id'] == UserData.userId) {
          color = player['color'];
        }
        usedColors.add(player['color']);
      }
    });
  }

  void setSettings(settings) {
    if (_isCreator) return;
    rounds = settings['maxRounds'];
    roundTime = settings['maxRounds'];
    _roundsController.text = "$rounds";
    _timeController.text = "$roundTime";
    _isRoomPublic = settings['isPublic'];
    setState(() => {});
  }

  void onRoundsChange(String r) {
    rounds = int.tryParse(r) ?? 0;
    bool hasChanged = false;
    if (rounds == 0) {
      hasChanged = true;
    } else if (rounds > 30) {
      rounds = 30;
      hasChanged = true;
    }
    if(hasChanged){
      _roundsController.text = "$rounds";
      _roundsController.selection =
          TextSelection.fromPosition(const TextPosition(offset: 0))
              .extendTo(TextPosition(offset: _roundsController.text.length));
    }
    _sendSettings();
  }

  void onTimeChange(String r) {
    roundTime = int.tryParse(r) ?? 0;
    bool hasChanged = false;
    if (roundTime == 0) {
      hasChanged = true;
    } else if (roundTime > 120) {
      hasChanged = true;
      roundTime = 120;
    } else if (roundTime > 0 && roundTime < 5) {
      hasChanged = true;
      roundTime = 5;
    }
    if(hasChanged){
      _timeController.text = "$roundTime";
      _timeController.selection =
          TextSelection.fromPosition(const TextPosition(offset: 0))
              .extendTo(TextPosition(offset: _timeController.text.length));
    }
    _sendSettings();
  }

  @override
  void dispose() {
    _roundsController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  void start() {
    WSService.startRound(roomId, callback: onMessageReceived);
    setState(() {});
  }

  void openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: false,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        body: Builder(
          builder: (c) => Stack(
            clipBehavior: Clip.antiAlias,
            children: [
              ScrollingBackground(isPaused: isBackgroundPaused),
              OpenDrawerButton(
                icon: Icons.settings,
                clickCallback: openDrawer,
              ),
              roomId == 0
                  ? const GbLoader()
                  : Align(
                      alignment: Alignment.center,
                      child: FractionallySizedBox(
                        widthFactor: 0.9,
                        heightFactor: 0.9,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 25),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 10,
                                child: Column(
                                  children: [
                                    const Text(
                                      "Код за присъединяване",
                                      style: TextStyle(fontSize: 20),
                                    ),
                                    Text(
                                      '$roomId',
                                      style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 15),
                                    const Text(
                                      "Играчи",
                                      style: TextStyle(fontSize: 26),
                                    ),
                                    const Divider(thickness: 0.7),
                                    Expanded(
                                      child: PlayerList(
                                        players,
                                        PlayerListType.lobby,
                                      ),
                                    ),
                                    const Divider(thickness: 0.7),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 10,
                                        child: NavigationButton(
                                          text: "Излез",
                                          onPressed: leave,
                                        ),
                                      ),
                                      if (_isCreator)
                                        const Expanded(
                                            flex: 1, child: Text("")),
                                      if (_isCreator)
                                        Expanded(
                                          flex: 10,
                                          child: NavigationButton(
                                            text: "Старт",
                                            onPressed:
                                                players.length > 1
                                                    ? start
                                                    : null,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
            ],
          ),
        ),
        drawerEnableOpenDragGesture: false,
        drawer: GbDrawer(
          icon: Icons.settings,
          children: [
            SizedBox(
              height: 20,
              child: FittedBox(
                fit: BoxFit.fitWidth,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.only(right: 4),
                      child: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Видимост',
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                    ),
                    Switch(
                      value: _isRoomPublic,
                      onChanged: _isCreator
                          ? (val) => {
                                setState(() => _isRoomPublic = val),
                                _sendSettings()
                              }
                          : null,
                      activeColor: Theme.of(context).colorScheme.tertiary,
                    ),
                  ],
                ),
              ),
            ),
            const Divider(thickness: 0.45),
            SizedBox(
              height: 30,
              child: TextFormField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.only(right: 30, top: 2, bottom: 9),
                  prefix: Text("Рундове:"),
                  prefixStyle: TextStyle(fontSize: 16),
                ),
                enabled: _isCreator,
                autovalidateMode: AutovalidateMode.always,
                textAlign: TextAlign.end,
                controller: _roundsController,
                onChanged: (rounds) => onRoundsChange(rounds),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                ],
              ),
            ),
            SizedBox(
              height: 38,
              child: TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefix: Container(
                    child: const Text("Време:"),
                    margin: const EdgeInsets.only(right: 10),
                  ),
                  prefixStyle: const TextStyle(fontSize: 16),
                  suffix: const Text("сек."),
                  suffixStyle: const TextStyle(fontSize: 16),
                ),
                textAlign: TextAlign.end,
                enabled: _isCreator,
                controller: _timeController,
                autovalidateMode: AutovalidateMode.always,
                onChanged: (rounds) => onTimeChange(rounds),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 10),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: ColorPicker(
                  usedColors: usedColors,
                  iconMargin: 3,
                  selectedColor: color,
                  onColorChange: (i) => WSService.changeColor(roomId, i),
                ),
              ),
            ),
            const Divider(thickness: 0.45)
          ],
        ),
      ),
      onWillPop: leave,
    );
  }
}
