import 'package:flutter/material.dart';
import '../main.dart';
import '../models/ingredient.dart';
import '../data/ingredients_data.dart';

class FridgeScreen extends StatefulWidget {
  final Set<String> selectedIngredientIds;
  final void Function(String id) onToggle;
  final VoidCallback onClear;

  const FridgeScreen({
    super.key,
    required this.selectedIngredientIds,
    required this.onToggle,
    required this.onClear,
  });

  @override
  State<FridgeScreen> createState() => _FridgeScreenState();
}

class _FridgeScreenState extends State<FridgeScreen> {
  IngredientCategory _selectedCategory = IngredientCategory.sebze;

  @override
  Widget build(BuildContext context) {
    final selectedCount = widget.selectedIngredientIds.length;

    return Scaffold(
      backgroundColor: KawaiiColors.creamBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Dolabımda Ne Var?',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: KawaiiColors.textDark,
                          ),
                        ),
                        Text(
                          '$selectedCount malzeme seçili ✨',
                          style: const TextStyle(
                            fontSize: 13,
                            color: KawaiiColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (selectedCount > 0)
                    TextButton.icon(
                      onPressed: widget.onClear,
                      icon: const Icon(Icons.refresh_rounded, size: 16, color: KawaiiColors.coral),
                      label: const Text(
                        'Temizle',
                        style: TextStyle(color: KawaiiColors.coral, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // HINT
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: KawaiiColors.lightMint,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: KawaiiColors.mint, width: 1),
                ),
                child: const Row(
                  children: [
                    Text('💡 ', style: TextStyle(fontSize: 14)),
                    Expanded(
                      child: Text(
                        'Tuz, karabiber, un, tereyağı, yumurta, süt ve soğan her zaman dolabınızda varsayılmaktadır.',
                        style: TextStyle(fontSize: 12, color: KawaiiColors.textDark),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // CATEGORY TABS
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: IngredientCategory.values.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedCategory = cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                        decoration: BoxDecoration(
                          color: isSelected ? KawaiiColors.mint : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? KawaiiColors.mint : KawaiiColors.cardBorder,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(cat.emoji, style: const TextStyle(fontSize: 14)),
                            const SizedBox(width: 6),
                            Text(
                              cat.label,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                                color: isSelected ? KawaiiColors.textDark : KawaiiColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 16),

            // INGREDIENT CHIPS GRID
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 10,
                  children: IngredientsData.ingredients
                      .where((ing) => ing.category == _selectedCategory)
                      .map((ing) {
                    final isSelected = widget.selectedIngredientIds.contains(ing.id);
                    return GestureDetector(
                      onTap: () => widget.onToggle(ing.id),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                        decoration: BoxDecoration(
                          color: isSelected ? KawaiiColors.mint : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isSelected ? KawaiiColors.mint : KawaiiColors.cardBorder,
                            width: 1.5,
                          ),
                          boxShadow: isSelected
                              ? [BoxShadow(color: KawaiiColors.mint.withOpacity(0.35), blurRadius: 8, offset: const Offset(0, 3))]
                              : [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(ing.emoji, style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: 6),
                            Text(
                              ing.name,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                                color: KawaiiColors.textDark,
                              ),
                            ),
                            if (isSelected) ...[
                              const SizedBox(width: 4),
                              const Icon(Icons.check_circle_rounded, size: 15, color: KawaiiColors.textDark),
                            ],
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
