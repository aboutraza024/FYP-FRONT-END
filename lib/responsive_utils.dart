import 'package:flutter/material.dart';
import 'dart:math' as math;

class ResponsiveUtils {
  // 1. Breakpoint Constants (Industry Standards)
  static const double mobileBreakpoint = 480;
  static const double tabletBreakpoint = 768;
  static const double desktopBreakpoint = 1024;

  static Size getScreenSize(BuildContext context) => MediaQuery.of(context).size;

  // 2. Pro Device Checks
  static bool isMobile(BuildContext context) => getScreenSize(context).width < tabletBreakpoint;
  static bool isTablet(BuildContext context) => 
      getScreenSize(context).width >= tabletBreakpoint && getScreenSize(context).width < desktopBreakpoint;
  static bool isDesktop(BuildContext context) => getScreenSize(context).width >= desktopBreakpoint;
  
  static bool isLandscape(BuildContext context) => 
      MediaQuery.of(context).orientation == Orientation.landscape;

  // 3. Pro Scaling Logic (Proportional Scaling)
  // This scales values based on the screen width relative to a standard 375px mobile screen
  static double _getScaleFactor(BuildContext context) {
    double width = getScreenSize(context).width;
    if (isTablet(context)) return width / 768; // Scale based on tablet base
    return width / 375; // Scale based on phone base
  }

  // Use this for dynamic font sizing
  static double getResponsiveFontSize(BuildContext context, double baseFontSize) {
    return baseFontSize * _getScaleFactor(context);
  }

  // 4. Modern Spacing and Padding
  static EdgeInsets getResponsivePadding(BuildContext context) {
    double width = getScreenSize(context).width;
    double scale = _getScaleFactor(context);
    
    if (isTablet(context)) {
      return EdgeInsets.symmetric(horizontal: width * 0.1, vertical: 24 * scale);
    }
    return EdgeInsets.symmetric(horizontal: width * 0.05, vertical: 16 * scale);
  }

  static double getResponsiveSpacing(BuildContext context, double baseSpacing) {
    return baseSpacing * _getScaleFactor(context);
  }

  // 5. Grid Configuration for Islamic Feature Cards
  static int getResponsiveGridCount(BuildContext context) {
    if (isLandscape(context)) return 4;
    if (isTablet(context)) return 3;
    return 2;
  }

  static double getResponsiveChildAspectRatio(BuildContext context) {
    if (isTablet(context)) return 1.2; // Cards are wider on tablet
    if (getScreenSize(context).height < 680) return 0.85; // Taller cards for short phones
    return 1.0; 
  }

  // 6. UI Element Proportions
  static double getResponsiveIconSize(BuildContext context, double baseIconSize) {
    return math.min(baseIconSize * _getScaleFactor(context), baseIconSize * 1.5);
  }

  static double getResponsiveBorderRadius(BuildContext context, double baseRadius) {
    return baseRadius * _getScaleFactor(context);
  }

  // Professional Bottom Navigation Height
  static double getResponsiveBottomNavHeight(BuildContext context) {
    double bottomPadding = MediaQuery.of(context).padding.bottom;
    if (isTablet(context)) return 85.0 + bottomPadding;
    return 65.0 + bottomPadding;
  }

  // Handling "Notches" and Safe areas for custom elements
  static double getTopSafeArea(BuildContext context) => MediaQuery.of(context).padding.top;
  static double getBottomSafeArea(BuildContext context) => MediaQuery.of(context).padding.bottom;
}