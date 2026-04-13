import 'package:flutter/widgets.dart';

class AppSpacing {
  const AppSpacing._();

  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;

  static const double pageHorizontal = 20;
  static const double pageTop = 24;
  static const double pageBottom = 20;

  static const EdgeInsets pagePadding = EdgeInsets.fromLTRB(
    pageHorizontal,
    pageTop,
    pageHorizontal,
    pageBottom,
  );
  static const EdgeInsets cardPadding = EdgeInsets.all(xl);
  static const EdgeInsets sectionPadding = EdgeInsets.all(lg);
}
