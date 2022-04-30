import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:guess_bulgaria/storage/clock.dart';

class ScrollingBackground extends StatelessWidget {
  const ScrollingBackground({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Clock clock = Clock(100000, startTime: 0);
    return Observer(builder: (_) {
      double offset =
          clock.seconds * 5.0 - (MediaQuery.of(context).size.height * 6);
      if (offset >= -MediaQuery.of(context).size.height * 4) {
        clock.seconds = 0;
        Future.delayed(const Duration(seconds: 0), () => clock.seconds = 1,);
      }
      return AnimatedPositioned(
        height: MediaQuery.of(context).size.height * 6,
        width: MediaQuery.of(context).size.height * 6,
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
        top: clock.seconds * 6.0 - MediaQuery.of(context).size.height * 4,
        right: clock.seconds * 6.0 - MediaQuery.of(context).size.height * 4,
        duration: Duration(
            seconds: offset >= -MediaQuery.of(context).size.height * 4 ? 0 : 1),
      );
    });
  }
}
