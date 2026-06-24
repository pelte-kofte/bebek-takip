class BabyMealRecipe {
  final String id;
  final String title;
  final int minMonths;
  final int maxMonths;
  final String mealType;
  final String texture;
  final List<String> ingredients;
  final List<String> steps;
  final List<String> allergens;
  final List<String> safetyNotes;
  final List<String> tags;
  final int prepTimeMinutes;
  final String imageKey;

  const BabyMealRecipe({
    required this.id,
    required this.title,
    required this.minMonths,
    required this.maxMonths,
    required this.mealType,
    required this.texture,
    required this.ingredients,
    required this.steps,
    required this.allergens,
    required this.safetyNotes,
    required this.tags,
    required this.prepTimeMinutes,
    required this.imageKey,
  });

  factory BabyMealRecipe.fromJson(Map<String, dynamic> json) {
    return BabyMealRecipe(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      minMonths: json['minMonths'] as int? ?? 0,
      maxMonths: json['maxMonths'] as int? ?? 24,
      mealType: json['mealType'] as String? ?? 'meal',
      texture: json['texture'] as String? ?? '',
      ingredients: List<String>.from(json['ingredients'] as List? ?? const []),
      steps: List<String>.from(json['steps'] as List? ?? const []),
      allergens: List<String>.from(json['allergens'] as List? ?? const []),
      safetyNotes: List<String>.from(json['safetyNotes'] as List? ?? const []),
      tags: List<String>.from(json['tags'] as List? ?? const []),
      prepTimeMinutes: json['prepTimeMinutes'] as int? ?? 0,
      imageKey: json['imageKey'] as String? ?? '',
    );
  }
}
