import 'package:fast_rx_flutter/fast_rx_flutter.dart';
import 'package:fast_rx_persistence/fast_rx_persistence.dart';
import 'package:flutter/material.dart';

class SettingsController {
  final themeMode = ThemeMode.system.rx
    ..persist(
      'themeMode',
      converter: EnumPersistenceConverter.string(ThemeMode.values),
    );
}
