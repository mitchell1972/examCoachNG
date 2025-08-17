import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/phone_input_screen.dart';
import '../../features/auth/screens/otp_screen.dart';
import '../../features/catalog/screens/subjects_screen.dart';
import '../../features/catalog/screens/home_screen.dart';
import '../../features/practice/screens/practice_setup_screen.dart';
import '../../features/practice/screens/question_screen.dart';
import '../../features/mock/screens/mock_exam_screen.dart';
import '../../features/results/screens/results_screen.dart';
import '../../features/downloads/screens/downloads_screen.dart';
import '../../features/billing/screens/billing_screen.dart';
import '../../features/settings/screens/settings_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  
  return GoRouter(
    initialLocation: '/phone',
    redirect: (context, state) {
      final isAuthenticated = authState.valueOrNull?.isAuthenticated ?? false;
      final isAuthRoute = state.uri.path.startsWith('/phone') || 
                         state.uri.path.startsWith('/otp');
      
      if (!isAuthenticated && !isAuthRoute) {
        return '/phone';
      }
      
      if (isAuthenticated && isAuthRoute) {
        return '/home';
      }
      
      return null;
    },
    routes: [
      // Authentication routes
      GoRoute(
        path: '/phone',
        name: 'phone',
        builder: (context, state) => const PhoneInputScreen(),
      ),
      GoRoute(
        path: '/otp',
        name: 'otp',
        builder: (context, state) {
          final phone = state.uri.queryParameters['phone'] ?? '';
          return OtpScreen(phone: phone);
        },
      ),
      
      // Subject selection (onboarding)
      GoRoute(
        path: '/subjects',
        name: 'subjects',
        builder: (context, state) => const SubjectsScreen(),
      ),
      
      // Main app routes
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      
      // Practice routes
      GoRoute(
        path: '/practice/:subject',
        name: 'practice-setup',
        builder: (context, state) {
          final subject = state.pathParameters['subject']!;
          final topic = state.uri.queryParameters['topic'];
          return PracticeSetupScreen(subject: subject, topic: topic);
        },
      ),
      GoRoute(
        path: '/practice/:subject/session/:sessionId',
        name: 'practice-session',
        builder: (context, state) {
          final subject = state.pathParameters['subject']!;
          final sessionId = state.pathParameters['sessionId']!;
          return QuestionScreen(
            subject: subject,
            sessionId: sessionId,
            mode: 'practice',
          );
        },
      ),
      
      // Mock exam routes
      GoRoute(
        path: '/mock/:subject',
        name: 'mock-exam',
        builder: (context, state) {
          final subject = state.pathParameters['subject']!;
          final sessionId = state.uri.queryParameters['sessionId'];
          return MockExamScreen(subject: subject, sessionId: sessionId);
        },
      ),
      
      // Results
      GoRoute(
        path: '/results/:sessionId',
        name: 'results',
        builder: (context, state) {
          final sessionId = state.pathParameters['sessionId']!;
          return ResultsScreen(sessionId: sessionId);
        },
      ),
      
      // Downloads
      GoRoute(
        path: '/downloads',
        name: 'downloads',
        builder: (context, state) => const DownloadsScreen(),
      ),
      
      // Billing
      GoRoute(
        path: '/billing',
        name: 'billing',
        builder: (context, state) => const BillingScreen(),
      ),
      
      // Settings
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});
