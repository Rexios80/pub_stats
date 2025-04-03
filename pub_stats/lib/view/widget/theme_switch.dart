import 'package:fast_ui/fast_ui.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pub_stats/controller/settings_controller.dart';

class ThemeSwitch extends StatelessWidget {
  static final _settings = GetIt.I<SettingsController>();

  const ThemeSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed:
          () =>
              _settings.themeMode.value = switch (_settings.themeMode.value) {
                ThemeMode.system => ThemeMode.dark,
                ThemeMode.dark => ThemeMode.light,
                ThemeMode.light => ThemeMode.system,
              },
      icon: FastBuilder(
        () => Icon(switch (_settings.themeMode.value) {
          ThemeMode.system => Icons.brightness_auto,
          ThemeMode.dark => Icons.brightness_4,
          ThemeMode.light => Icons.brightness_7,
        }),
      ),
    );
  }
}
