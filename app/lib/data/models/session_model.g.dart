// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SessionModelImpl _$$SessionModelImplFromJson(Map<String, dynamic> json) =>
    _$SessionModelImpl(
      id: json['id'] as String,
      mode: $enumDecode(_$SessionModeEnumMap, json['mode']),
      subject: json['subject'] as String,
      topic: json['topic'] as String?,
      startedAt: DateTime.parse(json['startedAt'] as String),
      endedAt: json['endedAt'] == null
          ? null
          : DateTime.parse(json['endedAt'] as String),
      duration: json['duration'] == null
          ? null
          : Duration(microseconds: (json['duration'] as num).toInt()),
      score: (json['score'] as num?)?.toInt(),
      questions: (json['questions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      meta: json['meta'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$SessionModelImplToJson(_$SessionModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'mode': _$SessionModeEnumMap[instance.mode]!,
      'subject': instance.subject,
      'topic': instance.topic,
      'startedAt': instance.startedAt.toIso8601String(),
      'endedAt': instance.endedAt?.toIso8601String(),
      'duration': instance.duration?.inMicroseconds,
      'score': instance.score,
      'questions': instance.questions,
      'meta': instance.meta,
    };

const _$SessionModeEnumMap = {
  SessionMode.practice: 'practice',
  SessionMode.mock: 'mock',
};
