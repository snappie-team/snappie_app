import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

Future<void> pumpUi(PatrolIntegrationTester $, {int milliseconds = 600}) async {
  await $.pump();
  await $.pump(Duration(milliseconds: milliseconds));
}

Future<void> openExploreTab(PatrolIntegrationTester $) async {
  await $.tester.ensureVisible(find.byKey(const Key('bottom_nav_explore')));
  await pumpUi($);
  await $(#bottom_nav_explore).tap();
  await pumpUi($, milliseconds: 900);
}

Future<void> enterExploreSearch(
  PatrolIntegrationTester $,
  String keyword,
) async {
  final searchField = find.byType(TextField).first;
  await $.tester.ensureVisible(searchField);
  await $.tester.tap(searchField);
  await $.tester.enterText(searchField, keyword);
  await pumpUi($, milliseconds: 700);
}

Future<void> tapExploreFilterChip(
  PatrolIntegrationTester $,
  String key,
) async {
  final finder = find.byKey(Key(key));
  await $.tester.ensureVisible(finder);
  await $.tester.tap(finder);
  await pumpUi($, milliseconds: 700);
}
