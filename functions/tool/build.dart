import 'package:firebase_js_interop/build.dart';

void main(List<String> args) async {
  final debug = args.contains('--debug');
  final optimization = debug ? OptimizationLevel.O1 : OptimizationLevel.O2;
  await buildCloudFunctions(optimization: optimization);
  await buildCloudFunctions(
    optimization: optimization,
    input: 'tool/src/restore_backup.dart',
    output: 'tool/lib/restore_backup.js',
  );
}
