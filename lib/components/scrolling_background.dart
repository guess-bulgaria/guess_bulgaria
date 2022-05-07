import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:guess_bulgaria/storage/clock.dart';

class ScrollingBackground extends StatefulWidget {
  final bool isPaused;
  const ScrollingBackground({Key? key, this.isPaused = false}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ScrollingBackgroundState();
}

class _ScrollingBackgroundState extends State<ScrollingBackground>{
  static Clock clock = Clock(100000, startTime: 0);

  @override
  void initState() {
    clock.unpause();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if(widget.isPaused) {
      clock.pause();
    } else {
      clock.unpause();
    }
    final backgroundHeight = MediaQuery.of(context).size.height;
    return Observer(builder: (_) {
      double offset =
          clock.seconds * 5.0 - (backgroundHeight * 10);
      double leaveSize = -MediaQuery.of(context).size.height * 5;
      if (offset >= leaveSize) {
        clock.seconds = 1;
        Future.delayed(const Duration(milliseconds: 1), () => clock.seconds = 2,);
      }
      return AnimatedPositioned(
        height: backgroundHeight * 10,
        width: backgroundHeight * 10,
        child: RotationTransition(
          turns: const AlwaysStoppedAnimation(20 / 360),
          child: Image.asset(
            'assets/icons/background.png',
            color: Colors.black,
            repeat: ImageRepeat.repeat,
            alignment: Alignment.topRight,
            opacity: const AlwaysStoppedAnimation(0.7),
          ),
        ),
        top: clock.seconds * 6.0 - backgroundHeight * 7,
        right: clock.seconds * 6.0 - backgroundHeight * 7,
        duration: Duration(
            seconds: offset >= leaveSize ? 0 : 1),
      );
    });
  }
}