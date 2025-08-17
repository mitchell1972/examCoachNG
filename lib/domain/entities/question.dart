import 'package:freezed_annotation/freezed_annotation.dart';

part 'question.freezed.dart';

@freezed
class QuestionEntity with _$QuestionEntity {
  const factory QuestionEntity({
    required String id,
    required String packId,
    required String stem,
    required Map<String, String> options,
    required String correct,
    required String explanation,
    required int difficulty,
    required String syllabusNode,
  }) = _QuestionEntity;

  const QuestionEntity._();

  List<String> get optionLabels => ['A', 'B', 'C', 'D'];
  
  List<MapEntry<String, String>> get sortedOptions {
    return optionLabels
        .where((label) => options.containsKey(label))
        .map((label) => MapEntry(label, options[label]!))
        .toList();
  }

  String get difficultyLabel {
    switch (difficulty) {
      case 1:
        return 'Easy';
      case 2:
        return 'Medium';
      case 3:
        return 'Hard';
      case 4:
        return 'Expert';
      default:
        return 'Unknown';
    }
  }

  bool isCorrectAnswer(String selectedOption) {
    return selectedOption == correct;
  }
}

@freezed
class QuestionState with _$QuestionState {
  const factory QuestionState({
    String? selectedOption,
    @Default(false) bool isAnswered,
    @Default(false) bool showExplanation,
    DateTime? answeredAt,
    int? timeSpentMs,
  }) = _QuestionState;

  const QuestionState._();

  bool get isCorrect => selectedOption != null && selectedOption == selectedOption;
}
