
import 'package:flutter/material.dart';

class Badge extends StatelessWidget {
  final Widget child;
  const Badge({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      height: 30,
      decoration: BoxDecoration(
        color: Theme.of(context).backgroundColor,
        borderRadius: BorderRadius.circular(18.0),
        border: Border.all(
          color: Theme.of(context).colorScheme.inversePrimary,
          width: 4,
        ),
      ),
      child: child
    );
  }

}