import 'package:fast_ui/fast_ui.dart';
import 'package:firebase_ui_database/firebase_ui_database.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pub_stats/controller/data_controller.dart';
import 'package:pub_stats/extension/diff_extension.dart';
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
        FastBuilder(
          () => FirebaseDatabaseQueryBuilder(
            query: _controller.diffQuery(_controller.loadedStats.first.package),
            reverseQuery: true,
            builder: (context, snap, child) => SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index == snap.docs.length - 4) {
                    snap.fetchMore();
                  }

                  final doc = snap.docs[index];
                  final date = DateTimeExtension.fromSecondsSinceEpoch(
                    int.parse(doc.key as String),
                  );
                  final diff = PackageDataDiffExtension.fromJson(
                    doc.value as Map<String, dynamic>,
                  );

                  return Card(
                    child: Column(
                      children: diff.entries
                          .map(
                            (e) => ListTile(
                              leading: SizedBox(
                                width: 100,
                                child: Text(e.key.name.titleCase),
                              ),
                              title: e.value.widget,
                              trailing: Text(Formatting.shortDate(date)),
                            ),
                          )
                          .toList(),
                    ),
                  );
                },
                childCount: snap.docs.length,
              ),
            ),
          ),
        ),
        Card(
          child: FastBuilder(() {
            final firstScan = _controller.loadedStats.first.firstScan;
            return ListTile(
              leading: const SizedBox(
                width: 100,
                child: Text('Meta'),
              ),
              title: const Text('First scan'),
              trailing: Text(Formatting.shortDate(firstScan)),
            );
          }),
        ),
      ],
    );
  }
}
