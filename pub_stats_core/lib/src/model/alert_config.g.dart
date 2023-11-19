// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: require_trailing_commas

part of 'alert_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DiscordConfig _$DiscordConfigFromJson(Map<String, dynamic> json) =>
    DiscordConfig(
      slug: json['slug'] as String,
      webhookUrl: json['webhookUrl'] as String,
      type: $enumDecodeNullable(_$AlertTypeEnumMap, json['type']) ??
          AlertType.discord,
    );

Map<String, dynamic> _$DiscordConfigToJson(DiscordConfig instance) =>
    <String, dynamic>{
      'slug': instance.slug,
      'type': _$AlertTypeEnumMap[instance.type]!,
      'webhookUrl': instance.webhookUrl,
    };

const _$AlertTypeEnumMap = {
  AlertType.discord: 'discord',
};
