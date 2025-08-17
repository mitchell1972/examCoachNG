class AppConstants {
  // API Endpoints
  static const String authEndpoint = '/auth';
  static const String subjectsEndpoint = '/subjects';
  static const String syllabusEndpoint = '/syllabus';
  static const String packsEndpoint = '/packs';
  static const String sessionsEndpoint = '/sessions';
  static const String attemptsEndpoint = '/attempts';
  static const String entitlementsEndpoint = '/me/entitlements';
  static const String paymentsEndpoint = '/payments';
  static const String iapEndpoint = '/iap';
  
  // Shared Preferences Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String selectedSubjectsKey = 'selected_subjects';
  static const String onboardingCompleteKey = 'onboarding_complete';
  static const String lastSyncKey = 'last_sync';
  
  // Database Constants
  static const String dbName = 'examcoach.db';
  static const int dbVersion = 1;
  
  // Pack Constants
  static const int minPackVersion = 10;
  static const Duration packLifetime = Duration(days: 180);
  static const Duration cacheLifetime = Duration(days: 30);
  
  // Session Constants
  static const int mockExamDuration = 60; // minutes
  static const int defaultQuestionCount = 20;
  static const int mockQuestionCount = 60;
  
  // Retry Constants
  static const int maxRetries = 3;
  static const Duration baseDelay = Duration(seconds: 1);
  static const Duration maxDelay = Duration(seconds: 30);
  
  // Notification Constants
  static const String dailyPracticeChannelId = 'daily_practice';
  static const String streakReminderChannelId = 'streak_reminder';
  static const String newContentChannelId = 'new_content';
  static const String achievementChannelId = 'achievement';
  static const String paymentChannelId = 'payment';
  
  // Subject Codes
  static const List<String> availableSubjects = [
    'ENG',  // Use of English
    'MAT',  // Mathematics
    'PHY',  // Physics
    'CHE',  // Chemistry
    'BIO',  // Biology
    'ECO',  // Economics
    'GOV',  // Government
    'HIS',  // History
    'GEO',  // Geography
    'LIT',  // Literature
  ];
  
  // Subject Names
  static const Map<String, String> subjectNames = {
    'ENG': 'Use of English',
    'MAT': 'Mathematics',
    'PHY': 'Physics',
    'CHE': 'Chemistry',
    'BIO': 'Biology',
    'ECO': 'Economics',
    'GOV': 'Government',
    'HIS': 'History',
    'GEO': 'Geography',
    'LIT': 'Literature in English',
  };
  
  // Difficulty Levels
  static const Map<int, String> difficultyLevels = {
    1: 'Easy',
    2: 'Medium',
    3: 'Hard',
    4: 'Expert',
  };
  
  // Payment Plans
  static const Map<String, Map<String, dynamic>> paymentPlans = {
    'monthly': {
      'name': 'Monthly Plan',
      'price': 2000, // NGN
      'duration': 30, // days
      'features': [
        'Access to all subjects',
        'Unlimited practice sessions',
        'Mock exams',
        'Performance analytics',
        'Offline access',
      ],
    },
    'term': {
      'name': 'Term Plan',
      'price': 5000, // NGN
      'duration': 120, // days
      'features': [
        'Access to all subjects',
        'Unlimited practice sessions',
        'Mock exams',
        'Performance analytics',
        'Offline access',
        'Priority support',
      ],
    },
    'annual': {
      'name': 'Annual Plan',
      'price': 15000, // NGN
      'duration': 365, // days
      'features': [
        'Access to all subjects',
        'Unlimited practice sessions',
        'Mock exams',
        'Performance analytics',
        'Offline access',
        'Priority support',
        'Exam preparation guides',
      ],
    },
  };
  
  // Error Messages
  static const String networkError = 'Network connection error. Please check your internet connection.';
  static const String serverError = 'Server error. Please try again later.';
  static const String authError = 'Authentication failed. Please login again.';
  static const String validationError = 'Please check your input and try again.';
  static const String unknownError = 'An unknown error occurred. Please try again.';
  
  // Success Messages
  static const String loginSuccess = 'Login successful!';
  static const String packDownloadSuccess = 'Pack downloaded successfully!';
  static const String sessionCompleteSuccess = 'Session completed successfully!';
  static const String paymentSuccess = 'Payment successful!';
  
  // Validation Patterns
  static const String phonePattern = r'^\+?[1-9]\d{1,14}$';
  static const String otpPattern = r'^\d{6}$';
}
