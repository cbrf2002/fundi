class AppConfig {
  static const String appName = 'Fundi';
  static const String appVersion = '0.1.1';
  static const int buildNumber = 260;
  
  // Minimum supported versions
  static const String minSupportedAndroidVersion = '31'; // Android 12
  static const String minSupportedIOSVersion = '15.0';
  
  // Feature flags
  static const bool enableAnalytics = true;
  static const bool enablePushNotifications = false;
  
  // API configurations
  static const int apiTimeoutSeconds = 30;
  static const int maxRetryAttempts = 3;
}
