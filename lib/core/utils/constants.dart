class AppConstants {
  // App Info
  static const String appName = 'ExamCoach';
  static const String appVersion = '1.0.0';
  
  // Database
  static const String databaseName = 'examcoach.db';
  static const int databaseVersion = 1;
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int questionsPerPage = 20;
  
  // Session limits
  static const int maxPracticeQuestions = 100;
  static const int mockExamQuestions = 60;
  static const int mockExamDurationMinutes = 60;
  
  // Retry configuration
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 1);
  static const Duration maxRetryDelay = Duration(seconds: 30);
  
  // Cache durations
  static const Duration manifestCacheDuration = Duration(hours: 6);
  static const Duration entitlementCacheDuration = Duration(minutes: 30);
  
  // Pack configuration
  static const int minPackVersion = 10;
  static const Duration packLifetime = Duration(days: 180);
  static const int maxPackSizeMB = 50;
  
  // Notification channels
  static const String dailyReminderChannelId = 'daily_reminder';
  static const String generalChannelId = 'general';
  static const String achievementChannelId = 'achievement';
  
  // Deep link schemes
  static const String deepLinkScheme = 'examcoach';
  
  // Error messages
  static const String networkErrorMessage = 'Please check your internet connection and try again.';
  static const String serverErrorMessage = 'Something went wrong. Please try again later.';
  static const String unauthorizedErrorMessage = 'Your session has expired. Please login again.';
  
  // Success messages
  static const String loginSuccessMessage = 'Welcome back!';
  static const String packDownloadSuccessMessage = 'Question pack downloaded successfully.';
  static const String sessionCompleteMessage = 'Session completed successfully!';
}

class ApiEndpoints {
  // Auth
  static const String otpStart = '/auth/otp/start';
  static const String otpVerify = '/auth/otp/verify';
  
  // Catalog
  static const String subjects = '/subjects';
  static String syllabus(String subject) => '/syllabus/$subject';
  
  // Packs
  static const String packsManifest = '/packs/manifest';
  static String packDownload(String packId) => '/packs/$packId';
  
  // Sessions
  static const String sessions = '/sessions';
  static const String attemptsBatch = '/attempts/batch';
  static String sessionSubmit(String sessionId) => '/sessions/$sessionId/submit';
  
  // Entitlements
  static const String entitlements = '/me/entitlements';
  static const String paymentsInit = '/payments/init';
  static const String iapVerify = '/iap/ios/verify';
  
  // User
  static const String userProfile = '/me/profile';
  static const String userStats = '/me/stats';
}

class StorageKeys {
  static const String authToken = 'auth_token';
  static const String userId = 'user_id';
  static const String selectedSubjects = 'selected_subjects';
  static const String onboardingComplete = 'onboarding_complete';
  static const String lastSyncTime = 'last_sync_time';
  static const String notificationsEnabled = 'notifications_enabled';
  static const String analyticsEnabled = 'analytics_enabled';
}

class Subjects {
  static const String english = 'ENG';
  static const String mathematics = 'MTH';
  static const String physics = 'PHY';
  static const String chemistry = 'CHM';
  static const String biology = 'BIO';
  static const String government = 'GOV';
  static const String economics = 'ECO';
  static const String literature = 'LIT';
  static const String geography = 'GEO';
  static const String history = 'HIS';
  
  static const Map<String, String> subjectNames = {
    english: 'Use of English',
    mathematics: 'Mathematics',
    physics: 'Physics',
    chemistry: 'Chemistry',
    biology: 'Biology',
    government: 'Government',
    economics: 'Economics',
    literature: 'Literature in English',
    geography: 'Geography',
    history: 'History',
  };
  
  static const List<String> coreSubjects = [english];
  static const List<String> electiveSubjects = [
    mathematics, physics, chemistry, biology,
    government, economics, literature, geography, history,
  ];
}
