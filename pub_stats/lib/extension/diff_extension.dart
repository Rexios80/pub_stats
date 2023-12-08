import 'package:flutter/material.dart';
import 'package:pub_stats/constant/app_theme.dart';
import 'package:pub_stats/constant/constants.dart';
import 'package:pub_stats_core/pub_stats_core.dart';
import 'package:url_launcher/url_launcher_string.dart';

extension DiffExtension on Diff {
  Widget get widget => switch (this) {
        (final StringDiff diff) => Text(diff.text),
        (final SetDiff diff) => Row(
            children: [
              PackageListButton(
                packages: diff.added.cast<String>(),
                qualifier: 'Added',
              ),
              const SizedBox(width: 8),
              PackageListButton(
                packages: diff.removed.cast<String>(),
                qualifier: 'Removed',
              ),
            ],
          ),
      };
}

class PackageListButton extends StatelessWidget {
  final Set<String> packages;
  final String qualifier;

  const PackageListButton({
    super.key,
    required this.packages,
    required this.qualifier,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: AppTheme.pillRadius),
      clipBehavior: Clip.antiAlias,
      child: PopupMenuButton(
        tooltip: 'Show packages',
        itemBuilder: (context) => packages
            .map(
              (package) => PopupMenuItem(
                child: Text(package),
                onTap: () =>
                    launchUrlString(Constants.pubPackageBaseUrl + package),
              ),
            )
            .toList(),
        child: SizedBox(
          width: 120,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              '${packages.length} $qualifier',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
