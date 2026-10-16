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

class DiscordWebhook {
  const DiscordWebhook({required this.name, required this.avatarUrl, required this.typeLabel, required this.lines});

  final String? name;
  final String? avatarUrl;
  final String typeLabel;
  final List<DiscordWebhookLine> lines;

  factory DiscordWebhook.fromJson(Map<String, dynamic> json) {
    final channelId = _text(json['channel_id']);
    final guildId = _text(json['guild_id']);
    final sourceChannel = _place(json['source_channel']);
    final sourceGuild = _place(json['source_guild']);
    return DiscordWebhook(
      name: _text(json['name']),
      avatarUrl: _avatarUrl(_text(json['id']), _text(json['avatar'])),
      typeLabel: _typeLabel(json['type']),
      lines: [
        if (channelId != null) DiscordWebhookLine('Channel $channelId', href: _discordUrl(guildId, channelId)),
        if (guildId != null) DiscordWebhookLine('Server $guildId', href: _discordUrl(guildId, null)),
        if (_text(json['application_id']) case final application?) DiscordWebhookLine('App $application'),
        ..._sourceLines(sourceChannel, sourceGuild),
      ],
    );
  }
}

class DiscordWebhookLine {
  const DiscordWebhookLine(this.text, {this.href});

  final String text;
  final String? href;
}

class _Place {
  const _Place({this.id, this.name});

  final String? id;
  final String? name;
}

final _cached = <String, DiscordWebhook?>{};
final _pending = <String, Future<DiscordWebhook?>>{};

// Discord allows a handful of webhook reads per second.
var _tail = Future<void>.value();

({bool hit, DiscordWebhook? webhook})? cachedDiscordWebhook(String id, String token) {
  final key = _key(id, token);
  if (!_cached.containsKey(key)) return null;
  return (hit: true, webhook: _cached[key]);
}

Future<DiscordWebhook?> lookupDiscordWebhook(String id, String token) {
  if (id.isEmpty || token.isEmpty) return Future.value();
  final key = _key(id, token);
  if (_cached.containsKey(key)) return Future.value(_cached[key]);
  final pending = _pending[key];
  if (pending != null) return pending;

  final result = _tail.then((_) => _readWebhook(key, id, token));
  _pending[key] = result;
  _tail = result.then((_) {}, onError: (_) {});
  return result;
}

Future<DiscordWebhook?> _readWebhook(String key, String id, String token) async {
  try {
    final read = await _fetchWebhook(id, token);
    if (read.remember) _cached[key] = read.webhook;
    return read.webhook;
  } on Object {
    return null;
  } finally {
    _pending.remove(key);
  }
}

Future<({DiscordWebhook? webhook, bool remember})> _fetchWebhook(String id, String token) async {
  final response = await _getWebhook(id, token);
  if (response == null) return (webhook: null, remember: false);
  if (response.statusCode == 429) return (webhook: null, remember: false);
  if (response.statusCode != 200) return (webhook: null, remember: true);
  final decoded = jsonDecode(response.body);
  if (decoded is! Map) return (webhook: null, remember: false);
  final json = Map<String, dynamic>.from(decoded);
  return (webhook: DiscordWebhook.fromJson(json), remember: true);
}

Future<http.Response?> _getWebhook(String id, String token) async {
  for (var attempt = 0; attempt < 3; attempt++) {
    final response = await http.get(_webhookUri(id, token));
    if (response.statusCode != 429 || attempt == 2) return response;
    final wait = int.tryParse(response.headers['retry-after'] ?? '') ?? 1;
    await Future<void>.delayed(Duration(seconds: wait.clamp(1, 5)));
  }
  return null;
}

Uri _webhookUri(String id, String token) {
  return Uri(scheme: 'https', host: 'discord.com', pathSegments: ['api', 'webhooks', id, token]);
}

String _key(String id, String token) => '$id\u0000$token';

final _snowflake = RegExp(r'^[0-9]{1,20}$');
final _avatarHash = RegExp(r'^(?:a_)?[0-9a-fA-F]+$');

String? _discordUrl(String? guildId, String? channelId) {
  if (guildId == null || !_snowflake.hasMatch(guildId)) return null;
  if (channelId == null) return 'https://discord.com/channels/$guildId';
  if (!_snowflake.hasMatch(channelId)) return null;
  return 'https://discord.com/channels/$guildId/$channelId';
}

String? _avatarUrl(String? id, String? avatar) {
  if (id == null || avatar == null) return null;
  if (!_snowflake.hasMatch(id) || !_avatarHash.hasMatch(avatar)) return null;
  final ext = avatar.startsWith('a_') ? 'gif' : 'png';
  return 'https://cdn.discordapp.com/avatars/$id/$avatar.$ext?size=32';
}

String _typeLabel(Object? value) => switch (value) {
  1 => 'Incoming',
  2 => 'Channel follower',
  3 => 'Application',
  _ => 'Webhook',
};

String? _text(Object? value) {
  if (value is String) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
  if (value is num) return value.toString();
  return null;
}

_Place? _place(Object? value) {
  if (value is! Map) return null;
  final json = Map<String, dynamic>.from(value);
  final place = _Place(id: _text(json['id']), name: _text(json['name']));
  if (place.id == null && place.name == null) return null;
  return place;
}

List<DiscordWebhookLine> _sourceLines(_Place? channel, _Place? guild) {
  final lines = <DiscordWebhookLine>[];
  final channelText = _member(channel, hash: true);
  if (channel != null && channelText != null) {
    final text = channel.name == null ? 'Source channel $channelText' : 'Following $channelText';
    lines.add(DiscordWebhookLine(text, href: _discordUrl(guild?.id, channel.id)));
  }
  final guildText = _member(guild, hash: false);
  if (guild != null && guildText != null) {
    final text = guild.name == null ? 'Source server $guildText' : 'From $guildText';
    lines.add(DiscordWebhookLine(text, href: guild.id == null ? null : _discordUrl(guild.id, null)));
  }
  return lines;
}

String? _member(_Place? place, {required bool hash}) {
  if (place == null) return null;
  final name = place.name;
  final id = place.id;
  if (name == null) return id;
  final shown = hash ? '#$name' : name;
  if (id == null) return shown;
  return '$shown ($id)';
}
