import 'package:fast_ui/fast_ui.dart';
import 'package:flutter/material.dart';

class SettingsController {
  final themeMode =
      ThemeMode.system.rx..persist(
        'themeMode',
        converter: EnumPersistenceConverter.string(ThemeMode.values),
      );
}
