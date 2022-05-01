import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guess_bulgaria/components/loader.dart';
import 'package:guess_bulgaria/components/navigation_button.dart';
import 'package:guess_bulgaria/components/player_list.dart';
import 'package:guess_bulgaria/pages/game_page.dart';
import 'package:guess_bulgaria/pages/main_page.dart';
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

  void _sendSettings() {
    if (!_isCreator) return;
    // debounce so it won't activate on each number type
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 700), () {
      WSService.changeSettings(roomId, maxRounds, 0, []);
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.joinData == null) {
      WSService.createGame(onMessageReceived);
    } else {
      setupJoinData();
    }
  }

  void leave() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const MainPage()));
  }

  void onMessageReceived(String type, dynamic message) {
    switch (type) {
      case 'current-data':
        setRoomData(message);
        break;
      case 'player-join':
      case 'player-leave':
        setState(() {
          players = message['players'];
          for (final player in players) {
            if (player['id'] == UserData.userId) {
              if (player['isCreator']) _isCreator = true;
              break;
            }
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
      _sizeController.text = "${message['settings']['maxRounds']}";
      players = message['players'];
    });
  }

  int maxRounds = 0;
  List<dynamic> players = [];

  void onRoundsChange(String r) {
    maxRounds = int.tryParse(r) ?? 0;
    if (maxRounds == 0) _sizeController.text = '0';
    _sendSettings();
  }

  final TextEditingController _sizeController = TextEditingController();

  @override
  void dispose() {
    _sizeController.dispose();
    //todo don't run next row if game has been started
    WSService.leave(roomId);
    super.dispose();
  }

  start() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => GamePage(roomId: roomId)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      body: roomId == 0
          ? const GbLoader()
          : Align(
              alignment: Alignment.center,
              child: FractionallySizedBox(
                widthFactor: 0.9,
                heightFactor: 0.9,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 4.0)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 25),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Center(
                          child: Text(
                            "Код за присъединяване",
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        Center(
                          child: Text(
                            '$roomId',
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                        TextFormField(
                          keyboardType: TextInputType.number,
                          showCursor: false,
                          enabled: _isCreator,
                          controller: _sizeController,
                          onChanged: (rounds) => onRoundsChange(rounds),
                          decoration: const InputDecoration(
                            labelText: "Максимален брой рундове",
                          ),
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                          ],
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          "Региони",
                          style: TextStyle(fontSize: 20),
                        ),
                        const SizedBox(height: 15),
                        PlayerList(players, PlayerListTypes.lobby),
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                NavigationButton(
                                  text: "Старт",
                                  width: double.maxFinite,
                                  onPressed: players.length > 1 ? start : null,
                                ),
                                NavigationButton(
                                  text: "Напусни",
                                  width: double.maxFinite,
                                  onPressed: leave,
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
            ),
    );
  }
}
