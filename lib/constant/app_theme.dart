import 'package:flutter/material.dart';
import 'package:fast_ui/fast_ui.dart';

class AppTheme {
  AppTheme._();

  static final pillRadius = BorderRadius.circular(100);

  static bool isWide(BuildContext context) => context.screenWidth > 900;
}
