import 'dart:async';
import 'package:mobx/mobx.dart';

class Clock {
  late final Atom _atom;
  late final int _maxTime;
  Function? _endCallback;
  late int _time;
  Timer? _timer;
  bool _isPaused = false;

  Clock(this._maxTime, {startTime = 0, endCallback}) {
    _time = startTime;
    _endCallback = endCallback;
    _atom = Atom(onObserved: _startTimer, onUnobserved: stopTimer);
  }

  int get seconds {
    _atom.reportObserved();
    return _time;
  }

  set seconds(int value) {
    _time = value;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _isPaused = false;
    _timer = Timer.periodic(const Duration(seconds: 1), _onTick);
  }

  void stopTimer() {
    _timer?.cancel();
  }

  void _onTick(_) {
    if (_isPaused) return;
    _time++;
    if (_time == _maxTime) {
      stopTimer();
      if (_endCallback != null) _endCallback!();
    }
    _atom.reportChanged();
  }

  void pause() {
    _isPaused = true;
  }

  void unpause() {
    _isPaused = false;
  }
}
