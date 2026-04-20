import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:snappie_app/app/routes/app_pages.dart';

import '../../common/test_app.dart';
import 'explore_test_helpers.dart';

void main() {
  patrolTest(
    'UC2.1 - Buka tab Jelajahi menampilkan daftar tempat',
    ($) async {
      await initTestApp(
        $: $,
        initialRoute: AppPages.MAIN,
        isLoggedIn: true,
      );

      await openExploreTab($);

      expect($('Favorit kami!'), findsOneWidget);
      expect($('Warung Hidden Gem'), findsOneWidget);
    },
  );

  patrolTest(
    'UC2.2 - Search tempat dengan keyword',
    ($) async {
      await initTestApp(
        $: $,
        initialRoute: AppPages.MAIN,
        isLoggedIn: true,
      );

      await openExploreTab($);
      await enterExploreSearch($, 'Warung');

      expect($('"Warung"'), findsOneWidget);
      expect($('Warung Hidden Gem'), findsOneWidget);
      expect($('Kedai Rahasia'), findsNothing);
    },
  );

  patrolTest(
    'UC2.3 - Filter penilaian menampilkan hasil terfilter',
    ($) async {
      await initTestApp(
        $: $,
        initialRoute: AppPages.MAIN,
        isLoggedIn: true,
      );

      await openExploreTab($);

      await tapExploreFilterChip($, 'explore_filter_penilaian');
      await $('5').tap();
      await $('Ok').tap();
      await pumpUi($, milliseconds: 900);

      expect($('Rating 5+'), findsOneWidget);
      expect($('0 tempat'), findsOneWidget);
      expect($('Tidak ada hasil'), findsOneWidget);
    },
  );

  patrolTest(
    'UC2.4 - Filter tipe kuliner menampilkan hasil sesuai',
    ($) async {
      await initTestApp(
        $: $,
        initialRoute: AppPages.MAIN,
        isLoggedIn: true,
      );

      await openExploreTab($);

      await tapExploreFilterChip($, 'explore_filter_tipe_kuliner');
      await $(#food_type_filter_0).tap();
      await $('Ok').tap();
      await pumpUi($, milliseconds: 900);

      expect($('Tipe Kuliner'), findsWidgets);
      expect($('Warung Hidden Gem'), findsOneWidget);
      expect($('Kedai Rahasia'), findsNothing);
    },
  );

  patrolTest(
    'UC2.5 - Clear filter menampilkan daftar default kembali',
    ($) async {
      await initTestApp(
        $: $,
        initialRoute: AppPages.MAIN,
        isLoggedIn: true,
      );

      await openExploreTab($);

      await tapExploreFilterChip($, 'explore_filter_penilaian');
      await $('5').tap();
      await $('Ok').tap();
      await pumpUi($, milliseconds: 900);

      expect($('Rating 5+'), findsOneWidget);

      await tapExploreFilterChip($, 'explore_filter_penilaian');
      await $('Hapus').tap();
      await pumpUi($, milliseconds: 900);

      expect($('Favorit kami!'), findsOneWidget);
      expect($('Teratas'), findsOneWidget);
      expect($('Rating 5+'), findsNothing);
    },
  );
}
