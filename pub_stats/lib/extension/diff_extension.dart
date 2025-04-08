import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pub_stats/controller/data_controller.dart';
import 'package:pub_stats_core/pub_stats_core.dart';

extension DiffExtension on Diff {
  Widget get widget => switch (this) {
    (final StringDiff diff) => Text(diff.text),
    (final LargeNumDiff diff) => Text(diff.text),
    (final SetDiff diff) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (diff.added.isNotEmpty)
          PackageListButton(
            packages: diff.added.cast<String>(),
            qualifier: 'Added',
          ),
        if (diff.removed.isNotEmpty)
          PackageListButton(
            packages: diff.removed.cast<String>(),
            qualifier: 'Removed',
          ),
      ],
    ),
  };
}

class PackageListButton extends StatelessWidget {
  static final _controller = GetIt.I<DataController>();

  final Set<String> packages;
  final String qualifier;

  const PackageListButton({
    super.key,
    required this.packages,
    required this.qualifier,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      tooltip: '',
      itemBuilder:
          (context) =>
              packages
                  .map(
                    (package) => PopupMenuItem(
                      child: Text(package),
                      onTap: () => _controller.fetchStats(package),
                    ),
                  )
                  .toList(),
      child: AbsorbPointer(
        child: TextButton(
          style: TextButton.styleFrom(padding: EdgeInsets.zero),
          child: Text('$qualifier: ${packages.length}'),
          onPressed: () {},
        ),
      ),
    );
  }
}
