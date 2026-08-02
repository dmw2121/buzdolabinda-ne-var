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
    final currentCategoryIngredients = IngredientsData.ingredients
        .where((ing) => ing.category == _selectedCategory)
        .toList();

    return Scaffold(
      backgroundColor: KawaiiColors.creamBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TOP HEADER
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
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
                          '$selectedCount malzeme seçildi ✨',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
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

            // 🌟 CATEGORY SELECTION CONTAINER (SOFT PASTEL HARMONIOUS BANNER)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 14),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0F3), // Soft pastel peach background matching app theme
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFFFD1DC), width: 1.8),
                boxShadow: [
                  BoxShadow(
                    color: KawaiiColors.peach.withOpacity(0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 10),
                    child: Row(
                      children: [
                        Text('📌 ', style: TextStyle(fontSize: 14)),
                        Text(
                          'KATEGORİ SEÇİN',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: KawaiiColors.coral,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 56,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: IngredientCategory.values.length,
                      itemBuilder: (context, index) {
                        final cat = IngredientCategory.values[index];
                        final isSelected = _selectedCategory == cat;
                        final selectedInCat = currentCategoryIngredients
                            .where((i) => widget.selectedIngredientIds.contains(i.id))
                            .length;

                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedCategory = cat),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? const LinearGradient(
                                        colors: [KawaiiColors.peach, KawaiiColors.coral],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : null,
                                color: isSelected ? null : Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: isSelected ? KawaiiColors.coral : KawaiiColors.cardBorder,
                                  width: isSelected ? 2 : 1.5,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: KawaiiColors.coral.withOpacity(0.35),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        )
                                      ]
                                    : [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.03),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        )
                                      ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(cat.emoji, style: const TextStyle(fontSize: 20)),
                                  const SizedBox(width: 8),
                                  Text(
                                    cat.label.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w900,
                                      color: isSelected ? Colors.white : KawaiiColors.textDark,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  if (selectedInCat > 0) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isSelected ? Colors.white.withOpacity(0.3) : KawaiiColors.mint,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        '$selectedInCat',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w900,
                                          color: isSelected ? Colors.white : KawaiiColors.textDark,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // 🥦 SECTION HEADER FOR INGREDIENTS BELOW
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: KawaiiColors.lightMint,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: KawaiiColors.mint, width: 1),
                    ),
                    child: Text(
                      '${_selectedCategory.emoji} ${_selectedCategory.label.toUpperCase()} (${currentCategoryIngredients.length})',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: Colors.green,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Divider(indent: 10, height: 1, color: KawaiiColors.cardBorder),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // INGREDIENT CHIPS (WHITE/MINT PILL CHIPS)
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 10,
                  children: currentCategoryIngredients.map((ing) {
                    final isSelected = widget.selectedIngredientIds.contains(ing.id);
                    return GestureDetector(
                      onTap: () => widget.onToggle(ing.id),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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

            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }
}
