import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'logger_service.dart';

/// Service to manage post-registration onboarding state (tab tour).
///
/// Tracks whether the user has completed the "tab tour" coach marks
/// that explain each navigation tab after first registration.
class OnboardingService extends GetxService {
  static const String _keyTabTourCompleted = 'has_seen_tab_tour';

  /// In-memory flag set by AuthController after a successful registration.
  /// This is NOT persisted — it resets on app restart, which is intentional:
  /// the tour should only show immediately after registration, not on
  /// subsequent app launches.
  bool _isNewRegistration = false;

  bool get isNewRegistration => _isNewRegistration;

  /// Mark that a fresh registration just happened (call before navigating to /main).
  /// Also resets the persistent "seen" flag to ensure the tour triggers for this new user.
  Future<void> markAsNewRegistration() async {
    _isNewRegistration = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyTabTourCompleted, false);
    Logger.debug(
        'OnboardingService: Marked as new registration and reset persistent flag',
        'Onboarding');
  }

  /// Clear the new-registration flag (called after the tour is shown or skipped).
  void clearNewRegistration() {
    _isNewRegistration = false;
  }

  /// Check if the user has already completed the tab tour.
  Future<bool> hasSeenTabTour() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyTabTourCompleted) ?? false;
  }

  /// Persist that the user has completed (or skipped) the tab tour.
  Future<void> markTabTourSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyTabTourCompleted, true);
    _isNewRegistration = false;
    Logger.debug('OnboardingService: Tab tour marked as seen', 'Onboarding');
  }
}
