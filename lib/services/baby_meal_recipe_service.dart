import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/baby_meal_recipe.dart';

class BabyMealRecipeService {
  BabyMealRecipeService._();

  static const String _assetPath = 'assets/data/baby_meal_recipes.json';
  static final BabyMealRecipeService instance = BabyMealRecipeService._();
  static const Set<String> _allowedAllergens = <String>{
    'egg',
    'dairy',
    'gluten',
    'fish',
    'nuts',
    'sesame',
    'peanut',
    'soy',
    'none',
  };
  static const Set<String> _allowedImageKeys = <String>{
    'porridge_01',
    'puree_01',
    'veggie_mash_01',
    'yogurt_bowl_01',
    'egg_breakfast_01',
    'lentil_soup_01',
    'fish_veg_01',
    'finger_food_01',
    'snack_plate_01',
    'family_bowl_01',
  };
  static const Set<String> _allowedMealTypes = <String>{
    'breakfast',
    'lunch',
    'dinner',
    'snack',
  };

  List<BabyMealRecipe>? _cache;

  Future<List<BabyMealRecipe>> loadRecipes() async {
    if (_cache != null) {
      return _cache!;
    }

    final rawJson = await rootBundle.loadString(_assetPath);
    final decoded = jsonDecode(rawJson) as List<dynamic>;
    final recipes = decoded
        .whereType<Map<String, dynamic>>()
        .map(BabyMealRecipe.fromJson)
        .toList(growable: false);
    for (final recipe in recipes) {
      _validateRecipe(recipe);
    }
    _cache = recipes;
    return recipes;
  }

  Future<List<BabyMealRecipe>> loadRecipesForAge(int ageInMonths) async {
    final recipes = await loadRecipes();
    return recipes
        .where((recipe) {
          return ageInMonths >= recipe.minMonths &&
              ageInMonths <= recipe.maxMonths;
        })
        .toList(growable: false);
  }

  void _validateRecipe(BabyMealRecipe recipe) {
    if (recipe.id.isEmpty || recipe.title.isEmpty) {
      throw FormatException('Recipe id/title cannot be empty: ${recipe.id}');
    }
    if (recipe.minMonths < 6 || recipe.maxMonths > 24) {
      throw FormatException(
        'Recipe age must stay within 6-24 months: ${recipe.id}',
      );
    }
    if (recipe.minMonths > recipe.maxMonths) {
      throw FormatException('Recipe age range is invalid: ${recipe.id}');
    }
    if (!_allowedMealTypes.contains(recipe.mealType)) {
      throw FormatException(
        'Recipe mealType is invalid for ${recipe.id}: ${recipe.mealType}',
      );
    }
    if (!_allowedImageKeys.contains(recipe.imageKey)) {
      throw FormatException(
        'Recipe imageKey is invalid for ${recipe.id}: ${recipe.imageKey}',
      );
    }
    if (recipe.texture.trim().isEmpty) {
      throw FormatException('Recipe texture is required: ${recipe.id}');
    }
    if (recipe.prepTimeMinutes <= 0) {
      throw FormatException(
        'Recipe prepTimeMinutes must be positive: ${recipe.id}',
      );
    }
    if (recipe.ingredients.isEmpty || recipe.steps.isEmpty) {
      throw FormatException(
        'Recipe ingredients/steps cannot be empty: ${recipe.id}',
      );
    }

    final normalizedAllergens = recipe.allergens
        .map((allergen) => allergen.trim().toLowerCase())
        .toSet();
    if (normalizedAllergens.isEmpty) {
      throw FormatException('Recipe allergens are required: ${recipe.id}');
    }
    if (!normalizedAllergens.every(_allowedAllergens.contains)) {
      throw FormatException('Recipe allergens are invalid: ${recipe.id}');
    }
    if (normalizedAllergens.contains('none') &&
        normalizedAllergens.length > 1) {
      throw FormatException(
        'Recipe cannot mix "none" with other allergens: ${recipe.id}',
      );
    }
    if (!normalizedAllergens.contains('none') && recipe.safetyNotes.isEmpty) {
      throw FormatException(
        'Recipe with allergens must include safetyNotes: ${recipe.id}',
      );
    }

    final textBlob = <String>[
      ...recipe.ingredients,
      ...recipe.steps,
      recipe.title,
    ].join(' ').toLowerCase();

    const bannedTerms = <String>[
      'honey',
      'whole grape',
      'whole grapes',
      'whole nut',
      'whole nuts',
      'popcorn',
      'sticky candy',
      'hard raw carrot',
      'hard raw vegetable',
      'hard apple chunk',
      'hard apple chunks',
      'added salt',
      'added sugar',
    ];
    for (final term in bannedTerms) {
      if (textBlob.contains(term)) {
        throw FormatException(
          'Recipe contains banned term "$term": ${recipe.id}',
        );
      }
    }

    if (recipe.maxMonths < 12 &&
        (textBlob.contains('cow milk') || textBlob.contains('whole milk'))) {
      throw FormatException(
        'Cow milk as a main drink is not allowed under 12 months: ${recipe.id}',
      );
    }
  }
}
