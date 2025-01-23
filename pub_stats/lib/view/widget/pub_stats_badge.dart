import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pub_stats_core/pub_stats_core.dart';

class PubStatsBadge extends StatelessWidget {
  static const baseUrl = kDebugMode
      ? 'http://127.0.0.1:5001/pub-stats-collector/us-central1/badges'
      : 'https://pubstats.dev/badges';

  final String url;

  const PubStatsBadge({
    super.key,
    required String package,
    required BadgeType type,
  }) : url = '$baseUrl/badges/packages/$package/$type.svg';

  @override
  Widget build(BuildContext context) {
    return SvgPicture.network(url);
  }
}
