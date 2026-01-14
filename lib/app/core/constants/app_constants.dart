import 'environment_config.dart';

class AppConstants {
  // API Configuration - Now using EnvironmentConfig
  static String get baseUrl => EnvironmentConfig.baseUrl;
  static String get apiVersion => EnvironmentConfig.apiVersion;
  static Duration get connectionTimeout => EnvironmentConfig.connectionTimeout;
  static Duration get receiveTimeout => EnvironmentConfig.receiveTimeout;
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';
  static const String onboardingKey = 'onboarding_completed';
  
  // App Info
  static const String appName = 'Snappie App';
  static const String appVersion = '1.1.3';
  static const int appVersionCode = 4;
  static const String appDescription = 'Discover and explore amazing places';
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Validation
  static const int minPasswordLength = 8;
  static const int maxUsernameLength = 50;
  static const int maxReviewLength = 500;
  
  // Location
  static const double defaultLatitude = -6.2088; // Jakarta
  static const double defaultLongitude = 106.8456;
  static const double maxCheckinDistance = 100.0; // meters
  
  // Rewards
  static const int baseExpPerCheckin = 20;
  static const int baseCoinsPerCheckin = 10;
  static const int bonusExpForReview = 5;
  static const int bonusCoinsForReview = 3;
  
  // Cache
  static const Duration placesCacheDuration = Duration(minutes: 15);
  static const Duration userDataCacheDuration = Duration(hours: 1);
  static const Duration articlesCacheDuration = Duration(hours: 2);
  
  // UI
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration snackbarDuration = Duration(seconds: 3);
  static const double defaultBorderRadius = 12.0;
  static const double defaultPadding = 16.0;
}
