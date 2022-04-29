import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guess_bulgaria/components/navigation_button.dart';
import 'package:guess_bulgaria/components/player_list.dart';
import 'package:guess_bulgaria/services/ws_service.dart';
import 'dart:async';

import 'package:guess_bulgaria/storage/user_data.dart';

class CreateGamePage extends StatefulWidget {
  int roomId;

  CreateGamePage({Key? key, this.roomId = 0}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreateGamePage> {
  Timer? _debounce;
  bool _isCreator = true;

  void _sendSettings() {
    // debounce so it won't activate on each number type
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 700), () {
      WSService.changeSettings(widget.roomId, maxRounds, 0, []);
    });
  }

  void leave() {
    WSService.leave(widget.roomId);
    Navigator.pop(context);
  }

  void onMessageReceived(String type, dynamic message) {
    switch (type) {
      case 'current-data':
        setState(() {
          widget.roomId = message['roomId'];
          _sizeController.text = "${message['settings']['maxRounds']}";
          players = message['players'];
        });
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
    //todo if game not started -> execute leave (if the player clicked back button)
    super.dispose();
  }

  start() {}

  @override
  Widget build(BuildContext context) {
    if (widget.roomId == 0) WSService.createGame(onMessageReceived);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      body: Align(
        alignment: Alignment.center,
        child: FractionallySizedBox(
          widthFactor: 0.9,
          heightFactor: 0.9,
          child: DecoratedBox(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 4.0)),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Center(
                      child: Text(
                        "Код за присъединяване:",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    Center(
                      child: Text(
                        '${widget.roomId}',
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
                    const Text(
                      "Региони",
                      style: TextStyle(fontSize: 20),
                    ),
                    PlayerList(players),
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
                          )),
                    ),
                  ]),
            ),
          ),
        ),
      ),
    );
  }
}
