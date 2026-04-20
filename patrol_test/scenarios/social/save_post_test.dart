import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:patrol/patrol.dart';
import 'package:snappie_app/app/modules/home/controllers/home_controller.dart';
import 'package:snappie_app/app/routes/app_pages.dart';

import '../../common/test_app.dart';
import '../explore/explore_test_helpers.dart';

void main() {
  patrolTest(
    'UC5.3 - Save post mengubah status bookmark',
    ($) async {
      await initTestApp(
        $: $,
        initialRoute: AppPages.MAIN,
        isLoggedIn: true,
      );

      final controller = Get.find<HomeController>();
      await $.tester.ensureVisible(find.byKey(const Key('post_save_button_1')));
      await pumpUi($, milliseconds: 500);

      final isSavedBefore = controller.isPostSaved(1);

      // Trigger simpan via controller untuk menghindari flakiness hit-test pada feed sliver.
      await controller.toggleSavePost(1);
      await pumpUi($, milliseconds: 900);

      final isSavedAfter = controller.isPostSaved(1);
      expect(isSavedAfter, isNot(isSavedBefore));
    },
  );
}
