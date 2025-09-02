// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'package_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PackageData {

@JsonKey(name: 'p') String? get publisher;@JsonKey(name: 'v') String get version;@JsonKey(name: 'lc') int get likeCount;@JsonKey(name: 'ps') int? get legacyPopularityScore;@JsonKey(name: 'ps2') int? get popularityScore;@JsonKey(name: 'dc') int? get downloadCount;@JsonKey(name: 'id') bool get isDiscontinued;@JsonKey(name: 'iu') bool get isUnlisted;@JsonKey(name: 'iff') bool get isFlutterFavorite;@JsonKey(name: 'd') Set<String> get dependents;@JsonKey(name: 'n') int? get overallRank;// Store this separately to save bandwidth when creating badges
@JsonKey(name: 'nd') int? get numDependents;
/// Create a copy of PackageData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PackageDataCopyWith<PackageData> get copyWith => _$PackageDataCopyWithImpl<PackageData>(this as PackageData, _$identity);

  /// Serializes this PackageData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PackageData&&(identical(other.publisher, publisher) || other.publisher == publisher)&&(identical(other.version, version) || other.version == version)&&(identical(other.likeCount, likeCount) || other.likeCount == likeCount)&&(identical(other.legacyPopularityScore, legacyPopularityScore) || other.legacyPopularityScore == legacyPopularityScore)&&(identical(other.popularityScore, popularityScore) || other.popularityScore == popularityScore)&&(identical(other.downloadCount, downloadCount) || other.downloadCount == downloadCount)&&(identical(other.isDiscontinued, isDiscontinued) || other.isDiscontinued == isDiscontinued)&&(identical(other.isUnlisted, isUnlisted) || other.isUnlisted == isUnlisted)&&(identical(other.isFlutterFavorite, isFlutterFavorite) || other.isFlutterFavorite == isFlutterFavorite)&&const DeepCollectionEquality().equals(other.dependents, dependents)&&(identical(other.overallRank, overallRank) || other.overallRank == overallRank)&&(identical(other.numDependents, numDependents) || other.numDependents == numDependents));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,publisher,version,likeCount,legacyPopularityScore,popularityScore,downloadCount,isDiscontinued,isUnlisted,isFlutterFavorite,const DeepCollectionEquality().hash(dependents),overallRank,numDependents);

@override
String toString() {
  return 'PackageData(publisher: $publisher, version: $version, likeCount: $likeCount, legacyPopularityScore: $legacyPopularityScore, popularityScore: $popularityScore, downloadCount: $downloadCount, isDiscontinued: $isDiscontinued, isUnlisted: $isUnlisted, isFlutterFavorite: $isFlutterFavorite, dependents: $dependents, overallRank: $overallRank, numDependents: $numDependents)';
}


}

/// @nodoc
abstract mixin class $PackageDataCopyWith<$Res>  {
  factory $PackageDataCopyWith(PackageData value, $Res Function(PackageData) _then) = _$PackageDataCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'p') String? publisher,@JsonKey(name: 'v') String version,@JsonKey(name: 'lc') int likeCount,@JsonKey(name: 'ps') int? legacyPopularityScore,@JsonKey(name: 'ps2') int? popularityScore,@JsonKey(name: 'dc') int? downloadCount,@JsonKey(name: 'id') bool isDiscontinued,@JsonKey(name: 'iu') bool isUnlisted,@JsonKey(name: 'iff') bool isFlutterFavorite,@JsonKey(name: 'd') Set<String> dependents,@JsonKey(name: 'n') int? overallRank,@JsonKey(name: 'nd') int? numDependents
});




}
/// @nodoc
class _$PackageDataCopyWithImpl<$Res>
    implements $PackageDataCopyWith<$Res> {
  _$PackageDataCopyWithImpl(this._self, this._then);

  final PackageData _self;
  final $Res Function(PackageData) _then;

/// Create a copy of PackageData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? publisher = freezed,Object? version = null,Object? likeCount = null,Object? legacyPopularityScore = freezed,Object? popularityScore = freezed,Object? downloadCount = freezed,Object? isDiscontinued = null,Object? isUnlisted = null,Object? isFlutterFavorite = null,Object? dependents = null,Object? overallRank = freezed,Object? numDependents = freezed,}) {
  return _then(_self.copyWith(
publisher: freezed == publisher ? _self.publisher : publisher // ignore: cast_nullable_to_non_nullable
as String?,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,likeCount: null == likeCount ? _self.likeCount : likeCount // ignore: cast_nullable_to_non_nullable
as int,legacyPopularityScore: freezed == legacyPopularityScore ? _self.legacyPopularityScore : legacyPopularityScore // ignore: cast_nullable_to_non_nullable
as int?,popularityScore: freezed == popularityScore ? _self.popularityScore : popularityScore // ignore: cast_nullable_to_non_nullable
as int?,downloadCount: freezed == downloadCount ? _self.downloadCount : downloadCount // ignore: cast_nullable_to_non_nullable
as int?,isDiscontinued: null == isDiscontinued ? _self.isDiscontinued : isDiscontinued // ignore: cast_nullable_to_non_nullable
as bool,isUnlisted: null == isUnlisted ? _self.isUnlisted : isUnlisted // ignore: cast_nullable_to_non_nullable
as bool,isFlutterFavorite: null == isFlutterFavorite ? _self.isFlutterFavorite : isFlutterFavorite // ignore: cast_nullable_to_non_nullable
as bool,dependents: null == dependents ? _self.dependents : dependents // ignore: cast_nullable_to_non_nullable
as Set<String>,overallRank: freezed == overallRank ? _self.overallRank : overallRank // ignore: cast_nullable_to_non_nullable
as int?,numDependents: freezed == numDependents ? _self.numDependents : numDependents // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [PackageData].
extension PackageDataPatterns on PackageData {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PackageData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PackageData() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PackageData value)  $default,){
final _that = this;
switch (_that) {
case _PackageData():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PackageData value)?  $default,){
final _that = this;
switch (_that) {
case _PackageData() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'p')  String? publisher, @JsonKey(name: 'v')  String version, @JsonKey(name: 'lc')  int likeCount, @JsonKey(name: 'ps')  int? legacyPopularityScore, @JsonKey(name: 'ps2')  int? popularityScore, @JsonKey(name: 'dc')  int? downloadCount, @JsonKey(name: 'id')  bool isDiscontinued, @JsonKey(name: 'iu')  bool isUnlisted, @JsonKey(name: 'iff')  bool isFlutterFavorite, @JsonKey(name: 'd')  Set<String> dependents, @JsonKey(name: 'n')  int? overallRank, @JsonKey(name: 'nd')  int? numDependents)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PackageData() when $default != null:
return $default(_that.publisher,_that.version,_that.likeCount,_that.legacyPopularityScore,_that.popularityScore,_that.downloadCount,_that.isDiscontinued,_that.isUnlisted,_that.isFlutterFavorite,_that.dependents,_that.overallRank,_that.numDependents);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'p')  String? publisher, @JsonKey(name: 'v')  String version, @JsonKey(name: 'lc')  int likeCount, @JsonKey(name: 'ps')  int? legacyPopularityScore, @JsonKey(name: 'ps2')  int? popularityScore, @JsonKey(name: 'dc')  int? downloadCount, @JsonKey(name: 'id')  bool isDiscontinued, @JsonKey(name: 'iu')  bool isUnlisted, @JsonKey(name: 'iff')  bool isFlutterFavorite, @JsonKey(name: 'd')  Set<String> dependents, @JsonKey(name: 'n')  int? overallRank, @JsonKey(name: 'nd')  int? numDependents)  $default,) {final _that = this;
switch (_that) {
case _PackageData():
return $default(_that.publisher,_that.version,_that.likeCount,_that.legacyPopularityScore,_that.popularityScore,_that.downloadCount,_that.isDiscontinued,_that.isUnlisted,_that.isFlutterFavorite,_that.dependents,_that.overallRank,_that.numDependents);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'p')  String? publisher, @JsonKey(name: 'v')  String version, @JsonKey(name: 'lc')  int likeCount, @JsonKey(name: 'ps')  int? legacyPopularityScore, @JsonKey(name: 'ps2')  int? popularityScore, @JsonKey(name: 'dc')  int? downloadCount, @JsonKey(name: 'id')  bool isDiscontinued, @JsonKey(name: 'iu')  bool isUnlisted, @JsonKey(name: 'iff')  bool isFlutterFavorite, @JsonKey(name: 'd')  Set<String> dependents, @JsonKey(name: 'n')  int? overallRank, @JsonKey(name: 'nd')  int? numDependents)?  $default,) {final _that = this;
switch (_that) {
case _PackageData() when $default != null:
return $default(_that.publisher,_that.version,_that.likeCount,_that.legacyPopularityScore,_that.popularityScore,_that.downloadCount,_that.isDiscontinued,_that.isUnlisted,_that.isFlutterFavorite,_that.dependents,_that.overallRank,_that.numDependents);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PackageData extends PackageData {
  const _PackageData({@JsonKey(name: 'p') this.publisher, @JsonKey(name: 'v') required this.version, @JsonKey(name: 'lc') required this.likeCount, @JsonKey(name: 'ps') required this.legacyPopularityScore, @JsonKey(name: 'ps2') this.popularityScore, @JsonKey(name: 'dc') required this.downloadCount, @JsonKey(name: 'id') required this.isDiscontinued, @JsonKey(name: 'iu') required this.isUnlisted, @JsonKey(name: 'iff') required this.isFlutterFavorite, @JsonKey(name: 'd') final  Set<String> dependents = const {}, @JsonKey(name: 'n') this.overallRank, @JsonKey(name: 'nd') this.numDependents}): _dependents = dependents,super._();
  factory _PackageData.fromJson(Map<String, dynamic> json) => _$PackageDataFromJson(json);

@override@JsonKey(name: 'p') final  String? publisher;
@override@JsonKey(name: 'v') final  String version;
@override@JsonKey(name: 'lc') final  int likeCount;
@override@JsonKey(name: 'ps') final  int? legacyPopularityScore;
@override@JsonKey(name: 'ps2') final  int? popularityScore;
@override@JsonKey(name: 'dc') final  int? downloadCount;
@override@JsonKey(name: 'id') final  bool isDiscontinued;
@override@JsonKey(name: 'iu') final  bool isUnlisted;
@override@JsonKey(name: 'iff') final  bool isFlutterFavorite;
 final  Set<String> _dependents;
@override@JsonKey(name: 'd') Set<String> get dependents {
  if (_dependents is EqualUnmodifiableSetView) return _dependents;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_dependents);
}

@override@JsonKey(name: 'n') final  int? overallRank;
// Store this separately to save bandwidth when creating badges
@override@JsonKey(name: 'nd') final  int? numDependents;

/// Create a copy of PackageData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PackageDataCopyWith<_PackageData> get copyWith => __$PackageDataCopyWithImpl<_PackageData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PackageDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PackageData&&(identical(other.publisher, publisher) || other.publisher == publisher)&&(identical(other.version, version) || other.version == version)&&(identical(other.likeCount, likeCount) || other.likeCount == likeCount)&&(identical(other.legacyPopularityScore, legacyPopularityScore) || other.legacyPopularityScore == legacyPopularityScore)&&(identical(other.popularityScore, popularityScore) || other.popularityScore == popularityScore)&&(identical(other.downloadCount, downloadCount) || other.downloadCount == downloadCount)&&(identical(other.isDiscontinued, isDiscontinued) || other.isDiscontinued == isDiscontinued)&&(identical(other.isUnlisted, isUnlisted) || other.isUnlisted == isUnlisted)&&(identical(other.isFlutterFavorite, isFlutterFavorite) || other.isFlutterFavorite == isFlutterFavorite)&&const DeepCollectionEquality().equals(other._dependents, _dependents)&&(identical(other.overallRank, overallRank) || other.overallRank == overallRank)&&(identical(other.numDependents, numDependents) || other.numDependents == numDependents));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,publisher,version,likeCount,legacyPopularityScore,popularityScore,downloadCount,isDiscontinued,isUnlisted,isFlutterFavorite,const DeepCollectionEquality().hash(_dependents),overallRank,numDependents);

@override
String toString() {
  return 'PackageData(publisher: $publisher, version: $version, likeCount: $likeCount, legacyPopularityScore: $legacyPopularityScore, popularityScore: $popularityScore, downloadCount: $downloadCount, isDiscontinued: $isDiscontinued, isUnlisted: $isUnlisted, isFlutterFavorite: $isFlutterFavorite, dependents: $dependents, overallRank: $overallRank, numDependents: $numDependents)';
}


}

/// @nodoc
abstract mixin class _$PackageDataCopyWith<$Res> implements $PackageDataCopyWith<$Res> {
  factory _$PackageDataCopyWith(_PackageData value, $Res Function(_PackageData) _then) = __$PackageDataCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'p') String? publisher,@JsonKey(name: 'v') String version,@JsonKey(name: 'lc') int likeCount,@JsonKey(name: 'ps') int? legacyPopularityScore,@JsonKey(name: 'ps2') int? popularityScore,@JsonKey(name: 'dc') int? downloadCount,@JsonKey(name: 'id') bool isDiscontinued,@JsonKey(name: 'iu') bool isUnlisted,@JsonKey(name: 'iff') bool isFlutterFavorite,@JsonKey(name: 'd') Set<String> dependents,@JsonKey(name: 'n') int? overallRank,@JsonKey(name: 'nd') int? numDependents
});




}
/// @nodoc
class __$PackageDataCopyWithImpl<$Res>
    implements _$PackageDataCopyWith<$Res> {
  __$PackageDataCopyWithImpl(this._self, this._then);

  final _PackageData _self;
  final $Res Function(_PackageData) _then;

/// Create a copy of PackageData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? publisher = freezed,Object? version = null,Object? likeCount = null,Object? legacyPopularityScore = freezed,Object? popularityScore = freezed,Object? downloadCount = freezed,Object? isDiscontinued = null,Object? isUnlisted = null,Object? isFlutterFavorite = null,Object? dependents = null,Object? overallRank = freezed,Object? numDependents = freezed,}) {
  return _then(_PackageData(
publisher: freezed == publisher ? _self.publisher : publisher // ignore: cast_nullable_to_non_nullable
as String?,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,likeCount: null == likeCount ? _self.likeCount : likeCount // ignore: cast_nullable_to_non_nullable
as int,legacyPopularityScore: freezed == legacyPopularityScore ? _self.legacyPopularityScore : legacyPopularityScore // ignore: cast_nullable_to_non_nullable
as int?,popularityScore: freezed == popularityScore ? _self.popularityScore : popularityScore // ignore: cast_nullable_to_non_nullable
as int?,downloadCount: freezed == downloadCount ? _self.downloadCount : downloadCount // ignore: cast_nullable_to_non_nullable
as int?,isDiscontinued: null == isDiscontinued ? _self.isDiscontinued : isDiscontinued // ignore: cast_nullable_to_non_nullable
as bool,isUnlisted: null == isUnlisted ? _self.isUnlisted : isUnlisted // ignore: cast_nullable_to_non_nullable
as bool,isFlutterFavorite: null == isFlutterFavorite ? _self.isFlutterFavorite : isFlutterFavorite // ignore: cast_nullable_to_non_nullable
as bool,dependents: null == dependents ? _self._dependents : dependents // ignore: cast_nullable_to_non_nullable
as Set<String>,overallRank: freezed == overallRank ? _self.overallRank : overallRank // ignore: cast_nullable_to_non_nullable
as int?,numDependents: freezed == numDependents ? _self.numDependents : numDependents // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
