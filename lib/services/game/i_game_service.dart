import 'package:mapbox_gl/mapbox_gl.dart';

abstract class IGameService {
  late MapboxMapController mapController;

  final initialCameraPosition =
      const CameraPosition(target: LatLng(42.5617153, 25.5166978), zoom: 5.4);

  void onMapCreated(MapboxMapController controller);

  void setEndRoundSymbols(List<dynamic> players, List<dynamic> answer);

  void lockAnswer(LatLng selectedLocation);

  void nextRound();

  bool isSingle();
}
