import 'package:flutter/material.dart';
import 'package:guess_bulgaria/configs/player_colors.dart';
import 'package:guess_bulgaria/services/game/i_game_service.dart';
import 'package:guess_bulgaria/services/ws_service.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

class MultiplayerGameService extends IGameService {
  final int roomId;

  MultiplayerGameService(this.roomId);

  @override
  void onMapCreated(MapboxMapController controller) {
    mapController = controller;
  }

  @override
  void setEndRoundSymbols(List<dynamic> players, List<dynamic> answer) {
    mapController.clearSymbols();
    mapController.clearLines();
    var answerLatLng = LatLng(answer[0], answer[1]);
    for (var p in players) {
      if(p['answer'] == null) continue;
      var playerAnswerLatLng = LatLng(p['answer'][0], p['answer'][1]);
      var color = PlayerColors.color(p['color']).toHexStringRGB();
      mapController.addSymbol(SymbolOptions(
        geometry: playerAnswerLatLng,
        iconOpacity: 1.0,
        iconImage: "pin",
        iconColor: color,
        textSize: 20,
        iconSize: 1.02,
      ));
      mapController.addLine(LineOptions(
        lineColor: color,
        geometry: [
          playerAnswerLatLng,
          answerLatLng
        ],
        lineOpacity: 0.5,
        lineWidth: 1
      ));
    }
    mapController.addSymbol(SymbolOptions(
      geometry: answerLatLng,
      iconColor: Colors.black.toHexStringRGB(),
      textSize: 20,
      iconImage: "pin",
      iconOpacity: 1.0,
      iconSize: 1.02,
    ));
    mapController.animateCamera(
        CameraUpdate.newLatLngZoom(answerLatLng, initialCameraPosition.zoom));
  }

  @override
  void lockAnswer(LatLng selectedLocation) {
      WSService.lockAnswer(roomId, [selectedLocation.latitude, selectedLocation.longitude]);
  }

  @override
  void nextRound() {
    WSService.nextRound(roomId);
  }

  @override
  bool isSingle() {
    return false;
  }
}
