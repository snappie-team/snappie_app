import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ============================================================================
// Auth Robot - Page Object Model for Authentication Integration Tests
// ============================================================================

/// Helper class that encapsulates UI interactions for authentication flows.
/// Follows the Page Object Model pattern for maintainable and readable tests.
class AuthRobot {
  final WidgetTester tester;

  AuthRobot(this.tester);

  /// Helper to scroll to and tap a widget
  Future<void> _ensureVisibleAndTap(Finder finder) async {
    final scrollable = find.byType(SingleChildScrollView);
    if (scrollable.evaluate().isNotEmpty) {
      try {
        await tester.scrollUntilVisible(
          finder,
          100.0,
          scrollable: scrollable,
          maxScrolls: 200, // Increase max scrolls
        );
      } catch (e) {
        // Ignore scroll errors, try ensureVisible next
      }
    }

    // Fallback to standard ensureVisible
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();

    expect(finder, findsOneWidget);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  // =========================================================================
  // Onboarding Actions
  // =========================================================================

  /// Verifies that the onboarding page is displayed.
  Future<void> verifyOnboardingDisplayed() async {
    expect(find.byKey(const Key('onboarding_page_view')), findsOneWidget);
  }

  /// Swipes through all onboarding pages and taps the start button.
  Future<void> completeOnboarding() async {
    // Find the PageView
    final pageView = find.byKey(const Key('onboarding_page_view'));
    expect(pageView, findsOneWidget);

    // Swipe through pages (3 pages total)
    for (int i = 0; i < 2; i++) {
      await tester.drag(pageView, const Offset(-400, 0));
      await tester.pumpAndSettle();
    }

    // Tap the start button on the last page
    final startButton = find.byKey(const Key('onboarding_start_button'));
    expect(startButton, findsOneWidget);
    await tester.tap(startButton);
    await tester.pumpAndSettle();
  }

  /// Taps the next button on onboarding.
  Future<void> tapOnboardingNext() async {
    final nextButton = find.byKey(const Key('onboarding_next_button'));
    if (nextButton.evaluate().isNotEmpty) {
      await tester.tap(nextButton);
      await tester.pumpAndSettle();
    } else {
      // Try start button if on last page
      final startButton = find.byKey(const Key('onboarding_start_button'));
      expect(startButton, findsOneWidget);
      await tester.tap(startButton);
      await tester.pumpAndSettle();
    }
  }

  /// Taps the back button on onboarding.
  Future<void> tapOnboardingBack() async {
    final backButton = find.byKey(const Key('onboarding_back_button'));
    expect(backButton, findsOneWidget);
    await tester.tap(backButton);
    await tester.pumpAndSettle();
  }

  // =========================================================================
  // Login Actions
  // =========================================================================

  /// Verifies that the login page is displayed.
  Future<void> verifyLoginDisplayed() async {
    expect(find.byKey(const Key('login_google_button')), findsOneWidget);
  }

  /// Taps the "Sign in with Google" button.
  Future<void> tapLoginWithGoogle() async {
    final loginButton = find.byKey(const Key('login_google_button'));
    expect(loginButton, findsOneWidget);
    await tester.tap(loginButton);
    await tester.pumpAndSettle();
  }

  /// Taps the "Sign up with Google" button.
  Future<void> tapSignUpWithGoogle() async {
    final signUpButton = find.byKey(const Key('register_google_button'));
    expect(signUpButton, findsOneWidget);
    await tester.tap(signUpButton);
    await tester.pumpAndSettle();
  }

  /// Verifies the mascot image is displayed on login.
  Future<void> verifyLoginMascotDisplayed() async {
    expect(find.byKey(const Key('login_mascot_image')), findsOneWidget);
  }

  // =========================================================================
  // Registration Actions
  // =========================================================================

  /// Verifies that the registration page is displayed.
  Future<void> verifyRegisterDisplayed() async {
    // Check for registration form elements
    expect(find.byKey(const Key('register_firstname_field')), findsOneWidget);
  }

  /// Fills the first name field.
  Future<void> enterFirstName(String firstName) async {
    final field = find.byKey(const Key('register_firstname_field'));
    await tester.ensureVisible(field);
    expect(field, findsOneWidget);
    await tester.enterText(field, firstName);
    await tester.pumpAndSettle();
  }

  /// Fills the last name field.
  Future<void> enterLastName(String lastName) async {
    final field = find.byKey(const Key('register_lastname_field'));
    await tester.ensureVisible(field);
    expect(field, findsOneWidget);
    await tester.enterText(field, lastName);
    await tester.pumpAndSettle();
  }

  /// Fills the username field.
  Future<void> enterUsername(String username) async {
    final field = find.byKey(const Key('register_username_field'));
    await tester.ensureVisible(field);
    expect(field, findsOneWidget);
    await tester.enterText(field, username);
    await tester.pumpAndSettle();
  }

  /// Selects gender (male or female).
  Future<void> selectGender(String gender) async {
    final key = gender.toLowerCase() == 'male'
        ? const Key('register_gender_male')
        : const Key('register_gender_female');
    final genderOption = find.byKey(key);
    await _ensureVisibleAndTap(genderOption);
  }

  /// Selects an avatar by index (0-3).
  Future<void> selectAvatar(int index) async {
    final avatarKey = Key('avatar_option_$index');
    var avatarOption = find.byKey(avatarKey);

    // If not found immediately, try creating it by scrolling if inside a scroll view
    if (avatarOption.evaluate().isEmpty) {
      // Find the SingleChildScrollView and drag up to show bottom content
      final scrollable = find.byType(SingleChildScrollView);
      if (scrollable.evaluate().isNotEmpty) {
        await tester.drag(scrollable, const Offset(0, -300));
        await tester.pumpAndSettle();
      }
    }

    avatarOption = find.byKey(avatarKey);
    if (avatarOption.evaluate().isNotEmpty) {
      await tester.ensureVisible(avatarOption);
      await tester.pumpAndSettle();
    }

    expect(avatarOption, findsOneWidget);
    await tester.tap(avatarOption);
    await tester.pumpAndSettle();
  }

  /// Taps the next button on registration form.
  Future<void> tapRegisterNext() async {
    final nextButton = find.byKey(const Key('register_next_button'));
    await _ensureVisibleAndTap(nextButton);
  }

  /// Taps the back button on registration form.
  Future<void> tapRegisterBack() async {
    final backButton = find.byKey(const Key('register_back_button'));
    await _ensureVisibleAndTap(backButton);
  }

  /// Taps the submit button on registration form.
  Future<void> tapRegisterSubmit() async {
    final submitButton = find.byKey(const Key('register_submit_button'));
    await _ensureVisibleAndTap(submitButton);
  }

  /// Selects food types by indices.
  Future<void> selectFoodTypes(List<int> indices) async {
    for (final index in indices) {
      final foodType = find.byKey(Key('food_type_$index'));
      // Find and ensure visible if it exists
      if (foodType.evaluate().isNotEmpty) {
        await _ensureVisibleAndTap(foodType);
      }
    }
  }

  /// Selects place values by indices.
  Future<void> selectPlaceValues(List<int> indices) async {
    for (final index in indices) {
      final placeValue = find.byKey(Key('place_value_$index'));
      if (placeValue.evaluate().isNotEmpty) {
        await _ensureVisibleAndTap(placeValue);
      }
    }
  }

  /// Fills the complete registration form (page 1).
  Future<void> fillUserDataForm({
    String firstName = 'Test',
    String lastName = 'User',
    String username = 'TestUser.123',
    String gender = 'male',
    int avatarIndex = 0,
  }) async {
    await enterFirstName(firstName);
    await enterLastName(lastName);
    await selectGender(gender);
    await selectAvatar(avatarIndex);
    await enterUsername(username);

    // Conditionally fill email if manual entry is required
    final emailField = find.byKey(const Key('register_email_field'));
    if (emailField.evaluate().isNotEmpty) {
      await _ensureVisibleAndTap(emailField);
      await tester.enterText(emailField, 'test@example.com');
      await tester.pumpAndSettle();
    }

    // Conditionally check terms if present
    final termsCheckbox = find.byKey(const Key('register_terms_checkbox'));
    if (termsCheckbox.evaluate().isNotEmpty) {
      // Check if already checked? Assuming unchecked.
      await _ensureVisibleAndTap(termsCheckbox);
    }
  }

  /// Completes the entire registration flow.
  Future<void> completeRegistration({
    String firstName = 'Test',
    String lastName = 'User',
    String username = 'TestUser.123',
    String gender = 'male',
    int avatarIndex = 0,
    List<int> foodTypeIndices = const [0, 1, 2],
    List<int> placeValueIndices = const [0, 1, 2],
  }) async {
    // Page 1: User data
    await fillUserDataForm(
      firstName: firstName,
      lastName: lastName,
      username: username,
      gender: gender,
      avatarIndex: avatarIndex,
    );
    await tapRegisterNext();

    // Page 2: Food types
    await selectFoodTypes(foodTypeIndices);
    await tapRegisterNext();

    // Page 3: Place values
    await selectPlaceValues(placeValueIndices);
    await tapRegisterSubmit();
  }

  // =========================================================================
  // Main Layout Actions
  // =========================================================================

  /// Verifies that the main layout (home) is displayed.
  Future<void> verifyMainLayoutDisplayed() async {
    expect(find.byKey(const Key('bottom_nav_home')), findsOneWidget);
  }

  /// Taps on a specific bottom navigation item.
  Future<void> tapBottomNav(String navItem) async {
    final navKey = Key('bottom_nav_$navItem');
    final navButton = find.byKey(navKey);
    expect(navButton, findsOneWidget);
    await tester.tap(navButton);
    await tester.pumpAndSettle();
  }

  // =========================================================================
  // Common Verifications
  // =========================================================================

  /// Verifies that a snackbar with certain text is displayed.
  Future<void> verifySnackbarDisplayed(String text) async {
    expect(find.text(text), findsOneWidget);
  }

  /// Verifies that a loading indicator is displayed.
  Future<void> verifyLoadingDisplayed() async {
    expect(find.byType(CircularProgressIndicator), findsWidgets);
  }

  /// Waits for loading to complete.
  Future<void> waitForLoadingToComplete({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    await tester.pumpAndSettle(timeout);
  }

  /// Dismisses any displayed dialogs.
  Future<void> dismissDialog() async {
    final dialogBackground = find.byType(ModalBarrier);
    if (dialogBackground.evaluate().isNotEmpty) {
      await tester.tapAt(Offset.zero);
      await tester.pumpAndSettle();
    }
  }
}
