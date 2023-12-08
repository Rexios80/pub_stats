// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: require_trailing_commas

part of 'diff.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StringDiff _$StringDiffFromJson(Map<String, dynamic> json) => StringDiff(
      json['before'] as Object,
      json['after'] as Object,
    );

Map<String, dynamic> _$StringDiffToJson(StringDiff instance) =>
    <String, dynamic>{
      'before': instance.before,
      'after': instance.after,
    };

SetDiff _$SetDiffFromJson(Map<String, dynamic> json) => SetDiff._(
      added:
          (json['added'] as List<dynamic>?)?.map((e) => e as Object).toSet() ??
              const {},
      removed: (json['removed'] as List<dynamic>?)
              ?.map((e) => e as Object)
              .toSet() ??
          const {},
    );

Map<String, dynamic> _$SetDiffToJson(SetDiff instance) => <String, dynamic>{
      'added': instance.added.toList(),
      'removed': instance.removed.toList(),
    };
