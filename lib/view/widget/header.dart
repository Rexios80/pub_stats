import 'package:flutter/material.dart';
import 'package:fast_ui/fast_ui.dart';
import 'package:get_it/get_it.dart';
import 'package:pub_stats/constant/app_theme.dart';
import 'package:pub_stats/controller/data_controller.dart';

class Header extends StatelessWidget {
  final _controller = GetIt.I<DataController>();

  Header({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          borderRadius: AppTheme.pillRadius,
          onTap: _controller.reset,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  width: 75,
                ),
                const SizedBox(width: 20),
                Text(
                  'pubstats.dev',
                  textAlign: TextAlign.center,
                  style: context.textTheme.headline2!
                      .copyWith(color: context.textTheme.bodyText1!.color),
                ),
              ],
            ),
          ),
        ),
        const Text(
          'Pub stats tracked over time',
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
