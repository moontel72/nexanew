//lib/core/constants/app_constants.dart
// App Constants for NexaTrace System
// This file contains application-wide constants

class AppConstants {
  // App Info
  static const String appName = 'NexaTrace';
  static const String appVersion = '1.0.0';

  // API Configuration
  static const String baseUrl = 'http://135.181.46.27/api/v1';
  static const int apiTimeout = 30000; // 30 seconds

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Cache
  static const int cacheDuration = 300; // 5 minutes in seconds

  // Date Formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';

  // Local Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  static const String selectedFactoryKey = 'selected_factory';
  static const String languageKey = 'app_language';

  // Supported Languages
  static const List<String> supportedLanguages = ['en', 'ur'];
  static const String defaultLanguage = 'en';

  // App Themes
  static const String lightTheme = 'light';
  static const String darkTheme = 'dark';
  static const String systemTheme = 'system';
}
