import 'package:flutter/material.dart';
import 'package:guess_bulgaria/services/audio_service.dart';

class NavigationButton extends StatelessWidget {
  const NavigationButton(
      {Key? key, this.width, this.height, this.onPressed, required this.text, this.icon})
      : super(key: key);

  final double? width;
  final double? height;
  final String text;
  final IconData? icon;
  final VoidCallback? onPressed;

  void onClick() {
    AudioService.click();
    onPressed!();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? 230,
      height: height ?? 60,
      margin: const EdgeInsets.only(bottom: 10),
      child: ElevatedButton(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if(icon != null) Padding(
              padding: const EdgeInsets.only(right: 3),
              child: Icon(icon),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(text, textAlign: TextAlign.center),
            ),
          ],
        ),
        onPressed: onPressed != null ? onClick : null,
      ),
    );
  }
}
