import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:patrol/patrol.dart';
import 'package:snappie_app/app/core/services/location_service.dart';
import 'package:snappie_app/app/modules/mission/controllers/mission_controller.dart';
import 'package:snappie_app/app/routes/app_pages.dart';

import '../../common/test_app.dart';
import '../../mocks/mock_data.dart';
import '../explore/explore_test_helpers.dart';

final List<int> _tinyPngBytes = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO7Z4QAAAABJRU5ErkJggg==',
);

Future<String> _createTempImagePath() async {
  final tempDir = await Directory.systemTemp.createTemp('patrol_uc3_');
  final imageFile = File('${tempDir.path}/checkin.png');
  await imageFile.writeAsBytes(_tinyPngBytes, flush: true);
  return imageFile.path;
}

Future<void> _openPlaceDetailAndPreparePreview(
    PatrolIntegrationTester $) async {
  await openExploreTab($);
  await $.tester.ensureVisible(find.byKey(const Key('place_card_1')));
  await pumpUi($, milliseconds: 700);
  await $(#place_card_1).tap();
  await pumpUi($, milliseconds: 900);

  if (!Get.isRegistered<MissionController>()) {
    Get.put<MissionController>(MissionController());
  }
  final missionController = Get.find<MissionController>();
  missionController.initMission(MockData.testPlaces.first);

  final imagePath = await _createTempImagePath();
  missionController.setCapturedImage(imagePath);

  Get.toNamed(AppPages.MISSION_PHOTO_PREVIEW);
  await pumpUi($, milliseconds: 900);
}

Future<void> _openPlaceDetailAndStartMission(PatrolIntegrationTester $) async {
  await openExploreTab($);
  await $.tester.ensureVisible(find.byKey(const Key('place_card_1')));
  await pumpUi($, milliseconds: 700);
  await $(#place_card_1).tap();
  await pumpUi($, milliseconds: 900);

  await $.tester.ensureVisible(
      find.byKey(const Key('place_detail_start_mission_button')));
  await pumpUi($, milliseconds: 700);
  await $(#place_detail_start_mission_button).tap();
  await pumpUi($, milliseconds: 700);

  // Modal konfirmasi misi: centang persetujuan lalu lanjutkan.
  await $.tester.tap(find.byType(Checkbox).first);
  await pumpUi($, milliseconds: 500);
  await $('Lanjutkan').tap();
  await pumpUi($, milliseconds: 1000);
}

class _FailingLocationService extends LocationService {
  @override
  Future<void> onInit() async {}

  @override
  Future<Position?> getCurrentPosition({
    bool showSnackbars = true,
    LocationAccuracy accuracy = LocationAccuracy.medium,
    Duration timeLimit = const Duration(seconds: 10),
  }) async {
    return null;
  }
}

void main() {
  patrolTest(
    'UC3.1 - Dari detail tempat tap Mulai Misi membuka halaman misi foto',
    ($) async {
      await initTestApp(
        $: $,
        initialRoute: AppPages.MAIN,
        isLoggedIn: true,
      );

      await _openPlaceDetailAndStartMission($);

      expect(Get.currentRoute, AppPages.MISSION_PHOTO);
    },
  );

  patrolTest(
    'UC3.2 - Ambil foto lalu tampil halaman preview',
    ($) async {
      await initTestApp(
        $: $,
        initialRoute: AppPages.MAIN,
        isLoggedIn: true,
      );

      await _openPlaceDetailAndStartMission($);

      if (!Get.isRegistered<MissionController>()) {
        Get.put<MissionController>(MissionController());
      }
      final missionController = Get.find<MissionController>();
      missionController.initMission(MockData.testPlaces.first);
      final imagePath = await _createTempImagePath();
      missionController.setCapturedImage(imagePath);

      Get.toNamed(AppPages.MISSION_PHOTO_PREVIEW);
      await pumpUi($, milliseconds: 900);

      expect(Get.currentRoute, AppPages.MISSION_PHOTO_PREVIEW);
      expect($(#mission_preview_submit_button), findsOneWidget);
      expect($('Kumpulkan'), findsOneWidget);
    },
  );

  patrolTest(
    'UC3.3 - Submit check-in sukses menampilkan modal reward',
    ($) async {
      await initTestApp(
        $: $,
        initialRoute: AppPages.MAIN,
        isLoggedIn: true,
      );

      await _openPlaceDetailAndPreparePreview($);

      expect($(#mission_preview_submit_button), findsOneWidget);

      await $(#mission_preview_submit_button).tap();
      await pumpUi($, milliseconds: 2200);

      expect($('Misi Berhasil!'), findsOneWidget);
      expect($('Klaim'), findsOneWidget);
    },
  );

  patrolTest(
    'UC3.5 - Setelah klaim pilih lanjutkan misi menuju mission review',
    ($) async {
      await initTestApp(
        $: $,
        initialRoute: AppPages.MAIN,
        isLoggedIn: true,
      );

      await _openPlaceDetailAndPreparePreview($);
      await $(#mission_preview_submit_button).tap();
      await pumpUi($, milliseconds: 2200);

      await $('Klaim').tap();
      await pumpUi($, milliseconds: 700);
      await $('Lanjutkan Misi').tap();
      await pumpUi($, milliseconds: 900);

      expect(Get.currentRoute, AppPages.MISSION_REVIEW);
    },
  );

  patrolTest(
    'UC3.6 - Setelah klaim pilih nanti dulu kembali di place detail',
    ($) async {
      await initTestApp(
        $: $,
        initialRoute: AppPages.MAIN,
        isLoggedIn: true,
      );

      await _openPlaceDetailAndPreparePreview($);
      await $(#mission_preview_submit_button).tap();
      await pumpUi($, milliseconds: 2200);

      await $('Klaim').tap();
      await pumpUi($, milliseconds: 700);
      await $('Nanti Dulu').tap();
      await pumpUi($, milliseconds: 900);

      expect(Get.currentRoute, AppPages.PLACE_DETAIL);
    },
  );

  patrolTest(
    'UC3.4 - Submit check-in gagal lokasi invalid menampilkan modal gagal',
    ($) async {
      await initTestApp(
        $: $,
        initialRoute: AppPages.MAIN,
        isLoggedIn: true,
      );

      await _openPlaceDetailAndPreparePreview($);

      if (Get.isRegistered<LocationService>()) {
        Get.replace<LocationService>(_FailingLocationService());
      } else {
        Get.put<LocationService>(_FailingLocationService(), permanent: true);
      }

      await $(#mission_preview_submit_button).tap();
      await pumpUi($, milliseconds: 2200);

      expect($('Ups, Misi Gagal!'), findsOneWidget);
      expect($('Coba Lagi'), findsOneWidget);

      await $('Nanti Saja').tap();
      await pumpUi($, milliseconds: 900);
      expect(Get.currentRoute, AppPages.MISSION_PHOTO_PREVIEW);
    },
  );

  patrolTest(
    'UC3.7 - Retake foto dari preview kembali ke kamera',
    ($) async {
      await initTestApp(
        $: $,
        initialRoute: AppPages.MAIN,
        isLoggedIn: true,
      );

      await _openPlaceDetailAndPreparePreview($);

      expect(Get.currentRoute, AppPages.MISSION_PHOTO_PREVIEW);
      await $('Kembali').tap();
      await pumpUi($, milliseconds: 900);

      expect(Get.currentRoute, AppPages.MISSION_PHOTO);
    },
  );
}
