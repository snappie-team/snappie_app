import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:patrol/patrol.dart';
import 'package:snappie_app/app/data/models/gamification_model.dart';
import 'package:snappie_app/app/modules/profile/controllers/profile_controller.dart';
import 'package:snappie_app/app/routes/app_pages.dart';

import '../../common/test_app.dart';
import '../../mocks/mock_repositories.dart';
import '../explore/explore_test_helpers.dart';

void main() {
  patrolTest(
    'UC7.6 - Halaman Koin menampilkan tab Kupon dan Riwayat',
    ($) async {
      await initTestApp(
        $: $,
        initialRoute: AppPages.MAIN,
        isLoggedIn: true,
      );

      await $.tester.ensureVisible(find.byKey(const Key('bottom_nav_profile')));
      await pumpUi($, milliseconds: 500);
      await $(#bottom_nav_profile).tap();
      await pumpUi($, milliseconds: 1200);

      final profileController = Get.find<ProfileController>();
      expect(profileController.totalCoins, greaterThan(0));

      await $('${profileController.totalCoins} Koin').tap();
      await pumpUi($, milliseconds: 1400);

      expect(Get.currentRoute, AppPages.COINS_HISTORY);
      expect($('Koin'), findsOneWidget);
      expect($('Kupon'), findsOneWidget);
      expect($('Riwayat'), findsOneWidget);
      expect($('Belum ada riwayat koin'), findsOneWidget);

      await $('Kupon').tap();
      await pumpUi($, milliseconds: 900);
      expect($('Belum ada kupon tersedia'), findsOneWidget);
    },
  );

  patrolTest(
    'UC7.7 - Tab Riwayat menampilkan transaksi terkelompok per tanggal',
    ($) async {
      await initTestApp(
        $: $,
        initialRoute: AppPages.MAIN,
        isLoggedIn: true,
      );

      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));

      mockGamificationRepository.setCoinTransactions([
        CoinTransaction(
          id: 1,
          userId: 1,
          amount: 20,
          metadata: CoinTransactionMetadata(type: 'checkin', id: 11),
          createdAt: now.toIso8601String(),
          updatedAt: now.toIso8601String(),
        ),
        CoinTransaction(
          id: 2,
          userId: 1,
          amount: -10,
          metadata: CoinTransactionMetadata(type: 'redeem', id: 12),
          createdAt: yesterday.toIso8601String(),
          updatedAt: yesterday.toIso8601String(),
        ),
      ]);

      await $.tester.ensureVisible(find.byKey(const Key('bottom_nav_profile')));
      await pumpUi($, milliseconds: 500);
      await $(#bottom_nav_profile).tap();
      await pumpUi($, milliseconds: 1200);

      final profileController = Get.find<ProfileController>();
      await $('${profileController.totalCoins} Koin').tap();
      await pumpUi($, milliseconds: 1400);

      expect(Get.currentRoute, AppPages.COINS_HISTORY);
      expect($('Riwayat'), findsOneWidget);
      expect($('Hari ini'), findsOneWidget);
      expect($('Kemarin'), findsOneWidget);
      expect($('+20 Koin'), findsOneWidget);
      expect($('-10 Koin'), findsOneWidget);
    },
  );
}
