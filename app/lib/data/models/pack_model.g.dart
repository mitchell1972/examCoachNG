// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pack_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PackModelImpl _$$PackModelImplFromJson(Map<String, dynamic> json) =>
    _$PackModelImpl(
      id: json['id'] as String,
      subject: json['subject'] as String,
      topic: json['topic'] as String,
      version: (json['version'] as num).toInt(),
      sizeBytes: (json['sizeBytes'] as num?)?.toInt() ?? 0,
      checksum: json['checksum'] as String?,
      installedAt: json['installedAt'] == null
          ? null
          : DateTime.parse(json['installedAt'] as String),
    );

Map<String, dynamic> _$$PackModelImplToJson(_$PackModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'subject': instance.subject,
      'topic': instance.topic,
      'version': instance.version,
      'sizeBytes': instance.sizeBytes,
      'checksum': instance.checksum,
      'installedAt': instance.installedAt?.toIso8601String(),
    };
