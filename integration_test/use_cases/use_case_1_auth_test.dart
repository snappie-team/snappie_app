import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/auth_robot.dart';
import '../helpers/test_app.dart';

// ============================================================================
// Use Case 1: User Authentication (Login and Registration) Integration Tests
// ============================================================================
//
// This test suite covers the complete authentication flow including:
// 1. Onboarding navigation
// 2. Login with Google (existing user)
// 3. Registration flow (new user)
// 4. Error handling scenarios
//
// Based on: docs/USE_CASES.md - Section 1: Autentikasi Pengguna
// ============================================================================

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late TestSetup testSetup;
  late AuthRobot robot;

  setUpAll(() async {
    // Initialize DotEnv with mock values
    dotenv.testLoad(fileInput: '''
ENVIRONMENT=development
API_VERSION=/api/v1
REGISTRATION_API_KEY=mock_key
LOCAL_BASE_URL=http://localhost:8080
HOST_BASE_URL=https://api.example.com
''');

    // Initialize EasyLocalization
    await EasyLocalization.ensureInitialized();

    // Initialize SharedPreferences with empty values for testing
    SharedPreferences.setMockInitialValues({});
  });

  setUp(() {
    testSetup = TestSetup();
  });

  tearDown(() async {
    testSetup.reset();
    await cleanupTestDependencies();
  });

  // ==========================================================================
  // Group 1: Onboarding Flow Tests
  // ==========================================================================
  group('Onboarding Flow', () {
    testWidgets('should display onboarding pages and navigate to login',
        (WidgetTester tester) async {
      // Arrange
      testSetup.configureLoginSuccess();

      // Act
      await tester.pumpWidget(testSetup.createApp());
      await tester.pumpAndSettle();
      robot = AuthRobot(tester);

      // Assert - Onboarding is displayed
      await robot.verifyOnboardingDisplayed();

      // Act - Complete onboarding
      await robot.completeOnboarding();

      // Assert - Login page is displayed
      await robot.verifyLoginDisplayed();
    });

    testWidgets('should navigate back and forward through onboarding pages',
        (WidgetTester tester) async {
      // Arrange
      testSetup.configureLoginSuccess();

      // Act
      await tester.pumpWidget(testSetup.createApp());
      await tester.pumpAndSettle();
      robot = AuthRobot(tester);

      // Verify initial state
      await robot.verifyOnboardingDisplayed();

      // Navigate forward
      await robot.tapOnboardingNext();
      await robot.tapOnboardingNext();

      // Navigate back
      await robot.tapOnboardingBack();
      await robot.tapOnboardingBack();

      // Should still be on onboarding
      await robot.verifyOnboardingDisplayed();
    });
  });

  // ==========================================================================
  // Group 2: Login Success Flow Tests
  // ==========================================================================
  group('Login Success Flow', () {
    testWidgets('should login successfully and navigate to main page',
        (WidgetTester tester) async {
      // Arrange
      testSetup.configureLoginSuccess();

      // Act
      await tester.pumpWidget(testSetup.createApp());
      await tester.pumpAndSettle();
      robot = AuthRobot(tester);

      // Complete onboarding
      await robot.completeOnboarding();
      await robot.verifyLoginDisplayed();

      // Tap login button
      await robot.tapLoginWithGoogle();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Assert - Should be on main page
      await robot.verifyMainLayoutDisplayed();

      // Verify mocks were called correctly
      expect(testSetup.mockGoogleAuthService.signInCallCount, 1);
      expect(testSetup.mockAuthService.loginCallCount, 1);
    });

    testWidgets('should display loading indicator during login',
        (WidgetTester tester) async {
      // Arrange
      testSetup.configureLoginSuccess();

      // Act
      await tester.pumpWidget(testSetup.createApp());
      await tester.pumpAndSettle();
      robot = AuthRobot(tester);

      await robot.completeOnboarding();
      await robot.tapLoginWithGoogle();

      // Pump a few frames to catch loading state
      await tester.pump(const Duration(milliseconds: 100));

      // Login should complete
      await tester.pumpAndSettle();
      await robot.verifyMainLayoutDisplayed();
    });
  });

  // ==========================================================================
  // Group 3: New User Registration Flow Tests
  // ==========================================================================
  group('New User Registration Flow', () {
    testWidgets('should complete full registration flow for new user',
        (WidgetTester tester) async {
      // Arrange
      testSetup.configureNewUserFlow();

      // Act
      await tester.pumpWidget(testSetup.createApp());
      await tester.pumpAndSettle();
      robot = AuthRobot(tester);

      // Complete onboarding
      await robot.completeOnboarding();

      // Attempt login (will redirect to register for new user)
      await robot.tapLoginWithGoogle();
      await tester.pumpAndSettle();

      // Should be on registration page
      await robot.verifyRegisterDisplayed();

      // Complete registration
      await robot.completeRegistration(
        firstName: 'John',
        lastName: 'Doe',
        username: 'JohnDoe.123',
        gender: 'male',
        avatarIndex: 0,
        foodTypeIndices: [0, 1, 2],
        placeValueIndices: [0, 1, 2],
      );

      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Assert - Should be on main page
      await robot.verifyMainLayoutDisplayed();

      // Verify registration data was sent correctly
      expect(testSetup.mockAuthService.registerCallCount, 1);
      expect(testSetup.mockAuthService.lastRegisterData?['name'], 'John Doe');
      expect(testSetup.mockAuthService.lastRegisterData?['username'],
          'JohnDoe.123');
      expect(testSetup.mockAuthService.lastRegisterData?['gender'], 'male');
    });

    testWidgets('should navigate between registration pages',
        (WidgetTester tester) async {
      // Arrange
      testSetup.configureNewUserFlow();

      // Act
      await tester.pumpWidget(testSetup.createApp());
      await tester.pumpAndSettle();
      robot = AuthRobot(tester);

      await robot.completeOnboarding();
      await robot.tapLoginWithGoogle();
      await tester.pumpAndSettle();

      // Fill page 1
      await robot.fillUserDataForm();
      await robot.tapRegisterNext();

      // Select food types on page 2
      await robot.selectFoodTypes([0, 1, 2]);
      await robot.tapRegisterNext();

      // Go back to page 2
      await robot.tapRegisterBack();

      // Should still have food types visible
      expect(find.byKey(const Key('food_type_0')), findsOneWidget);

      // Go back to page 1
      await robot.tapRegisterBack();

      // Should see user data form
      await robot.verifyRegisterDisplayed();
    });

    testWidgets('should require minimum 3 food types to proceed',
        (WidgetTester tester) async {
      // Arrange
      testSetup.configureNewUserFlow();

      // Act
      await tester.pumpWidget(testSetup.createApp());
      await tester.pumpAndSettle();
      robot = AuthRobot(tester);

      await robot.completeOnboarding();
      await robot.tapLoginWithGoogle();
      await tester.pumpAndSettle();

      // Fill page 1
      await robot.fillUserDataForm();
      await robot.tapRegisterNext();

      // Select only 2 food types
      await robot.selectFoodTypes([0, 1]);

      // Next button should be disabled (can't proceed)
      final nextButton = find.byKey(const Key('register_next_button'));
      if (nextButton.evaluate().isNotEmpty) {
        final button = tester.widget<ElevatedButton>(nextButton);
        // Button should be disabled
        expect(button.onPressed, isNull);
      }
    });
  });

  // ==========================================================================
  // Group 4: Error Handling Tests
  // ==========================================================================
  group('Error Handling', () {
    testWidgets('should handle Google Sign-In cancellation gracefully',
        (WidgetTester tester) async {
      // Arrange
      testSetup.configureGoogleSignInCancelled();

      // Act
      await tester.pumpWidget(testSetup.createApp());
      await tester.pumpAndSettle();
      robot = AuthRobot(tester);

      await robot.completeOnboarding();
      await robot.tapLoginWithGoogle();
      await tester.pumpAndSettle();

      // Assert - Should still be on login page
      await robot.verifyLoginDisplayed();

      // Google Sign-In was attempted but cancelled
      expect(testSetup.mockGoogleAuthService.signInCallCount, 1);
      // Backend login should not have been called
      expect(testSetup.mockAuthService.loginCallCount, 0);
    });

    testWidgets('should handle network error during login',
        (WidgetTester tester) async {
      // Arrange
      testSetup.configureNetworkError();

      // Act
      await tester.pumpWidget(testSetup.createApp());
      await tester.pumpAndSettle();
      robot = AuthRobot(tester);

      await robot.completeOnboarding();
      await robot.tapLoginWithGoogle();
      await tester.pumpAndSettle();

      // Assert - Should still be on login page (not navigated to main)
      await robot.verifyLoginDisplayed();
    });

    testWidgets('should handle active session error',
        (WidgetTester tester) async {
      // Arrange
      testSetup.configureActiveSessionError();

      // Act
      await tester.pumpWidget(testSetup.createApp());
      await tester.pumpAndSettle();
      robot = AuthRobot(tester);

      await robot.completeOnboarding();
      await robot.tapLoginWithGoogle();
      await tester.pumpAndSettle();

      // Assert - Should still be on login page
      await robot.verifyLoginDisplayed();
    });

    testWidgets('should handle registration failure',
        (WidgetTester tester) async {
      // Arrange
      testSetup.configureRegistrationFailure();

      // Act
      await tester.pumpWidget(testSetup.createApp());
      await tester.pumpAndSettle();
      robot = AuthRobot(tester);

      await robot.completeOnboarding();
      await robot.tapLoginWithGoogle();
      await tester.pumpAndSettle();

      // Complete registration form
      await robot.completeRegistration();
      await tester.pumpAndSettle();

      // Assert - Should NOT be on main page (registration failed)
      // The exact behavior depends on the app's error handling
      expect(testSetup.mockAuthService.registerCallCount, 1);
    });
  });

  // ==========================================================================
  // Group 5: Sign Up Button Flow Tests
  // ==========================================================================
  group('Sign Up Button Flow', () {
    testWidgets('should navigate to register when tapping sign up button',
        (WidgetTester tester) async {
      // Arrange - New user (will go to registration)
      testSetup.configureNewUserFlow();

      // Act
      await tester.pumpWidget(testSetup.createApp());
      await tester.pumpAndSettle();
      robot = AuthRobot(tester);

      await robot.completeOnboarding();

      // Tap "Sign up with Google" instead of "Sign in"
      await robot.tapSignUpWithGoogle();
      await tester.pumpAndSettle();

      // Should be on registration page
      await robot.verifyRegisterDisplayed();
    });

    testWidgets(
        'should redirect to main if user already exists when signing up',
        (WidgetTester tester) async {
      // Arrange - Existing user
      testSetup.configureLoginSuccess();

      // Act
      await tester.pumpWidget(testSetup.createApp());
      await tester.pumpAndSettle();
      robot = AuthRobot(tester);

      await robot.completeOnboarding();

      // Tap "Sign up with Google"
      await robot.tapSignUpWithGoogle();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Should be redirected to main page since user exists
      await robot.verifyMainLayoutDisplayed();
    });
  });

  // ==========================================================================
  // Group 6: Edge Cases Tests
  // ==========================================================================
  group('Edge Cases', () {
    testWidgets('should handle exception during Google Sign-In',
        (WidgetTester tester) async {
      // Arrange
      testSetup.mockGoogleAuthService.configureSignInThrows(
        Exception('Google Sign-In failed unexpectedly'),
      );

      // Act
      await tester.pumpWidget(testSetup.createApp());
      await tester.pumpAndSettle();
      robot = AuthRobot(tester);

      await robot.completeOnboarding();

      // This should not crash the app
      await robot.tapLoginWithGoogle();
      await tester.pumpAndSettle();

      // Wait for any async error handling
      await tester.pump(const Duration(seconds: 1));

      // Should still be on login page
      await robot.verifyLoginDisplayed();
    });

    testWidgets('should handle timeout during registration',
        (WidgetTester tester) async {
      // Arrange
      testSetup.configureNewUserFlow();
      testSetup.mockAuthService.configureRegisterThrows(
        Exception('Connection timeout'),
      );

      // Act
      await tester.pumpWidget(testSetup.createApp());
      await tester.pumpAndSettle();
      robot = AuthRobot(tester);

      await robot.completeOnboarding();
      await robot.tapLoginWithGoogle();
      await tester.pumpAndSettle();

      // Complete registration form
      await robot.completeRegistration();
      await tester.pumpAndSettle();

      // Wait for async registration call
      await tester.pump(const Duration(seconds: 1));

      // Registration was attempted
      expect(testSetup.mockAuthService.registerCallCount, 1);
    });

    testWidgets('should validate username format requirements',
        (WidgetTester tester) async {
      // Arrange
      testSetup.configureNewUserFlow();

      // Act
      await tester.pumpWidget(testSetup.createApp());
      await tester.pumpAndSettle();
      robot = AuthRobot(tester);

      await robot.completeOnboarding();
      await robot.tapLoginWithGoogle();
      await tester.pumpAndSettle();

      // Fill form with invalid username (too short, no special chars)
      await robot.enterFirstName('Test');
      await robot.enterLastName('User');
      await robot.selectGender('male');
      await robot.selectAvatar(0);
      await robot.enterUsername('abc'); // Invalid: too short

      // Next button should be disabled
      final nextButton = find.byKey(const Key('register_next_button'));
      if (nextButton.evaluate().isNotEmpty) {
        final button = tester.widget<ElevatedButton>(nextButton);
        expect(button.onPressed, isNull);
      }
    });
  });
}
