import 'package:pub_stats_collector/fetch_package_data.dart';
import 'package:shelf/shelf.dart' as shelf;

void main() async {
  await fetchPackageData(
    shelf.Request('GET', Uri.parse('https://pubstats.dev/test')),
    debug: true,
  );
}
