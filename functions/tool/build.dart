import 'package:firebase_js_interop/build.dart';

void main(List<String> args) async {
  final debug = args.contains('--debug');
  await buildCloudFunctions(
    optimization: debug ? OptimizationLevel.O1 : OptimizationLevel.O2,
  );
}
