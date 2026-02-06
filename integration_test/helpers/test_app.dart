import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:snappie_app/app/core/services/auth_service.dart';
import 'package:snappie_app/app/core/services/google_auth_service.dart';
import 'package:snappie_app/app/routes/app_pages.dart';
import 'package:snappie_app/app/data/repositories/achievement_repository_impl.dart';
import 'package:snappie_app/app/data/repositories/checkin_repository_impl.dart';
import 'package:snappie_app/app/data/repositories/gamification_repository_impl.dart';
import 'package:snappie_app/app/data/repositories/place_repository_impl.dart';
import 'package:snappie_app/app/data/repositories/post_repository_impl.dart';
import 'package:snappie_app/app/data/repositories/review_repository_impl.dart';
import 'package:snappie_app/app/data/repositories/social_repository_impl.dart';
import 'package:snappie_app/app/data/repositories/user_repository_impl.dart';

import '../mocks/auth_mocks.dart';
import '../mocks/repository_mocks.dart';

// ============================================================================
// Test App Configuration
// ============================================================================

/// Creates a testable app widget with mocked dependencies.
///
/// This function sets up the GetX dependency injection with mock services
/// and wraps the app with necessary providers for testing.
Widget createTestApp({
  MockAuthService? mockAuthService,
  MockGoogleAuthService? mockGoogleAuthService,
  String initialRoute = AppPages.ONBOARDING,
}) {
  // Initialize auth mocks if not provided
  final authService = mockAuthService ?? MockAuthService();
  final googleAuthService = mockGoogleAuthService ?? MockGoogleAuthService();

  // Register Auth mocks with GetX
  Get.put<AuthService>(authService, permanent: true);
  Get.put<GoogleAuthService>(googleAuthService, permanent: true);

  // Register Repository mocks required by MainBinding validation
  Get.put<UserRepository>(MockUserRepository(), permanent: true);
  Get.put<PostRepository>(MockPostRepository(), permanent: true);
  Get.put<PlaceRepository>(MockPlaceRepository(), permanent: true);
  Get.put<ReviewRepository>(MockReviewRepository(), permanent: true);
  Get.put<CheckinRepository>(MockCheckinRepository(), permanent: true);
  Get.put<SocialRepository>(MockSocialRepository(), permanent: true);
  Get.put<GamificationRepository>(MockGamificationRepository(),
      permanent: true);
  Get.put<AchievementRepository>(MockAchievementRepository(), permanent: true);

  return EasyLocalization(
    supportedLocales: const [Locale('id'), Locale('en')],
    path: 'assets/translations',
    fallbackLocale: const Locale('id'),
    child: Builder(
      builder: (context) => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        locale: context.locale,
        supportedLocales: context.supportedLocales,
        localizationsDelegates: context.localizationDelegates,
        initialRoute: initialRoute,
        getPages: AppPages.routes,
        theme: ThemeData(
          primarySwatch: Colors.teal,
          useMaterial3: true,
        ),
      ),
    ),
  );
}

/// Cleans up all registered GetX dependencies.
///
/// Call this in tearDown to ensure tests are isolated.
Future<void> cleanupTestDependencies() async {
  await Get.deleteAll(force: true);
  Get.reset();
}

/// Setup helper that initializes mocks with common configurations.
class TestSetup {
  final MockAuthService mockAuthService;
  final MockGoogleAuthService mockGoogleAuthService;

  TestSetup({
    MockAuthService? authService,
    MockGoogleAuthService? googleAuthService,
  })  : mockAuthService = authService ?? MockAuthService(),
        mockGoogleAuthService = googleAuthService ?? MockGoogleAuthService();

  /// Configure for successful login flow (existing user).
  void configureLoginSuccess() {
    mockGoogleAuthService.configureSignInSuccess();
    mockAuthService.configureLoginSuccess();
  }

  /// Configure for new user registration flow.
  void configureNewUserFlow() {
    mockGoogleAuthService.configureSignInSuccess();
    mockAuthService.configureLoginUserNotFound();
    mockAuthService.configureRegisterSuccess();
  }

  /// Configure for login with active session error.
  void configureActiveSessionError() {
    mockGoogleAuthService.configureSignInSuccess();
    mockAuthService.configureLoginActiveSession();
  }

  /// Configure for network error during login.
  void configureNetworkError() {
    mockGoogleAuthService.configureSignInSuccess();
    mockAuthService.configureLoginNetworkError();
  }

  /// Configure for Google Sign-In cancellation.
  void configureGoogleSignInCancelled() {
    mockGoogleAuthService.configureSignInCancelled();
  }

  /// Configure for registration failure.
  void configureRegistrationFailure() {
    mockGoogleAuthService.configureSignInSuccess();
    mockAuthService.configureLoginUserNotFound();
    mockAuthService.configureRegisterFailure();
  }

  /// Reset all mocks to default state.
  void reset() {
    mockAuthService.reset();
    mockGoogleAuthService.reset();
  }

  /// Creates the test app widget with the configured mocks.
  Widget createApp({String initialRoute = AppPages.ONBOARDING}) {
    return createTestApp(
      mockAuthService: mockAuthService,
      mockGoogleAuthService: mockGoogleAuthService,
      initialRoute: initialRoute,
    );
  }
}
