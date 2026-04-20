import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:patrol/patrol.dart';
import 'package:snappie_app/app/modules/explore/controllers/explore_controller.dart';
import 'package:snappie_app/app/routes/app_pages.dart';

import '../../common/test_app.dart';
import 'explore_test_helpers.dart';

void main() {
  patrolTest(
    'UC2.6 - Tap place card navigasi ke detail tempat',
    ($) async {
      await initTestApp(
        $: $,
        initialRoute: AppPages.MAIN,
        isLoggedIn: true,
      );

      await openExploreTab($);

      await $.tester.ensureVisible(find.byKey(const Key('place_card_1')));
      await pumpUi($, milliseconds: 700);
      await $(#place_card_1).tap();
      await pumpUi($, milliseconds: 900);

      expect($('Warung Hidden Gem'), findsWidgets);
      expect($('Alamat'), findsOneWidget);
    },
  );

  patrolTest(
    'UC2.7 - Toggle favorite di detail menampilkan status',
    ($) async {
      await initTestApp(
        $: $,
        initialRoute: AppPages.MAIN,
        isLoggedIn: true,
      );

      await openExploreTab($);
      await $.tester.ensureVisible(find.byKey(const Key('place_card_1')));
      await pumpUi($, milliseconds: 700);
      await $(#place_card_1).tap();
      await pumpUi($, milliseconds: 900);

      final controller = Get.find<ExploreController>();
      final isSavedBefore = controller.isPlaceSaved(1);

      await $(#place_detail_save_button).tap();
      await pumpUi($, milliseconds: 900);

      final isSavedAfter = controller.isPlaceSaved(1);

      expect(isSavedAfter, isNot(isSavedBefore));
    },
  );

  patrolTest(
    'UC2.8 - Di detail lihat reviews menuju halaman ulasan',
    ($) async {
      await initTestApp(
        $: $,
        initialRoute: AppPages.MAIN,
        isLoggedIn: true,
      );

      await openExploreTab($);
      await $.tester.ensureVisible(find.byKey(const Key('place_card_1')));
      await pumpUi($, milliseconds: 700);
      await $(#place_card_1).tap();
      await pumpUi($, milliseconds: 900);

      await $.tester
          .ensureVisible(find.byKey(const Key('place_detail_review_see_all')));
        await pumpUi($, milliseconds: 700);
      await $(#place_detail_review_see_all).tap();
        await pumpUi($, milliseconds: 900);

      expect($('Ulasan'), findsOneWidget);
    },
  );
}
