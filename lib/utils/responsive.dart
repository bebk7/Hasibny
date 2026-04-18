import 'package:flutter/material.dart';

class Responsive {
  static double width(BuildContext context) => MediaQuery.of(context).size.width;
  static double height(BuildContext context) => MediaQuery.of(context).size.height;

  static bool isSmall(BuildContext context) => width(context) < 360;
  static bool isMedium(BuildContext context) => width(context) >= 360 && width(context) < 600;
  static bool isLarge(BuildContext context) => width(context) >= 600;

  static double sp(BuildContext context, double size) {
    final w = width(context);
    if (w < 360) return size * 0.85;
    if (w < 600) return size;
    return size * 1.15;
  }

  static double hp(BuildContext context, double percent) => height(context) * percent;
  static double wp(BuildContext context, double percent) => width(context) * percent;

  static EdgeInsets pagePadding(BuildContext context) {
    final w = width(context);
    if (w < 360) return const EdgeInsets.all(12);
    if (w < 600) return const EdgeInsets.all(16);
    return EdgeInsets.symmetric(horizontal: w * 0.08, vertical: 20);
  }

  static double cardRadius(BuildContext context) => isSmall(context) ? 8 : 12;
  static double avatarRadius(BuildContext context) => isSmall(context) ? 28 : 40;
  static double iconSize(BuildContext context) => isSmall(context) ? 20 : 24;
  static double fabSize(BuildContext context) => isSmall(context) ? 48 : 56;
}
