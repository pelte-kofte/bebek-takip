import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/baby_meal_recipe.dart';
import '../models/veri_yonetici.dart';
import '../services/baby_meal_ingredient_matcher.dart';
import '../services/baby_meal_recipe_service.dart';
import '../theme/app_theme.dart';
import '../utils/baby_meal_image_assets.dart';
import '../utils/locale_text_utils.dart';

class BabyMealsScreen extends StatefulWidget {
  const BabyMealsScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<BabyMealsScreen> createState() => _BabyMealsScreenState();
}

class _BabyMealsScreenState extends State<BabyMealsScreen> {
  static const String _filterAll = 'all';

  final BabyMealRecipeService _recipeService = BabyMealRecipeService.instance;
  final TextEditingController _ingredientController = TextEditingController();
  List<BabyMealRecipe> _allRecipes = const <BabyMealRecipe>[];
  List<BabyMealIngredientMatch> _ingredientMatches =
      const <BabyMealIngredientMatch>[];
  bool _loading = true;
  bool _loadFailed = false;
  bool _didSearchIngredients = false;
  String _activeFilter = _filterAll;
  String _ingredientQuery = '';

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  @override
  void dispose() {
    _ingredientController.dispose();
    super.dispose();
  }

  Future<void> _loadRecipes() async {
    try {
      final recipes = await _recipeService.loadRecipes();
      if (!mounted) return;
      setState(() {
        _allRecipes = recipes;
        _loading = false;
        _loadFailed = false;
      });
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('BabyMealsScreen failed to load recipes: $error');
        debugPrintStack(stackTrace: stackTrace);
      }
      if (!mounted) return;
      setState(() {
        _allRecipes = const <BabyMealRecipe>[];
        _loading = false;
        _loadFailed = true;
      });
    }
  }

  bool get _isTurkish => Localizations.localeOf(context).languageCode == 'tr';

  String get _screenTitle => _isTurkish ? 'Ek Gıda' : 'Baby Meals';

  String get _emptyText => _isTurkish
      ? 'Bu yas icin henuz tarif bulunmuyor.'
      : 'No recipes yet for this age.';

  String get _loadErrorText => _isTurkish
      ? 'Tarifler simdilik yuklenemedi. Lutfen daha sonra tekrar deneyin.'
      : 'Recipes could not be loaded right now. Please try again later.';

  String get _todayText => _isTurkish ? 'Bugunun Tarifi' : "Today's Recipe";

  String get _forAgeText => _isTurkish ? 'Bu Donem Icin' : 'For This Age';

  String get _ingredientsText => _isTurkish ? 'Malzemeler' : 'Ingredients';

  String get _stepsText => _isTurkish ? 'Hazirlanis' : 'Steps';

  String get _allergensText => _isTurkish ? 'Alerjenler' : 'Allergens';

  String get _safetyText => _isTurkish ? 'Guvenlik Notlari' : 'Safety Notes';

  String get _tapForDetailsText =>
      _isTurkish ? 'Detaylar icin dokun' : 'Tap for details';

  String get _matcherTitle => _isTurkish ? 'Evde ne var?' : 'What can I make?';

  String get _matcherSubtitle => _isTurkish
      ? 'Malzemeleri yaz, uygun tarifleri bulalim.'
      : 'Enter ingredients and find matching baby meals.';

  String get _matcherHint => _isTurkish
      ? 'muz, yumurta, yogurt...'
      : 'banana, egg, yogurt...';

  String get _matcherButtonText => _isTurkish ? 'Tarif Bul' : 'Find Recipes';

  String get _matcherResultsText => _isTurkish
      ? 'Uygun Tarifler'
      : 'Matching Recipes';

  String get _matcherEmptyText => _isTurkish
      ? 'Bu malzemelerle uygun tarif bulamadik.'
      : 'No matching recipes found for these ingredients.';

  String get _missingIngredientsText =>
      _isTurkish ? 'Eksik' : 'Missing ingredients';

  Widget _buildStatusState({
    required bool isDark,
    required IconData icon,
    required String message,
  }) {
    final secondaryColor = isDark
        ? AppColors.textSecondaryDark
        : const Color(0xFF866F65);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.bgDarkCard.withValues(alpha: 0.92)
                : Colors.white.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: AppColors.primary, size: 26),
              ),
              const SizedBox(height: 14),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTypography.body(context).copyWith(
                  color: secondaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int? _babyAgeInMonths() {
    final baby = VeriYonetici.getActiveBabyOrNull();
    if (baby == null) return null;
    return calcAge(baby.birthDate, referenceDate: DateTime.now()).totalMonths;
  }

  List<({String key, String label})> _filters() {
    return <({String key, String label})>[
      (key: _filterAll, label: _isTurkish ? 'Tum' : 'All'),
      (key: 'breakfast', label: _isTurkish ? 'Kahvalti' : 'Breakfast'),
      (key: 'lunch', label: _isTurkish ? 'Ogle' : 'Lunch'),
      (key: 'dinner', label: _isTurkish ? 'Aksam' : 'Dinner'),
      (key: 'snack', label: _isTurkish ? 'Atistirmalik' : 'Snack'),
    ];
  }

  List<BabyMealRecipe> _recipesForCurrentAge() {
    final ageInMonths = _babyAgeInMonths();
    if (ageInMonths == null) {
      return _allRecipes;
    }
    return _allRecipes
        .where((recipe) {
          return ageInMonths >= recipe.minMonths &&
              ageInMonths <= recipe.maxMonths;
        })
        .toList(growable: false);
  }

  List<BabyMealRecipe> _visibleRecipes() {
    final recipes = _recipesForCurrentAge();
    if (_activeFilter == _filterAll) {
      return recipes;
    }
    return recipes
        .where((recipe) => recipe.mealType == _activeFilter)
        .toList(growable: false);
  }

  bool get _canSearchIngredients => _ingredientQuery.trim().isNotEmpty;

  BabyMealRecipe? _todaysRecipe(List<BabyMealRecipe> recipes) {
    if (recipes.isEmpty) return null;
    final today = DateTime.now();
    final seed = DateTime(
      today.year,
      today.month,
      today.day,
    ).difference(DateTime(2024, 1, 1)).inDays;
    return recipes[seed.remainder(recipes.length)];
  }

  String _ageRangeLabel(BabyMealRecipe recipe) {
    if (_isTurkish) {
      return '${recipe.minMonths}-${recipe.maxMonths} ay';
    }
    return '${recipe.minMonths}-${recipe.maxMonths} mo';
  }

  String _allergenLabel(String allergen) {
    if (!_isTurkish) return allergen;
    switch (allergen) {
      case 'egg':
        return 'yumurta';
      case 'dairy':
        return 'sut';
      case 'gluten':
        return 'gluten';
      case 'fish':
        return 'balik';
      case 'nuts':
        return 'kuruyemis';
      case 'sesame':
        return 'susam';
      case 'peanut':
        return 'yer fistigi';
      case 'soy':
        return 'soya';
      case 'none':
        return 'yok';
      default:
        return allergen;
    }
  }

  String _ingredientLabel(String ingredient) {
    if (!_isTurkish) return ingredient;
    switch (ingredient) {
      case 'plain yogurt':
        return 'yogurt';
      case 'banana':
        return 'muz';
      case 'pear':
        return 'armut';
      case 'apple':
        return 'elma';
      case 'avocado':
        return 'avokado';
      case 'sweet potato':
        return 'tatli patates';
      case 'zucchini':
        return 'kabak';
      case 'carrot':
        return 'havuc';
      case 'potato':
        return 'patates';
      case 'broccoli':
        return 'brokoli';
      case 'peas':
        return 'bezelye';
      case 'egg':
      case 'egg yolk':
        return 'yumurta';
      case 'rolled oats':
      case 'finely ground oats':
        return 'yulaf';
      case 'semolina':
        return 'irmik';
      case 'red lentils':
        return 'mercimek';
      case 'chicken':
        return 'tavuk';
      case 'lamb':
        return 'kuzu';
      case 'beef':
        return 'dana';
      case 'salmon':
        return 'somon';
      case 'white fish':
        return 'balik';
      case 'olive oil':
        return 'zeytinyagi';
      default:
        return ingredient;
    }
  }

  String _mealTypeLabel(String mealType) {
    if (!_isTurkish) {
      switch (mealType) {
        case 'breakfast':
          return 'Breakfast';
        case 'lunch':
          return 'Lunch';
        case 'dinner':
          return 'Dinner';
        case 'snack':
          return 'Snack';
        default:
          return mealType;
      }
    }
    switch (mealType) {
      case 'breakfast':
        return 'Kahvalti';
      case 'lunch':
        return 'Ogle';
      case 'dinner':
        return 'Aksam';
      case 'snack':
        return 'Atistirmalik';
      default:
        return mealType;
    }
  }

  String _matchLabel(BabyMealIngredientMatch match) {
    if (match.isGoodMatch) {
      return _isTurkish ? 'Iyi eslesme' : 'Good match';
    }
    return _isTurkish
        ? '%${match.matchPercentage} eslesme'
        : '${match.matchPercentage}% match';
  }

  void _runIngredientMatcher() {
    if (!_canSearchIngredients) {
      return;
    }

    FocusScope.of(context).unfocus();

    final results = BabyMealIngredientMatcher.findMatches(
      recipes: _allRecipes,
      query: _ingredientQuery,
      babyAgeInMonths: _babyAgeInMonths(),
    );

    setState(() {
      _didSearchIngredients = true;
      _ingredientMatches = results;
    });
  }

  Future<void> _showRecipeDetails(BabyMealRecipe recipe) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary = isDark
        ? AppColors.textSecondaryDark
        : const Color(0xFF866F65);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.bgDarkCard : const Color(0xFFFFFBF7),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: textSecondary.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        recipe.title,
                        style: AppTypography.h3(context).copyWith(fontSize: 20),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: _MealImageCard(
                          imageKey: recipe.imageKey,
                          compact: false,
                          detail: true,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _MealMetaPill(label: _ageRangeLabel(recipe)),
                          _MealMetaPill(label: recipe.texture),
                          _MealMetaPill(
                            label: '${recipe.prepTimeMinutes} min',
                            highlight: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _DetailSectionTitle(title: _ingredientsText),
                      const SizedBox(height: 8),
                      ...recipe.ingredients.map(
                        (item) => _DetailBullet(text: item),
                      ),
                      const SizedBox(height: 18),
                      _DetailSectionTitle(title: _stepsText),
                      const SizedBox(height: 8),
                      ...recipe.steps.asMap().entries.map(
                        (entry) => _DetailStep(
                          index: entry.key + 1,
                          text: entry.value,
                        ),
                      ),
                      const SizedBox(height: 18),
                      _DetailSectionTitle(title: _allergensText),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: recipe.allergens
                            .map(
                              (allergen) => _MealMetaPill(
                                label: _allergenLabel(allergen),
                              ),
                            )
                            .toList(growable: false),
                      ),
                      const SizedBox(height: 18),
                      _DetailSectionTitle(title: _safetyText),
                      const SizedBox(height: 8),
                      ...recipe.safetyNotes.map(
                        (item) => _DetailBullet(text: item),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeroCard(BabyMealRecipe recipe, bool isDark) {
    final textSecondary = isDark
        ? AppColors.textSecondaryDark
        : const Color(0xFF866F65);

    return GestureDetector(
      onTap: () => _showRecipeDetails(recipe),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? <Color>[AppColors.bgDarkCard, const Color(0xFF3E302B)]
                : <Color>[const Color(0xFFFFF3EC), const Color(0xFFFFFBF7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.18)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _todayText,
              style: AppTypography.caption(
                context,
              ).copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.title,
                        style: AppTypography.h3(context).copyWith(fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_ageRangeLabel(recipe)} • ${recipe.texture}',
                        style: AppTypography.caption(
                          context,
                        ).copyWith(color: textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _MealImageCard(imageKey: recipe.imageKey, compact: false),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeCard(BabyMealRecipe recipe, bool isDark) {
    final textSecondary = isDark
        ? AppColors.textSecondaryDark
        : const Color(0xFF866F65);

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () => _showRecipeDetails(recipe),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.bgDarkCard.withValues(alpha: 0.92)
              : Colors.white.withValues(alpha: 0.88),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _MealImageCard(imageKey: recipe.imageKey, compact: true),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    style: AppTypography.h3(context).copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${_ageRangeLabel(recipe)} • ${recipe.texture}',
                    style: AppTypography.caption(
                      context,
                    ).copyWith(color: textSecondary),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: recipe.allergens
                        .map(
                          (allergen) => _MealMetaPill(
                            label: _allergenLabel(allergen),
                            compact: true,
                          ),
                        )
                        .toList(growable: false),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _tapForDetailsText,
                    style: AppTypography.caption(context).copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              color: textSecondary.withValues(alpha: 0.8),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientMatcherCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? <Color>[const Color(0xFF3F2F2A), AppColors.bgDarkCard]
              : <Color>[const Color(0xFFFFF1E8), const Color(0xFFFFFBF7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.14)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.05),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.kitchen_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _matcherTitle,
                      style: AppTypography.h3(context).copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _matcherSubtitle,
                      style: AppTypography.bodySmall(context).copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : const Color(0xFF866F65),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _ingredientController,
            onChanged: (value) {
              setState(() {
                _ingredientQuery = value;
              });
            },
            onSubmitted: (_) => _runIngredientMatcher(),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: _matcherHint,
              filled: true,
              fillColor: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.white.withValues(alpha: 0.92),
              hintStyle: AppTypography.body(context).copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : const Color(0xFF9D8478),
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: AppColors.primary.withValues(alpha: 0.82),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.08),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.26),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _canSearchIngredients ? _runIngredientMatcher : null,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                _matcherButtonText,
                style: AppTypography.body(context).copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchCard(BabyMealIngredientMatch match, bool isDark) {
    final recipe = match.recipe;
    final textSecondary = isDark
        ? AppColors.textSecondaryDark
        : const Color(0xFF866F65);

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () => _showRecipeDetails(recipe),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.bgDarkCard.withValues(alpha: 0.92)
              : Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.title,
                        style: AppTypography.h3(context).copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${_ageRangeLabel(recipe)} • ${_mealTypeLabel(recipe.mealType)}',
                        style: AppTypography.caption(
                          context,
                        ).copyWith(color: textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                _MealMetaPill(label: _matchLabel(match), highlight: true),
              ],
            ),
            if (match.missingIngredients.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                '$_missingIngredientsText: ${match.missingIngredients.map(_ingredientLabel).join(', ')}',
                style: AppTypography.bodySmall(context).copyWith(
                  color: textSecondary,
                ),
              ),
            ],
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: recipe.allergens
                  .map(
                    (allergen) => _MealMetaPill(
                      label: _allergenLabel(allergen),
                      compact: true,
                    ),
                  )
                  .toList(growable: false),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final recipes = _visibleRecipes();
    final todaysRecipe = _todaysRecipe(recipes);

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        SizedBox(height: widget.embedded ? 8 : 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Expanded(
                child: Text(_screenTitle, style: AppTypography.h2(context)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: (_loadFailed || recipes.isEmpty)
              ? _buildStatusState(
                  isDark: isDark,
                  icon: _loadFailed
                      ? Icons.restaurant_menu_outlined
                      : Icons.soup_kitchen_outlined,
                  message: _loadFailed ? _loadErrorText : _emptyText,
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                  children: [
                    if (todaysRecipe != null)
                      _buildHeroCard(todaysRecipe, isDark),
                    const SizedBox(height: 18),
                    _buildIngredientMatcherCard(isDark),
                    if (_didSearchIngredients) ...[
                      const SizedBox(height: 18),
                      Text(
                        _matcherResultsText,
                        style: AppTypography.h3(context).copyWith(fontSize: 17),
                      ),
                      const SizedBox(height: 12),
                      if (_ingredientMatches.isEmpty)
                        _buildStatusState(
                          isDark: isDark,
                          icon: Icons.search_off_rounded,
                          message: _matcherEmptyText,
                        )
                      else
                        ..._ingredientMatches.map(
                          (match) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildMatchCard(match, isDark),
                          ),
                        ),
                    ],
                    const SizedBox(height: 6),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _filters()
                            .map((filter) {
                              final selected = _activeFilter == filter.key;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  selected: selected,
                                  label: Text(filter.label),
                                  onSelected: (_) {
                                    setState(() => _activeFilter = filter.key);
                                  },
                                  labelStyle: AppTypography.caption(context)
                                      .copyWith(
                                        color: selected
                                            ? Colors.white
                                            : (isDark
                                                  ? AppColors.textSecondaryDark
                                                  : const Color(0xFF866F65)),
                                        fontWeight: FontWeight.w600,
                                      ),
                                  selectedColor: AppColors.primary,
                                  backgroundColor: isDark
                                      ? AppColors.bgDarkCard
                                      : Colors.white.withValues(alpha: 0.84),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    side: BorderSide(
                                      color: AppColors.primary.withValues(
                                        alpha: selected ? 0 : 0.12,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            })
                            .toList(growable: false),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      _forAgeText,
                      style: AppTypography.h3(context).copyWith(fontSize: 17),
                    ),
                    const SizedBox(height: 12),
                    ...recipes.map(
                      (recipe) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildRecipeCard(recipe, isDark),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _MealImageCard extends StatelessWidget {
  const _MealImageCard({
    required this.imageKey,
    required this.compact,
    this.detail = false,
  });

  final String imageKey;
  final bool compact;
  final bool detail;

  @override
  Widget build(BuildContext context) {
    final assetPath = BabyMealImageAssets.assetPathFor(imageKey);
    final width = detail ? 164.0 : (compact ? 72.0 : 92.0);
    final height = detail ? 164.0 : (compact ? 72.0 : 92.0);
    final radius = detail ? 24.0 : 18.0;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFFFFE0D2), Color(0xFFFFF4EC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(radius),
      ),
      clipBehavior: Clip.antiAlias,
      child: assetPath == null
          ? _MealImageFallback(
              imageKey: imageKey,
              compact: compact,
              detail: detail,
            )
          : Image.asset(
              assetPath,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) {
                return _MealImageFallback(
                  imageKey: imageKey,
                  compact: compact,
                  detail: detail,
                );
              },
            ),
    );
  }
}

class _MealImageFallback extends StatelessWidget {
  const _MealImageFallback({
    required this.imageKey,
    required this.compact,
    required this.detail,
  });

  final String imageKey;
  final bool compact;
  final bool detail;

  @override
  Widget build(BuildContext context) {
    final iconSize = detail ? 34.0 : (compact ? 22.0 : 26.0);
    final labelSize = detail ? 12.0 : (compact ? 9.0 : 10.0);

    return Container(
      padding: EdgeInsets.all(detail ? 14 : 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFFFFE0D2), Color(0xFFFFF4EC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.45)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: detail ? 56 : 42,
            height: detail ? 56 : 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(detail ? 18 : 14),
            ),
            child: Icon(
              Icons.restaurant_menu_rounded,
              color: AppColors.primary,
              size: iconSize,
            ),
          ),
          SizedBox(height: detail ? 10 : 6),
          Text(
            imageKey.replaceAll('_', '\n'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: labelSize,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF9A6F5C),
              height: 1.05,
            ),
          ),
        ],
      ),
    );
  }
}

class _MealMetaPill extends StatelessWidget {
  const _MealMetaPill({
    required this.label,
    this.compact = false,
    this.highlight = false,
  });

  final String label;
  final bool compact;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: highlight
            ? AppColors.primary.withValues(alpha: 0.12)
            : const Color(0xFFF8EFE8),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: compact ? 11 : 12,
          fontWeight: FontWeight.w600,
          color: highlight ? AppColors.primary : const Color(0xFF7F6558),
        ),
      ),
    );
  }
}

class _DetailSectionTitle extends StatelessWidget {
  const _DetailSectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: AppTypography.h3(context).copyWith(fontSize: 16));
  }
}

class _DetailBullet extends StatelessWidget {
  const _DetailBullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: AppTypography.body(context).copyWith(
                color: isDark ? Colors.white : const Color(0xFF45312A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailStep extends StatelessWidget {
  const _DetailStep({required this.index, required this.text});

  final int index;
  final String text;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '$index',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: AppTypography.body(context).copyWith(
                color: isDark ? Colors.white : const Color(0xFF45312A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
