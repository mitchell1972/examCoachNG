import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../widgets/question_card.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/error_widget.dart';
import '../../../widgets/custom_button.dart';
import '../providers/practice_provider.dart';

class QuestionScreen extends HookConsumerWidget {
  final String subject;

  const QuestionScreen({
    super.key,
    required this.subject,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final practiceState = ref.watch(practiceProvider);
    final practiceNotifier = ref.read(practiceProvider.notifier);

    // Handle state changes
    ref.listen<PracticeState>(practiceProvider, (previous, next) {
      if (previous?.error != next.error && next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        practiceNotifier.clearError();
      }

      if (next.isCompleted) {
        // Navigate to results
        final sessionId = next.session?.id;
        if (sessionId != null) {
          context.go('/home/results/$sessionId');
        }
      }
    });

    if (practiceState.isLoading && practiceState.questions.isEmpty) {
      return const Scaffold(
        body: Center(
          child: LoadingWidget(
            size: 48,
            message: 'Loading questions...',
            showMessage: true,
          ),
        ),
      );
    }

    if (practiceState.error != null && practiceState.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Practice'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _showExitDialog(context, ref),
          ),
        ),
        body: ErrorDisplay(
          title: 'Failed to Load Questions',
          message: practiceState.error!,
          onRetry: () => practiceNotifier.startSession(
            subject: subject,
            topic: null,
            questionCount: 20,
          ),
        ),
      );
    }

    if (practiceState.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Practice'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.go('/home'),
          ),
        ),
        body: const EmptyStateDisplay(
          title: 'No Questions Available',
          message: 'Please download question packs for this subject',
          icon: Icons.quiz,
        ),
      );
    }

    final currentQuestion = practiceState.currentQuestion;
    if (currentQuestion == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Practice')),
        body: const ErrorDisplay(
          title: 'Question Not Found',
          message: 'Unable to load the current question',
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('Question ${practiceState.currentQuestionIndex + 1}'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _showExitDialog(context, ref),
        ),
        actions: [
          // Progress indicator
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '${practiceState.answeredCount}/${practiceState.questions.length}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: practiceState.progress,
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: QuestionCard(
              question: currentQuestion,
              selectedAnswer: practiceState.currentAnswer,
              onAnswerSelected: (answer) {
                practiceNotifier.selectAnswer(answer);
              },
              showNavigation: false,
              currentIndex: practiceState.currentQuestionIndex,
              totalQuestions: practiceState.questions.length,
            ),
          ),
          
          // Bottom navigation
          _buildBottomNavigation(context, ref, practiceState, practiceNotifier),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation(
    BuildContext context,
    WidgetRef ref,
    PracticeState state,
    PracticeNotifier notifier,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Previous button
            if (state.hasPrevious)
              Expanded(
                child: OutlineButton(
                  onPressed: notifier.previousQuestion,
                  icon: Icons.arrow_back,
                  child: const Text('Previous'),
                ),
              ),
            
            if (state.hasPrevious && (state.hasNext || state.currentAnswer != null))
              const SizedBox(width: 16),
            
            // Next/Finish button
            if (state.hasNext)
              Expanded(
                flex: state.hasPrevious ? 1 : 2,
                child: PrimaryButton(
                  onPressed: state.currentAnswer != null
                      ? notifier.nextQuestion
                      : null,
                  icon: Icons.arrow_forward,
                  child: const Text('Next'),
                ),
              )
            else if (state.currentAnswer != null)
              Expanded(
                flex: state.hasPrevious ? 1 : 2,
                child: PrimaryButton(
                  onPressed: state.isLoading ? null : () => _finishPractice(context, ref),
                  isLoading: state.isLoading,
                  icon: Icons.check,
                  child: const Text('Finish'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _finishPractice(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finish Practice'),
        content: const Text('Are you sure you want to finish this practice session?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Continue'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(practiceProvider.notifier).completeSession();
            },
            child: const Text('Finish'),
          ),
        ],
      ),
    );
  }

  void _showExitDialog(BuildContext context, WidgetRef ref) {
    final state = ref.read(practiceProvider);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Practice'),
        content: Text(state.answeredCount > 0
            ? 'You have answered ${state.answeredCount} questions. Your progress will be saved.'
            : 'Are you sure you want to exit this practice session?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Continue'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (state.answeredCount > 0) {
                // Save progress and exit
                ref.read(practiceProvider.notifier).completeSession().then((_) {
                  context.go('/home');
                });
              } else {
                // Just exit without saving
                ref.read(practiceProvider.notifier).resetSession();
                context.go('/home');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
}
