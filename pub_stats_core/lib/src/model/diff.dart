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

@JsonSerializable()
class LargeNumDiff extends Diff {
  final num? before;
  final num? after;

  LargeNumDiff(this.before, this.after);

  @override
  bool get different => before != after;

  static String format(num number) {
    if (number < 1000) return number.toString();

    const suffixes = ['K', 'M', 'B', 'T'];
    var suffixIndex = -1;
    var temp = number.toDouble();

    while (temp >= 1000 && suffixIndex < suffixes.length - 1) {
      temp /= 1000;
      suffixIndex++;
    }

    final formatted = temp
        .toStringAsFixed(2)
        // Remove trailing zeros and possible decimal point
        .replaceAll(RegExp(r'\.?0+$'), '');

    return '$formatted${suffixes[suffixIndex]}';
  }

  @override
  String get text {
    final before = this.before;
    final after = this.after;
    final beforeText = before == null ? 'null' : format(before);
    final afterText = after == null ? 'null' : format(after);
    return '$beforeText -> $afterText';
  }

  factory LargeNumDiff.fromJson(Map<String, dynamic> json) =>
      _$LargeNumDiffFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$LargeNumDiffToJson(this);
}
