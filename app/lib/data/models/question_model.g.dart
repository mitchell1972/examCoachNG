// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$QuestionModelImpl _$$QuestionModelImplFromJson(Map<String, dynamic> json) =>
    _$QuestionModelImpl(
      id: json['id'] as String,
      packId: json['packId'] as String,
      stem: json['stem'] as String,
      a: json['a'] as String,
      b: json['b'] as String,
      c: json['c'] as String,
      d: json['d'] as String,
      correct: json['correct'] as String,
      explanation: json['explanation'] as String,
      difficulty: (json['difficulty'] as num?)?.toInt() ?? 2,
      syllabusNode: json['syllabusNode'] as String,
    );

Map<String, dynamic> _$$QuestionModelImplToJson(_$QuestionModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'packId': instance.packId,
      'stem': instance.stem,
      'a': instance.a,
      'b': instance.b,
      'c': instance.c,
      'd': instance.d,
      'correct': instance.correct,
      'explanation': instance.explanation,
      'difficulty': instance.difficulty,
      'syllabusNode': instance.syllabusNode,
    };
