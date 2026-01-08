import 'package:get/get.dart';
import '../../../../core/services/app_update_service.dart';
import '../../../../core/services/logger_service.dart';
import '../../../home/controllers/home_controller.dart';
import '../../../profile/controllers/profile_controller.dart';

class MainController extends GetxController {
  final _currentIndex = 3.obs;
  int _previousIndex = 3;
  
  int get currentIndex => _currentIndex.value;
  
  void changeTab(int index) {
    final wasDifferentTab = _previousIndex != index;
    _previousIndex = _currentIndex.value;
    _currentIndex.value = index;
    
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
        Logger.debug('MainController: Refreshing Home data on tab switch', 'Navigation');
        homeController.refreshData();
      }
    } catch (e) {
      Logger.warning('MainController: HomeController not found, skipping refresh', 'Navigation');
    }
  }

  void _refreshProfileData() {
    try {
      final profileController = Get.find<ProfileController>();
      // Only refresh if already initialized (has been opened before)
      if (profileController.userData != null) {
        Logger.debug('MainController: Refreshing Profile data on tab switch', 'Navigation');
        profileController.refreshData();
      }
    } catch (e) {
      Logger.warning('MainController: ProfileController not found, skipping refresh', 'Navigation');
    }
  }

  @override
  void onReady() {
    super.onReady();
    try {
      final updater = Get.find<AppUpdateService>();
      updater.checkAndPrompt();
    } catch (_) {}
  }
}
