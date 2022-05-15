import 'package:flutter/material.dart';

class GameStartingDialog extends StatefulWidget {
  final int? timer;

  const GameStartingDialog({Key? key, this.timer}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _GameStartingDialogState();
}

class _GameStartingDialogState extends State<GameStartingDialog> {
  int time = 0;

  @override
  void initState() {
    super.initState();
    if (widget.timer != null) setTime(widget.timer!);
  }

  void setTime(int millis) async {
    time += (millis / 1000).floor();
    while (time > 0) {
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        --time;
      });
    }
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
            child: _getLoaderText(),
          ),
        ),
      ),
    );
  }

  Widget _getLoaderText() {
    if (widget.timer != null) {
      return Text(
        '$time',
        style: TextStyle(
          fontSize: 64,
          color: Theme.of(context).primaryColor,
          decoration: TextDecoration.none,
          shadows: const [
            Shadow(
              offset: Offset(5.0, 5.0),
              blurRadius: 3.0,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
          ],
        ),
      );
    }
    return Text(
      'В изчакване...',
      style: TextStyle(
        fontSize: 14,
        color: Theme.of(context).primaryColor,
        decoration: TextDecoration.none,
      ),
    );
  }
}
