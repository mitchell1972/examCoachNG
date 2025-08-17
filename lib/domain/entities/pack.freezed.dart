// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pack.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$PackEntity {
  String get id => throw _privateConstructorUsedError;
  String get subject => throw _privateConstructorUsedError;
  String get topic => throw _privateConstructorUsedError;
  int get version => throw _privateConstructorUsedError;
  int get sizeBytes => throw _privateConstructorUsedError;
  DateTime? get installedAt => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $PackEntityCopyWith<PackEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PackEntityCopyWith<$Res> {
  factory $PackEntityCopyWith(
          PackEntity value, $Res Function(PackEntity) then) =
      _$PackEntityCopyWithImpl<$Res, PackEntity>;
  @useResult
  $Res call(
      {String id,
      String subject,
      String topic,
      int version,
      int sizeBytes,
      DateTime? installedAt});
}

/// @nodoc
class _$PackEntityCopyWithImpl<$Res, $Val extends PackEntity>
    implements $PackEntityCopyWith<$Res> {
  _$PackEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? subject = null,
    Object? topic = null,
    Object? version = null,
    Object? sizeBytes = null,
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
      installedAt: freezed == installedAt
          ? _value.installedAt
          : installedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PackEntityImplCopyWith<$Res>
    implements $PackEntityCopyWith<$Res> {
  factory _$$PackEntityImplCopyWith(
          _$PackEntityImpl value, $Res Function(_$PackEntityImpl) then) =
      __$$PackEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String subject,
      String topic,
      int version,
      int sizeBytes,
      DateTime? installedAt});
}

/// @nodoc
class __$$PackEntityImplCopyWithImpl<$Res>
    extends _$PackEntityCopyWithImpl<$Res, _$PackEntityImpl>
    implements _$$PackEntityImplCopyWith<$Res> {
  __$$PackEntityImplCopyWithImpl(
      _$PackEntityImpl _value, $Res Function(_$PackEntityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? subject = null,
    Object? topic = null,
    Object? version = null,
    Object? sizeBytes = null,
    Object? installedAt = freezed,
  }) {
    return _then(_$PackEntityImpl(
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
      installedAt: freezed == installedAt
          ? _value.installedAt
          : installedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc

class _$PackEntityImpl extends _PackEntity {
  const _$PackEntityImpl(
      {required this.id,
      required this.subject,
      required this.topic,
      required this.version,
      required this.sizeBytes,
      this.installedAt})
      : super._();

  @override
  final String id;
  @override
  final String subject;
  @override
  final String topic;
  @override
  final int version;
  @override
  final int sizeBytes;
  @override
  final DateTime? installedAt;

  @override
  String toString() {
    return 'PackEntity(id: $id, subject: $subject, topic: $topic, version: $version, sizeBytes: $sizeBytes, installedAt: $installedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PackEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.subject, subject) || other.subject == subject) &&
            (identical(other.topic, topic) || other.topic == topic) &&
            (identical(other.version, version) || other.version == version) &&
            (identical(other.sizeBytes, sizeBytes) ||
                other.sizeBytes == sizeBytes) &&
            (identical(other.installedAt, installedAt) ||
                other.installedAt == installedAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, id, subject, topic, version, sizeBytes, installedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PackEntityImplCopyWith<_$PackEntityImpl> get copyWith =>
      __$$PackEntityImplCopyWithImpl<_$PackEntityImpl>(this, _$identity);
}

abstract class _PackEntity extends PackEntity {
  const factory _PackEntity(
      {required final String id,
      required final String subject,
      required final String topic,
      required final int version,
      required final int sizeBytes,
      final DateTime? installedAt}) = _$PackEntityImpl;
  const _PackEntity._() : super._();

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
  DateTime? get installedAt;
  @override
  @JsonKey(ignore: true)
  _$$PackEntityImplCopyWith<_$PackEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$PackManifestItem {
  String get id => throw _privateConstructorUsedError;
  String get subject => throw _privateConstructorUsedError;
  String get topic => throw _privateConstructorUsedError;
  int get version => throw _privateConstructorUsedError;
  int get sizeBytes => throw _privateConstructorUsedError;
  String? get checksum => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $PackManifestItemCopyWith<PackManifestItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PackManifestItemCopyWith<$Res> {
  factory $PackManifestItemCopyWith(
          PackManifestItem value, $Res Function(PackManifestItem) then) =
      _$PackManifestItemCopyWithImpl<$Res, PackManifestItem>;
  @useResult
  $Res call(
      {String id,
      String subject,
      String topic,
      int version,
      int sizeBytes,
      String? checksum});
}

/// @nodoc
class _$PackManifestItemCopyWithImpl<$Res, $Val extends PackManifestItem>
    implements $PackManifestItemCopyWith<$Res> {
  _$PackManifestItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? subject = null,
    Object? topic = null,
    Object? version = null,
    Object? sizeBytes = null,
    Object? checksum = freezed,
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
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PackManifestItemImplCopyWith<$Res>
    implements $PackManifestItemCopyWith<$Res> {
  factory _$$PackManifestItemImplCopyWith(_$PackManifestItemImpl value,
          $Res Function(_$PackManifestItemImpl) then) =
      __$$PackManifestItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String subject,
      String topic,
      int version,
      int sizeBytes,
      String? checksum});
}

/// @nodoc
class __$$PackManifestItemImplCopyWithImpl<$Res>
    extends _$PackManifestItemCopyWithImpl<$Res, _$PackManifestItemImpl>
    implements _$$PackManifestItemImplCopyWith<$Res> {
  __$$PackManifestItemImplCopyWithImpl(_$PackManifestItemImpl _value,
      $Res Function(_$PackManifestItemImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? subject = null,
    Object? topic = null,
    Object? version = null,
    Object? sizeBytes = null,
    Object? checksum = freezed,
  }) {
    return _then(_$PackManifestItemImpl(
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
    ));
  }
}

/// @nodoc

class _$PackManifestItemImpl extends _PackManifestItem {
  const _$PackManifestItemImpl(
      {required this.id,
      required this.subject,
      required this.topic,
      required this.version,
      required this.sizeBytes,
      this.checksum})
      : super._();

  @override
  final String id;
  @override
  final String subject;
  @override
  final String topic;
  @override
  final int version;
  @override
  final int sizeBytes;
  @override
  final String? checksum;

  @override
  String toString() {
    return 'PackManifestItem(id: $id, subject: $subject, topic: $topic, version: $version, sizeBytes: $sizeBytes, checksum: $checksum)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PackManifestItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.subject, subject) || other.subject == subject) &&
            (identical(other.topic, topic) || other.topic == topic) &&
            (identical(other.version, version) || other.version == version) &&
            (identical(other.sizeBytes, sizeBytes) ||
                other.sizeBytes == sizeBytes) &&
            (identical(other.checksum, checksum) ||
                other.checksum == checksum));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, id, subject, topic, version, sizeBytes, checksum);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PackManifestItemImplCopyWith<_$PackManifestItemImpl> get copyWith =>
      __$$PackManifestItemImplCopyWithImpl<_$PackManifestItemImpl>(
          this, _$identity);
}

abstract class _PackManifestItem extends PackManifestItem {
  const factory _PackManifestItem(
      {required final String id,
      required final String subject,
      required final String topic,
      required final int version,
      required final int sizeBytes,
      final String? checksum}) = _$PackManifestItemImpl;
  const _PackManifestItem._() : super._();

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
  @JsonKey(ignore: true)
  _$$PackManifestItemImplCopyWith<_$PackManifestItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$PackDownloadState {
  bool get isDownloading => throw _privateConstructorUsedError;
  double get progress => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $PackDownloadStateCopyWith<PackDownloadState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PackDownloadStateCopyWith<$Res> {
  factory $PackDownloadStateCopyWith(
          PackDownloadState value, $Res Function(PackDownloadState) then) =
      _$PackDownloadStateCopyWithImpl<$Res, PackDownloadState>;
  @useResult
  $Res call({bool isDownloading, double progress, String? error});
}

/// @nodoc
class _$PackDownloadStateCopyWithImpl<$Res, $Val extends PackDownloadState>
    implements $PackDownloadStateCopyWith<$Res> {
  _$PackDownloadStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isDownloading = null,
    Object? progress = null,
    Object? error = freezed,
  }) {
    return _then(_value.copyWith(
      isDownloading: null == isDownloading
          ? _value.isDownloading
          : isDownloading // ignore: cast_nullable_to_non_nullable
              as bool,
      progress: null == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as double,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PackDownloadStateImplCopyWith<$Res>
    implements $PackDownloadStateCopyWith<$Res> {
  factory _$$PackDownloadStateImplCopyWith(_$PackDownloadStateImpl value,
          $Res Function(_$PackDownloadStateImpl) then) =
      __$$PackDownloadStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool isDownloading, double progress, String? error});
}

/// @nodoc
class __$$PackDownloadStateImplCopyWithImpl<$Res>
    extends _$PackDownloadStateCopyWithImpl<$Res, _$PackDownloadStateImpl>
    implements _$$PackDownloadStateImplCopyWith<$Res> {
  __$$PackDownloadStateImplCopyWithImpl(_$PackDownloadStateImpl _value,
      $Res Function(_$PackDownloadStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isDownloading = null,
    Object? progress = null,
    Object? error = freezed,
  }) {
    return _then(_$PackDownloadStateImpl(
      isDownloading: null == isDownloading
          ? _value.isDownloading
          : isDownloading // ignore: cast_nullable_to_non_nullable
              as bool,
      progress: null == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as double,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$PackDownloadStateImpl implements _PackDownloadState {
  const _$PackDownloadStateImpl(
      {this.isDownloading = false, this.progress = 0.0, this.error});

  @override
  @JsonKey()
  final bool isDownloading;
  @override
  @JsonKey()
  final double progress;
  @override
  final String? error;

  @override
  String toString() {
    return 'PackDownloadState(isDownloading: $isDownloading, progress: $progress, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PackDownloadStateImpl &&
            (identical(other.isDownloading, isDownloading) ||
                other.isDownloading == isDownloading) &&
            (identical(other.progress, progress) ||
                other.progress == progress) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, isDownloading, progress, error);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PackDownloadStateImplCopyWith<_$PackDownloadStateImpl> get copyWith =>
      __$$PackDownloadStateImplCopyWithImpl<_$PackDownloadStateImpl>(
          this, _$identity);
}

abstract class _PackDownloadState implements PackDownloadState {
  const factory _PackDownloadState(
      {final bool isDownloading,
      final double progress,
      final String? error}) = _$PackDownloadStateImpl;

  @override
  bool get isDownloading;
  @override
  double get progress;
  @override
  String? get error;
  @override
  @JsonKey(ignore: true)
  _$$PackDownloadStateImplCopyWith<_$PackDownloadStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
