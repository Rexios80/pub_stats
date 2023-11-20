import 'package:functions_framework/serve.dart';
import 'package:pub_stats_collector/functions.dart' as functions;

/// Boiler plate code for the functions framework
///
/// You could probably do some fancy things here, but this is just a simple example
Future<void> main(List<String> args) async {
  await serve(args, _nameToFunctionTarget);
}

FunctionTarget? _nameToFunctionTarget(String name) {
  switch (name) {
    case 'function':
      return FunctionTarget.http(functions.function);
    default:
      return null;
  }
}
