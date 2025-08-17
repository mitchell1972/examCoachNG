import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/mock_provider.dart';
import '../widgets/timer_bar.dart';
import '../widgets/palette_grid.dart';
import '../../practice/widgets/question_card.dart';
import '../../../widgets/common/loading_widget.dart';
import '../../../widgets/common/error_widget.dart';
import '../../../core/utils/constants.dart';

final mockProvider = StateNotifierProvider.family<MockNotifier, MockState, String>((ref, subject) {
  return MockNotifier(subject);
});

class MockScreen extends ConsumerStatefulWidget {
  final String subject;
  
  const MockScreen({super.key, required this.subject});

  @override
  ConsumerState<MockScreen> createState() => _MockScreenState();
}

class _MockScreenState extends ConsumerState<MockScreen> with TickerProviderStateMixin {
  bool _showPalette = false;
  String? _selectedAnswer;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startMockSession();
    });
  }

  void _startMockSession() {
    ref.read(mockProvider(widget.subject).notifier).startSession();
  }

  @override
  Widget build(BuildContext context) {
    final mockState = ref.watch(mockProvider(widget.subject));
    
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) _showExitDialog();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Mock Exam - ${AppConstants.subjectNames[widget.subject]}'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: Icon(_showPalette ? Icons.quiz : Icons.grid_view),
              onPressed: () => setState(() => _showPalette = !_showPalette),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _showExitDialog,
            ),
          ],
        ),
        body: mockState.when(
          loading: () => const AppLoadingWidget(),
          error: (error, stack) => AppErrorWidget(
            error: error.toString(),
            onRetry: _startMockSession,
          ),
          data: (session) {
            if (session == null) {
              return const Center(child: Text('No active session'));
            }
            
            return Column(
              children: [
                // Timer Bar
                TimerBar(
                  duration: session.duration,
                  remainingTime: session.remainingTime,
                  onTimeUp: _handleTimeUp,
                ),
                
                // Content
                Expanded(
                  child: _showPalette
                    ? _buildPaletteView(session)
                    : _buildQuestionView(session),
                ),
                
                // Bottom Navigation
                if (!_showPalette) _buildBottomNavigation(session),
              ],
            );
          },
        ),
      ),
    );
  }
  
  Widget _buildQuestionView(session) {
    final question = session.currentQuestion;
    
    return Column(
      children: [
        // Progress Indicator
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey[50],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${session.currentQuestionIndex + 1} of ${session.totalQuestions}',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                children: [
                  Icon(
                    session.isQuestionFlagged(session.currentQuestionIndex)
                      ? Icons.flag
                      : Icons.flag_outlined,
                    size: 20,
                    color: session.isQuestionFlagged(session.currentQuestionIndex)
                      ? Colors.orange
                      : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${session.answeredCount} answered',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Question Card
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: QuestionCard(
              question: question,
              selectedAnswer: _selectedAnswer ?? session.answers[session.currentQuestionIndex],
              showExplanation: false,
              onAnswerSelected: _onAnswerSelected,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildPaletteView(session) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats
          Row(
            children: [
              _buildStatCard(
                'Answered',
                '${session.answeredCount}',
                Colors.green,
              ),
              const SizedBox(width: 16),
              _buildStatCard(
                'Flagged',
                '${session.flaggedCount}',
                Colors.orange,
              ),
              const SizedBox(width: 16),
              _buildStatCard(
                'Remaining',
                '${session.totalQuestions - session.answeredCount}',
                Colors.grey,
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Question Palette
          Text(
            'Question Navigator',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          PaletteGrid(
            totalQuestions: session.totalQuestions,
            currentQuestion: session.currentQuestionIndex,
            answeredQuestions: session.answers.keys.toSet(),
            flaggedQuestions: session.flaggedQuestions,
            onQuestionTap: (index) {
              ref.read(mockProvider(widget.subject).notifier).jumpToQuestion(index);
              setState(() => _showPalette = false);
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBottomNavigation(session) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Flag Button
          OutlinedButton.icon(
            onPressed: _toggleFlag,
            icon: Icon(
              session.isQuestionFlagged(session.currentQuestionIndex)
                ? Icons.flag
                : Icons.flag_outlined,
            ),
            label: const Text('Flag'),
          ),
          
          const SizedBox(width: 16),
          
          // Navigation Buttons
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Previous Button
                if (session.currentQuestionIndex > 0)
                  OutlinedButton(
                    onPressed: _previousQuestion,
                    child: const Text('Previous'),
                  )
                else
                  const SizedBox.shrink(),
                
                // Submit/Next Button
                if (session.currentQuestionIndex < session.totalQuestions - 1)
                  ElevatedButton(
                    onPressed: _nextQuestion,
                    child: const Text('Next'),
                  )
                else
                  ElevatedButton(
                    onPressed: _showSubmitDialog,
                    child: const Text('Submit'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  void _onAnswerSelected(String answer) {
    setState(() => _selectedAnswer = answer);
    ref.read(mockProvider(widget.subject).notifier).saveAnswer(answer);
  }
  
  void _toggleFlag() {
    ref.read(mockProvider(widget.subject).notifier).toggleFlag();
  }
  
  void _nextQuestion() {
    ref.read(mockProvider(widget.subject).notifier).nextQuestion();
    setState(() => _selectedAnswer = null);
  }
  
  void _previousQuestion() {
    ref.read(mockProvider(widget.subject).notifier).previousQuestion();
    setState(() => _selectedAnswer = null);
  }
  
  void _handleTimeUp() {
    _submitExam();
  }
  
  void _showSubmitDialog() {
    final session = ref.read(mockProvider(widget.subject)).value;
    if (session == null) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Submit Exam'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You have answered ${session.answeredCount} out of ${session.totalQuestions} questions.'),
            const SizedBox(height: 8),
            if (session.answeredCount < session.totalQuestions)
              Text(
                'Are you sure you want to submit? Unanswered questions will be marked as incorrect.',
                style: TextStyle(color: Colors.orange[700]),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue Exam'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _submitExam();
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
  
  void _submitExam() async {
    try {
      final summary = await ref.read(mockProvider(widget.subject).notifier).completeSession();
      if (mounted) {
        context.pushReplacement('/results/${summary.sessionId}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting exam: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Mock Exam'),
        content: const Text('Are you sure you want to exit? Your progress will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
}

// Mock Provider Implementation
class MockNotifier extends StateNotifier<AsyncValue<MockSessionData?>> {
  final String subject;
  
  MockNotifier(this.subject) : super(const AsyncValue.loading());
  
  void startSession() {
    // Mock implementation - would integrate with actual mock session logic
    state = AsyncValue.data(MockSessionData(
      subject: subject,
      currentQuestionIndex: 0,
      totalQuestions: 60,
      duration: const Duration(minutes: 60),
      startTime: DateTime.now(),
      answers: {},
      flaggedQuestions: {},
    ));
  }
  
  void saveAnswer(String answer) {
    final session = state.value;
    if (session != null) {
      final updatedAnswers = Map<int, String>.from(session.answers);
      updatedAnswers[session.currentQuestionIndex] = answer;
      state = AsyncValue.data(session.copyWith(answers: updatedAnswers));
    }
  }
  
  void jumpToQuestion(int index) {
    final session = state.value;
    if (session != null) {
      state = AsyncValue.data(session.copyWith(currentQuestionIndex: index));
    }
  }
  
  void toggleFlag() {
    final session = state.value;
    if (session != null) {
      final updatedFlags = Set<int>.from(session.flaggedQuestions);
      if (updatedFlags.contains(session.currentQuestionIndex)) {
        updatedFlags.remove(session.currentQuestionIndex);
      } else {
        updatedFlags.add(session.currentQuestionIndex);
      }
      state = AsyncValue.data(session.copyWith(flaggedQuestions: updatedFlags));
    }
  }
  
  void nextQuestion() {
    final session = state.value;
    if (session != null && session.currentQuestionIndex < session.totalQuestions - 1) {
      state = AsyncValue.data(session.copyWith(
        currentQuestionIndex: session.currentQuestionIndex + 1,
      ));
    }
  }
  
  void previousQuestion() {
    final session = state.value;
    if (session != null && session.currentQuestionIndex > 0) {
      state = AsyncValue.data(session.copyWith(
        currentQuestionIndex: session.currentQuestionIndex - 1,
      ));
    }
  }
  
  Future<MockSessionSummary> completeSession() async {
    // Mock implementation - would integrate with actual completion logic
    return MockSessionSummary(
      sessionId: 'mock_${DateTime.now().millisecondsSinceEpoch}',
      score: 75,
      totalQuestions: 60,
      correctAnswers: 45,
    );
  }
}

class MockState {}

class MockSessionData {
  final String subject;
  final int currentQuestionIndex;
  final int totalQuestions;
  final Duration duration;
  final DateTime startTime;
  final Map<int, String> answers;
  final Set<int> flaggedQuestions;
  
  MockSessionData({
    required this.subject,
    required this.currentQuestionIndex,
    required this.totalQuestions,
    required this.duration,
    required this.startTime,
    required this.answers,
    required this.flaggedQuestions,
  });
  
  Duration get remainingTime {
    final elapsed = DateTime.now().difference(startTime);
    final remaining = duration - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }
  
  int get answeredCount => answers.length;
  int get flaggedCount => flaggedQuestions.length;
  
  bool isQuestionFlagged(int index) => flaggedQuestions.contains(index);
  
  MockSessionData copyWith({
    int? currentQuestionIndex,
    Map<int, String>? answers,
    Set<int>? flaggedQuestions,
  }) {
    return MockSessionData(
      subject: subject,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      totalQuestions: totalQuestions,
      duration: duration,
      startTime: startTime,
      answers: answers ?? this.answers,
      flaggedQuestions: flaggedQuestions ?? this.flaggedQuestions,
    );
  }
  
  // Mock current question
  QuestionEntity get currentQuestion => QuestionEntity(
    id: 'mock_question_$currentQuestionIndex',
    packId: 'mock_pack',
    stem: 'This is a mock question ${currentQuestionIndex + 1}. Choose the correct answer from the options below.',
    options: ['Option A', 'Option B', 'Option C', 'Option D'],
    correctAnswer: 'B',
    explanation: 'This is the explanation for the correct answer.',
    difficulty: 2,
    syllabusNode: 'mock_node',
  );
}

class MockSessionSummary {
  final String sessionId;
  final int score;
  final int totalQuestions;
  final int correctAnswers;
  
  MockSessionSummary({
    required this.sessionId,
    required this.score,
    required this.totalQuestions,
    required this.correctAnswers,
  });
}
