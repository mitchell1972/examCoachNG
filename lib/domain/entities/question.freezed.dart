// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'question.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$QuestionEntity {
  String get id => throw _privateConstructorUsedError;
  String get packId => throw _privateConstructorUsedError;
  String get stem => throw _privateConstructorUsedError;
  Map<String, String> get options => throw _privateConstructorUsedError;
  String get correct => throw _privateConstructorUsedError;
  String get explanation => throw _privateConstructorUsedError;
  int get difficulty => throw _privateConstructorUsedError;
  String get syllabusNode => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $QuestionEntityCopyWith<QuestionEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QuestionEntityCopyWith<$Res> {
  factory $QuestionEntityCopyWith(
          QuestionEntity value, $Res Function(QuestionEntity) then) =
      _$QuestionEntityCopyWithImpl<$Res, QuestionEntity>;
  @useResult
  $Res call(
      {String id,
      String packId,
      String stem,
      Map<String, String> options,
      String correct,
      String explanation,
      int difficulty,
      String syllabusNode});
}

/// @nodoc
class _$QuestionEntityCopyWithImpl<$Res, $Val extends QuestionEntity>
    implements $QuestionEntityCopyWith<$Res> {
  _$QuestionEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? packId = null,
    Object? stem = null,
    Object? options = null,
    Object? correct = null,
    Object? explanation = null,
    Object? difficulty = null,
    Object? syllabusNode = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      packId: null == packId
          ? _value.packId
          : packId // ignore: cast_nullable_to_non_nullable
              as String,
      stem: null == stem
          ? _value.stem
          : stem // ignore: cast_nullable_to_non_nullable
              as String,
      options: null == options
          ? _value.options
          : options // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      correct: null == correct
          ? _value.correct
          : correct // ignore: cast_nullable_to_non_nullable
              as String,
      explanation: null == explanation
          ? _value.explanation
          : explanation // ignore: cast_nullable_to_non_nullable
              as String,
      difficulty: null == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as int,
      syllabusNode: null == syllabusNode
          ? _value.syllabusNode
          : syllabusNode // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$QuestionEntityImplCopyWith<$Res>
    implements $QuestionEntityCopyWith<$Res> {
  factory _$$QuestionEntityImplCopyWith(_$QuestionEntityImpl value,
          $Res Function(_$QuestionEntityImpl) then) =
      __$$QuestionEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String packId,
      String stem,
      Map<String, String> options,
      String correct,
      String explanation,
      int difficulty,
      String syllabusNode});
}

/// @nodoc
class __$$QuestionEntityImplCopyWithImpl<$Res>
    extends _$QuestionEntityCopyWithImpl<$Res, _$QuestionEntityImpl>
    implements _$$QuestionEntityImplCopyWith<$Res> {
  __$$QuestionEntityImplCopyWithImpl(
      _$QuestionEntityImpl _value, $Res Function(_$QuestionEntityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? packId = null,
    Object? stem = null,
    Object? options = null,
    Object? correct = null,
    Object? explanation = null,
    Object? difficulty = null,
    Object? syllabusNode = null,
  }) {
    return _then(_$QuestionEntityImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      packId: null == packId
          ? _value.packId
          : packId // ignore: cast_nullable_to_non_nullable
              as String,
      stem: null == stem
          ? _value.stem
          : stem // ignore: cast_nullable_to_non_nullable
              as String,
      options: null == options
          ? _value._options
          : options // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      correct: null == correct
          ? _value.correct
          : correct // ignore: cast_nullable_to_non_nullable
              as String,
      explanation: null == explanation
          ? _value.explanation
          : explanation // ignore: cast_nullable_to_non_nullable
              as String,
      difficulty: null == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as int,
      syllabusNode: null == syllabusNode
          ? _value.syllabusNode
          : syllabusNode // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$QuestionEntityImpl extends _QuestionEntity {
  const _$QuestionEntityImpl(
      {required this.id,
      required this.packId,
      required this.stem,
      required final Map<String, String> options,
      required this.correct,
      required this.explanation,
      required this.difficulty,
      required this.syllabusNode})
      : _options = options,
        super._();

  @override
  final String id;
  @override
  final String packId;
  @override
  final String stem;
  final Map<String, String> _options;
  @override
  Map<String, String> get options {
    if (_options is EqualUnmodifiableMapView) return _options;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_options);
  }

  @override
  final String correct;
  @override
  final String explanation;
  @override
  final int difficulty;
  @override
  final String syllabusNode;

  @override
  String toString() {
    return 'QuestionEntity(id: $id, packId: $packId, stem: $stem, options: $options, correct: $correct, explanation: $explanation, difficulty: $difficulty, syllabusNode: $syllabusNode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QuestionEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.packId, packId) || other.packId == packId) &&
            (identical(other.stem, stem) || other.stem == stem) &&
            const DeepCollectionEquality().equals(other._options, _options) &&
            (identical(other.correct, correct) || other.correct == correct) &&
            (identical(other.explanation, explanation) ||
                other.explanation == explanation) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            (identical(other.syllabusNode, syllabusNode) ||
                other.syllabusNode == syllabusNode));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      packId,
      stem,
      const DeepCollectionEquality().hash(_options),
      correct,
      explanation,
      difficulty,
      syllabusNode);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$QuestionEntityImplCopyWith<_$QuestionEntityImpl> get copyWith =>
      __$$QuestionEntityImplCopyWithImpl<_$QuestionEntityImpl>(
          this, _$identity);
}

abstract class _QuestionEntity extends QuestionEntity {
  const factory _QuestionEntity(
      {required final String id,
      required final String packId,
      required final String stem,
      required final Map<String, String> options,
      required final String correct,
      required final String explanation,
      required final int difficulty,
      required final String syllabusNode}) = _$QuestionEntityImpl;
  const _QuestionEntity._() : super._();

  @override
  String get id;
  @override
  String get packId;
  @override
  String get stem;
  @override
  Map<String, String> get options;
  @override
  String get correct;
  @override
  String get explanation;
  @override
  int get difficulty;
  @override
  String get syllabusNode;
  @override
  @JsonKey(ignore: true)
  _$$QuestionEntityImplCopyWith<_$QuestionEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$QuestionState {
  String? get selectedOption => throw _privateConstructorUsedError;
  bool get isAnswered => throw _privateConstructorUsedError;
  bool get showExplanation => throw _privateConstructorUsedError;
  DateTime? get answeredAt => throw _privateConstructorUsedError;
  int? get timeSpentMs => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $QuestionStateCopyWith<QuestionState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QuestionStateCopyWith<$Res> {
  factory $QuestionStateCopyWith(
          QuestionState value, $Res Function(QuestionState) then) =
      _$QuestionStateCopyWithImpl<$Res, QuestionState>;
  @useResult
  $Res call(
      {String? selectedOption,
      bool isAnswered,
      bool showExplanation,
      DateTime? answeredAt,
      int? timeSpentMs});
}

/// @nodoc
class _$QuestionStateCopyWithImpl<$Res, $Val extends QuestionState>
    implements $QuestionStateCopyWith<$Res> {
  _$QuestionStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? selectedOption = freezed,
    Object? isAnswered = null,
    Object? showExplanation = null,
    Object? answeredAt = freezed,
    Object? timeSpentMs = freezed,
  }) {
    return _then(_value.copyWith(
      selectedOption: freezed == selectedOption
          ? _value.selectedOption
          : selectedOption // ignore: cast_nullable_to_non_nullable
              as String?,
      isAnswered: null == isAnswered
          ? _value.isAnswered
          : isAnswered // ignore: cast_nullable_to_non_nullable
              as bool,
      showExplanation: null == showExplanation
          ? _value.showExplanation
          : showExplanation // ignore: cast_nullable_to_non_nullable
              as bool,
      answeredAt: freezed == answeredAt
          ? _value.answeredAt
          : answeredAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      timeSpentMs: freezed == timeSpentMs
          ? _value.timeSpentMs
          : timeSpentMs // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$QuestionStateImplCopyWith<$Res>
    implements $QuestionStateCopyWith<$Res> {
  factory _$$QuestionStateImplCopyWith(
          _$QuestionStateImpl value, $Res Function(_$QuestionStateImpl) then) =
      __$$QuestionStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? selectedOption,
      bool isAnswered,
      bool showExplanation,
      DateTime? answeredAt,
      int? timeSpentMs});
}

/// @nodoc
class __$$QuestionStateImplCopyWithImpl<$Res>
    extends _$QuestionStateCopyWithImpl<$Res, _$QuestionStateImpl>
    implements _$$QuestionStateImplCopyWith<$Res> {
  __$$QuestionStateImplCopyWithImpl(
      _$QuestionStateImpl _value, $Res Function(_$QuestionStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? selectedOption = freezed,
    Object? isAnswered = null,
    Object? showExplanation = null,
    Object? answeredAt = freezed,
    Object? timeSpentMs = freezed,
  }) {
    return _then(_$QuestionStateImpl(
      selectedOption: freezed == selectedOption
          ? _value.selectedOption
          : selectedOption // ignore: cast_nullable_to_non_nullable
              as String?,
      isAnswered: null == isAnswered
          ? _value.isAnswered
          : isAnswered // ignore: cast_nullable_to_non_nullable
              as bool,
      showExplanation: null == showExplanation
          ? _value.showExplanation
          : showExplanation // ignore: cast_nullable_to_non_nullable
              as bool,
      answeredAt: freezed == answeredAt
          ? _value.answeredAt
          : answeredAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      timeSpentMs: freezed == timeSpentMs
          ? _value.timeSpentMs
          : timeSpentMs // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc

class _$QuestionStateImpl extends _QuestionState {
  const _$QuestionStateImpl(
      {this.selectedOption,
      this.isAnswered = false,
      this.showExplanation = false,
      this.answeredAt,
      this.timeSpentMs})
      : super._();

  @override
  final String? selectedOption;
  @override
  @JsonKey()
  final bool isAnswered;
  @override
  @JsonKey()
  final bool showExplanation;
  @override
  final DateTime? answeredAt;
  @override
  final int? timeSpentMs;

  @override
  String toString() {
    return 'QuestionState(selectedOption: $selectedOption, isAnswered: $isAnswered, showExplanation: $showExplanation, answeredAt: $answeredAt, timeSpentMs: $timeSpentMs)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QuestionStateImpl &&
            (identical(other.selectedOption, selectedOption) ||
                other.selectedOption == selectedOption) &&
            (identical(other.isAnswered, isAnswered) ||
                other.isAnswered == isAnswered) &&
            (identical(other.showExplanation, showExplanation) ||
                other.showExplanation == showExplanation) &&
            (identical(other.answeredAt, answeredAt) ||
                other.answeredAt == answeredAt) &&
            (identical(other.timeSpentMs, timeSpentMs) ||
                other.timeSpentMs == timeSpentMs));
  }

  @override
  int get hashCode => Object.hash(runtimeType, selectedOption, isAnswered,
      showExplanation, answeredAt, timeSpentMs);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$QuestionStateImplCopyWith<_$QuestionStateImpl> get copyWith =>
      __$$QuestionStateImplCopyWithImpl<_$QuestionStateImpl>(this, _$identity);
}

abstract class _QuestionState extends QuestionState {
  const factory _QuestionState(
      {final String? selectedOption,
      final bool isAnswered,
      final bool showExplanation,
      final DateTime? answeredAt,
      final int? timeSpentMs}) = _$QuestionStateImpl;
  const _QuestionState._() : super._();

  @override
  String? get selectedOption;
  @override
  bool get isAnswered;
  @override
  bool get showExplanation;
  @override
  DateTime? get answeredAt;
  @override
  int? get timeSpentMs;
  @override
  @JsonKey(ignore: true)
  _$$QuestionStateImplCopyWith<_$QuestionStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
