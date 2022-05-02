import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class Badge extends StatelessWidget {
  final String title;
  final String text;
  final IconData? icon;
  final String? image;

  const Badge({
    Key? key,
    required this.title,
    required this.text,
    this.icon,
    this.image,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 11),
          alignment: Alignment.centerLeft,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          height: 30,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(
              color: Theme.of(context).colorScheme.secondary,
              width: 4,
            ),
          ),
          child: Center(
            child: Row(
              children: [
                if (image != null)
                  Container(
                    child: SvgPicture.asset(
                      image!,
                      height: 20,
                      color: Theme.of(context).secondaryHeaderColor,
                    ),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: 22,
                  ),
                if (icon != null)
                  Container(
                    child: Icon(
                      icon,
                      color: Theme.of(context).secondaryHeaderColor,
                    ),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                  ),
                Text(text),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
