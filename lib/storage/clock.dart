import 'dart:async';
import 'package:mobx/mobx.dart';

class Clock {
  late final Atom _atom;
  late final int _maxTime;
  late int _time;
  Timer? _timer;

  Clock(this._maxTime, {startTime = 0}) {
    _time = startTime;
    _atom = Atom(onObserved: _startTimer, onUnobserved: _stopTimer);
  }

  int get seconds {
    _atom.reportObserved();
    return _time;
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), _onTick);
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  void _onTick(_) {
    _time++;
    if (_time == _maxTime) _stopTimer();
    _atom.reportChanged();
  }
}
