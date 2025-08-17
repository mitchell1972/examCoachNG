import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ExamCoach',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'ExamCoach - Exam Preparation App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  String _selectedSubject = '';

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _selectSubject(String subject) {
    setState(() {
      _selectedSubject = subject;
      _counter++;
    });
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuestionScreen(subject: subject),
      ),
    );
  }

  Widget _buildSubjectCard(String subject, IconData icon, Color color) {
    return GestureDetector(
      onTap: () => _selectSubject(subject),
      child: Card(
        elevation: 4,
        child: Container(
          width: 120,
          height: 100,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 8),
              Text(
                subject,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(
              Icons.school,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 20),
            const Text(
              'ExamCoach JAMB Practice',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Practice JAMB questions and improve your scores',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            
            // Subject Cards
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSubjectCard('Mathematics', Icons.calculate, Colors.blue),
                _buildSubjectCard('English', Icons.menu_book, Colors.green),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSubjectCard('Physics', Icons.science, Colors.orange),
                _buildSubjectCard('Chemistry', Icons.biotech, Colors.purple),
              ],
            ),
            
            const SizedBox(height: 30),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Quick Stats',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text('Questions Attempted: $_counter'),
                    const SizedBox(height: 5),
                    Text('App Status: ✅ Ready for Practice'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class QuestionScreen extends StatefulWidget {
  final String subject;
  
  const QuestionScreen({super.key, required this.subject});

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  String _selectedAnswer = '';
  bool _answered = false;
  
  // Sample JAMB questions for each subject
  final Map<String, List<Question>> _questions = {
    'Mathematics': [
      Question(
        'If 2x + 3 = 7, what is the value of x?',
        ['1', '2', '3', '4'],
        '2',
      ),
      Question(
        'What is the square root of 144?',
        ['10', '11', '12', '13'],
        '12',
      ),
      Question(
        'Solve for y: 3y - 6 = 15',
        ['5', '6', '7', '8'],
        '7',
      ),
    ],
    'English': [
      Question(
        'Choose the correct spelling:',
        ['Recieve', 'Receive', 'Receeve', 'Recive'],
        'Receive',
      ),
      Question(
        'What is the plural of "child"?',
        ['childs', 'children', 'childes', 'child'],
        'children',
      ),
      Question(
        'Choose the synonym for "happy":',
        ['sad', 'joyful', 'angry', 'tired'],
        'joyful',
      ),
    ],
    'Physics': [
      Question(
        'What is the unit of force?',
        ['Joule', 'Newton', 'Watt', 'Volt'],
        'Newton',
      ),
      Question(
        'What is the acceleration due to gravity on Earth?',
        ['9.8 m/s²', '10 m/s²', '8.9 m/s²', '11 m/s²'],
        '9.8 m/s²',
      ),
      Question(
        'Light travels fastest in:',
        ['water', 'glass', 'vacuum', 'air'],
        'vacuum',
      ),
    ],
    'Chemistry': [
      Question(
        'What is the chemical symbol for water?',
        ['H2O', 'CO2', 'NaCl', 'O2'],
        'H2O',
      ),
      Question(
        'How many protons does carbon have?',
        ['4', '6', '8', '12'],
        '6',
      ),
      Question(
        'What is the most abundant gas in Earth\'s atmosphere?',
        ['Oxygen', 'Carbon dioxide', 'Nitrogen', 'Hydrogen'],
        'Nitrogen',
      ),
    ],
  };

  List<Question> get currentQuestions => _questions[widget.subject] ?? [];

  void _selectAnswer(String answer) {
    if (!_answered) {
      setState(() {
        _selectedAnswer = answer;
        _answered = true;
        if (answer == currentQuestions[_currentQuestionIndex].correctAnswer) {
          _score++;
        }
      });
    }
  }

  void _nextQuestion() {
    setState(() {
      if (_currentQuestionIndex < currentQuestions.length - 1) {
        _currentQuestionIndex++;
        _selectedAnswer = '';
        _answered = false;
      } else {
        _showResults();
      }
    });
  }

  void _showResults() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quiz Completed!'),
        content: Text(
          'Your score: $_score/${currentQuestions.length}\n'
          'Percentage: ${((_score / currentQuestions.length) * 100).toStringAsFixed(1)}%'
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Back to Home'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetQuiz();
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  void _resetQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _score = 0;
      _selectedAnswer = '';
      _answered = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (currentQuestions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('${widget.subject} - Coming Soon'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: const Center(
          child: Text(
            'Questions for this subject are coming soon!',
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    final question = currentQuestions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.subject} Quiz'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress indicator
            LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / currentQuestions.length,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            const SizedBox(height: 16),
            
            // Question number and score
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Question ${_currentQuestionIndex + 1}/${currentQuestions.length}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                Text(
                  'Score: $_score',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Question text
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  question.questionText,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Answer options
            Expanded(
              child: ListView.builder(
                itemCount: question.options.length,
                itemBuilder: (context, index) {
                  final option = question.options[index];
                  final isSelected = _selectedAnswer == option;
                  final isCorrect = option == question.correctAnswer;
                  
                  Color? cardColor;
                  if (_answered) {
                    if (isCorrect) {
                      cardColor = Colors.green[100];
                    } else if (isSelected && !isCorrect) {
                      cardColor = Colors.red[100];
                    }
                  }
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Card(
                      color: cardColor,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isSelected ? Colors.blue : Colors.grey[300],
                          child: Text(
                            String.fromCharCode(65 + index), // A, B, C, D
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          option,
                          style: const TextStyle(fontSize: 16),
                        ),
                        onTap: () => _selectAnswer(option),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Next button
            if (_answered)
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _nextQuestion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      _currentQuestionIndex < currentQuestions.length - 1
                          ? 'Next Question'
                          : 'Show Results',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class Question {
  final String questionText;
  final List<String> options;
  final String correctAnswer;
  
  Question(this.questionText, this.options, this.correctAnswer);
}
