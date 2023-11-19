import 'package:json_annotation/json_annotation.dart';

part 'alert_config.g.dart';

abstract class AlertConfig {
  /// `.system`, `package`, or `publisher:name`
  final String slug;
  final AlertType type;

  AlertConfig({
    required this.slug,
    required this.type,
  });

  factory AlertConfig.fromJson(Map<String, dynamic> json) =>
      switch (AlertType.values.byName(json['type'])) {
        AlertType.discord => DiscordConfig.fromJson(json),
      };

  Map<String, dynamic> toJson();
}

enum AlertType {
  discord,
}

@JsonSerializable()
class DiscordConfig extends AlertConfig {
  final String webhookUrl;

  DiscordConfig({
    required super.slug,
    required this.webhookUrl,
    super.type = AlertType.discord,
  }) : assert(type == AlertType.discord);

  factory DiscordConfig.fromJson(Map<String, dynamic> json) =>
      _$DiscordConfigFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$DiscordConfigToJson(this);
}
