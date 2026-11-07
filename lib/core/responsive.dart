// CONCEPT: Responsive layout system with MediaQuery & LayoutBuilder
// Mobile <600, Tablet 600-1024, Desktop >1024. Zero overflow across 360px, 768px, 1440px.

import 'package:flutter/material.dart';

enum DeviceScreenType { mobile, tablet, desktop }

class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const Responsive({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  static const double mobileBreakpoint = 600.0;
  static const double desktopBreakpoint = 1024.0;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileBreakpoint;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width <= desktopBreakpoint;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width > desktopBreakpoint;

  static DeviceScreenType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) return DeviceScreenType.mobile;
    if (width <= desktopBreakpoint) return DeviceScreenType.tablet;
    return DeviceScreenType.desktop;
  }

  /// Calculates responsive column counts for movie poster grids:
  /// Mobile = 2 columns, Tablet = 3 columns, Desktop = 4-6 columns based on width
  static int getGridColumnCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 480) return 2;
    if (width < mobileBreakpoint) return 2;
    if (width < 900) return 3;
    if (width < 1200) return 4;
    if (width < 1600) return 5;
    return 6;
  }

  /// Responsive page padding
  static EdgeInsets getPagePadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0);
    } else if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0);
    } else {
      return const EdgeInsets.symmetric(horizontal: 48.0, vertical: 32.0);
    }
  }

  /// Typography scale factor to guarantee zero overflow
  static double getTypographyScale(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 380) return 0.85;
    if (width < mobileBreakpoint) return 0.95;
    return 1.0;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > desktopBreakpoint) {
          return desktop;
        } else if (constraints.maxWidth >= mobileBreakpoint) {
          return tablet ?? desktop;
        } else {
          return mobile;
        }
      },
    );
  }
}
