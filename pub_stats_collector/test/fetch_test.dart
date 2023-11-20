import 'package:pub_stats_collector/functions.dart' as functions;
import 'package:shelf/shelf.dart' as shelf;

void main() async {
  await functions.function(
    shelf.Request('GET', Uri.parse('https://pubstats.dev/test')),
    debug: true,
  );
}
