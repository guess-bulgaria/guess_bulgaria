import 'package:flutter/material.dart';

class OpenDrawerButton extends StatelessWidget {
  final double? left;
  final int top;
  final VoidCallback clickCallback;

  const OpenDrawerButton({Key? key, required this.clickCallback, this.left, this.top = 6}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).size.height / top,
      left: left ?? -MediaQuery.of(context).size.width / 14,
      child: InkWell(
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: clickCallback,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Icon(Icons.circle,
                  color: Theme.of(context).colorScheme.primary, size: 64),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.only(left: 29, top: 20),
                child: const Icon(Icons.person, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
