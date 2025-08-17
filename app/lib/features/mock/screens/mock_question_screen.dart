import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../widgets/question_card.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/error_widget.dart';
import '../../../widgets/custom_button.dart';
import '../providers/mock_provider.dart';
import '../widgets/timer_widget.dart';
import '../widgets/palette_widget.dart';

class MockQuestionScreen extends HookConsumerWidget {
  final String subject;

  const MockQuestionScreen({
    super.key,
    required this.subject,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mockState = ref.watch(mockProvider);
    final mockNotifier = ref.read(mockProvider.notifier);

    // Handle state changes
    ref.listen<MockState>(mockProvider, (previous, next) {
      if (previous?.error != next.error && next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        mockNotifier.clearError();
      }

      if (next.isSubmitted && next.isCompleted) {
        // Navigate to results
        final sessionId = next.session?.id;
        if (sessionId != null) {
          context.go('/home/results/$sessionId');
        }
      }

      if (next.isTimeUp && !next.isSubmitted) {
        _showTimeUpDialog(context, ref);
      }
    });

    if (mockState.isLoading && mockState.questions.isEmpty) {
      return const Scaffold(
        body: Center(
          child: LoadingWidget(
            size: 48,
            message: 'Loading mock exam...',
            showMessage: true,
          ),
        ),
      );
    }

    if (mockState.error != null && mockState.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Mock Exam'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.go('/home'),
          ),
        ),
        body: ErrorDisplay(
          title: 'Failed to Load Exam',
          message: mockState.error!,
          onRetry: () => mockNotifier.startSession(subject: subject),
        ),
      );
    }

    if (mockState.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Mock Exam'),
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

    final currentQuestion = mockState.currentQuestion;
    if (currentQuestion == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mock Exam')),
        body: const ErrorDisplay(
          title: 'Question Not Found',
          message: 'Unable to load the current question',
        ),
      );
    }

    return WillPopScope(
      onWillPop: () => _onWillPop(context, ref),
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          title: Text('Question ${mockState.currentQuestionIndex + 1}'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _showExitDialog(context, ref),
          ),
          actions: [
            // Flag button
            IconButton(
              icon: Icon(
                mockState.flaggedQuestions.contains(currentQuestion.id)
                    ? Icons.flag
                    : Icons.flag_outlined,
                color: mockState.flaggedQuestions.contains(currentQuestion.id)
                    ? AppTheme.warningColor
                    : null,
              ),
              onPressed: mockNotifier.toggleFlag,
            ),
            
            // Palette button
            IconButton(
              icon: const Icon(Icons.grid_view),
              onPressed: () => _showPaletteDialog(context, ref),
            ),
            
            const SizedBox(width: 8),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TimerWidget(
                timeRemaining: mockState.timeRemaining,
                isPaused: mockState.isPaused,
                onPause: mockNotifier.pauseTimer,
                onResume: mockNotifier.resumeTimer,
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: QuestionCard(
                question: currentQuestion,
                selectedAnswer: mockState.currentAnswer,
                onAnswerSelected: mockState.isCompleted 
                    ? null 
                    : (answer) => mockNotifier.selectAnswer(answer),
                showNavigation: false,
                currentIndex: mockState.currentQuestionIndex,
                totalQuestions: mockState.questions.length,
              ),
            ),
            
            // Bottom navigation
            _buildBottomNavigation(context, ref, mockState, mockNotifier),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation(
    BuildContext context,
    WidgetRef ref,
    MockState state,
    MockNotifier notifier,
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
                  onPressed: state.isCompleted ? null : notifier.previousQuestion,
                  icon: Icons.arrow_back,
                  child: const Text('Previous'),
                ),
              ),
            
            if (state.hasPrevious)
              const SizedBox(width: 16),
            
            // Submit button (always visible in mock mode)
            Expanded(
              child: PrimaryButton(
                onPressed: state.isCompleted || state.isSubmitted 
                    ? null 
                    : () => _showSubmitDialog(context, ref),
                isLoading: state.isLoading,
                icon: Icons.send,
                child: const Text('Submit'),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Next button
            if (state.hasNext)
              Expanded(
                child: PrimaryButton(
                  onPressed: state.isCompleted ? null : notifier.nextQuestion,
                  icon: Icons.arrow_forward,
                  child: const Text('Next'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showPaletteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Question Navigator',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PaletteWidget(
                  onQuestionTap: (index) {
                    Navigator.of(context).pop();
                    ref.read(mockProvider.notifier).goToQuestion(index);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSubmitDialog(BuildContext context, WidgetRef ref) {
    final state = ref.read(mockProvider);
    final unanswered = state.questions.length - state.answeredCount;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit Mock Exam'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Answered: ${state.answeredCount}/${state.questions.length}'),
            if (unanswered > 0) ...[
              const SizedBox(height: 8),
              Text(
                'Unanswered: $unanswered questions',
                style: TextStyle(color: AppTheme.warningColor),
              ),
              const SizedBox(height: 8),
              const Text('Unanswered questions will be marked as incorrect.'),
            ],
            const SizedBox(height: 16),
            const Text('Are you sure you want to submit your exam?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Continue'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(mockProvider.notifier).submitSession();
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _showTimeUpDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.access_time, color: AppTheme.errorColor),
            const SizedBox(width: 8),
            const Text('Time\'s Up!'),
          ],
        ),
        content: const Text(
          'Your time has expired. The exam has been automatically submitted.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // The submission should have happened automatically
              final sessionId = ref.read(mockProvider).session?.id;
              if (sessionId != null) {
                context.go('/home/results/$sessionId');
              } else {
                context.go('/home');
              }
            },
            child: const Text('View Results'),
          ),
        ],
      ),
    );
  }

  void _showExitDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Mock Exam'),
        content: const Text(
          'Are you sure you want to exit the mock exam? '
          'Your progress will be lost and this attempt will be recorded.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Continue Exam'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(mockProvider.notifier).resetSession();
              context.go('/home');
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

  Future<bool> _onWillPop(BuildContext context, WidgetRef ref) async {
    _showExitDialog(context, ref);
    return false;
  }
}
