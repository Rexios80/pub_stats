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
  bool get different => format(before) != format(after);

  static String format(num? number) {
    if (number == null) return 'null';
    if (number < 1000) return number.toString();

    const suffixes = ['K', 'M', 'B', 'T'];
    var suffixIndex = -1;
    var temp = number.toDouble();

    // Determine the appropriate suffix
    while (temp >= 1000 && suffixIndex < suffixes.length - 1) {
      temp /= 1000;
      suffixIndex++;
    }

    // Calculate the number of digits before the decimal point
    final integerDigits = temp.floor().toString().length;

    // Determine the number of decimal places to ensure a total of 3 digits
    var decimalDigits = 3 - integerDigits;
    if (decimalDigits < 0) decimalDigits = 0;

    // Format the number with the appropriate number of decimal places
    final formatted = temp
        .toStringAsFixed(decimalDigits)
        // Remove any trailing zeros and possible decimal point
        .replaceAll(RegExp(r'\.?0+$'), '');

    return '$formatted${suffixes[suffixIndex]}';
  }

  @override
  String get text => '${format(before)} -> ${format(after)}';

  factory LargeNumDiff.fromJson(Map<String, dynamic> json) =>
      _$LargeNumDiffFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$LargeNumDiffToJson(this);
}
