import 'package:flutter/material.dart';
import 'package:fast_ui/fast_ui.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:pub_stats/constant/app_image.dart';
import 'package:pub_stats/constant/app_theme.dart';
import 'package:pub_stats/controller/data_controller.dart';

class Header extends StatelessWidget {
  final _controller = GetIt.I<DataController>();

  Header({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: AppTheme.pillRadius,
      onTap: _controller.reset,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            SvgPicture.asset(
              AppImage.logo,
              width: 75,
            ),
            const SizedBox(width: 20),
            Text(
              'pubstats',
              textAlign: TextAlign.center,
              style: context.textTheme.displayMedium!
                  .copyWith(color: context.textTheme.bodyLarge!.color),
            ),
          ],
        ),
      ),
    );
  }
}
