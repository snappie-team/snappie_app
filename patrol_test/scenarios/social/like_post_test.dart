import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:patrol/patrol.dart';
import 'package:snappie_app/app/data/repositories/post_repository_impl.dart';
import 'package:snappie_app/app/routes/app_pages.dart';

import '../../common/test_app.dart';
import '../explore/explore_test_helpers.dart';
import '../../mocks/mock_repositories.dart';

String _readLikeCount(PatrolIntegrationTester $, int postId) {
  final finder = find.byKey(Key('post_like_count_$postId'));
  final textWidget = $.tester.widget<Text>(finder);
  return textWidget.data ?? '0';
}

void main() {
  patrolTest(
    'UC5.1 - Like post menambah jumlah like secara optimistic',
    ($) async {
      await initTestApp(
        $: $,
        initialRoute: AppPages.MAIN,
        isLoggedIn: true,
      );

      await $.tester.ensureVisible(find.byKey(const Key('post_like_button_1')));
      await pumpUi($, milliseconds: 400);

      final before = _readLikeCount($, 1);
      expect(before, '10');

      await $(#post_like_button_1).tap();
      await pumpUi($, milliseconds: 1200);

      final after = _readLikeCount($, 1);
      expect(after, '11');
    },
  );

  patrolTest(
    'UC5.2 - Unlike post mengurangi jumlah like kembali',
    ($) async {
      await initTestApp(
        $: $,
        initialRoute: AppPages.MAIN,
        isLoggedIn: true,
      );

      await $.tester.ensureVisible(find.byKey(const Key('post_like_button_1')));
      await pumpUi($, milliseconds: 400);

      await $(#post_like_button_1).tap();
      await pumpUi($, milliseconds: 900);

      final afterLike = _readLikeCount($, 1);
      expect(afterLike, '11');

      await $(#post_like_button_1).tap();
      await pumpUi($, milliseconds: 900);

      final afterUnlike = _readLikeCount($, 1);
      expect(afterUnlike, '10');
    },
  );

  patrolTest(
    'UC5.4 - Like gagal akan revert ke state sebelumnya',
    ($) async {
      await initTestApp(
        $: $,
        initialRoute: AppPages.MAIN,
        isLoggedIn: true,
      );

      final mockRepo = Get.find<PostRepository>() as MockPostRepository;
      mockRepo.shouldFailToggleLike = true;

      await $.tester.ensureVisible(find.byKey(const Key('post_like_button_1')));
      await pumpUi($, milliseconds: 400);

      final before = _readLikeCount($, 1);
      expect(before, '10');

      await $(#post_like_button_1).tap();
      await pumpUi($, milliseconds: 1200);

      final after = _readLikeCount($, 1);
      expect(after, '10');
    },
  );

  patrolTest(
    'UC5.5 - Tap komentar menampilkan interaksi komentar',
    ($) async {
      await initTestApp(
        $: $,
        initialRoute: AppPages.MAIN,
        isLoggedIn: true,
      );

      await $.tester
          .ensureVisible(find.byKey(const Key('post_comment_button_1')));
      await pumpUi($, milliseconds: 500);
      await $(#post_comment_button_1).tap();
      await pumpUi($, milliseconds: 900);

      final showBottomSheet = find.text('Komentar').evaluate().isNotEmpty;
      final showComingSoon =
          find.text('Comment feature coming soon!').evaluate().isNotEmpty;

      expect(showBottomSheet || showComingSoon, isTrue);
    },
  );

  patrolTest(
    'UC5.6 - Buka halaman detail post menampilkan post card penuh',
    ($) async {
      await initTestApp(
        $: $,
        initialRoute: AppPages.MAIN,
        isLoggedIn: true,
      );

      Get.toNamed(
        AppPages.POST_DETAIL,
        arguments: <String, dynamic>{'postId': 1},
      );
      await pumpUi($, milliseconds: 1400);

      expect(Get.currentRoute, AppPages.POST_DETAIL);
      expect($('Postingan'), findsOneWidget);
      expect($('Tempat ini amazing!'), findsOneWidget);
    },
  );
}
