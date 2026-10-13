import 'package:flutter/material.dart';

class Breakpoints {
  Breakpoints._();

  static const double mobileMax = 600.0;
  static const double tabletMax = 1024.0;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileMax;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileMax && width <= tabletMax;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width > tabletMax;

  static bool isTabletLandscapeOrDesktop(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width > mobileMax &&
        (size.width > tabletMax || size.width > size.height);
  }
}
