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
  Recipe? _recommendedRecipe;
  int _currentTipIndex = 0;

  final List<Map<String, String>> _kitchenTips = [
    {
      'title': '🥚 Taze Yumurta Testi',
      'fact': 'Yumurtayı su dolu kaba atın. Dibe çökerse taze, suyun üstüne çıkarsa bayattır!'
    },
    {
      'title': '🍋 Bol Limon Suyu',
      'fact': 'Limonu sıkmadan önce tezgahta avucunuzla bastırarak yuvarlayın, 2 kat fazla su verir!'
    },
    {
      'title': '🧅 Göz Yaşartmayan Soğan',
      'fact': 'Soğanı doğramadan 10 dakika önce buzdolabında bekletin, gözleriniz hiç yaşarmaz!'
    },
    {
      'title': '🥔 Tuzlu Çorba Kurtarma',
      'fact': 'Fazla tuzlu sulu yemeğe soyulmuş yarım patates atın, patates fazla tuzu emer!'
    },
    {
      'title': '🥖 Bayat Ekmek Tazeleme',
      'fact': 'Bayat ekmeğe hafifçe su serpip fırında 5 dk ısıtın, fırından yeni çıkmış gibi taptaze olur!'
    },
    {
      'title': '🧀 Yapışmayan Kaşar Rendesi',
      'fact': 'Kaşar peynirini rendelemeden 10 dk önce dondurucuda bekletirseniz rendeye yapışmaz!'
    },
    {
      'title': '🌿 Uzun Ömürlü Yeşillik',
      'fact': 'Maydanoz ve naneyi kağıt havluya sarıp saklayın, 2 kat daha uzun süre taze kalır!'
    },
    {
      'title': '🍚 Kar Gibi Bembeyaz Pilav',
      'fact': 'Pirinç pilavı pişerken içine 2-3 damla limon suyu damlatın, tane tane ve bembeyaz olur!'
    },
    {
      'title': '🥩 Lokum Gibi Yumuşak Et',
      'fact': 'Et sote yaparken ilk 5 dakika tuz eklemeyin; tuz eti sertleştirebilir!'
    },
    {
      'title': '🧄 Kolay Soyulan Sarımsak',
      'fact': 'Sarımsak dişlerini geniş bıçağın yan tarafıyla hafifçe ezerseniz kabukları saniyede soyulur!'
    },
    {
      'title': '☕ Kokuları Gideren Kahve',
      'fact': 'Buzdolabındaki kötü kokuları gidermek için küçük kasede kurutulmuş kahve telvesi koyun!'
    },
    {
      'title': '🍅 Kolay Soyulan Domates',
      'fact': 'Domateslerin altına çapraz çizik atıp 30 saniye kaynar suda bekletin, kabuğu kayarak soyulur!'
    },
    {
      'title': '🍌 Muzları Uzun Taze Tutma',
      'fact': 'Muz saplarını streç filmle sararsanız etilen gazı yayılımı yavaşlar ve muz kararmaz!'
    },
    {
      'title': '🥑 Avokado Olgunlaştırma',
      'fact': 'Sert avokadoyu elma ile aynı kese kağıdına koyun, 1 günde yumuşacık olur!'
    },
    {
      'title': '🍯 Kristalleşen Balı Çözme',
      'fact': 'Donan bal kavanozunu ılık su dolu kapta (benmari) bekletin, bal eski haline döner!'
    },
    {
      'title': '🥦 Canlı Yeşil Brokoli',
      'fact': 'Brokoli ve haşlama sebzeleri haşladıktan hemen sonra buzlu suya atın, renkleri canlı kalır!'
    },
    {
      'title': '🥧 Çatlamayan Kek',
      'fact': 'Kek harcını fırına vermeden önce tezgah üzerine 2 kez hafifçe vurun, hava kabarcıkları söner!'
    },
    {
      'title': '🍳 Yapışmayan Omlet',
      'fact': 'Tavayı iyice ısıtıp yağı ekleyin, yumurtayı oda sıcaklığında kırarsanız tavaya asla yapışmaz!'
    },
    {
      'title': '🧅 Çıtır Soğan Halkası',
      'fact': 'Soğan halkalarını kızartmadan önce soda ve un karışımına batırırsanız çıtır çıtır olur!'
    },
    {
      'title': '🧄 Ağızda Sarımsak Kokusu',
      'fact': 'Sarımsak yedikten sonra 1 dilim taze elma yemek veya maydanoz çiğnemek kokuyu anında keser!'
    },
  ];

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
    final fullMatches = RecipesData.recipes.where((recipe) {
      final missing = recipe.requiredIngredients.where((ing) => !widget.selectedIngredientIds.contains(ing.id)).toList();
      return missing.isEmpty;
    }).toList();

    if (fullMatches.isNotEmpty) {
      final rnd = Random();
      setState(() {
        _recommendedRecipe = fullMatches[rnd.nextInt(fullMatches.length)];
      });
    } else {
      setState(() {
        _recommendedRecipe = null;
      });
    }
  }

  @override
  void didUpdateWidget(covariant FairyScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIngredientIds != widget.selectedIngredientIds) {
      _pickDailyRecommendation();
    }
  }

  void _nextTip() {
    setState(() {
      _currentTipIndex = (_currentTipIndex + 1) % _kitchenTips.length;
    });
  }

  void _openCameraModal() {
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
      backgroundColor: KawaiiColors.getBg(context),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 24),

                // TITLE
                Text(
                  'Yardımcı Şef',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: KawaiiColors.getTextPrimary(context),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Mutfaktaki en büyük yardımcınız! 👨‍🍳✨',
                  style: TextStyle(fontSize: 14, color: KawaiiColors.textMuted),
                ),

                const SizedBox(height: 20),

                // BOUNCING CHARACTER & SPEECH
                Row(
                  children: [
                    AnimatedBuilder(
                      animation: _bounceAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _bounceAnimation.value),
                          child: child,
                        );
                      },
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: KawaiiColors.getCardBg(context),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: KawaiiColors.peach.withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text('👨‍🍳', style: TextStyle(fontSize: 54)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: KawaiiColors.getCardBg(context),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: KawaiiColors.getBorder(context), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: KawaiiColors.peach.withOpacity(0.15),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.selectedCount > 0
                                  ? 'Dolabınızda ${widget.selectedCount} malzeme seçili!'
                                  : 'Henüz dolabınıza malzeme eklemediniz!',
                              style: TextStyle(fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: KawaiiColors.getTextPrimary(context),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Fotoğraf çekin veya aşağıdaki malzemelere dokunarak dolabınızı doldurun!',
                              style: TextStyle(fontSize: 11, color: KawaiiColors.getTextSecondary(context), height: 1.3),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 📸 LARGE PROMINENT FEATURE BUTTON (FOTOĞRAF ÇEK & MALZEME TESPİT ET)
                GestureDetector(
                  onTap: _openCameraModal,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
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
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: const Text('📸', style: TextStyle(fontSize: 28)),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Fotoğraf Çek & Malzeme Tespit Et',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                'Dolabınızın veya tezgahınızın fotoğrafını çekin, malzemeler anında eklensin!',
                                style: TextStyle(fontSize: 11, color: Colors.white70, height: 1.35),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 18),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 💡 MUTFAK İPUÇLARI & PÜF NOKTALARI CARD
                _buildKitchenTipsCard(),

                const SizedBox(height: 20),

                // 🌟 GÜNÜN YEMEK TAVSİYESİ CARD
                _buildDailyRecommendationCard(),

                const SizedBox(height: 20),

                // 🧺 EDITABLE PANTRY STAPLES
                _buildEditableStaplesCard(),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKitchenTipsCard() {
    final tip = _kitchenTips[_currentTipIndex];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: KawaiiColors.getCardBg(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFFD1DC), width: 1.8),
        boxShadow: [
          BoxShadow(
            color: KawaiiColors.peach.withOpacity(0.18),
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
              const Text('💡 ', style: TextStyle(fontSize: 20)),
              const Expanded(
                child: Text(
                  'Mutfak İpuçları & Püf Noktaları',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: KawaiiColors.coral,
                  ),
                ),
              ),
              GestureDetector(
                onTap: _nextTip,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: KawaiiColors.lightYellow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Text('Sonraki ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFB8860B))),
                      Icon(Icons.arrow_forward_rounded, size: 12, color: Color(0xFFB8860B)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            tip['title']!,
            style: TextStyle(fontSize: 14,
              fontWeight: FontWeight.w800,
              color: KawaiiColors.getTextPrimary(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            tip['fact']!,
            style: TextStyle(fontSize: 12.5,
              color: KawaiiColors.getTextSecondary(context),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyRecommendationCard() {
    if (_recommendedRecipe == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: KawaiiColors.getCardBg(context),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: KawaiiColors.cardBorder, width: 1.8),
        ),
        child: Column(
          children: [
            const Text('👩‍🍳', style: TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text(
              'Buzdolabındaki malzemeleri %100 tam olan bir yemek bulduğumda sana özel şef tavsiyemi burada göreceksin! 🛒✨',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: KawaiiColors.getTextPrimary(context),
              ),
            ),
          ],
        ),
      );
    }

    final recipe = _recommendedRecipe!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: KawaiiColors.getCardBg(context),
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
              Expanded(
                child: Text(
                  'Bugünkü Yemek Tavsiyem',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: KawaiiColors.getTextPrimary(context),
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
                      style: TextStyle(fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: KawaiiColors.getTextPrimary(context),
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
        color: Theme.of(context).brightness == Brightness.dark
            ? KawaiiColors.darkCard
            : KawaiiColors.lightMint,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? KawaiiColors.darkCardBorder
              : KawaiiColors.mint,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🧺 ', style: TextStyle(fontSize: 18)),
              Expanded(
                child: Text(
                  'Temel Mutfak Malzemelerim',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: KawaiiColors.getTextPrimary(context),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Dokunarak temel malzemelerinizi dolabınıza ekleyebilir veya çıkarabilirsiniz:',
            style: TextStyle(fontSize: 12, color: KawaiiColors.getTextSecondary(context)),
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
                    color: isSelected
                        ? (Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF2E6B4B)
                            : KawaiiColors.mint)
                        : KawaiiColors.getCardBg(context),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected
                          ? KawaiiColors.mint
                          : (Theme.of(context).brightness == Brightness.dark
                              ? KawaiiColors.darkCardBorder
                              : const Color(0xFFC8E6C9)),
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
                          color: KawaiiColors.getTextPrimary(context),
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
