// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: require_trailing_commas

part of 'alert_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DiscordAlertConfig _$DiscordAlertConfigFromJson(Map<String, dynamic> json) =>
    DiscordAlertConfig(
      slug: json['slug'] as String,
      ignore: (json['ignore'] as List<dynamic>?)
              ?.map((e) => $enumDecode(_$PackageDataFieldEnumMap, e))
              .toSet() ??
          const {},
      id: json['id'] as String,
      token: json['token'] as String,
      type: $enumDecodeNullable(_$AlertConfigTypeEnumMap, json['type']) ??
          AlertConfigType.discord,
    );

Map<String, dynamic> _$DiscordAlertConfigToJson(DiscordAlertConfig instance) =>
    <String, dynamic>{
      'slug': instance.slug,
      'ignore':
          instance.ignore.map((e) => _$PackageDataFieldEnumMap[e]!).toList(),
      'type': _$AlertConfigTypeEnumMap[instance.type]!,
      'id': instance.id,
      'token': instance.token,
    };

const _$PackageDataFieldEnumMap = {
  PackageDataField.publisher: 'publisher',
  PackageDataField.version: 'version',
  PackageDataField.likeCount: 'likeCount',
  PackageDataField.popularityScore: 'popularityScore',
  PackageDataField.isDiscontinued: 'isDiscontinued',
  PackageDataField.isUnlisted: 'isUnlisted',
  PackageDataField.dependents: 'dependents',
};

const _$AlertConfigTypeEnumMap = {
  AlertConfigType.discord: 'discord',
};
