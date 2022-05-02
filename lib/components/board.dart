import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'navigation_button.dart';

class Board extends StatelessWidget {
  final Widget child;
  final String title;

  const Board({Key? key, required this.child, required this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: FractionallySizedBox(
        widthFactor: 0.85,
        heightFactor: 0.85,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: Text(
                title,
                style: GoogleFonts.amaticSc(
                  fontSize: 46,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                  height: 0.9,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              flex: 10,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).backgroundColor,
                  borderRadius: BorderRadius.circular(18.0),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    width: 4,
                  ),
                ),
                child: child,
              ),
            ),
              Padding(
                child: NavigationButton(
                  text: "Назад",
                  onPressed: () => Navigator.pop(context),
                ), padding: const EdgeInsets.only(top: 10),
              )
          ],
        ),
      ),
    );
  }
}
