class Diff {
  final Object before;
  final Object after;

  Diff(this.before, this.after);

  bool get isDifferent => before != after;
}
