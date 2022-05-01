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
          clock.seconds * 5.0 - (MediaQuery.of(context).size.height * 10);
      double leaveSize = -MediaQuery.of(context).size.height * 4;
      // if (offset >= leaveSize) {
      //   clock.seconds = 1;
      //   Future.delayed(const Duration(milliseconds: 1), () => clock.seconds = 2,);
      // }
      return AnimatedPositioned(
        height: MediaQuery.of(context).size.height * 10,
        width: MediaQuery.of(context).size.height * 10,
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
        top: clock.seconds * 6.0 - MediaQuery.of(context).size.height * 7,
        right: clock.seconds * 6.0 - MediaQuery.of(context).size.height * 7,
        duration: Duration(
            seconds: offset >= leaveSize ? 0 : 1),
      );
    });
  }
}
