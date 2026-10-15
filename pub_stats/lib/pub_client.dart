import 'dart:convert';

import 'package:http/http.dart' as http;

const _pub = 'https://pub.dev/api';

class PubClient {
  Future<List<String>> packageNames() async {
    final response = await http.get(Uri.parse('$_pub/package-name-completion-data'));
    if (response.statusCode != 200) {
      throw Exception('Package names request failed (${response.statusCode})');
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return (json['packages'] as List).cast<String>();
  }

  Future<bool> packageExists(String name) async {
    final response = await http.get(Uri.parse('$_pub/packages/$name'));
    return response.statusCode == 200;
  }

  Future<bool> publisherExists(String name) async {
    final response = await http.get(
      Uri.parse('$_pub/search').replace(queryParameters: {'q': 'publisher:$name'}),
    );
    if (response.statusCode != 200) return false;
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final packages = json['packages'] as List? ?? const [];
    return packages.isNotEmpty;
  }
}
