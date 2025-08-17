import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../widgets/question_card.dart';
import '../providers/mock_provider.dart';

class PaletteWidget extends HookConsumerWidget {
  final Function(int)? onQuestionTap;

  const PaletteWidget({
    super.key,
    this.onQuestionTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mockState = ref.watch(mockProvider);

    if (mockState.questions.isEmpty) {
      return const Center(
        child: Text('No questions available'),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Legend
          _buildLegend(context),
          
          const SizedBox(height: 16),
          
          // Question grid
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemCount: mockState.questions.length,
              itemBuilder: (context, index) {
                final question = mockState.questions[index];
                final isAnswered = mockState.answers.containsKey(question.id);
                final isFlagged = mockState.flaggedQuestions.contains(question.id);
                final isSelected = mockState.currentQuestionIndex == index;

                return CompactQuestionCard(
                  questionNumber: index + 1,
                  isAnswered: isAnswered,
                  isFlagged: isFlagged,
                  isSelected: isSelected,
                  onTap: () => onQuestionTap?.call(index),
                );
              },
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Summary
          _buildSummary(context, mockState),
        ],
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Legend',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            _buildLegendItem(
              context,
              color: AppTheme.successColor.withOpacity(0.1),
              borderColor: AppTheme.successColor,
              label: 'Answered',
              icon: Icons.check,
            ),
            _buildLegendItem(
              context,
              color: AppTheme.surfaceColor,
              borderColor: Colors.grey.shade300,
              label: 'Not Answered',
            ),
            _buildLegendItem(
              context,
              color: AppTheme.primaryColor,
              borderColor: AppTheme.primaryColor,
              label: 'Current',
              textColor: Colors.white,
            ),
            _buildLegendItem(
              context,
              color: AppTheme.surfaceColor,
              borderColor: Colors.grey.shade300,
              label: 'Flagged',
              showFlag: true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(
    BuildContext context, {
    required Color color,
    required Color borderColor,
    required String label,
    IconData? icon,
    Color? textColor,
    bool showFlag = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 24,
          width: 24,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: borderColor),
          ),
          child: Stack(
            children: [
              if (icon != null)
                Center(
                  child: Icon(
                    icon,
                    color: textColor ?? borderColor,
                    size: 12,
                  ),
                ),
              if (showFlag)
                Positioned(
                  top: 1,
                  right: 1,
                  child: Container(
                    height: 6,
                    width: 6,
                    decoration: const BoxDecoration(
                      color: AppTheme.warningColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildSummary(BuildContext context, MockState state) {
    final totalQuestions = state.questions.length;
    final answered = state.answeredCount;
    final flagged = state.flaggedCount;
    final unanswered = totalQuestions - answered;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(
            context,
            label: 'Total',
            value: '$totalQuestions',
            color: AppTheme.textPrimary,
          ),
          _buildSummaryItem(
            context,
            label: 'Answered',
            value: '$answered',
            color: AppTheme.successColor,
          ),
          _buildSummaryItem(
            context,
            label: 'Unanswered',
            value: '$unanswered',
            color: AppTheme.errorColor,
          ),
          _buildSummaryItem(
            context,
            label: 'Flagged',
            value: '$flagged',
            color: AppTheme.warningColor,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context, {
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}

class MiniPaletteWidget extends HookConsumerWidget {
  final Function(int)? onQuestionTap;
  final int maxVisible;

  const MiniPaletteWidget({
    super.key,
    this.onQuestionTap,
    this.maxVisible = 10,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mockState = ref.watch(mockProvider);

    if (mockState.questions.isEmpty) {
      return const SizedBox.shrink();
    }

    final questions = mockState.questions.take(maxVisible).toList();
    final hasMore = mockState.questions.length > maxVisible;

    return SizedBox(
      height: 40,
      child: Row(
        children: [
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: questions.length,
              itemBuilder: (context, index) {
                final question = questions[index];
                final isAnswered = mockState.answers.containsKey(question.id);
                final isFlagged = mockState.flaggedQuestions.contains(question.id);
                final isSelected = mockState.currentQuestionIndex == index;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: CompactQuestionCard(
                      questionNumber: index + 1,
                      isAnswered: isAnswered,
                      isFlagged: isFlagged,
                      isSelected: isSelected,
                      onTap: () => onQuestionTap?.call(index),
                    ),
                  ),
                );
              },
            ),
          ),
          if (hasMore) ...[
            const SizedBox(width: 8),
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
              ),
              child: Center(
                child: Text(
                  '+${mockState.questions.length - maxVisible}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
