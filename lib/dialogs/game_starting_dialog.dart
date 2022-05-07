import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:guess_bulgaria/components/badge.dart';
import 'package:guess_bulgaria/components/navigation_button.dart';
import 'package:guess_bulgaria/components/player_list.dart';

class GameStartingDialog extends StatefulWidget {
  final int startAt;

  const GameStartingDialog(this.startAt, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _GameStartingDialogState();
}

class _GameStartingDialogState extends State<GameStartingDialog> {
  int time = 1;

  @override
  void initState() {
    super.initState();
    setTime(widget.startAt - DateTime.now().millisecondsSinceEpoch);
  }

  void setTime(int millis) async {
    time += (millis / 1000).floor();
    while (time > 1) {
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        --time;
      });
    }

    Future.delayed(Duration(milliseconds: millis % 1000))
        .then((value) => Navigator.pop(context));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Center(
        child: Container(
          height: MediaQuery.of(context).size.width / 3,
          width: MediaQuery.of(context).size.width / 3,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(180)),
            color: Theme.of(context).colorScheme.secondary,
          ),
          child: Center(
            child: Text(
              '$time',
              style: TextStyle(
                  fontSize: 64,
                  color: Theme.of(context).primaryColor,
                  decoration: TextDecoration.none,
                shadows: [
                  Shadow(
                    offset: Offset(5.0, 5.0),
                    blurRadius: 3.0,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
