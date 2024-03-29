import 'package:flutter/material.dart';
import 'package:pub_stats/constant/app_colors.dart';

class AppTheme {
  AppTheme._();

  static final pillRadius = BorderRadius.circular(100);

  static final theme = ThemeData(
    brightness: Brightness.dark,
    colorSchemeSeed: AppColors.primary,
    cardTheme: CardTheme(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
    ),
    appBarTheme: const AppBarTheme(centerTitle: true),
  );
}
