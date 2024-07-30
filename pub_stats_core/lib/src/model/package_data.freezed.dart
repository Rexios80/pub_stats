// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'package_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PackageData _$PackageDataFromJson(Map<String, dynamic> json) {
  return _PackageData.fromJson(json);
}

/// @nodoc
mixin _$PackageData {
  @JsonKey(name: 'p')
  String? get publisher => throw _privateConstructorUsedError;
  @JsonKey(name: 'v')
  String get version => throw _privateConstructorUsedError;
  @JsonKey(name: 'lc')
  int get likeCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'ps')
  int get popularityScore => throw _privateConstructorUsedError;
  @JsonKey(name: 'id')
  bool get isDiscontinued => throw _privateConstructorUsedError;
  @JsonKey(name: 'iu')
  bool get isUnlisted => throw _privateConstructorUsedError;
  @JsonKey(name: 'iff')
  bool get isFlutterFavorite => throw _privateConstructorUsedError;
  @JsonKey(name: 'd')
  Set<String> get dependents => throw _privateConstructorUsedError;
  @JsonKey(name: 'n')
  int get overallRank => throw _privateConstructorUsedError;

  /// Serializes this PackageData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PackageData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PackageDataCopyWith<PackageData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PackageDataCopyWith<$Res> {
  factory $PackageDataCopyWith(
          PackageData value, $Res Function(PackageData) then) =
      _$PackageDataCopyWithImpl<$Res, PackageData>;
  @useResult
  $Res call(
      {@JsonKey(name: 'p') String? publisher,
      @JsonKey(name: 'v') String version,
      @JsonKey(name: 'lc') int likeCount,
      @JsonKey(name: 'ps') int popularityScore,
      @JsonKey(name: 'id') bool isDiscontinued,
      @JsonKey(name: 'iu') bool isUnlisted,
      @JsonKey(name: 'iff') bool isFlutterFavorite,
      @JsonKey(name: 'd') Set<String> dependents,
      @JsonKey(name: 'n') int overallRank});
}

/// @nodoc
class _$PackageDataCopyWithImpl<$Res, $Val extends PackageData>
    implements $PackageDataCopyWith<$Res> {
  _$PackageDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PackageData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? publisher = freezed,
    Object? version = null,
    Object? likeCount = null,
    Object? popularityScore = null,
    Object? isDiscontinued = null,
    Object? isUnlisted = null,
    Object? isFlutterFavorite = null,
    Object? dependents = null,
    Object? overallRank = null,
  }) {
    return _then(_value.copyWith(
      publisher: freezed == publisher
          ? _value.publisher
          : publisher // ignore: cast_nullable_to_non_nullable
              as String?,
      version: null == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as String,
      likeCount: null == likeCount
          ? _value.likeCount
          : likeCount // ignore: cast_nullable_to_non_nullable
              as int,
      popularityScore: null == popularityScore
          ? _value.popularityScore
          : popularityScore // ignore: cast_nullable_to_non_nullable
              as int,
      isDiscontinued: null == isDiscontinued
          ? _value.isDiscontinued
          : isDiscontinued // ignore: cast_nullable_to_non_nullable
              as bool,
      isUnlisted: null == isUnlisted
          ? _value.isUnlisted
          : isUnlisted // ignore: cast_nullable_to_non_nullable
              as bool,
      isFlutterFavorite: null == isFlutterFavorite
          ? _value.isFlutterFavorite
          : isFlutterFavorite // ignore: cast_nullable_to_non_nullable
              as bool,
      dependents: null == dependents
          ? _value.dependents
          : dependents // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      overallRank: null == overallRank
          ? _value.overallRank
          : overallRank // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PackageDataImplCopyWith<$Res>
    implements $PackageDataCopyWith<$Res> {
  factory _$$PackageDataImplCopyWith(
          _$PackageDataImpl value, $Res Function(_$PackageDataImpl) then) =
      __$$PackageDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'p') String? publisher,
      @JsonKey(name: 'v') String version,
      @JsonKey(name: 'lc') int likeCount,
      @JsonKey(name: 'ps') int popularityScore,
      @JsonKey(name: 'id') bool isDiscontinued,
      @JsonKey(name: 'iu') bool isUnlisted,
      @JsonKey(name: 'iff') bool isFlutterFavorite,
      @JsonKey(name: 'd') Set<String> dependents,
      @JsonKey(name: 'n') int overallRank});
}

/// @nodoc
class __$$PackageDataImplCopyWithImpl<$Res>
    extends _$PackageDataCopyWithImpl<$Res, _$PackageDataImpl>
    implements _$$PackageDataImplCopyWith<$Res> {
  __$$PackageDataImplCopyWithImpl(
      _$PackageDataImpl _value, $Res Function(_$PackageDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of PackageData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? publisher = freezed,
    Object? version = null,
    Object? likeCount = null,
    Object? popularityScore = null,
    Object? isDiscontinued = null,
    Object? isUnlisted = null,
    Object? isFlutterFavorite = null,
    Object? dependents = null,
    Object? overallRank = null,
  }) {
    return _then(_$PackageDataImpl(
      publisher: freezed == publisher
          ? _value.publisher
          : publisher // ignore: cast_nullable_to_non_nullable
              as String?,
      version: null == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as String,
      likeCount: null == likeCount
          ? _value.likeCount
          : likeCount // ignore: cast_nullable_to_non_nullable
              as int,
      popularityScore: null == popularityScore
          ? _value.popularityScore
          : popularityScore // ignore: cast_nullable_to_non_nullable
              as int,
      isDiscontinued: null == isDiscontinued
          ? _value.isDiscontinued
          : isDiscontinued // ignore: cast_nullable_to_non_nullable
              as bool,
      isUnlisted: null == isUnlisted
          ? _value.isUnlisted
          : isUnlisted // ignore: cast_nullable_to_non_nullable
              as bool,
      isFlutterFavorite: null == isFlutterFavorite
          ? _value.isFlutterFavorite
          : isFlutterFavorite // ignore: cast_nullable_to_non_nullable
              as bool,
      dependents: null == dependents
          ? _value._dependents
          : dependents // ignore: cast_nullable_to_non_nullable
              as Set<String>,
      overallRank: null == overallRank
          ? _value.overallRank
          : overallRank // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PackageDataImpl extends _PackageData {
  const _$PackageDataImpl(
      {@JsonKey(name: 'p') this.publisher,
      @JsonKey(name: 'v') required this.version,
      @JsonKey(name: 'lc') required this.likeCount,
      @JsonKey(name: 'ps') required this.popularityScore,
      @JsonKey(name: 'id') required this.isDiscontinued,
      @JsonKey(name: 'iu') required this.isUnlisted,
      @JsonKey(name: 'iff') required this.isFlutterFavorite,
      @JsonKey(name: 'd') final Set<String> dependents = const {},
      @JsonKey(name: 'n') this.overallRank = -1})
      : _dependents = dependents,
        super._();

  factory _$PackageDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$PackageDataImplFromJson(json);

  @override
  @JsonKey(name: 'p')
  final String? publisher;
  @override
  @JsonKey(name: 'v')
  final String version;
  @override
  @JsonKey(name: 'lc')
  final int likeCount;
  @override
  @JsonKey(name: 'ps')
  final int popularityScore;
  @override
  @JsonKey(name: 'id')
  final bool isDiscontinued;
  @override
  @JsonKey(name: 'iu')
  final bool isUnlisted;
  @override
  @JsonKey(name: 'iff')
  final bool isFlutterFavorite;
  final Set<String> _dependents;
  @override
  @JsonKey(name: 'd')
  Set<String> get dependents {
    if (_dependents is EqualUnmodifiableSetView) return _dependents;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_dependents);
  }

  @override
  @JsonKey(name: 'n')
  final int overallRank;

  @override
  String toString() {
    return 'PackageData(publisher: $publisher, version: $version, likeCount: $likeCount, popularityScore: $popularityScore, isDiscontinued: $isDiscontinued, isUnlisted: $isUnlisted, isFlutterFavorite: $isFlutterFavorite, dependents: $dependents, overallRank: $overallRank)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PackageDataImpl &&
            (identical(other.publisher, publisher) ||
                other.publisher == publisher) &&
            (identical(other.version, version) || other.version == version) &&
            (identical(other.likeCount, likeCount) ||
                other.likeCount == likeCount) &&
            (identical(other.popularityScore, popularityScore) ||
                other.popularityScore == popularityScore) &&
            (identical(other.isDiscontinued, isDiscontinued) ||
                other.isDiscontinued == isDiscontinued) &&
            (identical(other.isUnlisted, isUnlisted) ||
                other.isUnlisted == isUnlisted) &&
            (identical(other.isFlutterFavorite, isFlutterFavorite) ||
                other.isFlutterFavorite == isFlutterFavorite) &&
            const DeepCollectionEquality()
                .equals(other._dependents, _dependents) &&
            (identical(other.overallRank, overallRank) ||
                other.overallRank == overallRank));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      publisher,
      version,
      likeCount,
      popularityScore,
      isDiscontinued,
      isUnlisted,
      isFlutterFavorite,
      const DeepCollectionEquality().hash(_dependents),
      overallRank);

  /// Create a copy of PackageData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PackageDataImplCopyWith<_$PackageDataImpl> get copyWith =>
      __$$PackageDataImplCopyWithImpl<_$PackageDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PackageDataImplToJson(
      this,
    );
  }
}

abstract class _PackageData extends PackageData {
  const factory _PackageData(
      {@JsonKey(name: 'p') final String? publisher,
      @JsonKey(name: 'v') required final String version,
      @JsonKey(name: 'lc') required final int likeCount,
      @JsonKey(name: 'ps') required final int popularityScore,
      @JsonKey(name: 'id') required final bool isDiscontinued,
      @JsonKey(name: 'iu') required final bool isUnlisted,
      @JsonKey(name: 'iff') required final bool isFlutterFavorite,
      @JsonKey(name: 'd') final Set<String> dependents,
      @JsonKey(name: 'n') final int overallRank}) = _$PackageDataImpl;
  const _PackageData._() : super._();

  factory _PackageData.fromJson(Map<String, dynamic> json) =
      _$PackageDataImpl.fromJson;

  @override
  @JsonKey(name: 'p')
  String? get publisher;
  @override
  @JsonKey(name: 'v')
  String get version;
  @override
  @JsonKey(name: 'lc')
  int get likeCount;
  @override
  @JsonKey(name: 'ps')
  int get popularityScore;
  @override
  @JsonKey(name: 'id')
  bool get isDiscontinued;
  @override
  @JsonKey(name: 'iu')
  bool get isUnlisted;
  @override
  @JsonKey(name: 'iff')
  bool get isFlutterFavorite;
  @override
  @JsonKey(name: 'd')
  Set<String> get dependents;
  @override
  @JsonKey(name: 'n')
  int get overallRank;

  /// Create a copy of PackageData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PackageDataImplCopyWith<_$PackageDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
