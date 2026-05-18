import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class ExploreRobot {
  final WidgetTester tester;

  ExploreRobot(this.tester);

  /// Verifies that the explore page is displayed
  Future<void> verifyExplorePageDisplayed() async {
    // Wait for places to load
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Check for explore page elements
    expect(find.text('Favorit kami!'), findsOneWidget);
    expect(find.text('Mau makan di mana hari ini?'), findsOneWidget);
  }

  /// Enters a search query into the search bar
  Future<void> enterSearchQuery(String query) async {
    final searchField = find.byType(TextField);
    expect(searchField, findsOneWidget);
    await tester.enterText(searchField, query);
    await tester
        .pumpAndSettle(const Duration(milliseconds: 500)); // Wait for debounce
  }

  /// Taps on a filter chip by label
  Future<void> tapFilterChip(String label) async {
    final chip = find.text(label);
    expect(chip, findsWidgets);
    await tester.tap(chip.first);
    await tester.pumpAndSettle();
  }

  /// Selects a food type category from the bottom sheet
  Future<void> selectFoodType(String foodType) async {
    // Open the food type filter bottom sheet
    await tapFilterChip('Tipe Kuliner');
    await tester.pumpAndSettle(const Duration(milliseconds: 500));

    // Find and tap the food type option
    final foodTypeOption = find.text(foodType);
    expect(foodTypeOption, findsWidgets,
        reason: 'Food type "$foodType" should be in the bottom sheet');
    await tester.tap(foodTypeOption.first);
    await tester.pumpAndSettle();

    // Tap "Ok" button to apply filter (this calls controller.applyFilter('foodTypes'))
    final okButton = find.text('Ok');
    expect(okButton, findsOneWidget,
        reason: '"Ok" button should be visible in bottom sheet');
    await tester.tap(okButton);
    await tester
        .pumpAndSettle(const Duration(seconds: 1)); // Wait for filter to apply
  }

  /// Verifies that a place card with [placeName] is displayed
  Future<void> verifyPlaceCardDisplayed(String placeName) async {
    await tester.pumpAndSettle(const Duration(seconds: 1));

    final placeText = find.text(placeName);
    expect(placeText, findsWidgets,
        reason: 'Place "$placeName" should be visible');
  }

  /// Verifies that a place card with [placeName] is NOT displayed
  Future<void> verifyPlaceCardNotDisplayed(String placeName) async {
    await tester.pumpAndSettle(const Duration(seconds: 1));
    final placeText = find.text(placeName);
    expect(placeText, findsNothing,
        reason: 'Place "$placeName" should NOT be visible');
  }

  /// Taps on a place card by ID to navigate to detail
  Future<void> tapPlaceById(int placeId) async {
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Use the Key we added to PlaceCardWidget
    final placeCard = find.byKey(Key('place_card_$placeId'));
    expect(placeCard, findsOneWidget,
        reason: 'Place card with id $placeId should exist');

    await tester.tap(placeCard);
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }

  /// Taps on a place card by name to navigate to detail
  Future<void> tapPlace(String placeName) async {
    await tester.pumpAndSettle(const Duration(seconds: 1));

    final placeText = find.text(placeName);
    expect(placeText, findsWidgets);

    // Find the GestureDetector ancestor of the text
    final gestureDetector = find.ancestor(
      of: placeText.first,
      matching: find.byType(GestureDetector),
    );

    if (gestureDetector.evaluate().isNotEmpty) {
      await tester.tap(gestureDetector.first, warnIfMissed: false);
    } else {
      // Fallback: tap the text directly
      await tester.tap(placeText.first, warnIfMissed: false);
    }

    await tester.pumpAndSettle(const Duration(seconds: 2));
  }

  /// Verifies that the place detail page is displayed
  Future<void> verifyPlaceDetailDisplayed(String placeName) async {
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Place detail page should show the place name
    expect(find.text(placeName), findsWidgets);

    // Check for common detail page elements
    final hasUlasan = find.text('Ulasan').evaluate().isNotEmpty;
    final hasDetail = find.text('Detail').evaluate().isNotEmpty;
    final hasMenu = find.text('Menu').evaluate().isNotEmpty;
    final hasLocation = find.byIcon(Icons.location_on).evaluate().isNotEmpty;

    // At least one detail indicator should be present
    expect(hasUlasan || hasDetail || hasMenu || hasLocation, isTrue,
        reason:
            'Expected to find detail page indicators (Ulasan, Detail, Menu, or location icon)');
  }

  /// Helper to go back from detail page
  Future<void> goBack() async {
    // Try Navigator pop via back button
    final backButton = find.byIcon(Icons.arrow_back);
    final backButton2 = find.byIcon(Icons.arrow_back_ios);

    if (backButton.evaluate().isNotEmpty) {
      await tester.tap(backButton.first);
    } else if (backButton2.evaluate().isNotEmpty) {
      await tester.tap(backButton2.first);
    } else {
      // Use back tooltip as fallback
      final backTooltip = find.byTooltip('Back');
      if (backTooltip.evaluate().isNotEmpty) {
        await tester.tap(backTooltip.first);
      }
    }

    await tester.pumpAndSettle(const Duration(seconds: 1));
  }
}
