import 'package:meta/meta.dart';

@immutable
class PackageCountSnapshot {
  final DateTime timestamp;
  final int count;

  const PackageCountSnapshot({required this.timestamp, required this.count});
}
