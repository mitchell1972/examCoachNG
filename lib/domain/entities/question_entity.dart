class QuestionEntity {
  final String id;
  final String packId;
  final String stem;
  final List<String> options;
  final String correctAnswer;
  final String explanation;
  final int difficulty;
  final String syllabusNode;
  final String? imageUrl;
  
  const QuestionEntity({
    required this.id,
    required this.packId,
    required this.stem,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    required this.difficulty,
    required this.syllabusNode,
    this.imageUrl,
  });
  
  Map<String, String> get optionsMap => {
    'A': options.isNotEmpty ? options[0] : '',
    'B': options.length > 1 ? options[1] : '',
    'C': options.length > 2 ? options[2] : '',
    'D': options.length > 3 ? options[3] : '',
  };
  
  String get correctAnswerText {
    final index = _getAnswerIndex(correctAnswer);
    return index < options.length ? options[index] : '';
  }
  
  bool isCorrectAnswer(String choice) {
    return choice.toUpperCase() == correctAnswer.toUpperCase();
  }
  
  int _getAnswerIndex(String answer) {
    switch (answer.toUpperCase()) {
      case 'A': return 0;
      case 'B': return 1;
      case 'C': return 2;
      case 'D': return 3;
      default: return -1;
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
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuestionEntity && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
  
  @override
  String toString() => 'QuestionEntity(id: $id, stem: ${stem.substring(0, 50)}...)';
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
  
  int get value {
    switch (this) {
      case DifficultyLevel.easy: return 1;
      case DifficultyLevel.medium: return 2;
      case DifficultyLevel.hard: return 3;
      case DifficultyLevel.expert: return 4;
    }
  }
}
