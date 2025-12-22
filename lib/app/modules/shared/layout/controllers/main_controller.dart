import 'package:get/get.dart';
import '../../../../core/services/app_update_service.dart';

class MainController extends GetxController {
  final _currentIndex = 3.obs;
  
  int get currentIndex => _currentIndex.value;
  
  void changeTab(int index) {
    _currentIndex.value = index;
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
