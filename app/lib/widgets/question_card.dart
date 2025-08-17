import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../domain/entities/question.dart';

class QuestionCard extends StatefulWidget {
  final Question question;
  final String? selectedAnswer;
  final bool showCorrectAnswer;
  final bool showExplanation;
  final Function(String)? onAnswerSelected;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;
  final bool showNavigation;
  final int? currentIndex;
  final int? totalQuestions;

  const QuestionCard({
    super.key,
    required this.question,
    this.selectedAnswer,
    this.showCorrectAnswer = false,
    this.showExplanation = false,
    this.onAnswerSelected,
    this.onNext,
    this.onPrevious,
    this.showNavigation = true,
    this.currentIndex,
    this.totalQuestions,
  });

  @override
  State<QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Question header with progress
              if (widget.currentIndex != null && widget.totalQuestions != null)
                _buildQuestionHeader(),
              
              const SizedBox(height: 16),
              
              // Difficulty badge
              _buildDifficultyBadge(),
              
              const SizedBox(height: 16),
              
              // Question stem
              _buildQuestionStem(),
              
              const SizedBox(height: 24),
              
              // Answer options
              _buildAnswerOptions(),
              
              // Explanation (if shown)
              if (widget.showExplanation) ...[
                const SizedBox(height: 24),
                _buildExplanation(),
              ],
              
              // Navigation buttons
              if (widget.showNavigation) ...[
                const SizedBox(height: 24),
                _buildNavigationButtons(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionHeader() {
    final progress = (widget.currentIndex! + 1) / widget.totalQuestions!;
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Question ${widget.currentIndex! + 1}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
              ),
            ),
            Text(
              '${widget.currentIndex! + 1} of ${widget.totalQuestions}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey.shade200,
          valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
        ),
      ],
    );
  }

  Widget _buildDifficultyBadge() {
    final difficulty = widget.question.difficultyText;
    Color badgeColor;
    
    switch (widget.question.difficulty) {
      case 1:
        badgeColor = Colors.green;
        break;
      case 2:
        badgeColor = Colors.blue;
        break;
      case 3:
        badgeColor = Colors.orange;
        break;
      case 4:
        badgeColor = Colors.red;
        break;
      default:
        badgeColor = Colors.grey;
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: badgeColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: badgeColor.withOpacity(0.3)),
        ),
        child: Text(
          difficulty,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: badgeColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionStem() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Text(
        widget.question.stem,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildAnswerOptions() {
    return Column(
      children: widget.question.optionKeys.map((key) {
        final option = widget.question.options[key]!;
        final isSelected = widget.selectedAnswer == key;
        final isCorrect = widget.question.correct == key;
        final shouldShowCorrect = widget.showCorrectAnswer && isCorrect;
        final shouldShowIncorrect = widget.showCorrectAnswer && 
                                   isSelected && 
                                   !isCorrect;

        Color backgroundColor;
        Color borderColor;
        Color textColor;

        if (shouldShowCorrect) {
          backgroundColor = AppTheme.successColor.withOpacity(0.1);
          borderColor = AppTheme.successColor;
          textColor = AppTheme.successColor;
        } else if (shouldShowIncorrect) {
          backgroundColor = AppTheme.errorColor.withOpacity(0.1);
          borderColor = AppTheme.errorColor;
          textColor = AppTheme.errorColor;
        } else if (isSelected) {
          backgroundColor = AppTheme.primaryColor.withOpacity(0.1);
          borderColor = AppTheme.primaryColor;
          textColor = AppTheme.primaryColor;
        } else {
          backgroundColor = AppTheme.surfaceColor;
          borderColor = Colors.grey.shade300;
          textColor = AppTheme.textPrimary;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: widget.onAnswerSelected != null && !widget.showCorrectAnswer
                ? () => widget.onAnswerSelected!(key)
                : null,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor, width: 1.5),
              ),
              child: Row(
                children: [
                  Container(
                    height: 24,
                    width: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: shouldShowCorrect || shouldShowIncorrect || isSelected
                          ? borderColor
                          : Colors.transparent,
                      border: Border.all(color: borderColor),
                    ),
                    child: shouldShowCorrect
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : shouldShowIncorrect
                            ? const Icon(Icons.close, color: Colors.white, size: 16)
                            : isSelected
                                ? Container(
                                    margin: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                    ),
                                  )
                                : null,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    key,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      option,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: textColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildExplanation() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: AppTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Explanation',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.question.explanation,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Correct answer: ${widget.question.correct}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.successColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      children: [
        if (widget.onPrevious != null)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: widget.onPrevious,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Previous'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        
        if (widget.onPrevious != null && widget.onNext != null)
          const SizedBox(width: 16),
        
        if (widget.onNext != null)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: widget.onNext,
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Next'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
      ],
    );
  }
}

// Compact question card for review/palette views
class CompactQuestionCard extends StatelessWidget {
  final int questionNumber;
  final bool isAnswered;
  final bool isCorrect;
  final bool isFlagged;
  final bool isSelected;
  final VoidCallback? onTap;

  const CompactQuestionCard({
    super.key,
    required this.questionNumber,
    this.isAnswered = false,
    this.isCorrect = false,
    this.isFlagged = false,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color borderColor;
    Color textColor;
    IconData? icon;

    if (isSelected) {
      backgroundColor = AppTheme.primaryColor;
      borderColor = AppTheme.primaryColor;
      textColor = Colors.white;
    } else if (isAnswered) {
      if (isCorrect) {
        backgroundColor = AppTheme.successColor.withOpacity(0.1);
        borderColor = AppTheme.successColor;
        textColor = AppTheme.successColor;
        icon = Icons.check;
      } else {
        backgroundColor = AppTheme.errorColor.withOpacity(0.1);
        borderColor = AppTheme.errorColor;
        textColor = AppTheme.errorColor;
        icon = Icons.close;
      }
    } else {
      backgroundColor = AppTheme.surfaceColor;
      borderColor = Colors.grey.shade300;
      textColor = AppTheme.textPrimary;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor),
        ),
        child: Stack(
          children: [
            Center(
              child: icon != null
                  ? Icon(icon, color: textColor, size: 16)
                  : Text(
                      questionNumber.toString(),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
            ),
            if (isFlagged)
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  height: 8,
                  width: 8,
                  decoration: const BoxDecoration(
                    color: AppTheme.warningColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
