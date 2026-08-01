enum IngredientCategory {
  sebze('🥦', 'Sebzeler'),
  et('🥩', 'Et & Şarküteri'),
  sut('🥛', 'Süt & Şarküteri'),
  tahil('🌾', 'Tahıl & Bakliyat'),
  baharat('🧂', 'Baharat & Tatlı & Sos');

  final String emoji;
  final String label;
  const IngredientCategory(this.emoji, this.label);
}

class Ingredient {
  final String id;
  final String name;
  final String emoji;
  final IngredientCategory category;

  const Ingredient({
    required this.id,
    required this.name,
    required this.emoji,
    required this.category,
  });
}
