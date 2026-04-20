import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:patrol/patrol.dart';
import 'package:snappie_app/app/modules/articles/views/articles_view.dart';
import 'package:snappie_app/app/modules/articles/controllers/articles_controller.dart';
import 'package:snappie_app/app/routes/app_pages.dart';

import '../../common/test_app.dart';
import '../explore/explore_test_helpers.dart';

void main() {
  patrolTest(
    'UC6.1 - Buka tab Artikel menampilkan daftar artikel',
    ($) async {
      await initTestApp(
        $: $,
        initialRoute: AppPages.MAIN,
        isLoggedIn: true,
      );

      await $.tester
          .ensureVisible(find.byKey(const Key('bottom_nav_articles')));
      await pumpUi($, milliseconds: 500);
      await $(#bottom_nav_articles).tap();
      await pumpUi($, milliseconds: 1200);

      expect($('Kuliner Hidden Gem Jakarta'), findsOneWidget);
      expect($('Kuliner'), findsOneWidget);
    },
  );

  patrolTest(
    'UC6.2 - Search artikel dengan keyword menampilkan hasil sesuai',
    ($) async {
      await initTestApp(
        $: $,
        initialRoute: AppPages.MAIN,
        isLoggedIn: true,
      );

      await $.tester
          .ensureVisible(find.byKey(const Key('bottom_nav_articles')));
      await pumpUi($, milliseconds: 500);
      await $(#bottom_nav_articles).tap();
      await pumpUi($, milliseconds: 900);

      final searchField = find.byType(TextField).first;
      await $.tester.ensureVisible(searchField);
      await $.tester.tap(searchField);
      await $.tester.enterText(searchField, 'Hidden');

      // Debounce pada ArticlesController adalah 300ms.
      await pumpUi($, milliseconds: 800);

      final controller = Get.find<ArticlesController>();

      expect(controller.searchQuery, 'Hidden');
      expect(controller.articles.length, 1);
      expect($('Kuliner Hidden Gem Jakarta'), findsOneWidget);
    },
  );

  patrolTest(
    'UC6.6 - Refresh data artikel memuat ulang daftar',
    ($) async {
      await initTestApp(
        $: $,
        initialRoute: AppPages.MAIN,
        isLoggedIn: true,
      );

      await $.tester
          .ensureVisible(find.byKey(const Key('bottom_nav_articles')));
      await pumpUi($, milliseconds: 500);
      await $(#bottom_nav_articles).tap();
      await pumpUi($, milliseconds: 900);

      final controller = Get.find<ArticlesController>();

      controller.searchArticles('zzztidakada');
      await pumpUi($, milliseconds: 900);
      expect(controller.articles.length, 0);

      controller.clearFilters();
      await pumpUi($, milliseconds: 500);

      await controller.refreshData();
      await pumpUi($, milliseconds: 900);

      expect(controller.articles.length, 1);
      expect($('Kuliner Hidden Gem Jakarta'), findsOneWidget);
    },
  );

  patrolTest(
    'UC6.4 - Tap artikel menjalankan interaksi tanpa crash',
    ($) async {
      await initTestApp(
        $: $,
        initialRoute: AppPages.MAIN,
        isLoggedIn: true,
      );

      await $.tester
          .ensureVisible(find.byKey(const Key('bottom_nav_articles')));
      await pumpUi($, milliseconds: 500);
      await $(#bottom_nav_articles).tap();
      await pumpUi($, milliseconds: 900);

      await $('Kuliner Hidden Gem Jakarta').tap();
      await pumpUi($, milliseconds: 1200);

      expect(Get.currentRoute, AppPages.MAIN);
      expect(find.byType(ArticlesView), findsOneWidget);
      expect($('Kuliner Hidden Gem Jakarta'), findsOneWidget);
    },
  );

  patrolTest(
    'UC6.3 - Tombol Hapus pada pencarian mengembalikan daftar default',
    ($) async {
      await initTestApp(
        $: $,
        initialRoute: AppPages.MAIN,
        isLoggedIn: true,
      );

      await $.tester
          .ensureVisible(find.byKey(const Key('bottom_nav_articles')));
      await pumpUi($, milliseconds: 500);
      await $(#bottom_nav_articles).tap();
      await pumpUi($, milliseconds: 900);

      final controller = Get.find<ArticlesController>();

      final searchField = find.byType(TextField).first;
      await $.tester.ensureVisible(searchField);
      await $.tester.tap(searchField);
      await $.tester.enterText(searchField, 'Hidden');
      await pumpUi($, milliseconds: 900);

      expect(controller.searchQuery, 'Hidden');
      expect(controller.articles.length, 1);

      await $('Hapus').tap();
      await pumpUi($, milliseconds: 900);

      expect(controller.searchQuery, '');
      expect(controller.articles.length, 1);
      expect($('Kuliner Hidden Gem Jakarta'), findsOneWidget);
    },
  );

  patrolTest(
    'UC6.5 - Bookmark artikel menampilkan konfirmasi',
    ($) async {
      await initTestApp(
        $: $,
        initialRoute: AppPages.MAIN,
        isLoggedIn: true,
      );

      await $.tester
          .ensureVisible(find.byKey(const Key('bottom_nav_articles')));
      await pumpUi($, milliseconds: 500);
      await $(#bottom_nav_articles).tap();
      await pumpUi($, milliseconds: 900);

      final controller = Get.find<ArticlesController>();
      controller.bookmarkArticle(1);
      await pumpUi($, milliseconds: 600);

      expect($('Article bookmarked successfully!'), findsOneWidget);
    },
  );
}
