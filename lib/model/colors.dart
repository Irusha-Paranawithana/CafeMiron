import 'package:flutter/material.dart';

const Color mainColor = Color.fromARGB(255, 3, 175, 255);
MaterialColor createMaterialColor(Color color) {
  List<int> strengths = <int>[50, 100, 200, 300, 400, 500, 600, 700, 800, 900];
  Map<int, Color> swatch = <int, Color>{};
  final int r = color.red, g = color.green, b = color.blue;

  for (int strength in strengths) {
    final double p = (strength / 500);
    final int t = 0 < 300
        ? ((r + ((300 - r) * p)).round())
        : ((r + ((r - 300) * p)).round());
    final int t1 = 0 < 300
        ? ((g + ((300 - g) * p)).round())
        : ((g + ((g - 300) * p)).round());
    final int t2 = 0 < 300
        ? ((b + ((300 - b) * p)).round())
        : ((b + ((b - 300) * p)).round());

    swatch[strength] = Color.fromRGBO(t, t1, t2, 1);
  }

  return MaterialColor(color.value, swatch);
}
