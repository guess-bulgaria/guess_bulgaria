import 'package:flutter/material.dart';

class OpenDrawerButton extends StatelessWidget {
  final double? left;
  final double top;
  final bool isEnd;
  final IconData? icon;
  final VoidCallback clickCallback;

  const OpenDrawerButton(
      {Key? key,
      required this.clickCallback,
      this.left,
      this.top = 1.341,
      this.icon,
      this.isEnd = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pos = left ?? -MediaQuery.of(context).size.width / 14;
    return Positioned(
      bottom: MediaQuery.of(context).size.height / top,
      right: isEnd ? pos : null,
      left: !isEnd ? pos : null,
      child: InkWell(
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: clickCallback,
        child: Stack(
          children: [
            Align(
              alignment: isEnd ? Alignment.centerRight : Alignment.centerLeft,
              child: Icon(Icons.circle,
                  color: Theme.of(context).colorScheme.primary, size: 64),
            ),
            Align(
              alignment: isEnd ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                margin: EdgeInsets.only(left: (!isEnd ? 29 : 11), top: 20),
                child: Icon(icon ?? Icons.person, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
