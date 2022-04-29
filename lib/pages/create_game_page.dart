import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guess_bulgaria/components/player_list.dart';
import 'package:guess_bulgaria/services/ws_service.dart';
import 'dart:async';

class CreateGamePage extends StatefulWidget {
  const CreateGamePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreateGamePage> {
  _CreatePageState() {
    WSService.createGame(onMessageReceived);
  }

  Timer? _debounce;
  _sendSettings(){
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 700), () {
      WSService.changeSettings(roomId!, maxRounds, 0, []);
    });
  }

  void onMessageReceived(String type, dynamic message) {
    switch (type) {
      case 'current-data':
        {
          setState(() {
            roomId = message['roomId'];
            _sizeController.text = "${message['settings']['maxRounds']}";
            players = message['players'];
          });
        }
    }
  }

  int? roomId;
  int maxRounds = 0;
  List<dynamic> players = [];

  void onRoundsChange(String r) {
    maxRounds = int.tryParse(r) ?? 0;
    _sendSettings();
  }

  final TextEditingController _sizeController = TextEditingController();

  @override
  void dispose() {
    _sizeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    '$roomId',
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                TextFormField(
                  keyboardType: TextInputType.number,
                  showCursor: false,
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
              ]
                  .map((el) => Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 25),
                        child: el,
                      ))
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}
