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

  void _confirmClear(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: KawaiiColors.getCardBg(context),
        title: Row(
          children: [
            const Text('🧹 '),
            Text(
              'Emin misiniz?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: KawaiiColors.getTextPrimary(context),
              ),
            ),
          ],
        ),
        content: Text(
          'Buzdolabınızdaki seçili malzemelerin tamamı temizlenecektir.',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: KawaiiColors.getTextPrimary(context).withOpacity(0.8),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('İptal', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              if (widget.onClear != null) {
                widget.onClear!();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: KawaiiColors.coral,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Evet, Temizle', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedCount = widget.selectedIngredientIds.length;
    final currentCategoryIngredients = IngredientsData.ingredients
        .where((ing) => ing.category == _selectedCategory)
        .toList();

    return Scaffold(
      backgroundColor: KawaiiColors.getBg(context),
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
                        Text(
                          'Dolabımda Ne Var?',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: KawaiiColors.getTextPrimary(context),
                          ),
                        ),
                        Text(
                          '$selectedCount malzeme seçildi ✨',
                          style: TextStyle(fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: KawaiiColors.getTextSecondary(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (selectedCount > 0)
                    TextButton.icon(
                      onPressed: () => _confirmClear(context),
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
                color: Theme.of(context).brightness == Brightness.dark
                    ? KawaiiColors.darkCard
                    : const Color(0xFFFFF0F3),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? KawaiiColors.darkCardBorder
                      : const Color(0xFFFFD1DC),
                  width: 1.8,
                ),
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
                          color: isSelected
                              ? (Theme.of(context).brightness == Brightness.dark
                                  ? const Color(0xFF2E6B4B)
                                  : KawaiiColors.mint)
                              : KawaiiColors.getCardBg(context),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isSelected
                                ? KawaiiColors.mint
                                : KawaiiColors.getBorder(context),
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
                                color: KawaiiColors.getTextPrimary(context),
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
