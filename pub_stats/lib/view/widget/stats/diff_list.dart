import 'package:fast_ui/fast_ui.dart';
import 'package:firebase_ui_database/firebase_ui_database.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pub_stats/controller/data_controller.dart';
import 'package:pub_stats/format/formatting.dart';
import 'package:pub_stats_core/pub_stats_core.dart';
import 'package:recase/recase.dart';
import 'package:sliver_tools/sliver_tools.dart';

class DiffList extends StatelessWidget {
  static final _controller = GetIt.I<DataController>();

  const DiffList({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiSliver(
      children: [
        Text(
          'History',
          style: context.textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        // TODO: Check if this is actually lazy loading
        FastBuilder(
          () => FirebaseDatabaseListView(
            query: _controller.diffQuery(_controller.loadedStats.first.package),
            shrinkWrap: true,
            itemBuilder: (context, snap) {
              final date = DateTime.fromMillisecondsSinceEpoch(
                int.parse(snap.key as String) * 1000,
              );
              final diff = PackageDataDiffExtension.fromJson(
                snap.value as Map<String, dynamic>,
              );

              return Card(
                child: Column(
                  children: diff.entries
                      .map(
                        (e) => ListTile(
                          leading: Text(e.key.name.titleCase),
                          title: Text(e.value.text),
                          trailing: Text(Formatting.shortDate(date)),
                        ),
                      )
                      .toList(),
                ),
              );
            },
          ),
        ),
        Card(
          child: FastBuilder(() {
            final firstSnapshot = _controller.loadedStats.first.stats.first;
            return ListTile(
              leading: const Text('Meta'),
              title: const Text('First scanned'),
              trailing: Text(Formatting.shortDate(firstSnapshot.timestamp)),
            );
          }),
        ),
      ],
    );
  }
}
