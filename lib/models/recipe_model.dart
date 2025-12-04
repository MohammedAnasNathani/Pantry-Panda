class Recipe {
  final String id;
  final String title;
  final String description;
  final int cookingTimeMinutes;
  final int calories;
  final String difficulty;
  final int moneySaved; // The "Trash-to-Cash" Value
  final List<String> steps;
  final List<String> ingredients;

  Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.cookingTimeMinutes,
    required this.calories,
    required this.difficulty,
    required this.moneySaved,
    required this.steps,
    required this.ingredients,
  });

  factory Recipe.fromJson(Map<String, dynamic> json, String generatedId) {
    return Recipe(
      id: generatedId,
      title: json['title'] ?? 'Mystery Meal',
      description: json['description'] ?? 'A delicious sustainable recipe.',
      cookingTimeMinutes: json['cooking_time_minutes'] ?? 20,
      calories: json['calories'] ?? 300,
      difficulty: json['difficulty'] ?? 'Medium',
      moneySaved: json['money_saved_inr'] ?? 150,
      steps: List<String>.from(json['steps'] ?? ['Mix.', 'Cook.', 'Serve.']),
      ingredients: List<String>.from(json['ingredients_needed'] ?? []),
    );
  }
}