import 'dart:math';

import 'package:flutter/material.dart';
import 'package:guess_bulgaria/components/navigation_button.dart';
import 'package:guess_bulgaria/pages/main_page.dart';
import 'package:guess_bulgaria/services/ws_service.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:guess_bulgaria/components/player_list.dart';

class GamePage extends StatefulWidget {
  int roomId;
  GamePage({Key? key, this.roomId = 0}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late MapboxMapController mapController;

  _onMapCreated(MapboxMapController controller) {
    mapController = controller;
  }

  _onStyleLoadedCallback() {}

  void _onMapClickCallback(Point<double> point, LatLng coordinates) {
    mapController.clearSymbols();
    mapController.addSymbol(
      SymbolOptions(
        geometry: coordinates,
        iconImage: "assets/icons/marker.png",
        iconColor: "#FF0000",
        iconOpacity: 1.0,
        iconSize: 1.02,
      ),
    );
  }

  void _lockAnswer() {}

  @override
  void initState() {
    if (widget.roomId != 0) {
      WSService.startGame(onMessageReceived, widget.roomId);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      body: Flex(
        direction: Axis.vertical,
        children: [
          const Expanded(
            child: FlutterLogo(),
            flex: 5,
          ),
          Text(widget.roomId.toString()),
          Expanded(
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
                    margin: const EdgeInsets.only(bottom: 20, right: 10),
                    width: 100,
                    child: TextButton(
                      child: const Text("Избери"),
                      onPressed: () => _lockAnswer(),
                    ),
                  ),
                )
              ],
            ),
            flex: 4,
          )
        ],
      ),
    );
  }

  void onMessageReceived(String type, dynamic message) {
    switch (type) {
      case "end-game":
        showEndGameResults(message);
        break;
    }
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

  void endGame() {
    // Navigator.push(
    //       context,
    //       MaterialPageRoute(
    //           builder: (context) => const MainPage()));
  }
}
