import 'package:flutter/material.dart';
import 'package:fast_ui/fast_ui.dart';

class Header extends StatelessWidget {
  const Header({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'pubstats.dev',
          textAlign: TextAlign.center,
          style: context.textTheme.headline2!
              .copyWith(color: context.textTheme.bodyText1!.color),
        ),
        const SizedBox(height: 20),
        const Text(
          'Pub stats tracked over time',
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
