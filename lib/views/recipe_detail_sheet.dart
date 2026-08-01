import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../main.dart';

class RecipeDetailSheet extends StatefulWidget {
  final Recipe recipe;
  final Set<String> selectedIngredientIds;

  const RecipeDetailSheet({
    super.key,
    required this.recipe,
    required this.selectedIngredientIds,
  });

  @override
  State<RecipeDetailSheet> createState() => _RecipeDetailSheetState();
}

class _RecipeDetailSheetState extends State<RecipeDetailSheet> {
  bool _ingredientsExpanded = false;

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;
    final availableTags = recipe.requiredIngredients.where((ing) => widget.selectedIngredientIds.contains(ing.id)).toList();
    final missingTags = recipe.requiredIngredients.where((ing) => !widget.selectedIngredientIds.contains(ing.id)).toList();
    final allMatch = missingTags.isEmpty;

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.92),
      decoration: const BoxDecoration(
        color: KawaiiColors.creamBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(36.0)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 48,
            height: 6,
            decoration: BoxDecoration(
              color: KawaiiColors.cardBorder,
              borderRadius: BorderRadius.circular(3),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // BIG IMAGE (tappable popup)
                  GestureDetector(
                    onTap: () => _showImagePopup(context, recipe),
                    child: Hero(
                      tag: 'detail_img_${recipe.id}',
                      child: Container(
                        height: 220,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: allMatch ? KawaiiColors.lightMint : KawaiiColors.butter,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: allMatch ? KawaiiColors.mint : KawaiiColors.cardBorder,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(22),
                              child: SizedBox.expand(
                                child: _buildRecipeImage(recipe),
                              ),
                            ),
                            // Tap to expand hint
                            Positioned(
                              bottom: 10,
                              right: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.45),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.zoom_in_rounded, color: Colors.white, size: 14),
                                    SizedBox(width: 4),
                                    Text('Büyüt', style: TextStyle(color: Colors.white, fontSize: 11)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // TITLE + STATS
                  Text(
                    recipe.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: KawaiiColors.textDark,
                      height: 1.2,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // STATS ROW
                  Row(
                    children: [
                      _statChip('⏱️', '${recipe.prepTimeMinutes} dk'),
                      const SizedBox(width: 8),
                      _statChip('🔥', '${recipe.calories} kcal'),
                      const SizedBox(width: 8),
                      _statChip('⭐', '★' * recipe.difficultyStars),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ── COLLAPSIBLE INGREDIENTS ──
                  GestureDetector(
                    onTap: () => setState(() => _ingredientsExpanded = !_ingredientsExpanded),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: KawaiiColors.cardBorder, width: 1.5),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Text('🛒 ', style: TextStyle(fontSize: 16)),
                              const Expanded(
                                child: Text(
                                  'Malzemeler',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: KawaiiColors.textDark,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: allMatch ? KawaiiColors.lightMint : Colors.pink.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${availableTags.length}/${recipe.requiredIngredients.length}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: allMatch ? Colors.green.shade700 : KawaiiColors.coral,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              AnimatedRotation(
                                turns: _ingredientsExpanded ? 0.5 : 0,
                                duration: const Duration(milliseconds: 200),
                                child: const Icon(Icons.keyboard_arrow_down_rounded, color: KawaiiColors.textMuted),
                              ),
                            ],
                          ),

                          AnimatedCrossFade(
                            crossFadeState: _ingredientsExpanded
                                ? CrossFadeState.showSecond
                                : CrossFadeState.showFirst,
                            duration: const Duration(milliseconds: 250),
                            firstChild: const SizedBox.shrink(),
                            secondChild: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 14),

                                if (recipe.ingredientsText.isNotEmpty) ...[
                                  ...recipe.ingredientsText.take(20).map((text) => Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('• ', style: TextStyle(fontSize: 14, color: KawaiiColors.peach, fontWeight: FontWeight.bold)),
                                        Expanded(
                                          child: Text(
                                            text,
                                            style: const TextStyle(fontSize: 13, color: KawaiiColors.textDark, height: 1.4),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                                ] else ...[
                                  // Fallback: show ingredient tags
                                  if (availableTags.isNotEmpty) ...[
                                    _ingSection('Dolabımda var ✅', availableTags, KawaiiColors.mint, Colors.green),
                                  ],
                                  if (missingTags.isNotEmpty) ...[
                                    const SizedBox(height: 10),
                                    _ingSection('Eksik malzemeler 🛒', missingTags, Colors.red.shade50, KawaiiColors.coral),
                                  ],
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // STEPS
                  const Text(
                    'Yapılışı',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: KawaiiColors.textDark),
                  ),
                  const SizedBox(height: 12),

                  ...recipe.steps.asMap().entries.map((e) {
                    final i = e.key;
                    final step = e.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: KawaiiColors.peach,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${i + 1}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: KawaiiColors.cardBorder, width: 1),
                              ),
                              child: Text(
                                step,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: KawaiiColors.textDark,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  // CHEF TIP
                  if (recipe.chefTip != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [const Color(0xFFFFF9E6), KawaiiColors.lightYellow],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.amber.shade300, width: 1.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Text('👩‍🍳 ', style: TextStyle(fontSize: 18)),
                              Text(
                                'Ablanızdan İpucu',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF8B6914),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            recipe.chefTip!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF8B6914),
                              fontStyle: FontStyle.italic,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeImage(Recipe recipe) {
    if (recipe.imageAsset != null) {
      return Image.asset(
        recipe.imageAsset!,
        fit: BoxFit.cover,
        errorBuilder: (c, e, s) => Center(child: Text(recipe.emoji, style: const TextStyle(fontSize: 64))),
      );
    }
    if (recipe.imageUrl != null) {
      return Image.network(
        recipe.imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (c, e, s) => Center(child: Text(recipe.emoji, style: const TextStyle(fontSize: 64))),
      );
    }
    return Center(child: Text(recipe.emoji, style: const TextStyle(fontSize: 64)));
  }

  void _showImagePopup(BuildContext context, Recipe recipe) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black87,
        pageBuilder: (ctx, anim, _) => FadeTransition(
          opacity: anim,
          child: GestureDetector(
            onTap: () => Navigator.pop(ctx),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.width * 0.9,
                    child: _buildRecipeImage(recipe),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _statChip(String icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: KawaiiColors.cardBorder, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: KawaiiColors.textDark)),
        ],
      ),
    );
  }

  Widget _ingSection(String title, List<dynamic> items, Color bgColor, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textColor)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: items.map((ing) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: textColor.withOpacity(0.3)),
            ),
            child: Text('${ing.emoji} ${ing.name}', style: TextStyle(fontSize: 11, color: textColor)),
          )).toList(),
        ),
      ],
    );
  }
}
