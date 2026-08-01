import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../main.dart';

class RecipeDetailSheet extends StatelessWidget {
  final Recipe recipe;
  final Set<String> selectedIngredientIds;

  const RecipeDetailSheet({
    super.key,
    required this.recipe,
    required this.selectedIngredientIds,
  });

  @override
  Widget build(BuildContext context) {
    final availableTags = recipe.requiredIngredients.where((ing) => selectedIngredientIds.contains(ing.id)).toList();
    final missingTags = recipe.requiredIngredients.where((ing) => !selectedIngredientIds.contains(ing.id)).toList();

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.88),
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
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER BANNER
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            color: KawaiiColors.butter,
                            borderRadius: BorderRadius.circular(28.0),
                            border: Border.all(color: Colors.amber.shade300, width: 2),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(26.0),
                            child: recipe.imageUrl != null
                                ? Image.network(
                                    recipe.imageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, e, s) => Center(child: Text(recipe.emoji, style: const TextStyle(fontSize: 48))),
                                  )
                                : Center(child: Text(recipe.emoji, style: const TextStyle(fontSize: 48))),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          recipe.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: KawaiiColors.textDark,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Chip(
                              label: Text('⏱️ ${recipe.prepTimeMinutes} Dk'),
                              backgroundColor: Colors.white,
                              side: const BorderSide(color: KawaiiColors.cardBorder),
                              labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            Chip(
                              label: Text('⭐ ${'⭐' * recipe.difficultyStars}'),
                              backgroundColor: Colors.white,
                              side: const BorderSide(color: KawaiiColors.cardBorder),
                              labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            Chip(
                              label: Text('🔥 ${recipe.calories} kcal'),
                              backgroundColor: Colors.white,
                              side: const BorderSide(color: KawaiiColors.cardBorder),
                              labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // MATCH STATUS BADGES
                  if (availableTags.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: KawaiiColors.lightMint,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: KawaiiColors.mint, width: 1.5),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: Colors.green, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Dolabında Var: ${availableTags.map((e) => e.name).join(', ')}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (missingTags.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: KawaiiColors.lightYellow,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.amber.shade300, width: 1.5),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.shopping_cart_rounded, color: Colors.amber, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Eksik Olanlar: ${missingTags.map((e) => e.name).join(', ')}',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.amber),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // DETAILED MEASURED INGREDIENTS LIST
                  const Text(
                    '📋 Ölçülü Malzeme Listesi',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: KawaiiColors.textDark),
                  ),
                  const SizedBox(height: 10),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: KawaiiColors.cardBorder, width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: recipe.ingredientsText.map((ingItem) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('• ', style: TextStyle(color: KawaiiColors.coral, fontWeight: FontWeight.bold, fontSize: 14)),
                              Expanded(
                                child: Text(
                                  ingItem,
                                  style: const TextStyle(fontSize: 13, height: 1.3, color: KawaiiColors.textDark),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // STEPS
                  const Text(
                    '👩‍🍳 Nefis Adım Adım Yapılış',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: KawaiiColors.textDark),
                  ),
                  const SizedBox(height: 12),

                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recipe.steps.length,
                    itemBuilder: (context, idx) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: const BoxDecoration(
                                color: KawaiiColors.peach,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${idx + 1}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                recipe.steps[idx],
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.4,
                                  color: KawaiiColors.textDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // CHEF SECRET TIP BOX
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.pink.shade50,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: KawaiiColors.peach, width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Text('💡 ', style: TextStyle(fontSize: 16)),
                            Text(
                              'Ablamdan İpucu & Püf Noktası:',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: KawaiiColors.coral,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          recipe.chefTip,
                          style: const TextStyle(
                            fontSize: 13,
                            height: 1.3,
                            color: KawaiiColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: KawaiiColors.peach,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: const Text(
                        'Harika! Anlaşıldı ✨',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
