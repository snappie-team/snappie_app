import 'package:flutter/material.dart';

enum FoodType {
  nonSup,
  miInstan,
  menuKomposit,
  supSoto,
  menuCampuran,
  minumanDanTambahan,
  liwetan,
  gayaPadang,
  gayaTionghoa,
  makananCepatSaji,
  makananTradisional,
  makananKemasan,
  buahBuahan,
}

extension FoodTypeExtension on FoodType {
  String get label {
    switch (this) {
      case FoodType.nonSup:
        return 'Non-Sup';
      case FoodType.miInstan:
        return 'Mi Instan';
      case FoodType.menuKomposit:
        return 'Menu Komposit';
      case FoodType.supSoto:
        return 'Sup/Soto';
      case FoodType.menuCampuran:
        return 'Menu Campuran';
      case FoodType.minumanDanTambahan:
        return 'Minuman dan Tambahan';
      case FoodType.liwetan:
        return 'Liwetan';
      case FoodType.gayaPadang:
        return 'Gaya Padang';
      case FoodType.gayaTionghoa:
        return 'Gaya Tionghoa';
      case FoodType.makananCepatSaji:
        return 'Makanan Cepat Saji';
      case FoodType.makananTradisional:
        return 'Makanan Tradisional';
      case FoodType.makananKemasan:
        return 'Makanan Kemasan';
      case FoodType.buahBuahan:
        return 'Buah-buahan';
    }
  }

  IconData get icon {
    switch (this) {
      case FoodType.nonSup:
        return Icons.restaurant;
      case FoodType.miInstan:
        return Icons.ramen_dining;
      case FoodType.menuKomposit:
        return Icons.dining;
      case FoodType.supSoto:
        return Icons.soup_kitchen;
      case FoodType.menuCampuran:
        return Icons.set_meal;
      case FoodType.minumanDanTambahan:
        return Icons.local_drink;
      case FoodType.liwetan:
        return Icons.rice_bowl;
      case FoodType.gayaPadang:
        return Icons.food_bank;
      case FoodType.gayaTionghoa:
        return Icons.restaurant_menu;
      case FoodType.makananCepatSaji:
        return Icons.fastfood;
      case FoodType.makananTradisional:
        return Icons.temple_hindu;
      case FoodType.makananKemasan:
        return Icons.inventory_2;
      case FoodType.buahBuahan:
        return Icons.apple;
    }
  }

  /// Get all labels as list
  static List<String> get allLabels => FoodType.values.map((e) => e.label).toList();

  /// Get icon by label
  static IconData? getIconByLabel(String label) {
    final normalizedLabel = label.toLowerCase().trim();
    for (final value in FoodType.values) {
      if (value.label.toLowerCase() == normalizedLabel) {
        return value.icon;
      }
    }
    return null;
  }
}