import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pub_stats/constant/app_image.dart';
import 'package:pub_stats_core/pub_stats_core.dart';
import 'package:recase/recase.dart';

class ShieldsBadge extends StatelessWidget {
  final String package;
  final BadgeType type;
  final Object? value;

  const ShieldsBadge({
    super.key,
    required this.package,
    required this.type,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: () => _createBadge(context),
        child: Row(
          children: [
            ColoredBox(
              color: const Color(0xFF555555),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(
                  spacing: 4,
                  children: [
                    SvgPicture.asset(AppImage.logo, height: 14),
                    Text(type.name),
                  ],
                ),
              ),
            ),
            ColoredBox(
              color: const Color(0xFF007EC6),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Text(value?.toString() ?? 'N/A'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _createBadge(BuildContext context) {
    final hint = type.name.titleCase;
    Clipboard.setData(
      ClipboardData(
        text:
            '[![PubStats $hint](https://pubstats.dev/badges/packages/$package/$type.svg)](https://pubstats.dev/packages/$package)',
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Badge markdown copied to clipboard')),
    );
  }
}
