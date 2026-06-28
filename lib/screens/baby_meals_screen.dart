import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/baby_meal_recipe.dart';
import '../models/veri_yonetici.dart';
import '../services/baby_meal_ingredient_matcher.dart';
import '../services/baby_meal_recipe_service.dart';
import '../theme/app_theme.dart';
import '../utils/baby_meal_image_assets.dart';
import '../utils/locale_text_utils.dart';
import '../widgets/nilico_motion.dart';
import '../widgets/nilico_section_header.dart';

class BabyMealsScreen extends StatefulWidget {
  const BabyMealsScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<BabyMealsScreen> createState() => _BabyMealsScreenState();
}

class _BabyMealsScreenState extends State<BabyMealsScreen> {
  static const String _filterAll = 'all';
  static const int _initialRecipeCount = 6;

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

  String get _matcherHint =>
      _isTurkish ? 'muz, yumurta, yogurt...' : 'banana, egg, yogurt...';

  String get _matcherButtonText => _isTurkish ? 'Tarif Bul' : 'Find Recipes';

  String get _matcherResultsText =>
      _isTurkish ? 'Uygun Tarifler' : 'Matching Recipes';

  String get _viewAllRecipesText =>
      _isTurkish ? 'Tum tarifleri gor' : 'View all recipes';

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
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
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
                style: AppTypography.body(
                  context,
                ).copyWith(color: secondaryColor),
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

  List<BabyMealRecipe> _previewRecipes(List<BabyMealRecipe> recipes) {
    if (recipes.length <= _initialRecipeCount) {
      return recipes;
    }
    return recipes.take(_initialRecipeCount).toList(growable: false);
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

  _MealVisuals _mealVisuals(String mealType, {required bool isDark}) {
    switch (mealType) {
      case 'breakfast':
        return _MealVisuals(
          accent: AppColors.accentLavender,
          tint: const Color(0xFFF4EFFB),
          border: const Color(0xFFE6DDF4),
          imageGradient: const <Color>[Color(0xFFE9DFF7), Color(0xFFFBF8FE)],
          text: const Color(0xFF7B6791),
        );
      case 'lunch':
        return _MealVisuals(
          accent: AppColors.accentPeach,
          tint: const Color(0xFFFFF1EA),
          border: const Color(0xFFF6DED1),
          imageGradient: const <Color>[Color(0xFFFFE5D8), Color(0xFFFFF8F3)],
          text: const Color(0xFF9B715D),
        );
      case 'dinner':
        return _MealVisuals(
          accent: const Color(0xFFF2C9C4),
          tint: const Color(0xFFFFF0EE),
          border: const Color(0xFFF0D5D2),
          imageGradient: const <Color>[Color(0xFFF5D7D2), Color(0xFFFFF8F6)],
          text: const Color(0xFF9A6C66),
        );
      case 'snack':
        return _MealVisuals(
          accent: const Color(0xFFF8EBD7),
          tint: const Color(0xFFFFFAF2),
          border: const Color(0xFFF1E3CC),
          imageGradient: const <Color>[Color(0xFFF8EBD7), Color(0xFFFFFCF8)],
          text: const Color(0xFF9B8062),
        );
      default:
        return _MealVisuals(
          accent: AppColors.primaryLight,
          tint: isDark
              ? AppColors.bgDarkCard.withValues(alpha: 0.92)
              : Colors.white.withValues(alpha: 0.9),
          border: AppColors.primary.withValues(alpha: 0.12),
          imageGradient: const <Color>[Color(0xFFFFE0D2), Color(0xFFFFF4EC)],
          text: const Color(0xFF866F65),
        );
    }
  }

  Future<void> _openAllRecipes(List<BabyMealRecipe> recipes) async {
    await Navigator.of(context).push(
      buildNilicoPageRoute<void>(
        builder: (_) => _AllRecipesScreen(
          title: _forAgeText,
          recipes: recipes,
          buildRecipeCard: (recipe, isDark) => _buildRecipeCard(recipe, isDark),
        ),
      ),
    );
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
    final visuals = _mealVisuals(recipe.mealType, isDark: isDark);

    await showNilicoModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final bottomPadding = MediaQuery.of(sheetContext).viewPadding.bottom;

        return Padding(
          padding: EdgeInsets.fromLTRB(12, 0, 12, 12 + bottomPadding),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.bgDarkCard : AppColors.surfaceWhite,
              borderRadius: BorderRadius.circular(30),
              boxShadow: AppShadows.card(isDark),
            ),
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 42,
                          height: 4,
                          decoration: BoxDecoration(
                            color: textSecondary.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      ),
                      const SizedBox(height: 26),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(56, 0, 56, 0),
                        child: Text(
                          recipe.title,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.h3(
                            context,
                          ).copyWith(fontSize: 22),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Center(
                        child: _MealImageCard(
                          imageKey: recipe.imageKey,
                          compact: false,
                          detail: true,
                          gradientColors: visuals.imageGradient,
                          heroTag: 'meal-${recipe.id}',
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _MealMetaPill(
                            label: _ageRangeLabel(recipe),
                            color: visuals.tint,
                            textColor: visuals.text,
                          ),
                          _MealMetaPill(
                            label: recipe.texture,
                            color: visuals.tint.withValues(alpha: 0.82),
                            textColor: visuals.text,
                          ),
                          _MealMetaPill(
                            label: '${recipe.prepTimeMinutes} min',
                            highlight: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _DetailSectionTitle(title: _ingredientsText),
                      const SizedBox(height: 10),
                      ...recipe.ingredients.map(
                        (item) => _DetailBullet(text: item),
                      ),
                      const SizedBox(height: 20),
                      _DetailSectionTitle(title: _stepsText),
                      const SizedBox(height: 10),
                      ...recipe.steps.asMap().entries.map(
                        (entry) => _DetailStep(
                          index: entry.key + 1,
                          text: entry.value,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _DetailSectionTitle(title: _allergensText),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: recipe.allergens
                            .map(
                              (allergen) => _MealMetaPill(
                                label: _allergenLabel(allergen),
                                color: visuals.tint,
                                textColor: visuals.text,
                              ),
                            )
                            .toList(growable: false),
                      ),
                      const SizedBox(height: 20),
                      _DetailSectionTitle(title: _safetyText),
                      const SizedBox(height: 10),
                      ...recipe.safetyNotes.map(
                        (item) => _DetailBullet(text: item),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 14,
                  left: 16,
                  child: SafeArea(
                    bottom: false,
                    child: _SheetCloseButton(
                      onPressed: () => Navigator.pop(sheetContext),
                    ),
                  ),
                ),
              ],
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
    final visuals = _mealVisuals(recipe.mealType, isDark: isDark);

    return NilicoPressable(
      onTap: () => _showRecipeDetails(recipe),
      haptic: NilicoHapticType.selection,
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: isDark ? AppColors.bgDarkCard : visuals.tint,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark
                ? visuals.accent.withValues(alpha: 0.18)
                : visuals.border,
          ),
          boxShadow: AppShadows.card(isDark),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  _todayText,
                  style: AppTypography.caption(context).copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                _MealMetaPill(
                  label: _mealTypeLabel(recipe.mealType),
                  color: visuals.tint,
                  textColor: visuals.text,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.h3(context).copyWith(fontSize: 19),
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
                const SizedBox(width: 18),
                _MealImageCard(
                  imageKey: recipe.imageKey,
                  compact: false,
                  gradientColors: visuals.imageGradient,
                  heroTag: 'meal-${recipe.id}',
                ),
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
    final visuals = _mealVisuals(recipe.mealType, isDark: isDark);

    return NilicoPressable(
      onTap: () => _showRecipeDetails(recipe),
      haptic: NilicoHapticType.selection,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.bgDarkCard.withValues(alpha: 0.92)
              : AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isDark
                ? visuals.accent.withValues(alpha: 0.16)
                : visuals.border,
          ),
          boxShadow: AppShadows.card(isDark),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _MealImageCard(
              imageKey: recipe.imageKey,
              compact: true,
              gradientColors: visuals.imageGradient,
              heroTag: 'meal-${recipe.id}',
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _MealMetaPill(
                    label: _mealTypeLabel(recipe.mealType),
                    compact: true,
                    color: visuals.tint.withValues(alpha: 0.96),
                    textColor: visuals.text,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    recipe.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgDarkCard : AppColors.lavenderSoft,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: isDark
              ? AppColors.accentLavender.withValues(alpha: 0.18)
              : const Color(0xFFE3D8F3),
        ),
        boxShadow: AppShadows.card(isDark),
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
                  color: AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.borderSoft),
                ),
                child: Icon(
                  Icons.kitchen_rounded,
                  color: const Color(0xFF7A749E),
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
                style: AppTypography.body(
                  context,
                ).copyWith(color: Colors.white, fontWeight: FontWeight.w700),
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
    final visuals = _mealVisuals(recipe.mealType, isDark: isDark);

    return NilicoPressable(
      onTap: () => _showRecipeDetails(recipe),
      haptic: NilicoHapticType.selection,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.bgDarkCard.withValues(alpha: 0.92)
              : Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isDark
                ? visuals.accent.withValues(alpha: 0.16)
                : visuals.border,
          ),
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
                style: AppTypography.bodySmall(
                  context,
                ).copyWith(color: textSecondary),
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
    final previewRecipes = _previewRecipes(recipes);
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
                  padding: EdgeInsets.fromLTRB(
                    24,
                    8,
                    24,
                    widget.embedded ? 110 : 32,
                  ),
                  children: [
                    if (todaysRecipe != null)
                      _buildHeroCard(todaysRecipe, isDark),
                    const SizedBox(height: 22),
                    _buildIngredientMatcherCard(isDark),
                    if (_didSearchIngredients) ...[
                      const SizedBox(height: 26),
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
                    const SizedBox(height: 18),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _filters()
                            .map((filter) {
                              final selected = _activeFilter == filter.key;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: NilicoPressable(
                                  onTap: () {
                                    if (!selected) {
                                      NilicoHaptics.trigger(
                                        NilicoHapticType.selection,
                                      );
                                    }
                                    setState(() => _activeFilter = filter.key);
                                  },
                                  child: AnimatedContainer(
                                    duration: NilicoMotion.chipDuration,
                                    curve: NilicoMotion.ease,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 9,
                                    ),
                                    decoration: BoxDecoration(
                                      color: selected
                                          ? const Color(0xFF9A8AC0)
                                          : (isDark
                                                ? AppColors.bgDarkCard
                                                : const Color(0xFFF7F1FB)),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: selected
                                            ? Colors.transparent
                                            : const Color(
                                                0xFFE3D8F3,
                                              ).withValues(alpha: 0.9),
                                      ),
                                    ),
                                    child: AnimatedDefaultTextStyle(
                                      duration: NilicoMotion.chipDuration,
                                      curve: NilicoMotion.ease,
                                      style: AppTypography.caption(context)
                                          .copyWith(
                                            color: selected
                                                ? Colors.white
                                                : (isDark
                                                      ? AppColors
                                                            .textSecondaryDark
                                                      : const Color(
                                                          0xFF7A749E,
                                                        )),
                                            fontWeight: FontWeight.w600,
                                          ),
                                      child: Text(filter.label),
                                    ),
                                  ),
                                ),
                              );
                            })
                            .toList(growable: false),
                      ),
                    ),
                    const SizedBox(height: 28),
                    NilicoSectionHeader(
                      title: _forAgeText,
                      trailing: recipes.length > _initialRecipeCount
                          ? Text(
                              '${recipes.length}',
                              style: AppTypography.caption(context).copyWith(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : const Color(0xFF866F65),
                                fontWeight: FontWeight.w700,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 14),
                    ...previewRecipes.map(
                      (recipe) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildRecipeCard(recipe, isDark),
                      ),
                    ),
                    if (recipes.length > _initialRecipeCount) ...[
                      const SizedBox(height: 4),
                      _ViewAllRecipesCard(
                        label: _viewAllRecipesText,
                        count: recipes.length,
                        isDark: isDark,
                        onTap: () => _openAllRecipes(recipes),
                      ),
                    ],
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
    this.gradientColors,
    this.heroTag,
  });

  final String imageKey;
  final bool compact;
  final bool detail;
  final List<Color>? gradientColors;
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final assetPath = BabyMealImageAssets.assetPathFor(imageKey);
    final width = detail ? 188.0 : (compact ? 82.0 : 108.0);
    final height = detail ? 188.0 : (compact ? 82.0 : 108.0);
    final radius = detail ? 28.0 : 20.0;
    final imagePadding = detail ? 16.0 : (compact ? 8.0 : 10.0);

    final imageCard = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color:
            gradientColors?.first.withValues(alpha: 0.7) ??
            AppColors.bgLightSurface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppColors.borderSoft),
        boxShadow: AppShadows.card(isDark),
      ),
      clipBehavior: Clip.antiAlias,
      child: assetPath == null
          ? _MealImageFallback(
              imageKey: imageKey,
              compact: compact,
              detail: detail,
            )
          : Padding(
              padding: EdgeInsets.all(imagePadding),
              child: Image.asset(
                assetPath,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) {
                  return _MealImageFallback(
                    imageKey: imageKey,
                    compact: compact,
                    detail: detail,
                  );
                },
              ),
            ),
    );

    if (heroTag == null) {
      return imageCard;
    }

    return Hero(tag: heroTag!, child: imageCard);
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
        color: AppColors.bgLightSurface,
        border: Border.all(color: AppColors.borderSoft),
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
    this.color,
    this.textColor,
  });

  final String label;
  final bool compact;
  final bool highlight;
  final Color? color;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 9 : 12,
        vertical: compact ? 5 : 7,
      ),
      decoration: BoxDecoration(
        color:
            color ??
            (highlight ? const Color(0xFFF2EAFB) : const Color(0xFFF6F1FC)),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: highlight
              ? const Color(0xFFE3D8F3)
              : Colors.white.withValues(alpha: 0.75),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: compact ? 11 : 12,
          fontWeight: FontWeight.w600,
          color:
              textColor ??
              (highlight ? const Color(0xFF7A749E) : const Color(0xFF6F628A)),
        ),
      ),
    );
  }
}

class _SheetCloseButton extends StatelessWidget {
  const _SheetCloseButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onPressed,
        child: Ink(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.white.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : const Color(0xFFE6E0DC),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.06),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(
            Icons.close_rounded,
            size: 20,
            color: isDark ? Colors.white : const Color(0xFF5B4A46),
          ),
        ),
      ),
    );
  }
}

class _MealVisuals {
  const _MealVisuals({
    required this.accent,
    required this.tint,
    required this.border,
    required this.imageGradient,
    required this.text,
  });

  final Color accent;
  final Color tint;
  final Color border;
  final List<Color> imageGradient;
  final Color text;
}

class _ViewAllRecipesCard extends StatelessWidget {
  const _ViewAllRecipesCard({
    required this.label,
    required this.count,
    required this.isDark,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return NilicoPressable(
      onTap: onTap,
      haptic: NilicoHapticType.selection,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.bgDarkCard.withValues(alpha: 0.9)
              : AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.14)),
          boxShadow: AppShadows.card(isDark),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.menu_book_rounded,
                color: AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: AppTypography.body(
                  context,
                ).copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            Text(
              '$count',
              style: AppTypography.bodySmall(context).copyWith(
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : const Color(0xFF866F65),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right_rounded,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : const Color(0xFF866F65),
            ),
          ],
        ),
      ),
    );
  }
}

class _AllRecipesScreen extends StatelessWidget {
  const _AllRecipesScreen({
    required this.title,
    required this.recipes,
    required this.buildRecipeCard,
  });

  final String title;
  final List<BabyMealRecipe> recipes;
  final Widget Function(BabyMealRecipe recipe, bool isDark) buildRecipeCard;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(title, style: AppTypography.h2(context)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        itemCount: recipes.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) =>
            buildRecipeCard(recipes[index], isDark),
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
