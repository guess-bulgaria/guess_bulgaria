import 'package:flutter/animation.dart';
import 'package:guess_bulgaria/storage/clock.dart';

class TimerController {
  final int _startTime;
  final int _maxTime;
  late AnimationController _animationController;
  final Clock _clock;

  TimerController(this._startTime, this._maxTime, Function? _endCallback) :
    _clock = Clock(_maxTime, startTime: _startTime, endCallback: _endCallback);

  set animationController(AnimationController value) {
    _animationController = value;
    if(_maxTime == 0) return;
    start();
  }

  int get maxTime => _maxTime;

  int get startTime => _startTime;

  Clock get clock => _clock;

  void start(){
    if(_maxTime == 0) return;
    _animationController.animateTo(1,
        duration: Duration(seconds: _maxTime));
  }

  void pause(){
    if(_maxTime == 0) return;
    _animationController.stop(canceled: true);
    _clock.pause();
  }

  void stop(){
    if(_maxTime == 0) return;
    _animationController.stop(canceled: true);
    _clock.stopTimer();
  }

  void reset(Function endCallback) async {
    if(_maxTime == 0) return;
    _animationController.stop(canceled: true);
    clock.seconds = _startTime;
    clock.callback = endCallback;
    _animationController.reset();
    await Future.delayed(const Duration(milliseconds: 1));
    _animationController.stop(canceled: true);
    _animationController.animateTo(1, duration: Duration(seconds: _maxTime));
    _clock.unpause();
  }
}