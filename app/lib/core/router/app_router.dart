import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../../features/onboarding/screens/welcome_screen.dart';
import '../../features/auth/screens/phone_screen.dart';
import '../../features/auth/screens/otp_screen.dart';
import '../../features/onboarding/screens/subject_selection_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/practice/screens/practice_screen.dart';
import '../../features/practice/screens/question_screen.dart';
import '../../features/mock/screens/mock_screen.dart';
import '../../features/mock/screens/mock_question_screen.dart';
import '../../features/results/screens/results_screen.dart';
import '../../features/downloads/screens/downloads_screen.dart';
import '../../features/billing/screens/billing_screen.dart';
import '../../features/settings/screens/settings_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  
  return GoRouter(
    initialLocation: '/welcome',
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final location = state.location;
      
      // Handle authentication redirects
      if (!isAuthenticated && !_isPublicRoute(location)) {
        return '/welcome';
      }
      
      if (isAuthenticated && _isAuthRoute(location)) {
        return '/home';
      }
      
      return null;
    },
    routes: [
      GoRoute(
        path: '/welcome',
        name: 'welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/phone',
        name: 'phone',
        builder: (context, state) => const PhoneScreen(),
      ),
      GoRoute(
        path: '/otp',
        name: 'otp',
        builder: (context, state) {
          final phone = state.queryParams['phone'] ?? '';
          return OTPScreen(phoneNumber: phone);
        },
      ),
      GoRoute(
        path: '/subjects',
        name: 'subjects',
        builder: (context, state) => const SubjectSelectionScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'practice/:subject',
            name: 'practice',
            builder: (context, state) {
              final subject = state.params['subject']!;
              final topic = state.queryParams['topic'];
              return PracticeScreen(subject: subject, topic: topic);
            },
            routes: [
              GoRoute(
                path: 'question',
                name: 'practice-question',
                builder: (context, state) {
                  final subject = state.params['subject']!;
                  return QuestionScreen(subject: subject);
                },
              ),
            ],
          ),
          GoRoute(
            path: 'mock/:subject',
            name: 'mock',
            builder: (context, state) {
              final subject = state.params['subject']!;
              return MockScreen(subject: subject);
            },
            routes: [
              GoRoute(
                path: 'question',
                name: 'mock-question',
                builder: (context, state) {
                  final subject = state.params['subject']!;
                  return MockQuestionScreen(subject: subject);
                },
              ),
            ],
          ),
          GoRoute(
            path: 'results/:sessionId',
            name: 'results',
            builder: (context, state) {
              final sessionId = state.params['sessionId']!;
              return ResultsScreen(sessionId: sessionId);
            },
          ),
          GoRoute(
            path: 'downloads',
            name: 'downloads',
            builder: (context, state) => const DownloadsScreen(),
          ),
          GoRoute(
            path: 'billing',
            name: 'billing',
            builder: (context, state) => const BillingScreen(),
          ),
          GoRoute(
            path: 'settings',
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.error.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});

bool _isPublicRoute(String location) {
  return location.startsWith('/welcome') ||
         location.startsWith('/phone') ||
         location.startsWith('/otp');
}

bool _isAuthRoute(String location) {
  return location.startsWith('/welcome') ||
         location.startsWith('/phone') ||
         location.startsWith('/otp') ||
         location.startsWith('/subjects');
}
