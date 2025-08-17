import 'package:flutter/material.dart';

import '../../../domain/entities/question.dart';
import 'option_button.dart';

class QuestionCard extends StatelessWidget {
  final QuestionEntity question;
  final String? selectedOption;
  final bool showAnswer;
  final void Function(String)? onOptionSelected;

  const QuestionCard({
    super.key,
    required this.question,
    this.selectedOption,
    this.showAnswer = false,
    this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question difficulty indicator
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getDifficultyColor(question.difficulty).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    question.difficultyLabel,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _getDifficultyColor(question.difficulty),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.quiz,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Question stem
            Text(
              question.stem,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.5,
              ),
            ),

            const SizedBox(height: 24),

            // Options
            ...question.sortedOptions.map((option) {
              final isSelected = selectedOption == option.key;
              final isCorrect = option.key == question.correct;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: OptionButton(
                  label: option.key,
                  text: option.value,
                  isSelected: isSelected,
                  isCorrect: showAnswer ? isCorrect : null,
                  isIncorrect: showAnswer && isSelected && !isCorrect,
                  onTap: onOptionSelected != null
                      ? () => onOptionSelected!(option.key)
                      : null,
                ),
              );
            }),

            // Explanation (shown after answering in practice mode)
            if (showAnswer && question.explanation.isNotEmpty) ...[
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Explanation',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      question.explanation,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor(int difficulty) {
    switch (difficulty) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.red;
      case 4:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
