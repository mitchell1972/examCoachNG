// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pack_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PackModel _$PackModelFromJson(Map<String, dynamic> json) {
  return _PackModel.fromJson(json);
}

/// @nodoc
mixin _$PackModel {
  String get id => throw _privateConstructorUsedError;
  String get subject => throw _privateConstructorUsedError;
  String get topic => throw _privateConstructorUsedError;
  int get version => throw _privateConstructorUsedError;
  int get sizeBytes => throw _privateConstructorUsedError;
  String? get checksum => throw _privateConstructorUsedError;
  DateTime? get installedAt => throw _privateConstructorUsedError;

  /// Serializes this PackModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PackModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PackModelCopyWith<PackModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PackModelCopyWith<$Res> {
  factory $PackModelCopyWith(PackModel value, $Res Function(PackModel) then) =
      _$PackModelCopyWithImpl<$Res, PackModel>;
  @useResult
  $Res call(
      {String id,
      String subject,
      String topic,
      int version,
      int sizeBytes,
      String? checksum,
      DateTime? installedAt});
}

/// @nodoc
class _$PackModelCopyWithImpl<$Res, $Val extends PackModel>
    implements $PackModelCopyWith<$Res> {
  _$PackModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PackModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? subject = null,
    Object? topic = null,
    Object? version = null,
    Object? sizeBytes = null,
    Object? checksum = freezed,
    Object? installedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      subject: null == subject
          ? _value.subject
          : subject // ignore: cast_nullable_to_non_nullable
              as String,
      topic: null == topic
          ? _value.topic
          : topic // ignore: cast_nullable_to_non_nullable
              as String,
      version: null == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as int,
      sizeBytes: null == sizeBytes
          ? _value.sizeBytes
          : sizeBytes // ignore: cast_nullable_to_non_nullable
              as int,
      checksum: freezed == checksum
          ? _value.checksum
          : checksum // ignore: cast_nullable_to_non_nullable
              as String?,
      installedAt: freezed == installedAt
          ? _value.installedAt
          : installedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PackModelImplCopyWith<$Res>
    implements $PackModelCopyWith<$Res> {
  factory _$$PackModelImplCopyWith(
          _$PackModelImpl value, $Res Function(_$PackModelImpl) then) =
      __$$PackModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String subject,
      String topic,
      int version,
      int sizeBytes,
      String? checksum,
      DateTime? installedAt});
}

/// @nodoc
class __$$PackModelImplCopyWithImpl<$Res>
    extends _$PackModelCopyWithImpl<$Res, _$PackModelImpl>
    implements _$$PackModelImplCopyWith<$Res> {
  __$$PackModelImplCopyWithImpl(
      _$PackModelImpl _value, $Res Function(_$PackModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of PackModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? subject = null,
    Object? topic = null,
    Object? version = null,
    Object? sizeBytes = null,
    Object? checksum = freezed,
    Object? installedAt = freezed,
  }) {
    return _then(_$PackModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      subject: null == subject
          ? _value.subject
          : subject // ignore: cast_nullable_to_non_nullable
              as String,
      topic: null == topic
          ? _value.topic
          : topic // ignore: cast_nullable_to_non_nullable
              as String,
      version: null == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as int,
      sizeBytes: null == sizeBytes
          ? _value.sizeBytes
          : sizeBytes // ignore: cast_nullable_to_non_nullable
              as int,
      checksum: freezed == checksum
          ? _value.checksum
          : checksum // ignore: cast_nullable_to_non_nullable
              as String?,
      installedAt: freezed == installedAt
          ? _value.installedAt
          : installedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PackModelImpl implements _PackModel {
  const _$PackModelImpl(
      {required this.id,
      required this.subject,
      required this.topic,
      required this.version,
      this.sizeBytes = 0,
      this.checksum,
      this.installedAt});

  factory _$PackModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PackModelImplFromJson(json);

  @override
  final String id;
  @override
  final String subject;
  @override
  final String topic;
  @override
  final int version;
  @override
  @JsonKey()
  final int sizeBytes;
  @override
  final String? checksum;
  @override
  final DateTime? installedAt;

  @override
  String toString() {
    return 'PackModel(id: $id, subject: $subject, topic: $topic, version: $version, sizeBytes: $sizeBytes, checksum: $checksum, installedAt: $installedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PackModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.subject, subject) || other.subject == subject) &&
            (identical(other.topic, topic) || other.topic == topic) &&
            (identical(other.version, version) || other.version == version) &&
            (identical(other.sizeBytes, sizeBytes) ||
                other.sizeBytes == sizeBytes) &&
            (identical(other.checksum, checksum) ||
                other.checksum == checksum) &&
            (identical(other.installedAt, installedAt) ||
                other.installedAt == installedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, subject, topic, version,
      sizeBytes, checksum, installedAt);

  /// Create a copy of PackModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PackModelImplCopyWith<_$PackModelImpl> get copyWith =>
      __$$PackModelImplCopyWithImpl<_$PackModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PackModelImplToJson(
      this,
    );
  }
}

abstract class _PackModel implements PackModel {
  const factory _PackModel(
      {required final String id,
      required final String subject,
      required final String topic,
      required final int version,
      final int sizeBytes,
      final String? checksum,
      final DateTime? installedAt}) = _$PackModelImpl;

  factory _PackModel.fromJson(Map<String, dynamic> json) =
      _$PackModelImpl.fromJson;

  @override
  String get id;
  @override
  String get subject;
  @override
  String get topic;
  @override
  int get version;
  @override
  int get sizeBytes;
  @override
  String? get checksum;
  @override
  DateTime? get installedAt;

  /// Create a copy of PackModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PackModelImplCopyWith<_$PackModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
