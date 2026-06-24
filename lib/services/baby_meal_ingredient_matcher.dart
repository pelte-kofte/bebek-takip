import '../models/baby_meal_recipe.dart';

class BabyMealIngredientMatch {
  const BabyMealIngredientMatch({
    required this.recipe,
    required this.score,
    required this.matchPercentage,
    required this.matchedIngredients,
    required this.missingIngredients,
  });

  final BabyMealRecipe recipe;
  final int score;
  final int matchPercentage;
  final List<String> matchedIngredients;
  final List<String> missingIngredients;

  bool get isGoodMatch => matchPercentage >= 80 || missingIngredients.isEmpty;
}

class BabyMealIngredientMatcher {
  BabyMealIngredientMatcher._();

  static const Map<String, String> _userAliases = <String, String>{
    'muz': 'banana',
    'banana': 'banana',
    'yumurta': 'egg',
    'egg': 'egg',
    'yogurt': 'yogurt',
    'yoghurt': 'yogurt',
    'yoğurt': 'yogurt',
    'irmik': 'semolina',
    'semolina': 'semolina',
    'yulaf': 'oats',
    'oats': 'oats',
    'avokado': 'avocado',
    'avocado': 'avocado',
    'armut': 'pear',
    'pear': 'pear',
    'elma': 'apple',
    'apple': 'apple',
    'havuc': 'carrot',
    'havuç': 'carrot',
    'carrot': 'carrot',
    'patates': 'potato',
    'potato': 'potato',
    'tatli patates': 'sweet potato',
    'tatlı patates': 'sweet potato',
    'sweet potato': 'sweet potato',
    'kabak': 'zucchini',
    'zucchini': 'zucchini',
    'mercimek': 'lentils',
    'lentils': 'lentils',
    'lentil': 'lentils',
    'tavuk': 'chicken',
    'chicken': 'chicken',
    'kuzu': 'lamb',
    'lamb': 'lamb',
    'dana': 'beef',
    'beef': 'beef',
    'somon': 'salmon',
    'salmon': 'salmon',
    'balik': 'fish',
    'balık': 'fish',
    'fish': 'fish',
    'brokoli': 'broccoli',
    'broccoli': 'broccoli',
    'bezelye': 'peas',
    'peas': 'peas',
    'zeytinyagi': 'olive oil',
    'zeytinyağı': 'olive oil',
    'olive oil': 'olive oil',
  };

  static const Set<String> _scoreExcludedIngredients = <String>{'water'};

  static List<BabyMealIngredientMatch> findMatches({
    required List<BabyMealRecipe> recipes,
    required String query,
    int? babyAgeInMonths,
    int maxResults = 5,
  }) {
    final availableIngredients = parseInput(query);
    if (availableIngredients.isEmpty) {
      return const <BabyMealIngredientMatch>[];
    }

    final filteredRecipes = babyAgeInMonths == null
        ? recipes
        : recipes.where((recipe) {
            return babyAgeInMonths >= recipe.minMonths &&
                babyAgeInMonths <= recipe.maxMonths;
          });

    final matches = filteredRecipes
        .map((recipe) => _scoreRecipe(recipe, availableIngredients))
        .whereType<BabyMealIngredientMatch>()
        .toList(growable: false)
      ..sort((a, b) {
        final scoreCompare = b.score.compareTo(a.score);
        if (scoreCompare != 0) return scoreCompare;

        final missingCompare = a.missingIngredients.length.compareTo(
          b.missingIngredients.length,
        );
        if (missingCompare != 0) return missingCompare;

        final percentageCompare = b.matchPercentage.compareTo(
          a.matchPercentage,
        );
        if (percentageCompare != 0) return percentageCompare;

        return a.recipe.prepTimeMinutes.compareTo(b.recipe.prepTimeMinutes);
      });

    return matches.take(maxResults).toList(growable: false);
  }

  static Set<String> parseInput(String query) {
    final normalizedQuery = _normalize(query);
    if (normalizedQuery.isEmpty) {
      return const <String>{};
    }

    final found = <String>{};

    for (final entry in _userAliases.entries) {
      final pattern = RegExp(
        '\\b${RegExp.escape(_normalize(entry.key)).replaceAll(' ', r'\s+')}\\b',
      );
      if (pattern.hasMatch(normalizedQuery)) {
        found.add(entry.value);
      }
    }

    final chunks = normalizedQuery.split(RegExp(r'[\s,;.\n]+'));
    for (final chunk in chunks) {
      final canonical = _userAliases[chunk];
      if (canonical != null) {
        found.add(canonical);
      }
    }

    return found;
  }

  static BabyMealIngredientMatch? _scoreRecipe(
    BabyMealRecipe recipe,
    Set<String> availableIngredients,
  ) {
    final scoreableIngredients = recipe.ingredients
        .where((ingredient) => !_scoreExcludedIngredients.contains(ingredient))
        .toList(growable: false);

    if (scoreableIngredients.isEmpty) {
      return null;
    }

    final matched = <String>[];
    final missing = <String>[];

    for (final ingredient in scoreableIngredients) {
      final recipeKeys = _canonicalKeysForRecipeIngredient(ingredient);
      final isMatched = recipeKeys.any(availableIngredients.contains);
      if (isMatched) {
        matched.add(ingredient);
      } else {
        missing.add(ingredient);
      }
    }

    if (matched.isEmpty) {
      return null;
    }
    if (scoreableIngredients.length >= 3 && matched.length < 2) {
      return null;
    }
    if (missing.length > 2) {
      return null;
    }

    final percentage = ((matched.length / scoreableIngredients.length) * 100)
        .round()
        .clamp(0, 100);

    final score =
        (matched.length * 40) +
        percentage -
        (missing.length * 18) +
        (missing.length <= 1 ? 10 : 0) +
        (missing.isEmpty ? 12 : 0);

    if (score <= 0) {
      return null;
    }

    return BabyMealIngredientMatch(
      recipe: recipe,
      score: score,
      matchPercentage: percentage,
      matchedIngredients: matched,
      missingIngredients: missing,
    );
  }

  static Set<String> _canonicalKeysForRecipeIngredient(String ingredient) {
    final normalized = _normalize(ingredient);
    final keys = <String>{};

    if (normalized.contains('banana')) keys.add('banana');
    if (normalized.contains('egg yolk') || normalized.contains('egg')) {
      keys.add('egg');
    }
    if (normalized.contains('yogurt')) keys.add('yogurt');
    if (normalized.contains('semolina')) keys.add('semolina');
    if (normalized.contains('oats')) keys.add('oats');
    if (normalized.contains('avocado')) keys.add('avocado');
    if (normalized.contains('pear')) keys.add('pear');
    if (normalized.contains('apple')) keys.add('apple');
    if (normalized.contains('carrot')) keys.add('carrot');
    if (normalized.contains('sweet potato')) keys.add('sweet potato');
    if (normalized.contains('potato') && !normalized.contains('sweet potato')) {
      keys.add('potato');
    }
    if (normalized.contains('zucchini')) keys.add('zucchini');
    if (normalized.contains('lentil')) keys.add('lentils');
    if (normalized.contains('chicken')) keys.add('chicken');
    if (normalized.contains('lamb')) keys.add('lamb');
    if (normalized.contains('beef')) keys.add('beef');
    if (normalized.contains('salmon')) {
      keys.add('salmon');
      keys.add('fish');
    }
    if (normalized.contains('fish')) keys.add('fish');
    if (normalized.contains('broccoli')) keys.add('broccoli');
    if (normalized.contains('peas')) keys.add('peas');
    if (normalized.contains('olive oil')) keys.add('olive oil');

    return keys.isEmpty ? <String>{normalized} : keys;
  }

  static String _normalize(String input) {
    return input
        .toLowerCase()
        .replaceAll('ı', 'i')
        .replaceAll('İ', 'i')
        .replaceAll('ğ', 'g')
        .replaceAll('Ğ', 'g')
        .replaceAll('ü', 'u')
        .replaceAll('Ü', 'u')
        .replaceAll('ş', 's')
        .replaceAll('Ş', 's')
        .replaceAll('ö', 'o')
        .replaceAll('Ö', 'o')
        .replaceAll('ç', 'c')
        .replaceAll('Ç', 'c')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
