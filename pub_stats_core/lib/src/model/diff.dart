import 'package:freezed_annotation/freezed_annotation.dart';

part 'diff.g.dart';

sealed class Diff {
  bool get different;
  String get text;

  Map<String, dynamic> toJson();
}

@JsonSerializable()
class StringDiff extends Diff {
  final Object? before;
  final Object? after;

  StringDiff(this.before, this.after);

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

  SetDiff._({
    this.added = const {},
    this.removed = const {},
  });

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
