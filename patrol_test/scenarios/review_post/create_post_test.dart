import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:snappie_app/app/routes/app_pages.dart';

import '../../common/test_app.dart';
import '../explore/explore_test_helpers.dart';

Future<void> _openCreatePostPage(PatrolIntegrationTester $) async {
  await $.tester.ensureVisible(find.byKey(const Key('home_create_post_fab')));
  await pumpUi($, milliseconds: 500);
  await $(#home_create_post_fab).tap();
  await pumpUi($, milliseconds: 1000);
}

Future<void> _selectPlaceIfNeeded(PatrolIntegrationTester $) async {
  final placeOption = find.byKey(const Key('create_post_place_option_1'));
  if (placeOption.evaluate().isNotEmpty) {
    await $.tester.ensureVisible(placeOption);
    await pumpUi($, milliseconds: 350);
    await $.tester.tap(placeOption);
    await pumpUi($, milliseconds: 700);
  }
}

void main() {
  patrolTest(
    'UC4.4 - Buat postingan valid berhasil dan kembali ke main',
    ($) async {
      await initTestApp(
        $: $,
        initialRoute: AppPages.MAIN,
        isLoggedIn: true,
      );

      await _openCreatePostPage($);
      await _selectPlaceIfNeeded($);

      await $(#create_post_content_field)
          .enterText('Hidden gem ini enak dan nyaman banget!');
      await pumpUi($, milliseconds: 350);
      await $.tester.tapAt(const Offset(20, 20));
      await pumpUi($, milliseconds: 200);

      await $(#create_post_test_add_image_button).tap();
      await pumpUi($, milliseconds: 600);

      final submitButtonFinder =
          find.byKey(const Key('create_post_submit_button'));
      await $.tester.ensureVisible(submitButtonFinder);
      await pumpUi($, milliseconds: 300);
      await $.tester.tap(submitButtonFinder);
      await pumpUi($, milliseconds: 2200);

      expect($(#bottom_nav_home), findsOneWidget);
      expect($(#home_create_post_fab), findsOneWidget);
    },
  );

  patrolTest(
    'UC4.5 - Create post tanpa foto membuat tombol submit nonaktif',
    ($) async {
      await initTestApp(
        $: $,
        initialRoute: AppPages.MAIN,
        isLoggedIn: true,
      );

      await _openCreatePostPage($);
      await _selectPlaceIfNeeded($);

      await $(#create_post_content_field)
          .enterText('Konten sudah diisi tapi belum ada foto');
      await pumpUi($, milliseconds: 350);
      await $.tester.tapAt(const Offset(20, 20));
      await pumpUi($, milliseconds: 200);

      final submitButtonFinder =
          find.byKey(const Key('create_post_submit_button'));
      final submitButton = $.tester.widget<ElevatedButton>(submitButtonFinder);

      expect(submitButton.onPressed, isNull);
      expect($(#create_post_submit_button), findsOneWidget);
    },
  );

  patrolTest(
    'UC4.6 - Create post sukses lalu postingan tampil di feed',
    ($) async {
      await initTestApp(
        $: $,
        initialRoute: AppPages.MAIN,
        isLoggedIn: true,
      );

      await _openCreatePostPage($);
      await _selectPlaceIfNeeded($);

      await $(#create_post_content_field)
          .enterText('Postingan baru dari test UC4.6');
      await pumpUi($, milliseconds: 350);
      await $.tester.tapAt(const Offset(20, 20));
      await pumpUi($, milliseconds: 200);

      await $(#create_post_test_add_image_button).tap();
      await pumpUi($, milliseconds: 600);

      final submitButtonFinder =
          find.byKey(const Key('create_post_submit_button'));
      await $.tester.ensureVisible(submitButtonFinder);
      await pumpUi($, milliseconds: 300);
      final submitButton = $.tester.widget<ElevatedButton>(submitButtonFinder);
      expect(submitButton.onPressed, isNotNull);
      await $.tester.tap(submitButtonFinder);
      await pumpUi($, milliseconds: 2300);

      expect($(#bottom_nav_home), findsOneWidget);
      expect($('Postingan baru dari test UC4.6'), findsOneWidget);
    },
  );
}
