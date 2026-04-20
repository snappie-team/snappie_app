import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:patrol/patrol.dart';
import 'package:snappie_app/app/data/models/place_model.dart';
import 'package:snappie_app/app/modules/mission/controllers/mission_controller.dart';
import 'package:snappie_app/app/routes/app_pages.dart';

import '../../common/test_app.dart';
import '../../mocks/mock_data.dart';
import '../explore/explore_test_helpers.dart';

Future<void> _openMissionReviewPage(PatrolIntegrationTester $) async {
  if (!Get.isRegistered<MissionController>()) {
    Get.put<MissionController>(MissionController());
  }

  final missionController = Get.find<MissionController>();
  missionController.currentPlace = MockData.testPlaces.first;
  missionController.currentStep.value = MissionStep.review;

  Get.toNamed(
    AppPages.MISSION_REVIEW,
    arguments: MockData.testPlaces.first,
  );
  await pumpUi($, milliseconds: 1100);
}

Future<void> _openMissionReviewPageFromPlaceDetail(
  PatrolIntegrationTester $,
) async {
  await openExploreTab($);
  await $.tester.ensureVisible(find.byKey(const Key('place_card_1')));
  await pumpUi($, milliseconds: 700);
  await $(#place_card_1).tap();
  await pumpUi($, milliseconds: 900);

  if (!Get.isRegistered<MissionController>()) {
    Get.put<MissionController>(MissionController());
  }

  final placeWithTwoImages = PlaceModel()
    ..id = MockData.testPlaces.first.id
    ..name = MockData.testPlaces.first.name
    ..imageUrls = <PlaceImage>[
      PlaceImage()..url = 'https://example.com/place1.jpg',
      PlaceImage()..url = 'https://example.com/place2.jpg',
    ];

  final missionController = Get.find<MissionController>();
  missionController.currentPlace = placeWithTwoImages;
  missionController.currentStep.value = MissionStep.review;

  Get.toNamed(
    AppPages.MISSION_REVIEW,
    arguments: placeWithTwoImages,
  );
  await pumpUi($, milliseconds: 1100);
}

Future<void> _ensureVisibleAndTap(
  PatrolIntegrationTester $,
  Finder finder,
) async {
  await $.tester.ensureVisible(finder);
  await pumpUi($, milliseconds: 300);
  await $.tester.tap(finder);
  await pumpUi($, milliseconds: 350);
}

Future<void> _tapSubmitReview(PatrolIntegrationTester $) async {
  final submitByKey = find.byKey(const Key('mission_review_submit_button'));
  if (submitByKey.evaluate().isNotEmpty) {
    await _ensureVisibleAndTap($, submitByKey);
    return;
  }

  await pumpUi($, milliseconds: 600);
  final submitByText = find.text('Kirim Ulasan');
  if (submitByText.evaluate().isEmpty) {
    final scrollable = find.byType(Scrollable).first;
    await $.tester.scrollUntilVisible(
      submitByText,
      360,
      scrollable: scrollable,
    );
    await pumpUi($, milliseconds: 300);
  }
  await $.tester.ensureVisible(submitByText);
  await pumpUi($, milliseconds: 250);
  await $.tester.tap(submitByText);
  await pumpUi($, milliseconds: 350);
}

void main() {
  patrolTest(
    'UC4.1 - Submit ulasan valid menampilkan modal misi berhasil',
    ($) async {
      await initTestApp(
        $: $,
        initialRoute: AppPages.MAIN,
        isLoggedIn: true,
      );

      await _openMissionReviewPage($);

      await _ensureVisibleAndTap(
        $,
        find.byKey(const Key('mission_review_rating_star_4')),
      );

      await _ensureVisibleAndTap(
        $,
        find.byKey(const Key('mission_review_food_type_0')),
      );

      await _ensureVisibleAndTap(
        $,
        find.byKey(const Key('mission_review_place_value_0')),
      );

      await $.tester
          .ensureVisible(find.byKey(const Key('mission_review_text_field')));
      await $(#mission_review_text_field)
          .enterText('Tempatnya nyaman dan makanannya enak.');
      await pumpUi($, milliseconds: 300);

      await _tapSubmitReview($);
      await pumpUi($, milliseconds: 2200);

      expect($('Misi Berhasil!'), findsOneWidget);
      expect($('Klaim'), findsOneWidget);
    },
  );

  patrolTest(
    'UC4.2 - Submit ulasan tanpa rating menampilkan validasi',
    ($) async {
      await initTestApp(
        $: $,
        initialRoute: AppPages.MAIN,
        isLoggedIn: true,
      );

      await _openMissionReviewPage($);

      await _tapSubmitReview($);
      await pumpUi($, milliseconds: 700);

      expect($('Silakan berikan penilaian terlebih dahulu'), findsOneWidget);
      expect(Get.currentRoute, AppPages.MISSION_REVIEW);
    },
  );

  patrolTest(
    'UC4.3 - Submit ulasan sukses lanjut feedback sampai terkirim',
    ($) async {
      await initTestApp(
        $: $,
        initialRoute: AppPages.MAIN,
        isLoggedIn: true,
      );

      await _openMissionReviewPageFromPlaceDetail($);

      await _ensureVisibleAndTap(
        $,
        find.byKey(const Key('mission_review_rating_star_5')),
      );
      await _ensureVisibleAndTap(
        $,
        find.byKey(const Key('mission_review_food_type_0')),
      );
      await _ensureVisibleAndTap(
        $,
        find.byKey(const Key('mission_review_place_value_0')),
      );
      await $(#mission_review_text_field)
          .enterText('Review untuk lanjut feedback.');
      await pumpUi($, milliseconds: 300);

      await _tapSubmitReview($);
      await pumpUi($, milliseconds: 2200);

      await $('Klaim').tap();
      await pumpUi($, milliseconds: 700);
      await $('Lanjutkan Misi').tap();
      await pumpUi($, milliseconds: 1000);

      expect(
          $('Apakah informasi yang disajikan sudah sesuai?'), findsOneWidget);
      await $(#mission_feedback_yes_button).tap();
      await pumpUi($, milliseconds: 600);

      await $(#mission_feedback_image_0).tap();
      await pumpUi($, milliseconds: 400);
      await $(#mission_feedback_continue_button).tap();
      await pumpUi($, milliseconds: 600);

      await $(#mission_feedback_yes_button).tap();
      await pumpUi($, milliseconds: 600);

      await $(#mission_feedback_submit_button).tap();
      await pumpUi($, milliseconds: 1800);

      expect($('Feedback Terkirim!'), findsOneWidget);
    },
  );
}
