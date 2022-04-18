import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

class GamePage extends StatefulWidget {
  const GamePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  MapboxMapController? mapController;

  _onMapCreated(MapboxMapController controller) {
    mapController = controller;
  }

  _onStyleLoadedCallback() {}

  void _onMapClickCallback(Point<double> point, LatLng coordinates) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("${coordinates.latitude} ${coordinates.longitude}"),
      backgroundColor: Theme.of(context).primaryColor,
      duration: const Duration(seconds: 5),
    ));
  }

  void _add(context) {
    var pos = mapController!.cameraPosition!.target;
    mapController!.addSymbol(
      SymbolOptions(geometry: pos, iconImage: "assets/icons/marker.png", iconColor: "#FF0000", iconOpacity: 1.0, iconSize: 2.5),
    );
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
          Expanded(
            child: Stack(
              children: [
                MapboxMap(
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
                  alignment: Alignment.center,
                  child: IconButton(
                      icon: const Icon(Icons.location_pin),
                      onPressed: () => _add(context)),
                ),
                // Container(
                //   // margin: EdgeInsets.only(
                //   //   top: MediaQuery.of(context).size.height * 0.179,
                //   //   left: MediaQuery.of(context).size.width * 0.437,
                //   // ),
                //
                // ),
                Align(
                  alignment: FractionalOffset.bottomRight,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 50, right: 10),
                    width: 100,
                    child: TextButton(
                        child: const Text("Place"), onPressed: () => _add(context)),
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
}
