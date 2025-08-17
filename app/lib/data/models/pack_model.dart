import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/pack.dart' as domain;

part 'pack_model.freezed.dart';
part 'pack_model.g.dart';

@freezed
class PackModel with _$PackModel {
  const factory PackModel({
    required String id,
    required String subject,
    required String topic,
    required int version,
    @Default(0) int sizeBytes,
    String? checksum,
    DateTime? installedAt,
  }) = _PackModel;

  factory PackModel.fromJson(Map<String, dynamic> json) =>
      _$PackModelFromJson(json);
}

extension PackModelX on PackModel {
  domain.Pack toEntity() {
    return domain.Pack(
      id: id,
      subject: subject,
      topic: topic,
      version: version,
      sizeBytes: sizeBytes,
      checksum: checksum,
      installedAt: installedAt,
    );
  }
}
