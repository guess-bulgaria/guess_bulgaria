import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class Badge extends StatelessWidget {
  final String? title;
  final String? text;
  final int? value;
  final int? plus;
  final double? letterSpacing;
  final bool center;
  final bool textCenter;
  final bool startAnimation;
  final IconData? icon;
  final String? image;

  const Badge({
    Key? key,
    this.text,
    this.value,
    this.plus,
    this.letterSpacing,
    this.title,
    this.icon,
    this.startAnimation = false,
    this.center = false,
    this.image,
    this.textCenter = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (title != null)
          Container(
            height: 18,
            margin: const EdgeInsets.symmetric(horizontal: 11),
            alignment: center ? Alignment.center : Alignment.centerLeft,
            child: FittedBox(
              fit: BoxFit.cover,
              child: Text(
                title ?? '',
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
          child: Align(
            alignment: textCenter ? Alignment.center : Alignment.centerLeft,
            child: FittedBox(
              fit: BoxFit.scaleDown,
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
                  if (text != null) Text(text!, style: TextStyle(letterSpacing: letterSpacing),),
                  if (value != null)
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(
                          begin: value!.toDouble(),
                          end: startAnimation
                              ? (value! + (plus ?? 0)).toDouble()
                              : value!.toDouble()),
                      duration: const Duration(milliseconds: 750),
                      builder:
                          (BuildContext context, double value, Widget? child) {
                        return Text('${value.toInt()}');
                      },
                    ),
                  if (plus != null && plus != 0)
                    Text(' +$plus', style: const TextStyle(fontSize: 10))
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
