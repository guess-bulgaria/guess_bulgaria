import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:guess_bulgaria/components/drawer.dart';
import 'package:guess_bulgaria/components/loader.dart';
import 'package:guess_bulgaria/components/navigation_button.dart';
import 'package:guess_bulgaria/components/open_drawer_button.dart';
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
  final initalCameraPosition =
      const CameraPosition(target: LatLng(42.5617153, 25.5166978), zoom: 5.4);
  late MapboxMapController mapController;
  late Color myColor;
  dynamic roundData;
  LatLng? pin;
  List<dynamic> players = [];
  late Image img;
  bool hasRoundEnded = false;
  bool hasLocked = false;

  _onMapCreated(MapboxMapController controller) {
    mapController = controller;
  }

  _onStyleLoadedCallback() async {
    final Uint8List list =
        (await rootBundle.load("assets/icons/marker.png")).buffer.asUint8List();
    await mapController.addImage("pin", list, true);
  }

  void _onMapClickCallback(Point<double> point, LatLng coordinates) {
    if (hasLocked) return;
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
    var answerLatLng = LatLng(answer[0], answer[1]);
    mapController.addSymbol(SymbolOptions(
      geometry: answerLatLng,
      iconColor: Colors.black.toHexStringRGB(),
      textSize: 20,
      iconImage: "pin",
      iconOpacity: 1.0,
      iconSize: 1.02,
    ));
    mapController.animateCamera(
        CameraUpdate.newLatLngZoom(answerLatLng, initalCameraPosition.zoom));
  }

  void onMessageReceived(String type, dynamic message) {
    switch (type) {
      case 'player-join':
        break;
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
        players = message['players'];
        setState(() {});
    }
  }

  void _lockAnswer() {
    WSService.lockAnswer(
        onMessageReceived, widget.roomId, [pin!.latitude, pin!.longitude]);
    setState(() {
      hasLocked = true;
    });
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

  int currentRound = 0;

  @override
  Widget build(BuildContext context) {
    var player =
        players.firstWhere((element) => element["id"] == UserData.userId);
    int totalPoints = player["points"];
    int totalRounds = widget.gameData["settings"]["maxRounds"];
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      body: Builder(
        builder: (context) => Flex(
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
                  width: double.maxFinite,
                  color: Theme.of(context).colorScheme.secondary,
                  height: MediaQuery.of(context).size.height * 0.2,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: double.maxFinite,
                        height: double.maxFinite,
                        child: Column(
                          children: [
                            Text('Брой точки: $totalPoints'),
                            Text('Рунд: $currentRound/$totalRounds'),
                            ElevatedButton(
                              onPressed:
                                  isNextRoundAllowed() ? _nextRound : null,
                              child: const Text('Start round'),
                            ),
                          ],
                        ),
                      ),
                      OpenDrawerButton(
                        clickCallback: () => Scaffold.of(context).openDrawer(),
                        icon: Icons.people,
                        top: 6,
                      ),
                    ],
                  )),
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
                    initialCameraPosition: initalCameraPosition,
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
                      color: hasLocked ? Colors.grey : Colors.red,
                      margin: const EdgeInsets.only(bottom: 20, right: 10),
                      width: 100,
                      child: TextButton(
                        child: const Text("Избери"),
                        onPressed: !hasLocked ? _lockAnswer : null,
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
      onDrawerChanged: (isOpen) {},
      drawerEnableOpenDragGesture: false,
      drawer: GbDrawer(
        width: MediaQuery.of(context).size.width / 1.7,
        children: [
          SizedBox(
            height: (MediaQuery.of(context).size.height / 2) - 85.0,
            width: double.maxFinite,
            child: PlayerList(players, PlayerListTypes.scoreboard),
          ),
        ],
        icon: Icons.people,
      ),
    );
  }

  void showEndGameResults(dynamic message) {
    UserData().loadStatistics();
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
          currentRound++,
          if (roundData?['image'] != null)
            {img = Image.memory(base64Decode(roundData?['image']))},
          for (var p in players) {p['hasAnswered'] = false},
          mapController.animateCamera(CameraUpdate.newLatLngZoom(
              initalCameraPosition.target, initalCameraPosition.zoom)),
          hasLocked = false
        });
  }

  void endGame() {
    // TODO: stats
    Navigator.of(context).popUntil(ModalRoute.withName('/'));
  }
}


// Column(children: [
                          //   if (players.isNotEmpty)
                          //     ...players
                          //         .map((p) => Text(
                          //               p['username'],
                          //               style: TextStyle(
                          //                   color: p['hasAnswered'] != null &&
                          //                           p['hasAnswered']
                          //                       ? Colors.blue
                          //                       : Colors.red),
                          //             ))
                          //         .toList()
                          //   else
                          //     const Text('No players'),
                          // ]),