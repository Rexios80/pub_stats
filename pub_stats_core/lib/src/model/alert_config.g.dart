// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: require_trailing_commas

part of 'alert_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DiscordConfig _$DiscordConfigFromJson(Map<String, dynamic> json) =>
    DiscordConfig(
      slug: json['slug'] as String,
      ignore: (json['ignore'] as List<dynamic>?)
              ?.map((e) => $enumDecode(_$PackageDataFieldEnumMap, e))
              .toSet() ??
          const {},
      id: json['id'] as String,
      token: json['token'] as String,
      type: $enumDecodeNullable(_$AlertTypeEnumMap, json['type']) ??
          AlertType.discord,
    );

Map<String, dynamic> _$DiscordConfigToJson(DiscordConfig instance) =>
    <String, dynamic>{
      'slug': instance.slug,
      'ignore':
          instance.ignore.map((e) => _$PackageDataFieldEnumMap[e]!).toList(),
      'type': _$AlertTypeEnumMap[instance.type]!,
      'id': instance.id,
      'token': instance.token,
    };

const _$PackageDataFieldEnumMap = {
  PackageDataField.likeCount: 'likeCount',
  PackageDataField.popularityScore: 'popularityScore',
  PackageDataField.pubPoints: 'pubPoints',
};

const _$AlertTypeEnumMap = {
  AlertType.discord: 'discord',
};
