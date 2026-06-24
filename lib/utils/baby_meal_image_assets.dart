class BabyMealImageAssets {
  BabyMealImageAssets._();

  static const Map<String, String> _assetPaths = <String, String>{
    'porridge_01': 'assets/images/meals/porridge_01.png',
    'puree_01': 'assets/images/meals/puree_01.png',
    'veggie_mash_01': 'assets/images/meals/veggie_mash_01.png',
    'yogurt_bowl_01': 'assets/images/meals/yogurt_bowl_01.png',
    'egg_breakfast_01': 'assets/images/meals/egg_breakfast_01.png',
    'lentil_soup_01': 'assets/images/meals/lentil_soup_01.png',
    'fish_veg_01': 'assets/images/meals/fish_veg_01.png',
    'finger_food_01': 'assets/images/meals/finger_food_01.png',
    'snack_plate_01': 'assets/images/meals/snack_plate_01.png',
    'family_bowl_01': 'assets/images/meals/family_bowl_01.png',
  };

  static String? assetPathFor(String imageKey) => _assetPaths[imageKey];
}
