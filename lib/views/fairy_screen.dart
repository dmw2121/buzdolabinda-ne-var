import 'dart:math';
import 'package:flutter/material.dart';
import '../main.dart';
import '../models/recipe.dart';
import '../data/recipes_data.dart';
import 'recipe_detail_sheet.dart';
import 'ai_camera_modal.dart';

class FairyScreen extends StatefulWidget {
  final int selectedCount;
  final Set<String> selectedIngredientIds;
  final void Function(String id)? onToggleIngredient;

  const FairyScreen({
    super.key,
    required this.selectedCount,
    required this.selectedIngredientIds,
    this.onToggleIngredient,
  });

  @override
  State<FairyScreen> createState() => _FairyScreenState();
}

class _FairyScreenState extends State<FairyScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;
  late Recipe _recommendedRecipe;

  final List<Map<String, String>> _basicStaples = [
    {'id': 'tuz', 'name': 'Tuz', 'emoji': '🧂'},
    {'id': 'karabiber', 'name': 'Karabiber', 'emoji': '🧂'},
    {'id': 'un', 'name': 'Un', 'emoji': '🌾'},
    {'id': 'tereyagi', 'name': 'Tereyağı', 'emoji': '🧈'},
    {'id': 'yumurta', 'name': 'Yumurta', 'emoji': '🥚'},
    {'id': 'sut', 'name': 'Süt', 'emoji': '🥛'},
    {'id': 'siviyag', 'name': 'Sıvı Yağ', 'emoji': '🫗'},
    {'id': 'sogan', 'name': 'Soğan', 'emoji': '🧅'},
    {'id': 'sarimsak', 'name': 'Sarımsak', 'emoji': '🧄'},
  ];

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _bounceAnimation = Tween<double>(begin: 0, end: -10).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );

    _pickDailyRecommendation();
  }

  void _pickDailyRecommendation() {
    if (RecipesData.recipes.isNotEmpty) {
      final now = DateTime.now();
      final seed = now.year * 1000 + now.month * 100 + now.day;
      final rnd = Random(seed + Random().nextInt(100));
      final idx = rnd.nextInt(RecipesData.recipes.length);
      setState(() {
        _recommendedRecipe = RecipesData.recipes[idx];
      });
    }
  }

  void _openRecipeDetail(Recipe recipe) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RecipeDetailSheet(
        recipe: recipe,
        selectedIngredientIds: widget.selectedIngredientIds,
      ),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F3),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 28),

                // TITLE
                const Text(
                  'Yardımcı Şef',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: KawaiiColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Mutfaktaki en büyük yardımcınız! 👨‍🍳✨',
                  style: TextStyle(fontSize: 14, color: KawaiiColors.textMuted),
                ),

                const SizedBox(height: 28),

                // BOUNCING CHARACTER
                AnimatedBuilder(
                  animation: _bounceAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _bounceAnimation.value),
                      child: child,
                    );
                  },
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: KawaiiColors.peach.withOpacity(0.4),
                          blurRadius: 26,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text('👨‍🍳', style: TextStyle(fontSize: 78)),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // SPEECH BUBBLE
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: KawaiiColors.cardBorder, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: KawaiiColors.peach.withOpacity(0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        widget.selectedCount > 5
                            ? 'Dolabınızda ${widget.selectedCount} malzeme var, harika yemekler yapabiliriz!'
                            : 'Dolabım sekmesinden daha fazla malzeme ekleyin!',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: KawaiiColors.textDark,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Bugün sizin için özel bir yemek tavsiyem var! 👇',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: KawaiiColors.textMuted),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 🌟 GÜNÜN YEMEK TAVSİYESİ CARD
                _buildDailyRecommendationCard(),

                const SizedBox(height: 24),

                // 🧺 EDITABLE PANTRY STAPLES
                _buildEditableStaplesCard(),

                const SizedBox(height: 20),

                // AI CAMERA CTA
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => AiCameraModal(
                        onIngredientsDetected: (detectedIds) {
                          if (widget.onToggleIngredient != null) {
                            for (var id in detectedIds) {
                              if (!widget.selectedIngredientIds.contains(id)) {
                                widget.onToggleIngredient!(id);
                              }
                            }
                          }
                        },
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [KawaiiColors.peach, KawaiiColors.coral],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: KawaiiColors.coral.withOpacity(0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: const Text('📸', style: TextStyle(fontSize: 26)),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'AI Kamera',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  Text('👑', style: TextStyle(fontSize: 14)),
                                ],
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Dolabınızı fotoğraflayın, Şef tüm malzemeleri otomatik tanısın!',
                                style: TextStyle(fontSize: 12, color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 16),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDailyRecommendationCard() {
    final recipe = _recommendedRecipe;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: KawaiiColors.cardBorder, width: 1.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🌟 ', style: TextStyle(fontSize: 18)),
              const Expanded(
                child: Text(
                  'Bugünkü Yemek Tavsiyem',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: KawaiiColors.textDark,
                  ),
                ),
              ),
              GestureDetector(
                onTap: _pickDailyRecommendation,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: KawaiiColors.lightMint,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: KawaiiColors.mint, width: 1),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.refresh_rounded, size: 14, color: Colors.green),
                      SizedBox(width: 4),
                      Text('Değiştir', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // DISH ITEM
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 76,
                  height: 76,
                  color: KawaiiColors.butter,
                  child: recipe.imageAsset != null
                      ? Image.asset(
                          recipe.imageAsset!,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Center(child: Text(recipe.emoji, style: const TextStyle(fontSize: 32))),
                        )
                      : Center(child: Text(recipe.emoji, style: const TextStyle(fontSize: 32))),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: KawaiiColors.textDark,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text('⏱️ ${recipe.prepTimeMinutes} dk', style: const TextStyle(fontSize: 11, color: KawaiiColors.textMuted)),
                        const SizedBox(width: 8),
                        Text('🔥 ${recipe.calories} kcal', style: const TextStyle(fontSize: 11, color: KawaiiColors.textMuted)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // BUTTON TO OPEN DETAIL
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: () => _openRecipeDetail(recipe),
              icon: const Text('🍲', style: TextStyle(fontSize: 16)),
              label: const Text('Tarifi İncele & Pişir', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
              style: ElevatedButton.styleFrom(
                backgroundColor: KawaiiColors.peach,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableStaplesCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: KawaiiColors.lightMint,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: KawaiiColors.mint, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('🧺 ', style: TextStyle(fontSize: 18)),
              Expanded(
                child: Text(
                  'Temel Mutfak Malzemelerim',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: KawaiiColors.textDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Dokunarak temel malzemelerinizi dolabınıza ekleyebilir veya çıkarabilirsiniz:',
            style: TextStyle(fontSize: 12, color: KawaiiColors.textMuted),
          ),
          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _basicStaples.map((staple) {
              final id = staple['id']!;
              final isSelected = widget.selectedIngredientIds.contains(id);

              return GestureDetector(
                onTap: () {
                  if (widget.onToggleIngredient != null) {
                    widget.onToggleIngredient!(id);
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? KawaiiColors.mint : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected ? KawaiiColors.mint : const Color(0xFFC8E6C9),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(staple['emoji']!, style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 6),
                      Text(
                        staple['name']!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                          color: KawaiiColors.textDark,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        isSelected ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
                        size: 14,
                        color: isSelected ? Colors.green.shade800 : KawaiiColors.textMuted,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
