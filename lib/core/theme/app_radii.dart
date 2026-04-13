import 'package:flutter/widgets.dart';

class AppRadii {
  const AppRadii._();

  static const double sm = 14;
  static const double md = 20;
  static const double lg = 28;
  static const double xl = 36;
  static const double pill = 999;

  static BorderRadius get input => BorderRadius.circular(sm);
  static BorderRadius get button => BorderRadius.circular(md);
  static BorderRadius get card => BorderRadius.circular(md);
  static BorderRadius get panel => BorderRadius.circular(lg);
  static BorderRadius get hero => BorderRadius.circular(xl);
  static BorderRadius get full => BorderRadius.circular(pill);
}
