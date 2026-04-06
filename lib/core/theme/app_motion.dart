import 'package:flutter/material.dart';

class AppMotion {
  const AppMotion._();

  static const short = Duration(milliseconds: 180);
  static const medium = Duration(milliseconds: 260);
  static const long = Duration(milliseconds: 360);

  static const curve = Curves.easeOutCubic;
}
