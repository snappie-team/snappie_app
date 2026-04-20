import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:patrol/patrol.dart';
import 'package:snappie_app/app/modules/profile/controllers/profile_controller.dart';
import 'package:snappie_app/app/routes/app_pages.dart';

import '../../common/test_app.dart';
import '../explore/explore_test_helpers.dart';

Future<void> _openLeaderboardFromProfile(PatrolIntegrationTester $) async {
  await $.tester.ensureVisible(find.byKey(const Key('bottom_nav_profile')));
  await pumpUi($, milliseconds: 500);
  await $(#bottom_nav_profile).tap();
  await pumpUi($, milliseconds: 1300);

  await $('Pencapaian').tap();
  await pumpUi($, milliseconds: 900);

  final leaderboardSectionFinder =
      find.byKey(const Key('profile_leaderboard_section'));
  await $.tester.ensureVisible(leaderboardSectionFinder);
  await $(#profile_leaderboard_section).tap();
  await pumpUi($, milliseconds: 1400);
}

void main() {
  patrolTest(
    'UC8.1 - Dari Profil dapat membuka halaman Papan Peringkat',
    ($) async {
      await initTestApp(
        $: $,
        initialRoute: AppPages.MAIN,
        isLoggedIn: true,
      );

      await _openLeaderboardFromProfile($);

      expect(Get.currentRoute, AppPages.LEADERBOARD);
      expect($('Papan Peringkat'), findsOneWidget);
      expect($('Minggu Ini'), findsOneWidget);
      expect($('Bulan Ini'), findsOneWidget);
    },
  );

  patrolTest(
    'UC8.2 - Leaderboard mingguan menampilkan data ranking',
    ($) async {
      await initTestApp(
        $: $,
        initialRoute: AppPages.MAIN,
        isLoggedIn: true,
      );

      await _openLeaderboardFromProfile($);

      final profileController = Get.find<ProfileController>();
      expect(profileController.weeklyLeaderboard, isNotEmpty);

      expect($('Minggu Ini'), findsOneWidget);
      expect($('Juara Teratas'), findsOneWidget);
      expect($('testuser'), findsWidgets);
      expect($('320 XP'), findsWidgets);
    },
  );

  patrolTest(
    'UC8.3 - Pindah ke tab bulanan menampilkan leaderboard bulanan',
    ($) async {
      await initTestApp(
        $: $,
        initialRoute: AppPages.MAIN,
        isLoggedIn: true,
      );

      await _openLeaderboardFromProfile($);

      await $('Bulan Ini').tap();
      await pumpUi($, milliseconds: 1400);

      final profileController = Get.find<ProfileController>();
      expect(profileController.monthlyLeaderboard, isNotEmpty);
      expect($('Bulan Ini'), findsOneWidget);
      expect($('640 XP'), findsWidgets);
    },
  );

  patrolTest(
    'UC8.4 - Pull to refresh leaderboard tidak menyebabkan error',
    ($) async {
      await initTestApp(
        $: $,
        initialRoute: AppPages.MAIN,
        isLoggedIn: true,
      );

      await _openLeaderboardFromProfile($);

      await $.tester.drag(
        find.byType(CustomScrollView),
        const Offset(0, 350),
      );
      await pumpUi($, milliseconds: 1300);

      expect(Get.currentRoute, AppPages.LEADERBOARD);
      expect($('Papan Peringkat'), findsOneWidget);
      expect($('Minggu Ini'), findsOneWidget);
    },
  );
}
