import 'package:json_annotation/json_annotation.dart';
import 'package:pub_stats_core/src/model/package_data.dart';

part 'alert_config.g.dart';

abstract class AlertConfig {
  /// `.system`, `package`, or `publisher:name`
  final String slug;

  /// Fields to ignore when sending the alert
  final Set<PackageDataField> ignore;

  /// The type of alert
  final AlertConfigType type;

  AlertConfig({
    required this.slug,
    this.ignore = const {},
    required this.type,
  });

  factory AlertConfig.fromJson(Map<String, dynamic> json) =>
      switch (AlertConfigType.values.byName(json['type'])) {
        AlertConfigType.discord => DiscordAlertConfig.fromJson(json),
      };

  Map<String, dynamic> toJson();

  String get extra => switch (type) {
        AlertConfigType.discord => (this as DiscordAlertConfig).id,
      };
}

enum AlertConfigType {
  discord;

  String get extraLabel => switch (this) {
        discord => 'Webhook URL',
      };
}

abstract class AlertServiceConfig {}

@JsonSerializable()
class DiscordAlertConfig extends AlertConfig {
  final String id;
  final String token;

  DiscordAlertConfig({
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
}
