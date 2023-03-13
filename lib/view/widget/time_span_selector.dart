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
      () => SegmentedButton<TimeSpan>(
        segments: TimeSpan.values
            .map(
              (e) => ButtonSegment(
                value: e,
                label: SizedBox(
                  width: 100,
                  child: Center(
                    child: Text('$e', textAlign: TextAlign.center),
                  ),
                ),
              ),
            )
            .toList(),
        selected: {controller.timeSpan.value},
        onSelectionChanged: (e) => controller.timeSpan.value = e.single,
      ),
    );
  }
}
