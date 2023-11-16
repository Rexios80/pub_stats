import 'package:flutter/material.dart';
import 'package:fast_ui/fast_ui.dart';
import 'package:pub_stats/constant/app_colors.dart';

class AppTheme {
  AppTheme._();

  static final pillRadius = BorderRadius.circular(100);

  static bool isWide(BuildContext context) => context.screenWidth > 900;

  static final theme = ThemeData(
    brightness: Brightness.dark,
    colorSchemeSeed: AppColors.primary,
    cardTheme: CardTheme(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: FastMaterialStateProperty(
          {MaterialState.selected: AppColors.primary},
        ),
        foregroundColor:
            FastMaterialStateProperty({MaterialState.selected: Colors.white}),
        side: const MaterialStatePropertyAll(BorderSide(color: Colors.grey)),
      ),
    ),
  );
}
