import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/question.dart' as domain;

part 'question_model.freezed.dart';
part 'question_model.g.dart';

@freezed
class QuestionModel with _$QuestionModel {
  const factory QuestionModel({
    required String id,
    required String packId,
    required String stem,
    required String a,
    required String b,
    required String c,
    required String d,
    required String correct,
    required String explanation,
    @Default(2) int difficulty,
    required String syllabusNode,
  }) = _QuestionModel;

  factory QuestionModel.fromJson(Map<String, dynamic> json) =>
      _$QuestionModelFromJson(json);
}

extension QuestionModelX on QuestionModel {
  domain.Question toEntity() {
    return domain.Question(
      id: id,
      packId: packId,
      stem: stem,
      options: {
        'A': a,
        'B': b,
        'C': c,
        'D': d,
      },
      correct: correct,
      explanation: explanation,
      difficulty: difficulty,
      syllabusNode: syllabusNode,
    );
  }
}
