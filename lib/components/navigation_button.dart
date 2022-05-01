import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:guess_bulgaria/services/audio_service.dart';

class NavigationButton extends StatelessWidget {
  const NavigationButton(
      {Key? key, this.width, this.height, this.onPressed, required this.text})
      : super(key: key);

  final double? width;
  final double? height;
  final String text;
  final VoidCallback? onPressed;

  void onClick() {
    AudioService.click();
    onPressed!();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? 200,
      height: height ?? 60,
      margin: const EdgeInsets.only(bottom: 10),
      child: ElevatedButton(
        child: Text(text, textAlign: TextAlign.center),
        onPressed: onPressed != null ? onClick : null,
      ),
    );
  }
}
