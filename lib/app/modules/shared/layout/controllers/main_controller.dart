import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../../core/services/app_update_service.dart';
import '../../../../core/services/logger_service.dart';
import '../../../../core/services/onboarding_service.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../home/controllers/home_controller.dart';
import '../../../explore/controllers/explore_controller.dart';
import '../../../articles/controllers/articles_controller.dart';
import '../../../profile/controllers/profile_controller.dart';
import '../../widgets/index.dart'; // To use TreasureChestModal

class MainController extends GetxController {
  final _currentIndex = 0.obs;
  int _previousIndex = 0;

  /// Maps tab index to the analytics screen name.
  static const _tabScreenNames = <int, String>{
    0: 'forum',
    1: 'catalog_home',
    2: 'article_page',
    3: 'user_profile',
  };

  // ─── Tab Tour State ─────────────────────────────────
  final showTabTour = false.obs;
  final currentTourStep = 0.obs;
  static const int _totalTourSteps = 4;

  int get currentIndex => _currentIndex.value;

  void changeTab(int index) {
    final wasDifferentTab = _previousIndex != index;
    _previousIndex = _currentIndex.value;
    _currentIndex.value = index;

    // Log screen_view for the newly selected tab
    final screenName = _tabScreenNames[index];
    if (screenName != null) {
      try {
        Get.find<AnalyticsService>().logScreenView(screenName: screenName);
      } catch (_) {}
    }

    // Refresh data saat switch ke Home atau Profile dari tab lain
    if (wasDifferentTab) {
      _refreshTabDataIfNeeded(index);
    }
  }

  /// Refresh data untuk tab Home (0) dan Profile (3) saat user switch ke tab tersebut
  void _refreshTabDataIfNeeded(int index) {
    switch (index) {
      case 0: // Home tab
        _refreshHomeData();
        break;
      case 3: // Profile tab
        _refreshProfileData();
        break;
    }
  }

  void _refreshHomeData() {
    try {
      final homeController = Get.find<HomeController>();
      // Only refresh if already initialized (has been opened before)
      if (homeController.posts.isNotEmpty) {
        Logger.debug(
            'MainController: Refreshing Home data on tab switch', 'Navigation');
        homeController.refreshData();
      }
    } catch (e) {
      Logger.warning(
          'MainController: HomeController not found, skipping refresh',
          'Navigation');
    }
  }

  void _refreshProfileData() {
    // Profile data is preloaded at startup, no need to refresh on every tab switch
    // User can manually pull-to-refresh if needed
  }

  // ─── Onboarding Flow (Harta Karun + Tab Tour) ───────

  /// Entry point for post-registration onboarding.
  /// Flows: Tab Tour -> Then Treasure Chest
  Future<void> checkAndStartOnboardingFlow() async {
    try {
      final onboarding = Get.find<OnboardingService>();
      if (onboarding.isNewRegistration) {
        final alreadySeen = await onboarding.hasSeenTabTour();
        if (!alreadySeen) {
          Logger.debug(
              'MainController: Starting onboarding flow', 'Navigation');

          // Step 1: Start Tab Tour
          _startTabTour();
        }
        onboarding.clearNewRegistration();
      }
    } catch (e) {
      Logger.warning(
          'MainController: OnboardingService check failed', 'Navigation');
    }
  }

  void _showTreasureChest(VoidCallback onComplete) {
    TreasureChestModal.show(
      onDismiss: onComplete,
    );
  }

  void _startTabTour() {
    Logger.debug('MainController: Starting tab tour', 'Navigation');
    _currentIndex.value = 0;
    currentTourStep.value = 0;
    showTabTour.value = true;
  }

  /// Advance to the next tour step. On the last step, complete the tour.
  void nextTourStep() {
    if (currentTourStep.value < _totalTourSteps - 1) {
      currentTourStep.value++;
      // Switch tab to match the tour step
      _currentIndex.value = currentTourStep.value;
      Logger.debug(
        'MainController: Tour step ${currentTourStep.value + 1}/$_totalTourSteps',
        'Navigation',
      );
    } else {
      completeTour();
    }
  }

  /// Go back to the previous tour step.
  void previousTourStep() {
    if (currentTourStep.value > 0) {
      currentTourStep.value--;
      // Switch tab back
      _currentIndex.value = currentTourStep.value;
      Logger.debug(
        'MainController: Back to tour step ${currentTourStep.value + 1}/$_totalTourSteps',
        'Navigation',
      );
    }
  }

  /// Skip or complete the tour — hide overlay and persist the flag.
  void skipTour() => completeTour();

  void completeTour() {
    showTabTour.value = false;
    // Return to Beranda after tour
    _currentIndex.value = 0;
    _persistTourSeen();
    Logger.debug('MainController: Tab tour completed', 'Navigation');

    // Step 2: Show Treasure Chest after tour
    _showTreasureChest(() {
      Logger.debug(
          'MainController: Onboarding flow fully complete', 'Navigation');
    });
  }

  Future<void> _persistTourSeen() async {
    try {
      final onboarding = Get.find<OnboardingService>();
      await onboarding.markTabTourSeen();
    } catch (_) {}
  }

  /// Debug method to manually trigger onboarding flow for testing
  void debugShowOnboarding() {
    Logger.info('MainController: Manually triggering onboarding flow', 'DEBUG');
    _startTabTour();
  }

  @override
  void onReady() {
    super.onReady();
    try {
      final updater = Get.find<AppUpdateService>();
      updater.checkAndPrompt();
    } catch (_) {}

    // Preload all tab data so users don't see loading on tab switch
    _preloadAllTabs();

    // Check if onboarding flow should be shown
    checkAndStartOnboardingFlow();
  }

  /// Preload data for all 4 main tabs at startup
  void _preloadAllTabs() {
    try {
      Get.find<HomeController>().initializeIfNeeded();
      Get.find<ExploreController>().initializeIfNeeded();
      Get.find<ArticlesController>().initializeIfNeeded();
      Get.find<ProfileController>().initializeIfNeeded();
      Logger.debug('MainController: All tabs preloaded', 'Navigation');
    } catch (e) {
      Logger.warning(
          'MainController: Failed to preload tabs: $e', 'Navigation');
    }
  }
}
