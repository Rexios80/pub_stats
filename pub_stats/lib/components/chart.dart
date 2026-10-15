import 'dart:js_interop';
import 'dart:math' as math;

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:web/web.dart' as web;

import '../format.dart';

class ChartPoint {
  const ChartPoint(this.time, this.value);

  final DateTime time;
  final double value;
}

class ChartSeries {
  const ChartSeries({required this.label, required this.color, required this.points});

  final String label;
  final String color;
  final List<ChartPoint> points;
}

class StatChart extends StatelessComponent {
  const StatChart({
    required this.label,
    required this.series,
    required this.formatValue,
    this.minY,
    this.maxY,
    this.padFlat = false,
    this.actions = const [],
    super.key,
  });

  final String label;
  final List<ChartSeries> series;
  final String Function(num value) formatValue;
  final double? minY;
  final double? maxY;
  final bool padFlat;
  final List<Component> actions;

  @override
  Component build(BuildContext context) {
    final plotted = series.where((item) => item.points.length >= 2).toList();
    final only = series.length == 1 ? series.first.points : const <ChartPoint>[];
    return div(
      classes: 'chart-card',
      [
        div(
          classes: 'chart-top',
          [
            span([.text(label)]),
            span([]),
          ],
        ),
        if (actions.isNotEmpty)
          div(
            actions,
            classes: 'chart-actions',
          ),
        if (plotted.isEmpty)
          div(
            classes: 'message',
            [
              if (only.length == 1) strong([.text(formatValue(only.first.value))]),
              .text(only.isEmpty ? 'No data' : 'Not enough data to show chart'),
            ],
          ),
        if (plotted.isNotEmpty && only.length >= 2)
          div(styles: Styles(height: 12.px), []),
        if (plotted.isNotEmpty && only.length >= 2)
          ChangeOverview(first: only.first.value, last: only.last.value, formatValue: formatValue),
        if (plotted.isNotEmpty) div(styles: Styles(height: 32.px), []),
        if (plotted.isNotEmpty)
          LinePlot(
            plotId: _plotId(label, plotted),
            series: plotted,
            formatValue: formatValue,
            minY: minY,
            maxY: maxY,
            padFlat: padFlat && series.length == 1,
          ),
      ],
    );
  }
}

String _plotId(String label, List<ChartSeries> series) {
  final names = [label, for (final item in series) item.label].join('-');
  return 'plot-${names.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-')}';
}

class ChangeOverview extends StatelessComponent {
  const ChangeOverview({required this.first, required this.last, required this.formatValue, super.key});

  final double first;
  final double last;
  final String Function(num value) formatValue;

  @override
  Component build(BuildContext context) {
    final change = (last - first).round();
    final (text, tone) = switch (change) {
      > 0 => ('(+${formatValue(change)})', 'positive'),
      < 0 => ('(${formatValue(change)})', 'negative'),
      _ => ('(0)', 'flat'),
    };
    return div(
      classes: 'overview',
      [
        span([.text(formatValue(last.round()))]),
        span(
          classes: tone,
          [.text(text)],
        ),
      ],
    );
  }
}

class LinePlot extends StatefulComponent {
  const LinePlot({
    required this.plotId,
    required this.series,
    required this.formatValue,
    this.minY,
    this.maxY,
    this.padFlat = false,
    super.key,
  });

  final String plotId;
  final List<ChartSeries> series;
  final String Function(num value) formatValue;
  final double? minY;
  final double? maxY;
  final bool padFlat;

  @override
  State<LinePlot> createState() => _LinePlotState();
}

class _LinePlotState extends State<LinePlot> {
  _Hover? _hover;

  @override
  Component build(BuildContext context) {
    final domain = _domain(component.series, component.minY, component.maxY, component.padFlat);
    final ticks = [for (var i = 0; i < 4; i++) domain.maxY - (domain.maxY - domain.minY) * i / 3];
    return div(
      classes: 'chart-body',
      [
        div(
          classes: 'y-labels',
          [
            for (final tick in ticks) span([.text(component.formatValue(tick.round()))]),
          ],
        ),
        div(
          id: component.plotId,
          classes: 'plot',
          events: {
            'pointermove': (event) => _move(event, domain),
            'pointerdown': (event) => _move(event, domain),
            'pointerleave': (_) => setState(() => _hover = null),
          },
          [
            svg(
              viewBox: '0 0 100 100',
              attributes: {'preserveAspectRatio': 'none'},
              [
                line(
                  x1: '0',
                  y1: '99.5',
                  x2: '100',
                  y2: '99.5',
                  stroke: .variable('--on-surface'),
                  strokeWidth: '1',
                  attributes: {'vector-effect': 'non-scaling-stroke'},
                  [],
                ),
                line(
                  x1: '0.5',
                  y1: '0',
                  x2: '0.5',
                  y2: '100',
                  stroke: .variable('--on-surface'),
                  strokeWidth: '1',
                  attributes: {'vector-effect': 'non-scaling-stroke'},
                  [],
                ),
                for (final series in component.series)
                  polyline(
                    points: series.points
                        .map((point) {
                          final x = _x(point.time, domain);
                          final y = _y(point.value, domain);
                          return '${x.toStringAsFixed(2)},${y.toStringAsFixed(2)}';
                        })
                        .join(' '),
                    fill: Colors.transparent,
                    stroke: Color(series.color),
                    strokeWidth: '2',
                    attributes: {
                      'vector-effect': 'non-scaling-stroke',
                      'stroke-linejoin': 'round',
                      'stroke-linecap': 'round',
                    },
                    [],
                  ),
              ],
            ),
            if (component.series.every((series) => series.points.length < 10))
              for (final series in component.series)
                for (final point in series.points)
                  span(
                    classes: 'dot',
                    styles: Styles(
                      raw: {
                        'left': '${_x(point.time, domain)}%',
                        'top': '${_y(point.value, domain)}%',
                        'background': series.color,
                      },
                    ),
                    [],
                  ),
            if (_hover != null) ...[
              div(
                classes: 'guide',
                styles: Styles(position: .absolute(left: _hover!.localX.px)),
                [],
              ),
              div(
                classes: 'tooltip',
                styles: Styles(
                  position: _hover!.flip
                      ? .absolute(right: _hover!.edge.px, top: 8.px)
                      : .absolute(left: _hover!.edge.px, top: 8.px),
                ),
                [
                  div([.text(shortDate(_hover!.time))]),
                  for (final item in _hover!.values)
                    div([
                      span(
                        classes: 'swatch',
                        styles: Styles(backgroundColor: Color(item.$1)),
                        [],
                      ),
                      .text(
                        component.series.length > 1
                            ? '${item.$2} ${component.formatValue(item.$3)}'
                            : component.formatValue(item.$3),
                      ),
                    ]),
                ],
              ),
            ],
          ],
        ),
      ],
    );
  }

  void _move(web.Event event, _Domain domain) {
    final pointer = _PointerPoint(event as JSObject);
    final rect = web.document.getElementById(component.plotId)?.getBoundingClientRect();
    if (rect == null || rect.width == 0) return;
    final localX = pointer.clientX - rect.left;
    final fraction = (localX / rect.width).clamp(0, 1).toDouble();
    final flip = localX > rect.width / 2;
    final edge = flip ? rect.width - localX + 12 : localX + 12;
    final millis = domain.minX + (domain.maxX - domain.minX) * fraction;
    final time = DateTime.fromMillisecondsSinceEpoch(millis.round());
    final values = <(String, String, double)>[];
    for (final series in component.series) {
      if (series.points.isEmpty) continue;
      var best = series.points.first;
      var bestDistance = (best.time.millisecondsSinceEpoch - millis).abs();
      for (final point in series.points.skip(1)) {
        final distance = (point.time.millisecondsSinceEpoch - millis).abs();
        if (distance < bestDistance) {
          best = point;
          bestDistance = distance;
        }
      }
      values.add((series.color, series.label, best.value));
    }
    setState(() => _hover = _Hover(localX: localX, flip: flip, edge: edge, time: time, values: values));
  }
}

extension type _PointerPoint(JSObject _) implements JSObject {
  external double get clientX;
  external double get clientY;
}

class _Hover {
  const _Hover({required this.localX, required this.flip, required this.edge, required this.time, required this.values});

  final double localX;
  final bool flip;
  final double edge;
  final DateTime time;
  final List<(String, String, double)> values;
}

class _Domain {
  const _Domain({required this.minX, required this.maxX, required this.minY, required this.maxY});

  final double minX;
  final double maxX;
  final double minY;
  final double maxY;
}

_Domain _domain(List<ChartSeries> series, double? fixedMin, double? fixedMax, bool padFlat) {
  final points = series.expand((series) => series.points).toList();
  var minX = points.first.time.millisecondsSinceEpoch.toDouble();
  var maxX = minX;
  var minY = points.first.value;
  var maxY = minY;
  for (final point in points) {
    final x = point.time.millisecondsSinceEpoch.toDouble();
    minX = math.min(minX, x);
    maxX = math.max(maxX, x);
    minY = math.min(minY, point.value);
    maxY = math.max(maxY, point.value);
  }
  if (minX == maxX) {
    minX -= 3600000;
    maxX += 3600000;
  }
  if (fixedMin != null && fixedMax != null) {
    minY = fixedMin;
    maxY = fixedMax;
  } else if (padFlat &&
      series.length == 1 &&
      series.first.points.map((point) => point.value.round()).toSet().length == 1) {
    final y = series.first.points.first.value;
    minY = y < 10 ? 0 : y - 10;
    maxY = y + 10;
  } else if (minY == maxY) {
    minY -= 1;
    maxY += 1;
  }
  return _Domain(minX: minX, maxX: maxX, minY: minY, maxY: maxY);
}

double _x(DateTime time, _Domain domain) {
  return (time.millisecondsSinceEpoch - domain.minX) / (domain.maxX - domain.minX) * 100;
}

double _y(double value, _Domain domain) {
  return 100 - (value - domain.minY) / (domain.maxY - domain.minY) * 100;
}
