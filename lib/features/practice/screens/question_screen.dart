import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';

import '../providers/session_provider.dart';
import '../widgets/question_card.dart';
import '../../../widgets/loading_indicator.dart';
import '../../../widgets/error_widget.dart';

class QuestionScreen extends HookConsumerWidget {
  final String subject;
  final String sessionId;
  final String mode;

  const QuestionScreen({
    super.key,
    required this.subject,
    required this.sessionId,
    required this.mode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionState = ref.watch(sessionProvider(sessionId));
    final currentQuestionIndex = useState(0);
    final selectedAnswer = useState<String?>(null);
    final showExplanation = useState(false);
    final startTime = useState<DateTime?>(null);

    return Scaffold(
      appBar: AppBar(
        title: Text(mode == 'practice' ? 'Practice' : 'Mock Exam'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _showExitDialog(context),
        ),
        actions: [
          if (mode == 'mock')
            IconButton(
              icon: const Icon(Icons.grid_view),
              onPressed: () {
                // TODO: Show question palette
              },
            ),
        ],
      ),
      body: sessionState.when(
        loading: () => const Center(child: LoadingIndicator()),
        error: (error, stackTrace) => AppErrorWidget(
          error: error.toString(),
          onRetry: () => ref.refresh(sessionProvider(sessionId)),
        ),
        data: (state) {
          if (!state.isLoaded || state.questions.isEmpty) {
            return const Center(
              child: Text('No questions available'),
            );
          }

          final currentQuestion = state.questions[currentQuestionIndex.value];
          final progress = (currentQuestionIndex.value + 1) / state.questions.length;
          final attempt = state.getAttemptForQuestion(currentQuestion.id);
          final isAnswered = attempt != null;

          // Initialize start time
          useEffect(() {
            if (startTime.value == null) {
              startTime.value = DateTime.now();
            }
            return null;
          }, []);

          return Column(
            children: [
              // Progress indicator
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Question ${currentQuestionIndex.value + 1} of ${state.questions.length}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (mode == 'mock')
                          // TODO: Add timer display
                          Text(
                            '45:30',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                    ),
                  ],
                ),
              ),

              // Question content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: QuestionCard(
                    question: currentQuestion,
                    selectedOption: isAnswered ? attempt!.chosen : selectedAnswer.value,
                    showAnswer: isAnswered || showExplanation.value,
                    onOptionSelected: isAnswered ? null : (option) {
                      selectedAnswer.value = option;
                    },
                  ),
                ),
              ),

              // Action buttons
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Previous button
                    if (currentQuestionIndex.value > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            currentQuestionIndex.value--;
                            selectedAnswer.value = null;
                            showExplanation.value = false;
                          },
                          child: const Text('Previous'),
                        ),
                      ),
                    
                    if (currentQuestionIndex.value > 0)
                      const SizedBox(width: 16),

                    // Submit/Next button
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: isAnswered
                            ? () => _handleNext(
                                context,
                                ref,
                                currentQuestionIndex,
                                selectedAnswer,
                                showExplanation,
                                state,
                              )
                            : selectedAnswer.value != null
                                ? () => _handleSubmitAnswer(
                                    context,
                                    ref,
                                    currentQuestion,
                                    selectedAnswer.value!,
                                    showExplanation,
                                    startTime.value!,
                                  )
                                : null,
                        child: Text(
                          isAnswered
                              ? (currentQuestionIndex.value == state.questions.length - 1
                                  ? 'Finish'
                                  : 'Next')
                              : 'Submit Answer',
                        ),
                      ),
                    ),

                    // Flag button (for mock mode)
                    if (mode == 'mock') ...[
                      const SizedBox(width: 16),
                      IconButton(
                        onPressed: () {
                          ref.read(sessionProvider(sessionId).notifier)
                              .flagQuestion(currentQuestion.id);
                        },
                        icon: Icon(
                          state.progress.isQuestionFlagged(currentQuestion.id)
                              ? Icons.flag
                              : Icons.flag_outlined,
                          color: state.progress.isQuestionFlagged(currentQuestion.id)
                              ? Theme.of(context).colorScheme.error
                              : null,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _handleSubmitAnswer(
    BuildContext context,
    WidgetRef ref,
    question,
    String selectedOption,
    ValueNotifier<bool> showExplanation,
    DateTime startTime,
  ) {
    final isCorrect = question.isCorrectAnswer(selectedOption);
    final timeMs = DateTime.now().difference(startTime).inMilliseconds;

    ref.read(sessionProvider(sessionId).notifier).submitAnswer(
      questionId: question.id,
      selectedOption: selectedOption,
      isCorrect: isCorrect,
      timeMs: timeMs,
    );

    if (mode == 'practice') {
      showExplanation.value = true;
    }
  }

  void _handleNext(
    BuildContext context,
    WidgetRef ref,
    ValueNotifier<int> currentQuestionIndex,
    ValueNotifier<String?> selectedAnswer,
    ValueNotifier<bool> showExplanation,
    state,
  ) {
    if (currentQuestionIndex.value == state.questions.length - 1) {
      // Complete session and navigate to results
      ref.read(sessionProvider(sessionId).notifier).completeSession().then((_) {
        context.go('/results/$sessionId');
      });
    } else {
      // Move to next question
      currentQuestionIndex.value++;
      selectedAnswer.value = null;
      showExplanation.value = false;
    }
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Session?'),
        content: const Text(
          'Are you sure you want to exit? Your progress will be saved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.pop();
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
}
