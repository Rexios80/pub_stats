class PubCatalogPage({required final List<PubCatalogPackage> packages}) {
  factory PubCatalogPage.fromJson(Map<String, dynamic> json) => PubCatalogPage(
    packages: [
      for (final package in json['packages'] as List)
        PubCatalogPackage.fromJson(package as Map<String, dynamic>),
    ],
  );
}

class PubCatalogPackage({
  required final String name,
  required final LatestPackage latest,
}) {
  factory PubCatalogPackage.fromJson(Map<String, dynamic> json) =>
      PubCatalogPackage(
        name: json['name'] as String,
        latest: LatestPackage.fromJson(json['latest'] as Map<String, dynamic>),
      );
}

class LatestPackage({
  required final String version,
  required final Set<String> dependencies,
}) {
  factory LatestPackage.fromJson(Map<String, dynamic> json) {
    final pubspec = json['pubspec'] as Map<String, dynamic>;
    return LatestPackage(
      version: json['version'] as String,
      dependencies: {
        for (final key in ['dependencies', 'dev_dependencies'])
          ...?(pubspec[key] as Map<String, dynamic>?)?.keys,
      },
    );
  }
}
