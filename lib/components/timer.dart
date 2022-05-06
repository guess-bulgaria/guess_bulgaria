import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:guess_bulgaria/components/controllers/timer_controller.dart';

class Timer extends StatefulWidget {
  final TimerController timerController;

  const Timer(this.timerController, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TimerState();
}

class _TimerState extends State<Timer> with TickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      value: 0.0,
    )..addListener(() {
        setState(() {});
      });
    widget.timerController.animationController = controller;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(
          color: Colors.transparent,
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          LinearProgressIndicator(
            backgroundColor: Theme.of(context).colorScheme.secondary,
            value: controller.value,
            minHeight: 16,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
          ),
          Center(
            child: Observer(
              builder: (_) {
                return Text(
                  widget.timerController.clock.seconds ==
                          widget.timerController.maxTime
                      ? "Времето изтече!"
                      : "${widget.timerController.maxTime - widget.timerController.clock.seconds} секунди...",
                  style: const TextStyle(color: Colors.white),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
