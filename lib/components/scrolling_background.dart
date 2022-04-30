import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:guess_bulgaria/storage/clock.dart';

class ScrollingBackground extends StatelessWidget {
  const ScrollingBackground({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Clock clock = Clock(100000, startTime: 0);
    return Observer(builder: (_) {
      return AnimatedPositioned(
        child: Image.asset(
          'assets/icons/marker.png',
          color: Colors.black,
          repeat: ImageRepeat.repeat,
          opacity: const AlwaysStoppedAnimation(0.7),
        ),
        top: clock.seconds * 4.5,
        right: clock.seconds * 4.5,
        duration: const Duration(seconds: 1),
      );
    });
  }
}
