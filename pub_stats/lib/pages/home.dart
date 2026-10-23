import 'dart:async';

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';
import 'package:web/web.dart' as web;

import '../app_controller.dart';
import '../app_scope.dart';
import '../components/chart.dart';
import '../components/widgets.dart';
import '../format.dart';
import '../models.dart';

class Home extends StatefulComponent {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? _routeKey;

  @override
  Component build(BuildContext context) {
    final controller = AppScope.of(context);
    final packages = _packages(context);
    final routeKey = packages.join(',');
    if (_routeKey != routeKey) {
      _routeKey = routeKey;
      Future.microtask(() {
        if (mounted) unawaited(controller.loadPackages(packages));
      });
    }
    final title = switch (packages.length) {
      0 => 'pubstats',
      1 => '${packages.single} · pubstats',
      _ => 'Comparing · pubstats',
    };

    if (controller.startupError case final error?) {
      return div(
        classes: 'page',
        [
          Document.head(title: 'pubstats'),
          div(
            classes: 'message',
            [
              strong([.text('Unable to load pubstats')]),
              p([.text(error)]),
            ],
          ),
        ],
      );
    }

    if (packages.isEmpty) {
      return div(
        classes: 'page',
        [
          Document.head(title: title),
          const GlobalStatsView(),
        ],
      );
    }
    final stats = controller.statsFor(packages);
    if (stats == null) {
      return div(
        classes: 'page',
        [
          Document.head(title: title),
          const LoadingView(),
        ],
      );
    }
    if (stats.isEmpty) {
      return div(
        classes: 'page',
        [
          Document.head(title: title),
          div(
            classes: 'message',
            [
              strong([.text('No stats')]),
              p([.text('Nothing was found for ${packages.join(', ')} in this time span.')]),
            ],
          ),
        ],
      );
    }
    return div(
      classes: 'page',
      [
        Document.head(title: title),
        PackageStatsView(stats: stats),
      ],
    );
  }

  List<String> _packages(BuildContext context) {
    final raw = RouteState.of(context).params['packages'];
    if (raw == null || raw.isEmpty) return const [];
    return raw.split(',').where((item) => item.isNotEmpty).toList();
  }
}

class GlobalStatsView extends StatelessComponent {
  const GlobalStatsView({super.key});

  @override
  Component build(BuildContext context) {
    final controller = AppScope.of(context);
    final stats = controller.globalStats;
    if (stats == null) {
      if (controller.homeFailed) {
        return div(
          classes: 'message',
          [
            strong([.text('Unable to load pubstats')]),
            p([.text('Global stats are unavailable.')]),
          ],
        );
      }
      return const LoadingView();
    }
    final cards = [
      (stats.topPackage, 'Top package', true),
      (stats.mostDownloadedPackage, 'Most downloaded package', true),
      (stats.mostLikedPackage, 'Most liked package', true),
      (stats.mostDependedPackage, 'Most depended package', true),
      (formatNumber(stats.packageCount), 'Packages scanned', false),
      (timeAgo(stats.lastUpdated), 'Last updated', false),
    ];
    final counts = controller.packageCounts.where((item) => controller.timeSpan.contains(item.timestamp)).toList();
    return section(
      classes: 'global',
      [
        div(
          classes: 'stat-grid',
          [
            for (final card in cards)
              if (card.$3)
                button(
                  classes: 'stat-card',
                  type: ButtonType.button,
                  onClick: () => context.push('/packages/${card.$1}'),
                  [
                    strong([.text(card.$1)]),
                    span([.text(card.$2)]),
                  ],
                )
              else
                div(
                  classes: 'stat-card',
                  [
                    strong([.text(card.$1)]),
                    span([.text(card.$2)]),
                  ],
                ),
          ],
        ),
        if (!controller.countsLoaded)
          const LoadingView(label: 'Loading chart')
        else
          div(
            classes: controller.loading ? 'chart-slot is-loading' : 'chart-slot',
            [
              StatChart(
                label: 'Total Package Count',
                formatValue: formatNumber,
                series: [
                  ChartSeries(
                    label: 'Packages',
                    color: chartColors.first,
                    points: [for (final count in counts) ChartPoint(count.timestamp, count.count.toDouble())],
                  ),
                ],
              ),
            ],
          ),
      ],
    );
  }
}

class PackageStatsView extends StatelessComponent {
  const PackageStatsView({required this.stats, super.key});

  final List<PackageStats> stats;

  @override
  Component build(BuildContext context) {
    final controller = AppScope.of(context);
    return section(
      classes: 'center-col',
      [
        if (stats.length == 1)
          _PackageHeading(stats: stats.first)
        else
          div(
            classes: 'package-head',
            [
              h1([.text('Comparing')]),
              div(
                classes: 'badge-row',
                [
                  for (var i = 0; i < stats.length; i++)
                    span(
                      classes: 'chip',
                      [
                        span([.text(stats[i].package)]),
                        button(
                          classes: 'chip-delete',
                          type: ButtonType.button,
                          attributes: {'aria-label': 'Remove ${stats[i].package}'},
                          styles: Styles(color: Color(chartColors[i])),
                          onClick: () {
                            final next = stats
                                .map((item) => item.package)
                                .where((name) => name != stats[i].package)
                                .toList();
                            context.push(next.isEmpty ? '/' : '/packages/${next.join(',')}');
                          },
                          [const Icon('close')],
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        div(
          classes: controller.loading ? 'chart-grid is-loading' : 'chart-grid',
          [
            StatChart(
              label: 'Like Count',
              formatValue: _count,
              padFlat: true,
              series: [
                for (var i = 0; i < stats.length; i++)
                  ChartSeries(
                    label: stats[i].package,
                    color: chartColors[i],
                    points: _points(stats[i], controller, (item) => item.likeCount),
                  ),
              ],
            ),
            PopularityChart(stats: stats),
            StatChart(
              label: 'Download Count',
              formatValue: (value) => formatLargeNum(value),
              series: [
                for (var i = 0; i < stats.length; i++)
                  ChartSeries(
                    label: stats[i].package,
                    color: chartColors[i],
                    points: _points(stats[i], controller, (item) => item.downloadCount),
                  ),
              ],
            ),
          ],
        ),
        p(
          classes: 'hint',
          [.text('Hover/touch the charts for more information')],
        ),
        if (stats.length == 1 && controller.ready) HistoryList(package: stats.first.package),
      ],
    );
  }
}

class _PackageHeading extends StatelessComponent {
  const _PackageHeading({required this.stats});

  final PackageStats stats;

  @override
  Component build(BuildContext context) {
    final data = stats.data;
    final updated = stats.stats.isEmpty ? 'never' : timeAgo(stats.stats.last.timestamp);
    return div(
      classes: 'package-head',
      [
        h1([
          a(
            href: 'https://pub.dev/packages/${stats.package}',
            target: Target.blank,
            attributes: {'rel': 'noopener noreferrer'},
            [.text(stats.package)],
          ),
        ]),
        p(
          classes: 'muted',
          [.text('Last updated $updated')],
        ),
        div(
          classes: 'badge-row',
          [
            ShieldsBadge(package: stats.package, kind: BadgeKind.popularity, value: data.popularityScore),
            ShieldsBadge(
              package: stats.package,
              kind: BadgeKind.rank,
              value: data.overallRank == null ? null : data.overallRank! + 1,
            ),
            ShieldsBadge(package: stats.package, kind: BadgeKind.dependents, value: data.numDependents),
          ],
        ),
        p(
          classes: 'hint',
          [.text('Click a badge to copy its markdown')],
        ),
      ],
    );
  }
}

class PopularityChart extends StatefulComponent {
  const PopularityChart({required this.stats, super.key});

  final List<PackageStats> stats;

  @override
  State<PopularityChart> createState() => _PopularityChartState();
}

class _PopularityChartState extends State<PopularityChart> {
  var _legacy = false;

  @override
  Component build(BuildContext context) {
    final controller = AppScope.of(context);
    return StatChart(
      label: 'Popularity Score',
      minY: 0,
      maxY: 100,
      formatValue: _count,
      series: [
        for (var i = 0; i < component.stats.length; i++)
          ChartSeries(
            label: component.stats[i].package,
            color: chartColors[i],
            points: _points(
              component.stats[i],
              controller,
              (item) => _legacy ? item.legacyPopularityScore : item.popularityScore,
            ),
          ),
      ],
      actions: [
        button(
          classes: 'icon-btn',
          type: ButtonType.button,
          attributes: {'aria-label': 'About popularity score'},
          onClick: controller.showPopularityInfo,
          [const Icon('info')],
        ),
        button(
          classes: 'icon-btn',
          type: ButtonType.button,
          attributes: {'title': _legacy ? 'Show modern scores' : 'Show legacy scores'},
          onClick: () => setState(() => _legacy = !_legacy),
          [const Icon('swap_horiz')],
        ),
      ],
    );
  }
}

class HistoryList extends StatefulComponent {
  const HistoryList({required this.package, super.key});

  final String package;

  @override
  State<HistoryList> createState() => _HistoryListState();
}

class _HistoryListState extends State<HistoryList> {
  final _entries = <HistoryEntry>[];
  StreamSubscription<web.Event>? _scroll;
  web.Element? _scroller;
  DateTime? _firstScan;
  var _loading = true;
  var _busy = false;
  var _hasMore = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) unawaited(_load());
    });
  }

  @override
  void dispose() {
    unawaited(_scroll?.cancel());
    super.dispose();
  }

  void _bindScroll() {
    final element = web.document.getElementById('history-scroll');
    if (element == null || identical(element, _scroller)) return;
    unawaited(_scroll?.cancel());
    _scroller = element;
    _scroll = web.EventStreamProviders.scrollEvent.forTarget(element).listen((_) => _maybeLoadMore());
  }

  void _maybeLoadMore() {
    if (!_hasMore || _busy) return;
    final scroller = _scroller;
    final sentinel = web.document.getElementById('history-more');
    if (scroller == null || sentinel == null) return;
    final edge = scroller.getBoundingClientRect().right;
    if (sentinel.getBoundingClientRect().left < edge + 240) {
      unawaited(_load(more: true));
    }
  }

  Future<void> _load({bool more = false}) async {
    if (_busy) return;
    _busy = true;
    if (more && mounted) setState(() {});
    final controller = AppScope.of(context);
    final endBefore = more && _entries.isNotEmpty
        ? (_entries.last.timestamp.millisecondsSinceEpoch / 1000).round().toString()
        : null;
    final pageFuture = controller.history(component.package, endBefore: endBefore);
    final scanFuture = endBefore == null ? _firstScanOf(component.package) : null;
    try {
      final page = await pageFuture;
      final scan = scanFuture == null ? _firstScan : await scanFuture;
      final fresh = endBefore == null
          ? page
          : page.where((entry) => entry.timestamp.isBefore(_entries.last.timestamp)).toList();
      if (!mounted) return;
      setState(() {
        _entries.addAll(fresh);
        _firstScan = scan ?? _firstScan;
        _hasMore = fresh.isNotEmpty && page.length >= 20;
        _loading = false;
        _busy = false;
      });
      Future.microtask(() {
        _bindScroll();
        _maybeLoadMore();
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _busy = false;
      });
      controller.snack('Unable to load history');
    } finally {
      _busy = false;
    }
  }

  Future<DateTime?> _firstScanOf(String package) async {
    try {
      return await AppScope.of(context).firstScan(package);
    } catch (_) {
      return null;
    }
  }

  @override
  Component build(BuildContext context) {
    return section(
      classes: 'history',
      [
        h2([.text('History')]),
        if (_loading && _entries.isEmpty)
          const LoadingView(label: 'Loading history')
        else
          div(
            id: 'history-scroll',
            classes: 'history-scroll',
            [
              for (final entry in _entries)
                div(
                  classes: 'history-card',
                  [
                    span(classes: 'when', [.text(shortDate(entry.timestamp))]),
                    for (final change in entry.changes) _changeBlock(context, change),
                  ],
                ),
              if (_hasMore) div(id: 'history-more', classes: 'history-more', []),
              if (_busy && _entries.isNotEmpty)
                div(
                  classes: 'history-card is-pending',
                  attributes: {'role': 'status'},
                  [const Spinner()],
                ),
              if (!_loading && !_hasMore && _firstScan != null)
                div(
                  classes: 'history-card',
                  [
                    span(classes: 'when', [.text(shortDate(_firstScan!))]),
                    span([.text('First scan')]),
                  ],
                ),
            ],
          ),
      ],
    );
  }
}

Component _changeBlock(BuildContext context, FieldChange change) {
  if (change.isSet) {
    return div(
      classes: 'history-body',
      [
        if (change.added.isNotEmpty) _packageLine(context, 'Dependents added', change.added),
        if (change.removed.isNotEmpty) _packageLine(context, 'Dependents removed', change.removed),
      ],
    );
  }

  final phrase = _statusPhrase(change);
  if (phrase != null) return span([.text(phrase)]);

  final pair = _pair(change.text);
  return div(
    classes: 'history-body',
    [
      span(classes: 'history-field', [.text(_fieldLabel(change.field))]),
      if (pair == null)
        span([.text(change.text)])
      else
        span([
          span(classes: 'history-old', [.text(_shown(pair.$1))]),
          .text(' → '),
          .text(_shown(pair.$2)),
        ]),
    ],
  );
}

Component _packageLine(BuildContext context, String label, Set<String> packages) {
  final names = packages.toList()..sort();
  return div(
    classes: 'history-body',
    [
      span(classes: 'history-field', [.text(label)]),
      if (names.length > 2)
        button(
          classes: 'linkish',
          type: ButtonType.button,
          onClick: () => AppScope.of(context).showPackages(label, names),
          [.text('${names.length} packages')],
        )
      else
        div(
          classes: 'history-names',
          [for (final name in names) Link(to: '/packages/$name', child: .text(name))],
        ),
    ],
  );
}

String? _statusPhrase(FieldChange change) {
  final pair = _pair(change.text);
  if (pair == null) return null;
  final after = switch (pair.$2) {
    'true' => true,
    'false' => false,
    _ => null,
  };
  if (after == null) return null;
  return switch (change.field) {
    'isDiscontinued' => after ? 'Discontinued' : 'No longer discontinued',
    'isUnlisted' => after ? 'Unlisted' : 'No longer unlisted',
    'isFlutterFavorite' => after ? 'Flutter Favorite' : 'No longer a Flutter Favorite',
    _ => null,
  };
}

String _fieldLabel(String field) => switch (field) {
  'likeCount' => 'Likes',
  'popularityScore' => 'Popularity',
  'downloadCount' => 'Downloads',
  'pubPoints' => 'Pub points',
  _ => titleCase(field),
};

(String, String)? _pair(String text) {
  const separator = ' -> ';
  final index = text.indexOf(separator);
  if (index == -1) return null;
  return (text.substring(0, index), text.substring(index + separator.length));
}

String _shown(String value) => value == 'null' || value.isEmpty ? 'none' : value;

List<ChartPoint> _points(PackageStats stats, AppController controller, num? Function(ScoreSnapshot snapshot) read) {
  return [
    for (final snapshot in stats.stats)
      if (controller.timeSpan.contains(snapshot.timestamp) && read(snapshot) != null)
        ChartPoint(snapshot.timestamp, read(snapshot)!.toDouble()),
  ];
}

String _count(num value) => value.round().toString();
