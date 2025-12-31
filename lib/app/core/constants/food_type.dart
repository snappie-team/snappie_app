import 'package:snappie_app/app/core/constants/app_assets.dart';

enum FoodType {
  nonSup,
  miInstan,
  menuKomposit,
  supSoto,
  menuCampuran,
  minumanDanTambahan,
  liwetan,
  makanBersama,
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
      case FoodType.makanBersama:
        return 'Makan Bersama';
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

  String get imagePath {
    switch (this) {
      case FoodType.nonSup:
        return AppAssets.images.food1;
      case FoodType.miInstan:
        return AppAssets.images.food2;
      case FoodType.menuKomposit:
        return AppAssets.images.food3;
      case FoodType.supSoto:
        return AppAssets.images.food4;
      case FoodType.menuCampuran:
        return AppAssets.images.food5;
      case FoodType.minumanDanTambahan:
        return AppAssets.images.food6;
      case FoodType.liwetan:
        return AppAssets.images.food7;
      case FoodType.makanBersama:
        return AppAssets.images.food8;
      case FoodType.gayaPadang:
        return AppAssets.images.food9;
      case FoodType.gayaTionghoa:
        return AppAssets.images.food10;
      case FoodType.makananCepatSaji:
        return AppAssets.images.food11;
      case FoodType.makananTradisional:
        return AppAssets.images.food12;
      case FoodType.makananKemasan:
        return AppAssets.images.food13;
      case FoodType.buahBuahan:
        return AppAssets.images.food14;
    }
  }

  /// Get image path by label
  static String? getImageByLabel(String label) {
    final normalizedLabel = label.toLowerCase().trim();
    for (final value in FoodType.values) {
      if (value.label.toLowerCase() == normalizedLabel) {
        return value.imagePath;
      }
    }
    return null;
  }

  /// Get all labels as list
  static List<String> get allLabels => FoodType.values.map((e) => e.label).toList();
}