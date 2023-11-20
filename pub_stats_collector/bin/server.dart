import 'dart:io';

import 'package:pub_stats_collector/fetch_package_data.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

void main(List<String> arguments) async {
  final app = Router()..mount('/fetchPackageData', fetchPackageData);

  final port = Platform.environment.containsKey('PORT')
      ? int.parse(Platform.environment['PORT']!)
      : 8080;
  final server = await shelf_io.serve(app.call, '0.0.0.0', port);

  print('Listening on :${server.port}');
}
