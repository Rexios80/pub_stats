import 'package:firebase_js_interop/build.dart';

void main() async {
  await buildCloudFunctions(optimization: OptimizationLevel.O0);
}
