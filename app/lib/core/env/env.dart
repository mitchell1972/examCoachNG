import 'dart:io';

class Env {
  static const apiBase = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://examcoach-backend.repl.co',
  );
  
  static const sentryDsn = String.fromEnvironment(
    'SENTRY_DSN',
    defaultValue: '',
  );
  
  static const flavor = String.fromEnvironment(
    'FLAVOR',
    defaultValue: 'dev',
  );
  
  static const paystackPublicKey = String.fromEnvironment(
    'PAYSTACK_PUBLIC_KEY',
    defaultValue: 'pk_test_default',
  );
  
  static const flutterwavePublicKey = String.fromEnvironment(
    'FLUTTERWAVE_PUBLIC_KEY',
    defaultValue: 'FLWPUBK_TEST-default',
  );
  
  static bool get isProduction => flavor == 'prod';
  static bool get isDevelopment => flavor == 'dev';
  
  static String get baseUrl => apiBase;
  
  static String get platform => Platform.isAndroid ? 'android' : 'ios';
  
  // Deep link scheme
  static const deepLinkScheme = 'examcoach';
  static const deepLinkHost = 'app';
  
  // Firebase configuration
  static const firebaseProjectId = 'examcoach-app';
  
  // Version info
  static const appVersion = '1.0.0';
  static const minSupportedVersion = '1.0.0';
}
