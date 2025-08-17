class Env {
  static const String apiBase = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://examcoach-backend.repl.co',
  );
  
  static const String sentryDsn = String.fromEnvironment(
    'SENTRY_DSN',
    defaultValue: '',
  );
  
  static const String flavor = String.fromEnvironment(
    'FLAVOR',
    defaultValue: 'dev',
  );
  
  static const bool isProduction = String.fromEnvironment('FLAVOR') == 'prod';
  static const bool isDevelopment = String.fromEnvironment('FLAVOR') == 'dev';
  
  static const String appScheme = 'examcoach';
  
  // Payment configuration
  static const String paystackPublicKey = String.fromEnvironment(
    'PAYSTACK_PUBLIC_KEY',
    defaultValue: 'pk_test_default',
  );
  
  static const String flutterwavePublicKey = String.fromEnvironment(
    'FLUTTERWAVE_PUBLIC_KEY',
    defaultValue: 'FLWPUBK_TEST-default',
  );
}
