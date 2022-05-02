import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guess_bulgaria/components/loader.dart';
import 'package:guess_bulgaria/components/navigation_button.dart';
import 'package:guess_bulgaria/configs/player_colors.dart';
import 'package:guess_bulgaria/services/ws_service.dart';
import 'package:guess_bulgaria/storage/user_data.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:guess_bulgaria/components/player_list.dart';
import 'package:photo_view/photo_view.dart';

class GamePage extends StatefulWidget {
  final int roomId;
  final dynamic gameData;

  const GamePage({Key? key, this.roomId = 0, this.gameData}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late MapboxMapController mapController;
  late Color myColor;
  dynamic roundData;
  LatLng? pin;
  List<dynamic> players = [];
  late Image img;
  bool hasRoundEnded = false;

  _onMapCreated(MapboxMapController controller) {
    mapController = controller;
  }

  _onStyleLoadedCallback() async {
    final Uint8List list =
        (await rootBundle.load("assets/icons/marker.png")).buffer.asUint8List();
    await mapController.addImage("pin", list, true);
  }

  void _onMapClickCallback(Point<double> point, LatLng coordinates) {
    mapController.clearSymbols();
    mapController.addSymbol(
      SymbolOptions(
        geometry: coordinates,
        iconImage: "pin",
        iconColor: myColor.toHexStringRGB(),
        textSize: 20,
        iconOpacity: 1.0,
        iconSize: 1.02,
      ),
    );
    pin = coordinates;
  }

  void _setEndRoundSymbols(List<dynamic> players, List<dynamic> answer) {
    mapController.clearSymbols();
    for (var p in players) {
      mapController.addSymbol(
        SymbolOptions(
          geometry: LatLng(p['answer'][0], p['answer'][1]),
          iconOpacity: 1.0,
          iconImage: "pin",
          iconColor: PlayerColors.color(p['color']).toHexStringRGB(),
          textSize: 20,
          iconSize: 1.02,
        ),
      );
    }
    mapController.addSymbol(
      SymbolOptions(
        geometry: LatLng(answer[0], answer[1]),
        iconColor: Colors.black.toHexStringRGB(),
        textSize: 20,
        iconImage: "pin",
        iconOpacity: 1.0,
        iconSize: 1.02,
      ),
    );
  }

  void onMessageReceived(String type, dynamic message) {
    switch (type) {
      case 'player-join':
      case 'player-leave':
        setState(() {
          players = message['players'];
        });
        break;
      case "end-game":
        showEndGameResults(message);
        break;
      case "start-round":
        loadRound(message['currentRound']);
        break;
      case "player-answer":
        setState(() {
          for (final player in players) {
            if (player['id'] == message['id']) {
              player['hasAnswered'] = true;
            }
          }
        });
        break;
      case "end-round":
        hasRoundEnded = true;
        _setEndRoundSymbols(
            message['players'], message['currentRound']['coordinates']);
        setState(() {});
    }
  }

  void _lockAnswer() {
    WSService.lockAnswer(
        onMessageReceived, widget.roomId, [pin!.latitude, pin!.longitude]);
  }

  void _nextRound() {
    WSService.nextRound(widget.roomId);
  }

  @override
  void initState() {
    WSService.changeCallback(onMessageReceived);
    if (widget.gameData == null && widget.roomId != 0) {
      WSService.startRound(widget.roomId);
    } else if (widget.gameData != null) {
      roundData = widget.gameData['currentRound'];
      players = widget.gameData['players'];
    }
    if (roundData?['image'] != null) {
      img = Image.memory(base64Decode(roundData?['image']));
    }
    myColor = PlayerColors.color(
      players.firstWhere((p) => p['id'] == UserData.userId,
          orElse: () => {'color': UserData.defaultColor})['color'],
    );

    super.initState();
  }

  bool isNextRoundAllowed() {
    return players.firstWhere((p) => p['isCreator'] == true)['id'] ==
            UserData.userId &&
        hasRoundEnded;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      body: Flex(
        direction: Axis.vertical,
        children: [
          Expanded(
            flex: 3,
            child: roundData?['image'] != null
                ? PhotoView(
                    backgroundDecoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary),
                    basePosition: Alignment.center,
                    imageProvider: img.image,
                    minScale: PhotoViewComputedScale.contained,
                    maxScale: 3.5)
                : const GbLoader(),
          ),
          Expanded(
            flex: 2,
            child: Container(
              color: Theme.of(context).colorScheme.secondary,
              height: MediaQuery.of(context).size.height * 0.2,
              child: Row(
                children: [
                  Column(children: [
                    if (players.isNotEmpty)
                      ...players
                          .map((p) => Text(
                                p['username'],
                                style: TextStyle(
                                    color: p['hasAnswered'] != null &&
                                            p['hasAnswered']
                                        ? Colors.blue
                                        : Colors.red),
                              ))
                          .toList()
                    else
                      const Text('No players'),
                  ]),
                  ElevatedButton(
                    onPressed: isNextRoundAllowed() ? _nextRound : null,
                    child: const Text('Start round'),
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
                  attributionButtonMargins: const Point(15000, 15000),
                  styleString:
                      "mapbox://styles/zealbg/cl23l4amx000m14nvowuqneao",
                  accessToken:
                      "pk.eyJ1IjoiemVhbGJnIiwiYSI6ImNsMjNsMTFydzFxYngzaW10ZnR6Mmp5cXIifQ.-sw5o3XCLxMoSjUhs3li2A",
                  onMapCreated: _onMapCreated,
                  rotateGesturesEnabled: false,
                  tiltGesturesEnabled: false,
                  trackCameraPosition: true,
                  onMapClick: _onMapClickCallback,
                  initialCameraPosition: const CameraPosition(
                      target: LatLng(42.5617153, 25.5166978), zoom: 5.4),
                  minMaxZoomPreference: const MinMaxZoomPreference(5.4, 16),
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
                    color: Colors.red,
                    margin: const EdgeInsets.only(bottom: 20, right: 10),
                    width: 100,
                    child: TextButton(
                      child: const Text("Избери"),
                      onPressed: _lockAnswer,
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  void showEndGameResults(dynamic message) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => AlertDialog(
              title: const Align(
                alignment: Alignment.center,
                child: Text("Резултати"),
              ),
              content: SizedBox(
                height: double.maxFinite,
                width: double.maxFinite,
                child:
                    PlayerList(message["players"], PlayerListTypes.gameResults),
              ),
              actions: [
                Align(
                  alignment: Alignment.center,
                  child: NavigationButton(
                    text: "Начална страница",
                    onPressed: endGame,
                    width: double.maxFinite,
                  ),
                )
              ],
            ));
  }

  void loadRound(dynamic roundData) {
    setState(() => {
          hasRoundEnded = false,
          mapController.clearSymbols(),
          roundData = roundData,
          if (roundData?['image'] != null)
            {img = Image.memory(base64Decode(roundData?['image']))},
          for (var p in players) {p['hasAnswered'] = false}
        });
  }

  void endGame() {
    // Navigator.push(
    //       context,
    //       MaterialPageRoute(
    //           builder: (context) => const MainPage()));
  }
}
