import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pub_stats_core/pub_stats_core.dart';

part 'diff.g.dart';

@immutable
sealed class Diff {
  bool get different;
  String get text;

  const Diff();

  Map<String, dynamic> toJson();
}

@JsonSerializable()
class StringDiff extends Diff {
  final Object? before;
  final Object? after;

  const StringDiff(this.before, this.after);

  @override
  bool get different => before != after;

  @override
  String get text => '$before -> $after';

  factory StringDiff.fromJson(Map<String, dynamic> json) =>
      _$StringDiffFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$StringDiffToJson(this);
}

@JsonSerializable(constructor: '_')
class SetDiff extends Diff {
  final Set<Object> added;
  final Set<Object> removed;

  const SetDiff._({this.added = const {}, this.removed = const {}});

  SetDiff(Set<Object> before, Set<Object> after)
    : added = after.difference(before),
      removed = before.difference(after);

  @override
  bool get different => added.isNotEmpty || removed.isNotEmpty;

  @override
  String get text => [
    if (added.isNotEmpty) 'Added: ${added.join(', ')}',
    if (removed.isNotEmpty) 'Removed: ${removed.join(', ')}',
  ].join('\n');

  factory SetDiff.fromJson(Map<String, dynamic> json) =>
      _$SetDiffFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SetDiffToJson(this);
}

@JsonSerializable()
class LargeNumDiff extends Diff {
  final num? before;
  final num? after;

  const LargeNumDiff(this.before, this.after);

  @override
  bool get different => formatLargeNum(before) != formatLargeNum(after);

  @override
  String get text => '${formatLargeNum(before)} -> ${formatLargeNum(after)}';

  factory LargeNumDiff.fromJson(Map<String, dynamic> json) =>
      _$LargeNumDiffFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$LargeNumDiffToJson(this);
}
