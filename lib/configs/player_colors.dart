import 'package:flutter/material.dart';

class PlayerColors {
  static final List<Color> _colors = [
    Colors.greenAccent,
    Colors.green,
    Colors.teal,
    Colors.yellow,
    Colors.orange,
    Colors.red,
    Colors.pink,
    Colors.lightBlue,
    Colors.blueAccent,
    Colors.indigo,
    Colors.purple,
    //todo more colors
  ];

  static Color color(int colorId) => _colors[colorId];

  static List<Color> get colors => _colors;
}