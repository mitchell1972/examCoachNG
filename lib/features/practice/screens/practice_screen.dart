import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/session_provider.dart';
import '../widgets/question_card.dart';
import '../../../widgets/common/loading_widget.dart';
import '../../../widgets/common/error_widget.dart';
import '../../../core/utils/constants.dart';

class PracticeScreen extends ConsumerStatefulWidget {
  final String subject;
  final String? topic;
  
  const PracticeScreen({
    super.key, 
    required this.subject, 
    this.topic,
  });

  @override
  ConsumerState<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends ConsumerState<PracticeScreen> {
  bool _showExplanation = false;
  String? _selectedAnswer;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startSession();
    });
  }

  void _startSession() {
    ref.read(practiceSessionProvider(widget.subject).notifier)
        .startSession(topic: widget.topic);
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(practiceSessionProvider(widget.subject));
    
    return Scaffold(
      appBar: AppBar(
        title: Text(AppConstants.subjectNames[widget.subject] ?? widget.subject),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _showExitDialog(context),
          ),
        ],
      ),
      body: sessionState.when(
        loading: () => const AppLoadingWidget(),
        error: (error, stack) => AppErrorWidget(
          error: error.toString(),
          onRetry: _startSession,
        ),
        data: (session) {
          if (session == null) {
            return const Center(
              child: Text('Session not found'),
            );
          }
          
          if (session.isCompleted) {
            return _buildCompletionScreen(session);
          }
          
          return _buildQuestionScreen(session);
        },
      ),
    );
  }
  
  Widget _buildQuestionScreen(session) {
    final question = session.currentQuestion;
    
    return Column(
      children: [
        // Progress Bar
        LinearProgressIndicator(
          value: (session.currentQuestionIndex + 1) / session.totalQuestions,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
        ),
        
        // Question Counter
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Colors.grey[50],
          child: Text(
            'Question ${session.currentQuestionIndex + 1} of ${session.totalQuestions}',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        
        // Question Card
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: QuestionCard(
              question: question,
              selectedAnswer: _selectedAnswer,
              showExplanation: _showExplanation,
              onAnswerSelected: _onAnswerSelected,
            ),
          ),
        ),
        
        // Navigation Buttons
        Container(
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
          child: _buildNavigationButtons(session),
        ),
      ],
    );
  }
  
  Widget _buildNavigationButtons(session) {
    if (_showExplanation) {
      return Row(
        children: [
          if (session.currentQuestionIndex > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () => _previousQuestion(),
                child: const Text('Previous'),
              ),
            ),
          if (session.currentQuestionIndex > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _nextQuestion(session),
              child: Text(session.isLastQuestion ? 'Finish' : 'Next'),
            ),
          ),
        ],
      );
    }
    
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _selectedAnswer != null ? () => _submitAnswer() : null,
        child: const Text('Submit Answer'),
      ),
    );
  }
  
  Widget _buildCompletionScreen(session) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              size: 64,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 24),
            Text(
              'Session Complete!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'You answered ${session.answeredCount} out of ${session.totalQuestions} questions.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _viewResults,
                child: const Text('View Results'),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => context.pop(),
                child: const Text('Back to Home'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _onAnswerSelected(String answer) {
    setState(() {
      _selectedAnswer = answer;
    });
  }
  
  void _submitAnswer() {
    if (_selectedAnswer == null) return;
    
    ref.read(practiceSessionProvider(widget.subject).notifier)
        .submitAnswer(_selectedAnswer!);
    
    setState(() {
      _showExplanation = true;
    });
  }
  
  void _nextQuestion(session) {
    if (session.isLastQuestion) {
      _completeSession();
    } else {
      ref.read(practiceSessionProvider(widget.subject).notifier).nextQuestion();
      _resetQuestionState();
    }
  }
  
  void _previousQuestion() {
    ref.read(practiceSessionProvider(widget.subject).notifier).previousQuestion();
    _resetQuestionState();
  }
  
  void _resetQuestionState() {
    setState(() {
      _selectedAnswer = null;
      _showExplanation = false;
    });
  }
  
  void _completeSession() async {
    try {
      final summary = await ref
          .read(practiceSessionProvider(widget.subject).notifier)
          .completeSession();
      
      if (mounted) {
        context.pushReplacement('/results/${summary.sessionId}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error completing session: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  void _viewResults() async {
    try {
      final summary = await ref
          .read(practiceSessionProvider(widget.subject).notifier)
          .completeSession();
      
      if (mounted) {
        context.pushReplacement('/results/${summary.sessionId}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error viewing results: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Practice'),
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
