import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pub_stats/controller/user_controller.dart';

class AlertsManager extends StatelessWidget {
  static final _user = GetIt.I<UserController>();
  
  const AlertsManager({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alerts Manager'),
      ),
      body: const Center(
        child: Text('boo'),
      ),
    );
  }
}
