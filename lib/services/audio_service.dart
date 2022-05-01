import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioCache _player = AudioCache(prefix: 'assets/audio/');
  static double _volume = 1.0;

  static const _click = 'click.wav';

  AudioService(){
    _player.loadAll([_click]);
  }

  static set volume(double value) {
    _volume = value;
  }

  static void click() {
    _player.play(_click, volume: _volume);
  }
}
