// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$SessionEntity {
  String get id => throw _privateConstructorUsedError;
  String get mode => throw _privateConstructorUsedError;
  String get subject => throw _privateConstructorUsedError;
  String? get topic => throw _privateConstructorUsedError;
  DateTime get startedAt => throw _privateConstructorUsedError;
  DateTime? get endedAt => throw _privateConstructorUsedError;
  int? get score => throw _privateConstructorUsedError;
  List<String> get questionIds => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $SessionEntityCopyWith<SessionEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SessionEntityCopyWith<$Res> {
  factory $SessionEntityCopyWith(
          SessionEntity value, $Res Function(SessionEntity) then) =
      _$SessionEntityCopyWithImpl<$Res, SessionEntity>;
  @useResult
  $Res call(
      {String id,
      String mode,
      String subject,
      String? topic,
      DateTime startedAt,
      DateTime? endedAt,
      int? score,
      List<String> questionIds});
}

/// @nodoc
class _$SessionEntityCopyWithImpl<$Res, $Val extends SessionEntity>
    implements $SessionEntityCopyWith<$Res> {
  _$SessionEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? mode = null,
    Object? subject = null,
    Object? topic = freezed,
    Object? startedAt = null,
    Object? endedAt = freezed,
    Object? score = freezed,
    Object? questionIds = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      mode: null == mode
          ? _value.mode
          : mode // ignore: cast_nullable_to_non_nullable
              as String,
      subject: null == subject
          ? _value.subject
          : subject // ignore: cast_nullable_to_non_nullable
              as String,
      topic: freezed == topic
          ? _value.topic
          : topic // ignore: cast_nullable_to_non_nullable
              as String?,
      startedAt: null == startedAt
          ? _value.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endedAt: freezed == endedAt
          ? _value.endedAt
          : endedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      score: freezed == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as int?,
      questionIds: null == questionIds
          ? _value.questionIds
          : questionIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SessionEntityImplCopyWith<$Res>
    implements $SessionEntityCopyWith<$Res> {
  factory _$$SessionEntityImplCopyWith(
          _$SessionEntityImpl value, $Res Function(_$SessionEntityImpl) then) =
      __$$SessionEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String mode,
      String subject,
      String? topic,
      DateTime startedAt,
      DateTime? endedAt,
      int? score,
      List<String> questionIds});
}

/// @nodoc
class __$$SessionEntityImplCopyWithImpl<$Res>
    extends _$SessionEntityCopyWithImpl<$Res, _$SessionEntityImpl>
    implements _$$SessionEntityImplCopyWith<$Res> {
  __$$SessionEntityImplCopyWithImpl(
      _$SessionEntityImpl _value, $Res Function(_$SessionEntityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? mode = null,
    Object? subject = null,
    Object? topic = freezed,
    Object? startedAt = null,
    Object? endedAt = freezed,
    Object? score = freezed,
    Object? questionIds = null,
  }) {
    return _then(_$SessionEntityImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      mode: null == mode
          ? _value.mode
          : mode // ignore: cast_nullable_to_non_nullable
              as String,
      subject: null == subject
          ? _value.subject
          : subject // ignore: cast_nullable_to_non_nullable
              as String,
      topic: freezed == topic
          ? _value.topic
          : topic // ignore: cast_nullable_to_non_nullable
              as String?,
      startedAt: null == startedAt
          ? _value.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endedAt: freezed == endedAt
          ? _value.endedAt
          : endedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      score: freezed == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as int?,
      questionIds: null == questionIds
          ? _value._questionIds
          : questionIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc

class _$SessionEntityImpl extends _SessionEntity {
  const _$SessionEntityImpl(
      {required this.id,
      required this.mode,
      required this.subject,
      this.topic,
      required this.startedAt,
      this.endedAt,
      this.score,
      required final List<String> questionIds})
      : _questionIds = questionIds,
        super._();

  @override
  final String id;
  @override
  final String mode;
  @override
  final String subject;
  @override
  final String? topic;
  @override
  final DateTime startedAt;
  @override
  final DateTime? endedAt;
  @override
  final int? score;
  final List<String> _questionIds;
  @override
  List<String> get questionIds {
    if (_questionIds is EqualUnmodifiableListView) return _questionIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_questionIds);
  }

  @override
  String toString() {
    return 'SessionEntity(id: $id, mode: $mode, subject: $subject, topic: $topic, startedAt: $startedAt, endedAt: $endedAt, score: $score, questionIds: $questionIds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SessionEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.mode, mode) || other.mode == mode) &&
            (identical(other.subject, subject) || other.subject == subject) &&
            (identical(other.topic, topic) || other.topic == topic) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.endedAt, endedAt) || other.endedAt == endedAt) &&
            (identical(other.score, score) || other.score == score) &&
            const DeepCollectionEquality()
                .equals(other._questionIds, _questionIds));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      mode,
      subject,
      topic,
      startedAt,
      endedAt,
      score,
      const DeepCollectionEquality().hash(_questionIds));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SessionEntityImplCopyWith<_$SessionEntityImpl> get copyWith =>
      __$$SessionEntityImplCopyWithImpl<_$SessionEntityImpl>(this, _$identity);
}

abstract class _SessionEntity extends SessionEntity {
  const factory _SessionEntity(
      {required final String id,
      required final String mode,
      required final String subject,
      final String? topic,
      required final DateTime startedAt,
      final DateTime? endedAt,
      final int? score,
      required final List<String> questionIds}) = _$SessionEntityImpl;
  const _SessionEntity._() : super._();

  @override
  String get id;
  @override
  String get mode;
  @override
  String get subject;
  @override
  String? get topic;
  @override
  DateTime get startedAt;
  @override
  DateTime? get endedAt;
  @override
  int? get score;
  @override
  List<String> get questionIds;
  @override
  @JsonKey(ignore: true)
  _$$SessionEntityImplCopyWith<_$SessionEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$SessionProgress {
  int get currentIndex => throw _privateConstructorUsedError;
  int get totalQuestions => throw _privateConstructorUsedError;
  List<String> get answeredQuestions => throw _privateConstructorUsedError;
  List<String> get flaggedQuestions => throw _privateConstructorUsedError;
  DateTime? get startTime => throw _privateConstructorUsedError;
  Duration? get timeLimit => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $SessionProgressCopyWith<SessionProgress> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SessionProgressCopyWith<$Res> {
  factory $SessionProgressCopyWith(
          SessionProgress value, $Res Function(SessionProgress) then) =
      _$SessionProgressCopyWithImpl<$Res, SessionProgress>;
  @useResult
  $Res call(
      {int currentIndex,
      int totalQuestions,
      List<String> answeredQuestions,
      List<String> flaggedQuestions,
      DateTime? startTime,
      Duration? timeLimit});
}

/// @nodoc
class _$SessionProgressCopyWithImpl<$Res, $Val extends SessionProgress>
    implements $SessionProgressCopyWith<$Res> {
  _$SessionProgressCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentIndex = null,
    Object? totalQuestions = null,
    Object? answeredQuestions = null,
    Object? flaggedQuestions = null,
    Object? startTime = freezed,
    Object? timeLimit = freezed,
  }) {
    return _then(_value.copyWith(
      currentIndex: null == currentIndex
          ? _value.currentIndex
          : currentIndex // ignore: cast_nullable_to_non_nullable
              as int,
      totalQuestions: null == totalQuestions
          ? _value.totalQuestions
          : totalQuestions // ignore: cast_nullable_to_non_nullable
              as int,
      answeredQuestions: null == answeredQuestions
          ? _value.answeredQuestions
          : answeredQuestions // ignore: cast_nullable_to_non_nullable
              as List<String>,
      flaggedQuestions: null == flaggedQuestions
          ? _value.flaggedQuestions
          : flaggedQuestions // ignore: cast_nullable_to_non_nullable
              as List<String>,
      startTime: freezed == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      timeLimit: freezed == timeLimit
          ? _value.timeLimit
          : timeLimit // ignore: cast_nullable_to_non_nullable
              as Duration?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SessionProgressImplCopyWith<$Res>
    implements $SessionProgressCopyWith<$Res> {
  factory _$$SessionProgressImplCopyWith(_$SessionProgressImpl value,
          $Res Function(_$SessionProgressImpl) then) =
      __$$SessionProgressImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int currentIndex,
      int totalQuestions,
      List<String> answeredQuestions,
      List<String> flaggedQuestions,
      DateTime? startTime,
      Duration? timeLimit});
}

/// @nodoc
class __$$SessionProgressImplCopyWithImpl<$Res>
    extends _$SessionProgressCopyWithImpl<$Res, _$SessionProgressImpl>
    implements _$$SessionProgressImplCopyWith<$Res> {
  __$$SessionProgressImplCopyWithImpl(
      _$SessionProgressImpl _value, $Res Function(_$SessionProgressImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentIndex = null,
    Object? totalQuestions = null,
    Object? answeredQuestions = null,
    Object? flaggedQuestions = null,
    Object? startTime = freezed,
    Object? timeLimit = freezed,
  }) {
    return _then(_$SessionProgressImpl(
      currentIndex: null == currentIndex
          ? _value.currentIndex
          : currentIndex // ignore: cast_nullable_to_non_nullable
              as int,
      totalQuestions: null == totalQuestions
          ? _value.totalQuestions
          : totalQuestions // ignore: cast_nullable_to_non_nullable
              as int,
      answeredQuestions: null == answeredQuestions
          ? _value._answeredQuestions
          : answeredQuestions // ignore: cast_nullable_to_non_nullable
              as List<String>,
      flaggedQuestions: null == flaggedQuestions
          ? _value._flaggedQuestions
          : flaggedQuestions // ignore: cast_nullable_to_non_nullable
              as List<String>,
      startTime: freezed == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      timeLimit: freezed == timeLimit
          ? _value.timeLimit
          : timeLimit // ignore: cast_nullable_to_non_nullable
              as Duration?,
    ));
  }
}

/// @nodoc

class _$SessionProgressImpl extends _SessionProgress {
  const _$SessionProgressImpl(
      {required this.currentIndex,
      required this.totalQuestions,
      required final List<String> answeredQuestions,
      required final List<String> flaggedQuestions,
      this.startTime,
      this.timeLimit})
      : _answeredQuestions = answeredQuestions,
        _flaggedQuestions = flaggedQuestions,
        super._();

  @override
  final int currentIndex;
  @override
  final int totalQuestions;
  final List<String> _answeredQuestions;
  @override
  List<String> get answeredQuestions {
    if (_answeredQuestions is EqualUnmodifiableListView)
      return _answeredQuestions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_answeredQuestions);
  }

  final List<String> _flaggedQuestions;
  @override
  List<String> get flaggedQuestions {
    if (_flaggedQuestions is EqualUnmodifiableListView)
      return _flaggedQuestions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_flaggedQuestions);
  }

  @override
  final DateTime? startTime;
  @override
  final Duration? timeLimit;

  @override
  String toString() {
    return 'SessionProgress(currentIndex: $currentIndex, totalQuestions: $totalQuestions, answeredQuestions: $answeredQuestions, flaggedQuestions: $flaggedQuestions, startTime: $startTime, timeLimit: $timeLimit)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SessionProgressImpl &&
            (identical(other.currentIndex, currentIndex) ||
                other.currentIndex == currentIndex) &&
            (identical(other.totalQuestions, totalQuestions) ||
                other.totalQuestions == totalQuestions) &&
            const DeepCollectionEquality()
                .equals(other._answeredQuestions, _answeredQuestions) &&
            const DeepCollectionEquality()
                .equals(other._flaggedQuestions, _flaggedQuestions) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.timeLimit, timeLimit) ||
                other.timeLimit == timeLimit));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      currentIndex,
      totalQuestions,
      const DeepCollectionEquality().hash(_answeredQuestions),
      const DeepCollectionEquality().hash(_flaggedQuestions),
      startTime,
      timeLimit);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SessionProgressImplCopyWith<_$SessionProgressImpl> get copyWith =>
      __$$SessionProgressImplCopyWithImpl<_$SessionProgressImpl>(
          this, _$identity);
}

abstract class _SessionProgress extends SessionProgress {
  const factory _SessionProgress(
      {required final int currentIndex,
      required final int totalQuestions,
      required final List<String> answeredQuestions,
      required final List<String> flaggedQuestions,
      final DateTime? startTime,
      final Duration? timeLimit}) = _$SessionProgressImpl;
  const _SessionProgress._() : super._();

  @override
  int get currentIndex;
  @override
  int get totalQuestions;
  @override
  List<String> get answeredQuestions;
  @override
  List<String> get flaggedQuestions;
  @override
  DateTime? get startTime;
  @override
  Duration? get timeLimit;
  @override
  @JsonKey(ignore: true)
  _$$SessionProgressImplCopyWith<_$SessionProgressImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
