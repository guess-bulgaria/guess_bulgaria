import 'package:flutter/material.dart';
import 'package:guess_bulgaria/configs/player_colors.dart';
import 'package:guess_bulgaria/services/game/i_game_service.dart';
import 'package:guess_bulgaria/services/ws_service.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

class SinglePlayerGameService extends IGameService {
  SinglePlayerGameService(){
    //todo start round logic
  }

  @override
  void onMapCreated(MapboxMapController controller){
    mapController = controller;
  }

  @override
  void setEndRoundSymbols(List<dynamic> players, List<dynamic> answer) {
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
        CameraUpdate.newLatLngZoom(answerLatLng, initialCameraPosition.zoom));
  }

  @override
  void lockAnswer(LatLng? pin){
    //todo end round
  }

  @override
  void nextRound() {
    //todo start new round
  }

  @override
  bool isSingle() {
    return true; // :(
  }
}