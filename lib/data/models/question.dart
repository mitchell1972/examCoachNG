import 'package:freezed_annotation/freezed_annotation.dart';

part 'question.freezed.dart';
part 'question.g.dart';

@freezed
class QuestionModel with _$QuestionModel {
  const factory QuestionModel({
    required String id,
    @JsonKey(name: 'pack_id') required String packId,
    required String stem,
    required String a,
    required String b,
    required String c,
    required String d,
    required String correct,
    required String explanation,
    @Default(2) int difficulty,
    @JsonKey(name: 'syllabus_node') required String syllabusNode,
    @JsonKey(name: 'image_url') String? imageUrl,
  }) = _QuestionModel;

  factory QuestionModel.fromJson(Map<String, dynamic> json) => _$QuestionModelFromJson(json);
}

extension QuestionModelExtension on QuestionModel {
  List<String> get options => [a, b, c, d];
  
  Map<String, String> get optionsMap => {
    'A': a,
    'B': b,
    'C': c,
    'D': d,
  };
  
  bool isCorrectAnswer(String choice) => choice.toUpperCase() == correct.toUpperCase();
  
  String get correctAnswerText {
    switch (correct.toUpperCase()) {
      case 'A': return a;
      case 'B': return b;
      case 'C': return c;
      case 'D': return d;
      default: return '';
    }
  }
  
  DifficultyLevel get difficultyLevel {
    switch (difficulty) {
      case 1: return DifficultyLevel.easy;
      case 2: return DifficultyLevel.medium;
      case 3: return DifficultyLevel.hard;
      case 4: return DifficultyLevel.expert;
      default: return DifficultyLevel.medium;
    }
  }
  
  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;
}

enum DifficultyLevel {
  easy,
  medium,
  hard,
  expert;
  
  String get displayName {
    switch (this) {
      case DifficultyLevel.easy: return 'Easy';
      case DifficultyLevel.medium: return 'Medium';
      case DifficultyLevel.hard: return 'Hard';
      case DifficultyLevel.expert: return 'Expert';
    }
  }
  
  String get emoji {
    switch (this) {
      case DifficultyLevel.easy: return '🟢';
      case DifficultyLevel.medium: return '🟡';
      case DifficultyLevel.hard: return '🟠';
      case DifficultyLevel.expert: return '🔴';
    }
  }
}
