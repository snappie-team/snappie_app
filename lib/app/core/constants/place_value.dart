import 'package:flutter/material.dart';

enum PlaceValue {
  affordablePrice,
  authenticTaste,
  uniqueMenu,
  open24Hours,
  goodNetwork,
  aesthetic,
  calmAtmosphere,
  homeyAtmosphere,
  historicalTraditional,
  petFriendly,
  familyFriendly,
  friendlyService,
  meetingDiscussion,
  hangoutSpot,
  workFromCafe,
}

extension PlaceValueExtension on PlaceValue {
  String get label {
    switch (this) {
      case PlaceValue.affordablePrice:
        return 'Harga Terjangkau';
      case PlaceValue.authenticTaste:
        return 'Rasa Autentik';
      case PlaceValue.uniqueMenu:
        return 'Menu Unik/Variasi';
      case PlaceValue.open24Hours:
        return 'Buka 24 Jam';
      case PlaceValue.goodNetwork:
        return 'Jaringan Lancar';
      case PlaceValue.aesthetic:
        return 'Estetika/Instagrammable';
      case PlaceValue.calmAtmosphere:
        return 'Suasana Tenang';
      case PlaceValue.homeyAtmosphere:
        return 'Suasana Homey';
      case PlaceValue.historicalTraditional:
        return 'Bersejarah/Tradisional';
      case PlaceValue.petFriendly:
        return 'Pet Friendly';
      case PlaceValue.familyFriendly:
        return 'Ramah Keluarga';
      case PlaceValue.friendlyService:
        return 'Pelayanan Ramah';
      case PlaceValue.meetingDiscussion:
        return 'Rapat/Diskusi';
      case PlaceValue.hangoutSpot:
        return 'Nongkrong';
      case PlaceValue.workFromCafe:
        return 'Work From Cafe';
    }
  }

  IconData get icon {
    switch (this) {
      case PlaceValue.affordablePrice:
        return Icons.attach_money;
      case PlaceValue.authenticTaste:
        return Icons.restaurant;
      case PlaceValue.uniqueMenu:
        return Icons.menu_book;
      case PlaceValue.open24Hours:
        return Icons.nights_stay;
      case PlaceValue.goodNetwork:
        return Icons.wifi;
      case PlaceValue.aesthetic:
        return Icons.photo_camera;
      case PlaceValue.calmAtmosphere:
        return Icons.spa;
      case PlaceValue.homeyAtmosphere:
        return Icons.home_filled;
      case PlaceValue.historicalTraditional:
        return Icons.museum_outlined;
      case PlaceValue.petFriendly:
        return Icons.pets;
      case PlaceValue.familyFriendly:
        return Icons.family_restroom;
      case PlaceValue.friendlyService:
        return Icons.emoji_people;
      case PlaceValue.meetingDiscussion:
        return Icons.meeting_room;
      case PlaceValue.hangoutSpot:
        return Icons.groups_2_outlined;
      case PlaceValue.workFromCafe:
        return Icons.laptop_mac;
    }
  }

  /// Get all labels as list
  static List<String> get allLabels => PlaceValue.values.map((e) => e.label).toList();

  /// Get icon by label (for API response matching)
  static IconData? getIconByLabel(String label) {
    final normalizedLabel = label.toLowerCase().trim();
    for (final value in PlaceValue.values) {
      if (value.label.toLowerCase() == normalizedLabel) {
        return value.icon;
      }
    }
    return null; // Default icon if not found
  }
}