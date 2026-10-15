import 'package:jaspr/jaspr.dart';

import 'app_controller.dart';

class AppScope extends InheritedComponent {
  const AppScope({required this.controller, required this.revision, required super.child, super.key});

  final AppController controller;
  final int revision;

  static AppController of(BuildContext context) {
    final scope = context.dependOnInheritedComponentOfExactType<AppScope>();
    if (scope == null) throw StateError('AppScope is missing');
    return scope.controller;
  }

  @override
  bool updateShouldNotify(AppScope oldComponent) => revision != oldComponent.revision;
}
