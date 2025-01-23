import 'dart:js_interop';

import 'package:firebase_js_interop/node.dart';

@anonymous
extension type SourceMapSupport._(JSObject _) implements JSObject {
  external void install();
}

final sourceMapSupport = require('source-map-support') as SourceMapSupport;
