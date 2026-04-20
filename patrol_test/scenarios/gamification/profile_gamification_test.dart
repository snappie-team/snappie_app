import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:patrol/patrol.dart';
import 'package:snappie_app/app/data/models/achievement_model.dart';
import 'package:snappie_app/app/modules/profile/controllers/profile_controller.dart';
import 'package:snappie_app/app/routes/app_pages.dart';

import '../../common/test_app.dart';
import '../../mocks/mock_repositories.dart';
import '../explore/explore_test_helpers.dart';

void main() {
  patrolTest(
    'UC7.1 - Tab Akun menampilkan ringkasan gamifikasi (XP dan Koin)',
    ($) async {
      await initTestApp(
        $: $,
        initialRoute: AppPages.MAIN,
        isLoggedIn: true,
      );

      await $.tester.ensureVisible(find.byKey(const Key('bottom_nav_profile')));
      await pumpUi($, milliseconds: 500);
      await $(#bottom_nav_profile).tap();
      await pumpUi($, milliseconds: 1400);

      final controller = Get.find<ProfileController>();

      expect(controller.totalExp, greaterThan(0));
      expect(controller.totalCoins, greaterThan(0));

      expect($('${controller.totalExp} XP'), findsOneWidget);
      expect($('${controller.totalCoins} Koin'), findsOneWidget);
      expect($('Postingan'), findsOneWidget);
      expect($('Pengikut'), findsOneWidget);
      expect($('Mengikuti'), findsOneWidget);
    },
  );

  patrolTest(
    'UC7.2 - Tab Pencapaian menampilkan section Penghargaan Saya',
    ($) async {
      await initTestApp(
        $: $,
        initialRoute: AppPages.MAIN,
        isLoggedIn: true,
      );

      await $.tester.ensureVisible(find.byKey(const Key('bottom_nav_profile')));
      await pumpUi($, milliseconds: 500);
      await $(#bottom_nav_profile).tap();
      await pumpUi($, milliseconds: 1400);

      await $('Pencapaian').tap();
      await pumpUi($, milliseconds: 900);

      final achievementSectionFinder =
          find.byKey(const Key('profile_achievement_section'));
      await $.tester.ensureVisible(achievementSectionFinder);
      expect(Get.currentRoute, AppPages.MAIN);
      expect(find.textContaining('Penghargaan Saya'), findsWidgets);
    },
  );

  patrolTest(
    'UC7.3 - Achievement completed dan locked tampil berbeda',
    ($) async {
      await initTestApp(
        $: $,
        initialRoute: AppPages.MAIN,
        isLoggedIn: true,
      );

      mockAchievementRepository.setUserAchievements([
        UserAchievement()
          ..id = 1
          ..code = 'checkin_1'
          ..name = 'Explorer Bronze'
          ..criteriaAction = 'checkin'
          ..isCompleted = true
          ..progress = 1
          ..target = 1,
        UserAchievement()
          ..id = 2
          ..code = 'review_2'
          ..name = 'Reviewer Silver'
          ..criteriaAction = 'review'
          ..isCompleted = false
          ..progress = 1
          ..target = 3,
      ]);

      Get.toNamed(AppPages.ACHIEVEMENTS);
      await pumpUi($, milliseconds: 1400);

      expect(Get.currentRoute, AppPages.ACHIEVEMENTS);
      expect($('Penghargaan Saya'), findsOneWidget);
      expect($('Explorer Bronze'), findsOneWidget);
      expect($('Reviewer Silver'), findsOneWidget);
    },
  );

  patrolTest(
    'UC7.4 - Halaman Tantangan menampilkan daftar challenge',
    ($) async {
      await initTestApp(
        $: $,
        initialRoute: AppPages.MAIN,
        isLoggedIn: true,
      );

      await $.tester.ensureVisible(find.byKey(const Key('bottom_nav_profile')));
      await pumpUi($, milliseconds: 500);
      await $(#bottom_nav_profile).tap();
      await pumpUi($, milliseconds: 1400);

      await $('Pencapaian').tap();
      await pumpUi($, milliseconds: 900);

      Get.toNamed(AppPages.CHALLENGES);
      await pumpUi($, milliseconds: 1300);

      expect(Get.currentRoute, AppPages.CHALLENGES);
      expect($('Tantangan'), findsOneWidget);
    },
  );

  patrolTest(
    'UC7.5 - Klaim challenge menambah XP dan Koin',
    ($) async {
      await initTestApp(
        $: $,
        initialRoute: AppPages.MAIN,
        isLoggedIn: true,
      );

      mockAchievementRepository.setUserChallenges([
        UserAchievement()
          ..id = 101
          ..name = 'Check-in Harian'
          ..criteriaAction = 'checkin'
          ..resetSchedule = 'daily'
          ..isCompleted = true
          ..isClaimed = false
          ..rewardXp = 25
          ..rewardCoins = 10
          ..progress = 1
          ..target = 1,
      ]);
      mockAchievementRepository.setClaimRewards(coins: 10, xp: 25);

      final profileController = Get.find<ProfileController>();
      final initialExp = profileController.totalExp;
      final initialCoins = profileController.totalCoins;

      Get.toNamed(AppPages.CHALLENGES);
      await pumpUi($, milliseconds: 1400);

      expect(Get.currentRoute, AppPages.CHALLENGES);
      expect($('Check-in Harian'), findsOneWidget);

      await $('Ambil Hadiah').tap();
      await pumpUi($, milliseconds: 600);
      await $('Klaim').tap();
      await pumpUi($, milliseconds: 1100);

      expect(profileController.totalExp, initialExp + 25);
      expect(profileController.totalCoins, initialCoins + 10);
    },
  );
}
