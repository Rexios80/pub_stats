import 'dart:js_interop';

import 'package:firebase_js_interop/node.dart';

@anonymous
extension type BadgeFormat._(JSObject _) implements JSObject {
  external factory BadgeFormat({
    // (Optional) Badge label
    String? label,
    // (Required) Badge message
    required String message,
    // (Optional) Label color
    String? labelColor,
    // (Optional) Message color
    String? color,
    // (Optional) Any custom logo can be passed in a URL parameter by base64 encoding
    String? logoBase64,
    // (Optional) Links array of maximum two links
    JSArray<JSString>? links,
    // (Optional) One of: 'plastic', 'flat', 'flat-square', 'for-the-badge' or 'social'
    // Each offers a different visual design.
    String? style,
    // (Optional) A string with only letters, numbers, -, and _. This can be used
    // to ensure every element id within the SVG is unique and prevent CSS
    // cross-contamination when the SVG badge is rendered inline in HTML pages.
    String? idSuffix,
  });
}

extension type BadgeMaker._(JSObject _) implements JSObject {
  external String makeBadge(BadgeFormat format);
}

final badgeMaker = require('badge-maker') as BadgeMaker;
