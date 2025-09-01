
// lib/utils/responsive_helper.dart

import 'package:flutter/material.dart';

class ResponsiveHelper {
  static double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;
  static double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;
  static double statusBarHeight(BuildContext context) => MediaQuery.of(context).padding.top;
  static double bottomPadding(BuildContext context) => MediaQuery.of(context).padding.bottom;
  
  // Device type detection
  static bool isMobile(BuildContext context) => screenWidth(context) < 600;
  static bool isTablet(BuildContext context) => screenWidth(context) >= 600 && screenWidth(context) < 1200;
  static bool isDesktop(BuildContext context) => screenWidth(context) >= 1200;
  
  // Responsive font sizes
  static double getResponsiveFontSize(BuildContext context, {
    double mobile = 16,
    double tablet = 20,
    double desktop = 24,
  }) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet;
    return desktop;
  }
  
  // Responsive padding
  static EdgeInsets getResponsivePadding(BuildContext context, {
    double mobile = 16,
    double tablet = 24,
    double desktop = 32,
  }) {
    final padding = isMobile(context) ? mobile : (isTablet(context) ? tablet : desktop);
    return EdgeInsets.all(padding);
  }
  
  // Responsive spacing
  static double getResponsiveSpacing(BuildContext context, {
    double mobile = 8,
    double tablet = 12,
    double desktop = 16,
  }) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet;
    return desktop;
  }
  
  // Responsive button height
  static double getResponsiveButtonHeight(BuildContext context) {
    if (isMobile(context)) return 48;
    if (isTablet(context)) return 56;
    return 64;
  }
  
  // Responsive card width
  static double getResponsiveCardWidth(BuildContext context) {
    final screenWidth = ResponsiveHelper.screenWidth(context);
    if (isMobile(context)) return screenWidth * 0.9;
    if (isTablet(context)) return screenWidth * 0.7;
    return screenWidth * 0.5;
  }
  
  // Responsive spectrum size
  static double getResponsiveSpectrumSize(BuildContext context) {
    final screenWidth = ResponsiveHelper.screenWidth(context);
    if (isMobile(context)) return screenWidth * 0.8;
    if (isTablet(context)) return screenWidth * 0.6;
    return screenWidth * 0.4;
  }
  
  // Responsive category font size
  static double getResponsiveCategoryFontSize(BuildContext context) {
    if (isMobile(context)) return 24;
    if (isTablet(context)) return 32;
    return 40;
  }
  
  // Responsive header font size
  static double getResponsiveHeaderFontSize(BuildContext context) {
    if (isMobile(context)) return 28;
    if (isTablet(context)) return 36;
    return 48;
  }
  
  // Responsive button font size
  static double getResponsiveButtonFontSize(BuildContext context) {
    if (isMobile(context)) return 18;
    if (isTablet(context)) return 24;
    return 32;
  }
  
  // Responsive clue font size
  static double getResponsiveClueFontSize(BuildContext context) {
    if (isMobile(context)) return 20;
    if (isTablet(context)) return 28;
    return 36;
  }
  
  // Responsive score font size
  static double getResponsiveScoreFontSize(BuildContext context) {
    if (isMobile(context)) return 48;
    if (isTablet(context)) return 64;
    return 80;
  }
  
  // Responsive dice font size
  static double getResponsiveDiceFontSize(BuildContext context) {
    if (isMobile(context)) return 80;
    if (isTablet(context)) return 120;
    return 160;
  }
  
  // Responsive language toggle font size
  static double getResponsiveLanguageToggleFontSize(BuildContext context) {
    if (isMobile(context)) return 16;
    if (isTablet(context)) return 20;
    return 24;
  }
}
