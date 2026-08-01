import 'ingredient.dart';

enum PrepTimeFilter {
  all('Tümü', 'Tüm Süreler', 999),
  quick('⚡ Şık Şak (15 Dk)', 'Hızlıca Atıştır!', 15),
  medium('🍲 Tam Kıvamında (15-30 Dk)', 'Pratik Lezzetler', 30),
  long('👨‍🍳 Mutfak Sefası (30+ Dk)', 'Özenli Sofralar', 9999);

  final String label;
  final String subtitle;
  final int maxMinutes;
  const PrepTimeFilter(this.label, this.subtitle, this.maxMinutes);
}

enum MealTypeFilter {
  all('Tüm Öğünler', '✨'),
  breakfast('🥐 Kahvaltılık & Hamur İşleri', '🥐'),
  mainCourse('🥗 Çorba & Ana Yemek', '🥗'),
  dessert('🧁 Tatlılar & Kaçamaklar', '🧁');

  final String label;
  final String emoji;
  const MealTypeFilter(this.label, this.emoji);
}

class Recipe {
  final String id;
  final String title;
  final String emoji;
  final String? imageUrl;
  final int prepTimeMinutes;
  final int difficultyStars; // 1, 2, 3
  final int calories;
  final MealTypeFilter mealType;
  final List<String> ingredientsText;
  final List<Ingredient> requiredIngredients;
  final List<String> steps;
  final String chefTip;

  const Recipe({
    required this.id,
    required this.title,
    required this.emoji,
    this.imageUrl,
    required this.prepTimeMinutes,
    required this.difficultyStars,
    required this.calories,
    required this.mealType,
    required this.ingredientsText,
    required this.requiredIngredients,
    required this.steps,
    required this.chefTip,
  });
}
