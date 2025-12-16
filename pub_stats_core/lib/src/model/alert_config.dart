import 'package:json_annotation/json_annotation.dart';
import 'package:pub_stats_core/src/model/package_data.dart';
import 'package:meta/meta.dart';

part 'alert_config.g.dart';

@immutable
sealed class AlertConfig {
  /// `.system`, `package`, or `publisher:name`
  final String slug;

  /// Fields to ignore when sending the alert
  final Set<PackageDataField> ignore;

  /// The type of alert
  final AlertConfigType type;

  const AlertConfig({
    required this.slug,
    this.ignore = const {},
    required this.type,
  });

  factory AlertConfig.fromJson(Map<String, dynamic> json) =>
      switch (AlertConfigType.values.byName(json['type'])) {
        AlertConfigType.discord => DiscordAlertConfig.fromJson(json),
        AlertConfigType.telegram => TelegramAlertConfig.fromJson(json),
      };

  Map<String, dynamic> toJson();

  String get extra;
}

enum AlertConfigType {
  discord,
  telegram;

  String get extraLabel => switch (this) {
    discord => 'Webhook URL',
    telegram => 'Chat ID',
  };
}

@JsonSerializable()
class DiscordAlertConfig extends AlertConfig {
  final String id;
  final String token;

  const DiscordAlertConfig({
    required super.slug,
    super.ignore,
    required this.id,
    required this.token,
    super.type = AlertConfigType.discord,
  }) : assert(type == AlertConfigType.discord);

  factory DiscordAlertConfig.fromJson(Map<String, dynamic> json) =>
      _$DiscordAlertConfigFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$DiscordAlertConfigToJson(this);

  @override
  String get extra => id;
}

@JsonSerializable()
class TelegramAlertConfig extends AlertConfig {
  final String chatId;

  const TelegramAlertConfig({
    required super.slug,
    super.ignore,
    required this.chatId,
    super.type = AlertConfigType.telegram,
  }) : assert(type == AlertConfigType.telegram);

  factory TelegramAlertConfig.fromJson(Map<String, dynamic> json) =>
      _$TelegramAlertConfigFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$TelegramAlertConfigToJson(this);

  @override
  String get extra => chatId;
}
