// Utility for responsive layout breakpoints across phone and tablet.
import 'package:flutter/material.dart';

class ResponsiveHelper {
  ResponsiveHelper._();

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width > 600;

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width <= 600;

  static double screenWidth(BuildContext context) =>
      MediaQuery.sizeOf(context).width;
}
