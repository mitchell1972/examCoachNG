class Question {
  final String id;
  final String packId;
  final String stem;
  final Map<String, String> options;
  final String correct;
  final String explanation;
  final int difficulty;
  final String syllabusNode;

  const Question({
    required this.id,
    required this.packId,
    required this.stem,
    required this.options,
    required this.correct,
    required this.explanation,
    this.difficulty = 2,
    required this.syllabusNode,
  });

  Question copyWith({
    String? id,
    String? packId,
    String? stem,
    Map<String, String>? options,
    String? correct,
    String? explanation,
    int? difficulty,
    String? syllabusNode,
  }) {
    return Question(
      id: id ?? this.id,
      packId: packId ?? this.packId,
      stem: stem ?? this.stem,
      options: options ?? this.options,
      correct: correct ?? this.correct,
      explanation: explanation ?? this.explanation,
      difficulty: difficulty ?? this.difficulty,
      syllabusNode: syllabusNode ?? this.syllabusNode,
    );
  }

  String get difficultyText {
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

  List<String> get optionKeys => options.keys.toList()..sort();
  
  bool isCorrectAnswer(String answer) => answer.toUpperCase() == correct.toUpperCase();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is Question &&
      other.id == id &&
      other.packId == packId &&
      other.stem == stem &&
      other.options == options &&
      other.correct == correct &&
      other.explanation == explanation &&
      other.difficulty == difficulty &&
      other.syllabusNode == syllabusNode;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      packId.hashCode ^
      stem.hashCode ^
      options.hashCode ^
      correct.hashCode ^
      explanation.hashCode ^
      difficulty.hashCode ^
      syllabusNode.hashCode;
  }
}
