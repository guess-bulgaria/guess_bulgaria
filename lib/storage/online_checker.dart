import 'dart:async';
import 'package:guess_bulgaria/services/ping_service.dart';
import 'package:mobx/mobx.dart';

class OnlineChecker {
  final _isOnline = Observable(true);

  bool get isOnline {
    _atom.reportObserved();
    return _isOnline.value;
  }

  late final Atom _atom;
  Timer? _timer;

  OnlineChecker() {
    _atom = Atom(onObserved: _startCheck, onUnobserved: _endCheck);
  }

  _startCheck() async {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: isOnline ? 5 : 5), _tick);
    await _checkOnline();
  }

  void _endCheck() {
    _timer?.cancel();
  }

  _tick(_) async {
    await _checkOnline();
  }

  Future<void> _checkOnline() async {
    var response = true;
    try {
      await PingService.ping();
    } catch (e) {
      response = false;
    }
    if(isOnline != response){
      Action(() => _isOnline.value = response)();
      _atom.reportChanged();
    }
  }
}
