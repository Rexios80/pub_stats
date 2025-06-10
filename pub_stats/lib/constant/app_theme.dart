import 'package:flutter/material.dart';
import 'package:pub_stats/constant/app_colors.dart';

class AppTheme {
  AppTheme._();

  static final pillRadius = BorderRadius.circular(100);

  static ThemeData theme(Brightness brightness) => ThemeData(
    brightness: brightness,
    colorSchemeSeed: AppColors.primary,
    cardTheme: CardThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
    ),
    appBarTheme: const AppBarTheme(centerTitle: true),
  );
}
