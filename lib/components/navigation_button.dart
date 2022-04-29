import 'package:flutter/material.dart';

class NavigationButton extends StatelessWidget {
  const NavigationButton(
      {Key? key, this.width, this.height, this.onPressed, required this.text})
      : super(key: key);

  final double? width;
  final double? height;
  final String text;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? 200,
      height: height ?? 60,
      margin: const EdgeInsets.only(bottom: 10),
      child: TextButton(
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.brown)),
        child: Text(
          text,
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        onPressed: onPressed,
      ),
    );
  }
}
