import 'package:fast_ui/fast_ui.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pub_stats/controller/data_controller.dart';
import 'package:pub_stats/model/time_span.dart';

class TimeSpanSelector extends StatelessWidget {
  final controller = GetIt.I<DataController>();

  TimeSpanSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return FastBuilder(
      () => SizedBox(
        height: 28,
        child: SegmentedButton<TimeSpan>(
          showSelectedIcon: false,
          segments: TimeSpan.values
              .map(
                (e) => ButtonSegment(
                  value: e,
                  label: Padding(
                    padding: const EdgeInsets.all(2),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('$e'),
                    ),
                  ),
                ),
              )
              .toList(),
          selected: {controller.timeSpan.value},
          onSelectionChanged: (e) => controller.timeSpan.value = e.single,
        ),
      ),
    );
  }
}
