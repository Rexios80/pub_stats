enum BadgeType {
  popularity,
  rank,
  dependents;

  String get databaseKey => switch (this) {
        popularity => 'ps2',
        rank => 'n',
        dependents => 'nd',
      };

  @override
  String toString() => name;
}
