import 'dart:async';
import 'package:guess_bulgaria/services/ping_service.dart';
import 'package:guess_bulgaria/storage/user_data.dart';
import 'package:mobx/mobx.dart';

class OnlineChecker {
  final _isOnline = Observable(false);

  bool get isOnline {
    _atom.reportObserved();
    return _isOnline.value;
  }

  late final Atom _atom;
  Timer? _timer;

  OnlineChecker() {
    _checkOnline();
    _atom = Atom(onObserved: _startCheck, onUnobserved: _endCheck);
  }

  _startCheck() async {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: isOnline ? 30 : 5), _tick);
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
      if(isOnline) UserData().setupUserId();
      Action(() => _isOnline.value = response)();
      _atom.reportChanged();
    }
  }
}
