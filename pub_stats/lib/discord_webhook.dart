import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

final _discordWebhookUrl = RegExp(r'https:\/\/discord\.com\/api\/webhooks\/([^/?#]+)\/([^/?#]+)');

({String id, String token})? parseDiscordWebhook(String value) {
  final match = _discordWebhookUrl.firstMatch(value.trim());
  if (match == null) return null;
  return (id: match.group(1)!, token: match.group(2)!);
}

bool isDiscordWebhook(String value) => parseDiscordWebhook(value) != null;

class DiscordTarget {
  const DiscordTarget({this.server, this.channel});

  final String? server;
  final String? channel;
}

final _cache = <String, DiscordTarget?>{};
final _pending = <String, Future<DiscordTarget?>>{};

Future<DiscordTarget?> lookupDiscordWebhook(String id, String token) {
  if (id.isEmpty || token.isEmpty) return Future.value();
  final key = '$id\u0000$token';
  if (_cache.containsKey(key)) return Future.value(_cache[key]);
  final pending = _pending[key];
  if (pending != null) return pending;

  final result = _load(key, id, token);
  _pending[key] = result;
  return result;
}

Future<DiscordTarget?> _load(String key, String id, String token) async {
  try {
    final response = await http.get(Uri.https('discord.com', '/api/webhooks/$id/$token'));
    if (response.statusCode != 200) {
      _cache[key] = null;
      return null;
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! Map) {
      _cache[key] = null;
      return null;
    }
    final json = Map<String, dynamic>.from(decoded);
    final names = await _widgetNames(_text(json['guild_id']), _text(json['channel_id']));
    final target = names.server == null && names.channel == null
        ? null
        : DiscordTarget(server: names.server, channel: names.channel);
    _cache[key] = target;
    return target;
  } on Object {
    return null;
  } finally {
    _pending.remove(key);
  }
}

/// Webhook reads include ids only. A server widget publishes the names.
Future<({String? server, String? channel})> _widgetNames(String? guildId, String? channelId) async {
  if (guildId == null) return (server: null, channel: null);
  final response = await http.get(Uri.https('discord.com', '/api/guilds/$guildId/widget.json'));
  if (response.statusCode != 200) return (server: null, channel: null);
  final decoded = jsonDecode(response.body);
  if (decoded is! Map) return (server: null, channel: null);
  final json = Map<String, dynamic>.from(decoded);
  return (server: _text(json['name']), channel: _channelName(json['channels'], channelId));
}

String? _channelName(Object? channels, String? channelId) {
  if (channelId == null || channels is! List) return null;
  for (final item in channels) {
    if (item is! Map) continue;
    final channel = Map<String, dynamic>.from(item);
    if (_text(channel['id']) != channelId) continue;
    return _text(channel['name']);
  }
  return null;
}

String? _text(Object? value) {
  if (value is String) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
  if (value is num) return value.toString();
  return null;
}
