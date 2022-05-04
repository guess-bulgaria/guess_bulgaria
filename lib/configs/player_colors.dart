import 'package:flutter/material.dart';

class PlayerColors {
  static final List<Color> _colors = [
    const Color.fromRGBO(166, 28, 0, 1),
    const Color.fromRGBO(204, 0, 0, 1),
    const Color.fromRGBO(230, 145, 56, 1),
    const Color.fromRGBO(241, 194, 50, 1),
    const Color.fromRGBO(56, 118, 29, 1),
    const Color.fromRGBO(52, 168, 83, 1),
    const Color.fromRGBO(106, 168, 79, 1),
    const Color.fromRGBO(182, 215, 168, 1),
    const Color.fromRGBO(69, 129, 142, 1),
    const Color.fromRGBO(60, 120, 216, 1),
    const Color.fromRGBO(66, 133, 244, 1),
    const Color.fromRGBO(0, 200, 200, 1),
    const Color.fromRGBO(103, 78, 167, 1),
    const Color.fromRGBO(166, 77, 167, 1),
    const Color.fromRGBO(166, 77, 121, 1),
    const Color.fromRGBO(255, 132, 232, 1),
    // Colors.greenAccent,
    // Colors.green,
    // Colors.teal,
    // Colors.lightBlue,
    // Colors.blueAccent,
    // Colors.indigo,
    // const Color.fromRGBO(61, 90, 128, 1),
    // Colors.purple,
    // const Color.fromRGBO(105, 38, 105, 1),
    // Colors.pink,
    // const Color.fromRGBO(247, 37, 133, 1),
    // Colors.red,
    // const Color.fromRGBO(238, 108, 77, 1),
    // Colors.orange,
    // Colors.yellow,
    // const Color.fromRGBO(255, 203, 242, 1),
  ];

  static Color color(int colorId) => _colors[colorId];

  static List<Color> get colors => _colors;
}