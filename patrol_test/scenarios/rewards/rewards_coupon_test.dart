import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:patrol/patrol.dart';
import 'package:snappie_app/app/data/models/reward_model.dart';
import 'package:snappie_app/app/modules/profile/controllers/profile_controller.dart';
import 'package:snappie_app/app/routes/app_pages.dart';

import '../../common/test_app.dart';
import '../../mocks/mock_repositories.dart';
import '../explore/explore_test_helpers.dart';

Future<void> _openCoinsHistoryFromProfile(PatrolIntegrationTester $) async {
  await $.tester.ensureVisible(find.byKey(const Key('bottom_nav_profile')));
  await pumpUi($, milliseconds: 500);
  await $(#bottom_nav_profile).tap();
  await pumpUi($, milliseconds: 1200);

  final profileController = Get.find<ProfileController>();
  await $('${profileController.totalCoins} Koin').tap();
  await pumpUi($, milliseconds: 1400);

  expect(Get.currentRoute, AppPages.COINS_HISTORY);
}

void _setOneAvailableReward() {
  final reward = UserReward()
    ..id = 1
    ..name = 'Diskon 20%'
    ..description = 'Potongan harga untuk menu pilihan'
    ..coinRequirement = 80
    ..stock = 5
    ..status = true
    ..canRedeem = true
    ..isRedeemed = false
    ..isUsed = false
    ..isExpired = false
    ..additionalInfo = (RewardAdditionalInfo()
      ..deskripsi = 'Dapat dipakai untuk transaksi minimum 50rb'
      ..caraPakai = <String>[
        'Tukar kupon ini dengan koin',
        'Tekan tombol pakai untuk mendapatkan kode',
      ]
      ..syaratKetentuan = <String>[
        'Berlaku 1 kali per akun',
        'Tidak dapat digabung promo lain',
      ]);

  mockAchievementRepository.setAvailableRewards([reward]);
}

void main() {
  patrolTest(
    'UC9.1 - Tab Kupon menampilkan kupon yang tersedia',
    ($) async {
      await initTestApp(
        $: $,
        initialRoute: AppPages.MAIN,
        isLoggedIn: true,
      );

      _setOneAvailableReward();

      await _openCoinsHistoryFromProfile($);

      await $('Kupon').tap();
      await pumpUi($, milliseconds: 900);

      expect($('Diskon 20%'), findsOneWidget);
      expect($('80 Koin'), findsOneWidget);
      expect($('Detail'), findsOneWidget);
    },
  );

  patrolTest(
    'UC9.2 - Detail kupon menampilkan informasi penukaran',
    ($) async {
      await initTestApp(
        $: $,
        initialRoute: AppPages.MAIN,
        isLoggedIn: true,
      );

      _setOneAvailableReward();

      await _openCoinsHistoryFromProfile($);

      await $('Kupon').tap();
      await pumpUi($, milliseconds: 900);

      await $('Detail').tap();
      await pumpUi($, milliseconds: 1000);

      expect($('Tukar Kupon'), findsOneWidget);
      expect($('Diskon 20%'), findsWidgets);
      expect($('Deskripsi'), findsOneWidget);
      expect($('Cara Pakai'), findsOneWidget);
      expect($('Syarat dan Ketentuan'), findsOneWidget);
      expect($('Tukar'), findsOneWidget);
    },
  );

  patrolTest(
    'UC9.3 - Menukar kupon mengurangi koin user',
    ($) async {
      await initTestApp(
        $: $,
        initialRoute: AppPages.MAIN,
        isLoggedIn: true,
      );

      _setOneAvailableReward();

      final profileController = Get.find<ProfileController>();
      expect(profileController.totalCoins, 120);

      await _openCoinsHistoryFromProfile($);

      await $('Kupon').tap();
      await pumpUi($, milliseconds: 900);

      await $('Detail').tap();
      await pumpUi($, milliseconds: 1000);

      await $('Tukar').tap();
      await pumpUi($, milliseconds: 1400);

      expect(profileController.totalCoins, 40);
      expect($('Tekan "Pakai" untuk mengaktifkan kode kupon'), findsOneWidget);
      expect($('Pakai'), findsWidgets);
    },
  );

  patrolTest(
    'UC9.4 - Pakai kupon menampilkan kode kupon aktif',
    ($) async {
      await initTestApp(
        $: $,
        initialRoute: AppPages.MAIN,
        isLoggedIn: true,
      );

      _setOneAvailableReward();
      mockAchievementRepository.setUseRewardResponse(1000, {
        'redemption_code': 'UC9-CODE-001',
        'expires_at':
            DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
      });

      await _openCoinsHistoryFromProfile($);

      await $('Kupon').tap();
      await pumpUi($, milliseconds: 900);

      await $('Detail').tap();
      await pumpUi($, milliseconds: 1000);

      await $('Tukar').tap();
      await pumpUi($, milliseconds: 1200);

      await $('Pakai').tap();
      await pumpUi($, milliseconds: 1300);

      expect($('Kode Kupon untuk Diskon 20%'), findsOneWidget);
      expect($('UC9-CODE-001'), findsOneWidget);
      expect($('Salin'), findsOneWidget);
    },
  );

  patrolTest(
    'UC9.5 - Pull to refresh kupon memuat ulang daftar',
    ($) async {
      await initTestApp(
        $: $,
        initialRoute: AppPages.MAIN,
        isLoggedIn: true,
      );

      _setOneAvailableReward();

      await _openCoinsHistoryFromProfile($);

      await $('Kupon').tap();
      await pumpUi($, milliseconds: 900);

      await $.tester.drag(
        find.byType(CustomScrollView),
        const Offset(0, 350),
      );
      await pumpUi($, milliseconds: 1200);

      expect($('Diskon 20%'), findsOneWidget);
      expect($('Detail'), findsOneWidget);
    },
  );
}
