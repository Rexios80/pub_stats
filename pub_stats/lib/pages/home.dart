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
    if (!controller.ready || (packages.isNotEmpty && !controller.settled(packages))) {
      return div(
        classes: 'page',
        [
          Document.head(title: title),
          const LoadingView(),
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
    if (controller.loadedStats.isEmpty) {
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
        PackageStatsView(stats: controller.loadedStats),
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
    if (stats == null) return const LoadingView();
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
        if (stats.length == 1) HistoryList(package: stats.first.package, firstScan: stats.first.firstScan),
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
  const HistoryList({required this.package, required this.firstScan, super.key});

  final String package;
  final DateTime firstScan;

  @override
  State<HistoryList> createState() => _HistoryListState();
}

class _HistoryListState extends State<HistoryList> {
  final _entries = <HistoryEntry>[];
  StreamSubscription<web.Event>? _scroll;
  var _loading = true;
  var _busy = false;
  var _hasMore = false;

  @override
  void initState() {
    super.initState();
    _scroll = web.EventStreamProviders.scrollEvent.forTarget(web.window).listen((_) => _maybeLoadMore());
    Future.microtask(() {
      if (mounted) unawaited(_load());
    });
  }

  @override
  void dispose() {
    unawaited(_scroll?.cancel());
    super.dispose();
  }

  void _maybeLoadMore() {
    if (!_hasMore || _busy) return;
    final sentinel = web.document.getElementById('history-more');
    if (sentinel == null) return;
    if (sentinel.getBoundingClientRect().top < web.window.innerHeight + 240) {
      unawaited(_load(more: true));
    }
  }

  Future<void> _load({bool more = false}) async {
    if (_busy) return;
    _busy = true;
    final controller = AppScope.of(context);
    final endBefore = more && _entries.isNotEmpty
        ? (_entries.last.timestamp.millisecondsSinceEpoch / 1000).round().toString()
        : null;
    try {
      final page = await controller.history(component.package, endBefore: endBefore);
      final fresh = endBefore == null
          ? page
          : page.where((entry) => entry.timestamp.isBefore(_entries.last.timestamp)).toList();
      if (!mounted) return;
      setState(() {
        _entries.addAll(fresh);
        _hasMore = fresh.isNotEmpty && page.length >= 20;
        _loading = false;
      });
      Future.microtask(_maybeLoadMore);
    } catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
      controller.snack('Unable to load history');
    } finally {
      _busy = false;
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
          for (final entry in _entries)
            div(
              classes: 'history-card',
              [
                for (final change in entry.changes)
                  div(
                    classes: 'history-row',
                    [
                      strong([.text(titleCase(change.field))]),
                      if (change.isSet)
                        div(
                          classes: 'history-changes',
                          [
                            if (change.added.isNotEmpty) _PackageCount(label: 'Added', packages: change.added),
                            if (change.removed.isNotEmpty) _PackageCount(label: 'Removed', packages: change.removed),
                          ],
                        )
                      else
                        span([.text(change.text)]),
                      span(
                        classes: 'when',
                        [.text(shortDate(entry.timestamp))],
                      ),
                    ],
                  ),
              ],
            ),
        if (_hasMore) div(id: 'history-more', []),
        div(
          classes: 'history-card',
          [
            div(
              classes: 'history-row',
              [
                strong([.text('Meta')]),
                span([.text('First scan')]),
                span(
                  classes: 'when',
                  [.text(shortDate(component.firstScan))],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _PackageCount extends StatelessComponent {
  const _PackageCount({required this.label, required this.packages});

  final String label;
  final Set<String> packages;

  @override
  Component build(BuildContext context) {
    return button(
      classes: 'linkish',
      type: ButtonType.button,
      onClick: () {
        final names = packages.toList()..sort();
        AppScope.of(context).showPackages('$label packages', names);
      },
      [.text('$label: ${packages.length}')],
    );
  }
}

List<ChartPoint> _points(PackageStats stats, AppController controller, num? Function(ScoreSnapshot snapshot) read) {
  return [
    for (final snapshot in stats.stats)
      if (controller.timeSpan.contains(snapshot.timestamp) && read(snapshot) != null)
        ChartPoint(snapshot.timestamp, read(snapshot)!.toDouble()),
  ];
}

String _count(num value) => value.round().toString();
