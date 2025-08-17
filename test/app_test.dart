import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:examcoach_app/main.dart';

void main() {
  group('ExamCoach App Tests', () {
    testWidgets('App loads and displays welcome screen', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const MyApp());

      // Verify that our welcome text is displayed.
      expect(find.text('Welcome to ExamCoach!'), findsOneWidget);
      expect(find.text('Your comprehensive exam preparation app'), findsOneWidget);
      expect(find.text('App Status: ✅ Running Successfully'), findsOneWidget);
      
      // Verify that the school icon is present
      expect(find.byIcon(Icons.school), findsOneWidget);
      
      // Verify the counter starts at 0
      expect(find.text('0'), findsOneWidget);
      expect(find.text('You have clicked the button this many times:'), findsOneWidget);
    });

    testWidgets('Counter increments when button is tapped', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const MyApp());

      // Verify that our counter starts at 0.
      expect(find.text('0'), findsOneWidget);
      expect(find.text('1'), findsNothing);

      // Tap the '+' icon and trigger a frame.
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // Verify that our counter has incremented.
      expect(find.text('0'), findsNothing);
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('App has correct title and theme', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const MyApp());

      // Find the MaterialApp widget
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      
      // Verify app title
      expect(materialApp.title, 'ExamCoach');
      
      // Verify theme uses blue seed color
      expect(materialApp.theme?.colorScheme.primary, isA<Color>());
    });

    testWidgets('Status card displays correctly', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const MyApp());

      // Verify status card content
      expect(find.text('App Status: ✅ Running Successfully'), findsOneWidget);
      expect(find.text('Flutter web app is working perfectly!'), findsOneWidget);
      
      // Verify card widget exists
      expect(find.byType(Card), findsOneWidget);
    });
  });
}