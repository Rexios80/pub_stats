import 'package:json_annotation/json_annotation.dart';
import 'package:pub_stats_core/src/model/package_data.dart';

part 'alert_config.g.dart';

abstract class AlertConfig {
  /// `.system`, `package`, or `publisher:name`
  final String slug;

  /// The type of alert
  final AlertType type;

  /// Fields to ignore when sending the alert
  final Set<PackageDataField> ignore;

  AlertConfig({
    required this.slug,
    required this.type,
    required this.ignore,
  });

  factory AlertConfig.fromJson(Map<String, dynamic> json) =>
      switch (AlertType.values.byName(json['type'])) {
        AlertType.discord => DiscordConfig.fromJson(json),
      };

  Map<String, dynamic> toJson();

  String get extra => switch (type) {
        AlertType.discord => (this as DiscordConfig).webhookUrl,
      };
}

enum AlertType {
  discord;

  String get extraLabel => switch (this) {
        discord => 'Webhook URL',
      };
}

abstract class AlertServiceConfig {}

@JsonSerializable()
class DiscordConfig extends AlertConfig {
  final String webhookUrl;

  DiscordConfig({
    required super.slug,
    required this.webhookUrl,
    super.type = AlertType.discord,
    super.ignore = const {},
  }) : assert(type == AlertType.discord);

  factory DiscordConfig.fromJson(Map<String, dynamic> json) =>
      _$DiscordConfigFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$DiscordConfigToJson(this);
}
