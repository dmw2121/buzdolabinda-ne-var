import '../models/ingredient.dart';

class IngredientsData {
  static const List<Ingredient> ingredients = [
    // Sebzeler
    Ingredient(id: 'domates', name: 'Domates', emoji: '🍅', category: IngredientCategory.sebze),
    Ingredient(id: 'biber', name: 'Yeşil Biber', emoji: '🫑', category: IngredientCategory.sebze),
    Ingredient(id: 'kapya_biber', name: 'Kapya Biber', emoji: '🌶️', category: IngredientCategory.sebze),
    Ingredient(id: 'sogan', name: 'Kuru Soğan', emoji: '🧅', category: IngredientCategory.sebze),
    Ingredient(id: 'sarimsak', name: 'Sarımsak', emoji: '🧄', category: IngredientCategory.sebze),
    Ingredient(id: 'patates', name: 'Patates', emoji: '🥔', category: IngredientCategory.sebze),
    Ingredient(id: 'havuc', name: 'Havuç', emoji: '🥕', category: IngredientCategory.sebze),
    Ingredient(id: 'mantar', name: 'Mantar', emoji: '🍄', category: IngredientCategory.sebze),
    Ingredient(id: 'salatalik', name: 'Salatalık', emoji: '🥒', category: IngredientCategory.sebze),
    Ingredient(id: 'patlican', name: 'Patlıcan', emoji: '🍆', category: IngredientCategory.sebze),
    Ingredient(id: 'kabak', name: 'Kabak', emoji: '🥒', category: IngredientCategory.sebze),
    Ingredient(id: 'ispanak', name: 'Ispanak', emoji: '🥬', category: IngredientCategory.sebze),
    Ingredient(id: 'maydanoz', name: 'Maydanoz', emoji: '🌿', category: IngredientCategory.sebze),
    Ingredient(id: 'dereotu', name: 'Dereotu', emoji: '🌿', category: IngredientCategory.sebze),
    Ingredient(id: 'nane', name: 'Taze Nane', emoji: '🍃', category: IngredientCategory.sebze),
    Ingredient(id: 'marul', name: 'Marul / Kıvırcık', emoji: '🥬', category: IngredientCategory.sebze),
    Ingredient(id: 'bezelye', name: 'Bezelye', emoji: '🫛', category: IngredientCategory.sebze),
    Ingredient(id: 'misir', name: 'Mısır', emoji: '🌽', category: IngredientCategory.sebze),
    Ingredient(id: 'limon', name: 'Limon', emoji: '🍋', category: IngredientCategory.sebze),
    Ingredient(id: 'karnabahar', name: 'Karnabahar', emoji: '🥦', category: IngredientCategory.sebze),
    Ingredient(id: 'brokoli', name: 'Brokoli', emoji: '🥦', category: IngredientCategory.sebze),
    Ingredient(id: 'lahana', name: 'Lahana', emoji: '🥬', category: IngredientCategory.sebze),

    // Et & Şarküteri
    Ingredient(id: 'tavuk', name: 'Tavuk Göğsü', emoji: '🍗', category: IngredientCategory.et),
    Ingredient(id: 'tavuk_baget', name: 'Tavuk Baget', emoji: '🍗', category: IngredientCategory.et),
    Ingredient(id: 'kiyma', name: 'Kıymalı Et', emoji: '🥩', category: IngredientCategory.et),
    Ingredient(id: 'kusbasi', name: 'Kuşbaşı Et', emoji: '🥩', category: IngredientCategory.et),
    Ingredient(id: 'sucuk', name: 'Sucuk', emoji: '🥓', category: IngredientCategory.et),
    Ingredient(id: 'sosis', name: 'Sosis', emoji: '🌭', category: IngredientCategory.et),
    Ingredient(id: 'yumurta', name: 'Yumurta', emoji: '🥚', category: IngredientCategory.et),
    Ingredient(id: 'pastirma', name: 'Pastırma', emoji: '🥓', category: IngredientCategory.et),

    // Süt & Şarküteri
    Ingredient(id: 'sut', name: 'Süt', emoji: '🥛', category: IngredientCategory.sut),
    Ingredient(id: 'kasar', name: 'Kaşar Peyniri', emoji: '🧀', category: IngredientCategory.sut),
    Ingredient(id: 'beyaz_peynir', name: 'Beyaz Peynir', emoji: '🧀', category: IngredientCategory.sut),
    Ingredient(id: 'lor', name: 'Lor Peyniri', emoji: '🧀', category: IngredientCategory.sut),
    Ingredient(id: 'tereyagi', name: 'Tereyağı', emoji: '🧈', category: IngredientCategory.sut),
    Ingredient(id: 'krema', name: 'Krema', emoji: '🥛', category: IngredientCategory.sut),
    Ingredient(id: 'yogurt', name: 'Yoğurt', emoji: '🥣', category: IngredientCategory.sut),
    Ingredient(id: 'labne', name: 'Labne Peyniri', emoji: '🧀', category: IngredientCategory.sut),
    Ingredient(id: 'kaymak', name: 'Kaymak', emoji: '🧈', category: IngredientCategory.sut),

    // Tahıl & Bakliyat
    Ingredient(id: 'makarna', name: 'Makarna', emoji: '🍝', category: IngredientCategory.tahil),
    Ingredient(id: 'sehriye', name: 'Şehriye', emoji: '🍝', category: IngredientCategory.tahil),
    Ingredient(id: 'un', name: 'Un', emoji: '🌾', category: IngredientCategory.tahil),
    Ingredient(id: 'mercimek', name: 'Kırmızı Mercimek', emoji: '🥣', category: IngredientCategory.tahil),
    Ingredient(id: 'yesil_mercimek', name: 'Yeşil Mercimek', emoji: '🥣', category: IngredientCategory.tahil),
    Ingredient(id: 'nohut', name: 'Nohut', emoji: '🫘', category: IngredientCategory.tahil),
    Ingredient(id: 'fasulye', name: 'Kuru Fasulye', emoji: '🫘', category: IngredientCategory.tahil),
    Ingredient(id: 'ekmek', name: 'Ekmek', emoji: '🍞', category: IngredientCategory.tahil),
    Ingredient(id: 'seker', name: 'Şeker', emoji: '🍬', category: IngredientCategory.tahil),
    Ingredient(id: 'pudra_sekeri', name: 'Pudra Şekeri', emoji: '🍬', category: IngredientCategory.tahil),
    Ingredient(id: 'pirinc', name: 'Pirinç', emoji: '🍚', category: IngredientCategory.tahil),
    Ingredient(id: 'bulgur', name: 'Bulgur', emoji: '🌾', category: IngredientCategory.tahil),
    Ingredient(id: 'irmik', name: 'İrmik', emoji: '🌾', category: IngredientCategory.tahil),
    Ingredient(id: 'nisasta', name: 'Nişasta', emoji: '🌾', category: IngredientCategory.tahil),
    Ingredient(id: 'milfoy', name: 'Milföy Hamuru', emoji: '🥐', category: IngredientCategory.tahil),
    Ingredient(id: 'yufka', name: 'Yufka', emoji: '🫓', category: IngredientCategory.tahil),
    Ingredient(id: 'biskuvi', name: 'Bisküvi', emoji: '🍪', category: IngredientCategory.tahil),

    // Baharat & Sos & Tatlı
    Ingredient(id: 'salca', name: 'Domates Salçası', emoji: '🥫', category: IngredientCategory.baharat),
    Ingredient(id: 'biber_salcasi', name: 'Biber Salçası', emoji: '🥫', category: IngredientCategory.baharat),
    Ingredient(id: 'zeytinyagi', name: 'Zeytinyağı', emoji: '🫗', category: IngredientCategory.baharat),
    Ingredient(id: 'siviyag', name: 'Sıvı Yağ', emoji: '🫗', category: IngredientCategory.baharat),
    Ingredient(id: 'kakao', name: 'Kakao', emoji: '🍫', category: IngredientCategory.baharat),
    Ingredient(id: 'cikolata', name: 'Çikolata', emoji: '🍫', category: IngredientCategory.baharat),
    Ingredient(id: 'kekik', name: 'Kekik & Baharat', emoji: '🌿', category: IngredientCategory.baharat),
    Ingredient(id: 'tuz', name: 'Tuz', emoji: '🧂', category: IngredientCategory.baharat),
    Ingredient(id: 'karabiber', name: 'Karabiber', emoji: '🧂', category: IngredientCategory.baharat),
    Ingredient(id: 'pulbiber', name: 'Pul Biber', emoji: '🌶️', category: IngredientCategory.baharat),
    Ingredient(id: 'nane_kurusu', name: 'Kuru Nane', emoji: '🌿', category: IngredientCategory.baharat),
    Ingredient(id: 'vanilya', name: 'Vanilya', emoji: '🌸', category: IngredientCategory.baharat),
    Ingredient(id: 'kabartma_tozu', name: 'Kabartma Tozu', emoji: '🍞', category: IngredientCategory.baharat),
    Ingredient(id: 'tahin', name: 'Tahin', emoji: '🫙', category: IngredientCategory.baharat),
    Ingredient(id: 'pekmez', name: 'Pekmez', emoji: '🍯', category: IngredientCategory.baharat),
    Ingredient(id: 'ceviz', name: 'Ceviz İçi', emoji: '🥜', category: IngredientCategory.baharat),
    Ingredient(id: 'findik', name: 'Fındık', emoji: '🌰', category: IngredientCategory.baharat),
    Ingredient(id: 'fistik', name: 'Antep Fıstığı', emoji: '💚', category: IngredientCategory.baharat),
  ];

  static Ingredient getIng(String id) {
    return ingredients.firstWhere(
      (ing) => ing.id == id,
      orElse: () => Ingredient(id: id, name: id, emoji: '✨', category: IngredientCategory.baharat),
    );
  }
}
