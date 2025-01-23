import 'package:flutter/material.dart';
import 'package:pub_stats_core/pub_stats_core.dart';

class Badge extends StatelessWidget {
  final String url;

  const Badge({super.key, required String package, required BadgeType type})
      : url = 'https://pubstats/dev/badges/packages/$package/$type.svg';

  @override
  Widget build(BuildContext context) {
    return Image.network(url);
  }
}
