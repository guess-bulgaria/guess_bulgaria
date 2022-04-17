import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:guess_bulgaria/storage/clock.dart';

class Timer extends StatefulWidget {
  final int startTime;
  final int maxTime;

  const Timer({Key? key, required this.maxTime, this.startTime = 0})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _TimerState();
}

class _TimerState extends State<Timer> with TickerProviderStateMixin {
  late Clock clock;

  late AnimationController controller;

  @override
  void initState() {
    clock = Clock(widget.maxTime, startTime: widget.startTime);
    controller = AnimationController(
      vsync: this,
      value: 0.0,
    )..addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        LinearProgressIndicator(
          value: controller.value,
          minHeight: 16,
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
          semanticsLabel: 'Linear progress indicator',
        ),
        Observer(
          builder: (_) {
            controller.animateTo((clock.seconds + 1) / 10,
                duration: const Duration(seconds: 1), curve: Curves.ease);
            return Text(
              "${clock.seconds}",
              style: const TextStyle(color: Colors.white),
            );
          },
        )
      ],
    );
  }
}
