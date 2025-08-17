import 'package:flutter/material.dart';

class PaletteGrid extends StatelessWidget {
  final int totalQuestions;
  final int currentIndex;
  final List<String> answeredQuestions;
  final List<String> flaggedQuestions;
  final List<String> questionIds;
  final void Function(int) onQuestionTap;
  final VoidCallback? onClose;

  const PaletteGrid({
    super.key,
    required this.totalQuestions,
    required this.currentIndex,
    required this.answeredQuestions,
    required this.flaggedQuestions,
    required this.questionIds,
    required this.onQuestionTap,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                Text(
                  'Question Palette',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (onClose != null)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: onClose,
                  ),
              ],
            ),
          ),

          // Legend
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _LegendItem(
                  color: Theme.of(context).colorScheme.primary,
                  label: 'Current',
                ),
                _LegendItem(
                  color: Colors.green,
                  label: 'Answered',
                ),
                _LegendItem(
                  color: Colors.orange,
                  label: 'Flagged',
                ),
                _LegendItem(
                  color: Theme.of(context).colorScheme.outline,
                  label: 'Not Visited',
                ),
              ],
            ),
          ),

          // Question grid
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemCount: totalQuestions,
                itemBuilder: (context, index) {
                  final questionId = questionIds[index];
                  final isAnswered = answeredQuestions.contains(questionId);
                  final isFlagged = flaggedQuestions.contains(questionId);
                  final isCurrent = index == currentIndex;

                  return _QuestionButton(
                    number: index + 1,
                    isCurrent: isCurrent,
                    isAnswered: isAnswered,
                    isFlagged: isFlagged,
                    onTap: () {
                      onQuestionTap(index);
                      onClose?.call();
                    },
                  );
                },
              ),
            ),
          ),

          // Statistics
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatItem(
                  label: 'Answered',
                  value: answeredQuestions.length.toString(),
                  total: totalQuestions,
                ),
                _StatItem(
                  label: 'Flagged',
                  value: flaggedQuestions.length.toString(),
                  total: totalQuestions,
                ),
                _StatItem(
                  label: 'Not Visited',
                  value: (totalQuestions - answeredQuestions.length).toString(),
                  total: totalQuestions,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionButton extends StatelessWidget {
  final int number;
  final bool isCurrent;
  final bool isAnswered;
  final bool isFlagged;
  final VoidCallback onTap;

  const _QuestionButton({
    required this.number,
    required this.isCurrent,
    required this.isAnswered,
    required this.isFlagged,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    Widget? child;

    if (isCurrent) {
      backgroundColor = Theme.of(context).colorScheme.primary;
      textColor = Colors.white;
    } else if (isAnswered) {
      backgroundColor = Colors.green;
      textColor = Colors.white;
    } else if (isFlagged) {
      backgroundColor = Colors.orange;
      textColor = Colors.white;
    } else {
      backgroundColor = Theme.of(context).colorScheme.outline.withOpacity(0.2);
      textColor = Theme.of(context).colorScheme.onSurface;
    }

    child = Text(
      number.toString(),
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        color: textColor,
        fontWeight: FontWeight.bold,
      ),
    );

    // Add flag indicator
    if (isFlagged && !isCurrent) {
      child = Stack(
        alignment: Alignment.center,
        children: [
          child!,
          Positioned(
            top: 2,
            right: 2,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      );
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: isCurrent
              ? Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                )
              : null,
        ),
        child: Center(child: child),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final int total;

  const _StatItem({
    required this.label,
    required this.value,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$value/$total',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}
