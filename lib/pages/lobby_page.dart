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

  bool _isRoomPublic = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _roundsController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  void _sendSettings() {
    if (!_isCreator) return;
    // debounce so it won't activate on each number type
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 700), () {
      WSService.changeSettings(
          roomId,
          int.tryParse(_roundsController.text) ?? 0,
          int.tryParse(_timeController.text) ?? 0, []);
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.joinData == null) {
      WSService.createGame(onMessageReceived);
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
      case 'room-privacy-notifier':
        setRoomPrivacy(message);
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
      _isRoomPublic = message['isPublic'] ?? true;
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
    _roundsController.text = "${settings['maxRounds']}";
    _timeController.text = "${settings['answerTimeInSeconds']}";
  }

  void setRoomPrivacy(message) {
    setState(() {
      _isRoomPublic = message['isPublic'];
    });
  }

  void onRoundsChange(String r) {
    int rounds = int.tryParse(r) ?? 0;
    if (rounds == 0) {
      _roundsController.text = '0';
      _roundsController.selection =
          TextSelection.fromPosition(const TextPosition(offset: 0))
              .extendTo(const TextPosition(offset: 1));
    }
    _sendSettings();
  }

  void onTimeChange(String r) {
    int roundTime = int.tryParse(r) ?? 0;
    if (roundTime == 0) {
      _timeController.text = '0';
      _timeController.selection =
          TextSelection.fromPosition(const TextPosition(offset: 0))
              .extendTo(const TextPosition(offset: 1));
    }
    _sendSettings();
  }

  void changeRoomPrivacy(bool value) {
    WSService.roomPrivacy(roomId, value);
    setState(() {
      _isRoomPublic = value;
    });
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
                                                //todo > 1
                                                players.length > 0
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
                      onChanged:
                          _isCreator ? (val) => changeRoomPrivacy(val) : null,
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
                validator: (value) {
                  int rounds = int.tryParse(value!) ?? 0;
                  if (rounds > 30) {
                    _roundsController.text = "30";
                  }
                  return null;
                },
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
                validator: (value) {
                  int time = int.tryParse(value!) ?? 0;
                  if (time > 120) {
                    _timeController.text = "120";
                  }
                  if (time > 0 && time < 5) {
                    _timeController.text = "5";
                  }
                  return null;
                },
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
