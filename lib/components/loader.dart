import 'dart:math';

import 'package:flutter/material.dart';

class GbLoader extends StatefulWidget {
  final double radius;
  final double strokeWidth;

  const GbLoader({
    Key? key,
    this.radius = 58,
    this.strokeWidth = 20.0,
  }) : super(key: key);

  @override
  State<GbLoader> createState() => _GbLoaderState();
}

class _GbLoaderState extends State<GbLoader> with TickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..addListener(() => setState(() {}))
          ..repeat();
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gradientColors = [
      Theme.of(context).colorScheme.secondary,
      Colors.yellow,
      Colors.green,
      Colors.lightGreen,
    ];
    return Container(
        color: Theme.of(context).colorScheme.secondary,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Column(
                  children: [
                    RotationTransition(
                      turns: Tween(begin: 0.0, end: 1.0)
                          .animate(_animationController),
                      child: CustomPaint(
                        size: Size.fromRadius(widget.radius),
                        painter: GradientCircularProgressPainter(
                          radius: widget.radius,
                          gradientColors: gradientColors,
                          strokeWidth: widget.strokeWidth,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ]));
  }
}

class GradientCircularProgressPainter extends CustomPainter {
  GradientCircularProgressPainter({
    required this.radius,
    required this.gradientColors,
    required this.strokeWidth,
  });
  final double radius;
  final List<Color> gradientColors;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    size = Size.fromRadius(radius);
    double offset = strokeWidth / 2;
    Rect rect = Offset(offset, offset) &
        Size(size.width - strokeWidth, size.height - strokeWidth);
    var paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = SweepGradient(
              colors: gradientColors, startAngle: 0.0, endAngle: 2 * pi)
          .createShader(rect);
    canvas.drawArc(rect, 0.0, 2 * pi, false, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
