import 'package:collection/collection.dart';

abstract class Diff<T> {
  final T before;
  final T after;

  Diff(this.before, this.after);

  bool get different;
  String get text;
}

class StringDiff extends Diff<Object> {
  StringDiff(super.before, super.after);

  @override
  bool get different => before != after;

  @override
  String get text => '$before -> $after';
}

class SetDiff extends Diff<Set<String>> {
  SetDiff(super.before, super.after);

  @override
  bool get different => !const SetEquality().equals(before, after);

  @override
  String get text {
    final added = after.difference(before);
    final removed = before.difference(after);

    return [
      if (added.isNotEmpty) 'Added: ${added.join(', ')}',
      if (removed.isNotEmpty) 'Removed: ${removed.join(', ')}',
    ].join('\n');
  }
}
