import 'package:flutter/material.dart';

class PaddedVerticalDivider extends StatelessWidget {
  const PaddedVerticalDivider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: VerticalDivider(),
    );
  }
}
