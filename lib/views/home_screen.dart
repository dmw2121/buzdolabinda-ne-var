import 'package:flutter/material.dart';
import '../models/ingredient.dart';
import '../models/recipe.dart';
import '../data/ingredients_data.dart';
import '../data/recipes_data.dart';
import '../main.dart';
import 'recipe_detail_sheet.dart';
import 'paywall_modal.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Set<String> _selectedIngredientIds = {'domates', 'biber', 'yumurta', 'tereyagi', 'sogan'};
  IngredientCategory _selectedCategory = IngredientCategory.sebze;
  PrepTimeFilter _selectedTimeFilter = PrepTimeFilter.all;
  MealTypeFilter _selectedMealFilter = MealTypeFilter.all;
  String _searchQuery = '';

  // PERFORMANCE MEMOIZATION CACHE
  List<Recipe>? _cachedFilteredRecipes;
  String _cacheKey = '';

  String _buildCacheKey() {
    return '${_selectedIngredientIds.join(",")}_${_selectedCategory.name}_${_selectedTimeFilter.name}_${_selectedMealFilter.name}_$_searchQuery';
  }

  int _getMatchCount(Recipe recipe) {
    int count = 0;
    for (var ing in recipe.requiredIngredients) {
      if (_selectedIngredientIds.contains(ing.id)) count++;
    }
    return count;
  }

  int _getMissingCount(Recipe recipe) {
    return recipe.requiredIngredients.length - _getMatchCount(recipe);
  }

  double _getMatchPercentage(Recipe recipe) {
    if (recipe.requiredIngredients.isEmpty) return 0.0;
    return _getMatchCount(recipe) / recipe.requiredIngredients.length;
  }

  List<Recipe> get _filteredRecipes {
    final currentKey = _buildCacheKey();
    if (_cachedFilteredRecipes != null && _cacheKey == currentKey) {
      return _cachedFilteredRecipes!;
    }

    final query = _searchQuery.toLowerCase().trim();

    final result = RecipesData.recipes.where((recipe) {
      // 1. Search Query Filter
      if (query.isNotEmpty) {
        final matchesTitle = recipe.title.toLowerCase().contains(query);
        final matchesIng = recipe.ingredientsText.any((ing) => ing.toLowerCase().contains(query)) ||
            recipe.requiredIngredients.any((ing) => ing.name.toLowerCase().contains(query));
        if (!matchesTitle && !matchesIng) return false;
      }

      // 2. Prep Time Filter
      if (_selectedTimeFilter == PrepTimeFilter.quick && recipe.prepTimeMinutes > 15) return false;
      if (_selectedTimeFilter == PrepTimeFilter.medium && (recipe.prepTimeMinutes <= 15 || recipe.prepTimeMinutes > 30)) return false;
      if (_selectedTimeFilter == PrepTimeFilter.long && recipe.prepTimeMinutes <= 30) return false;

      // 3. Meal Type Filter
      if (_selectedMealFilter != MealTypeFilter.all && recipe.mealType != _selectedMealFilter) return false;

      return true;
    }).toList()
      ..sort((a, b) {
        final pA = _getMatchPercentage(a);
        final pB = _getMatchPercentage(b);
        if (pA != pB) return pB.compareTo(pA);
        return _getMissingCount(a).compareTo(_getMissingCount(b));
      });

    _cacheKey = currentKey;
    _cachedFilteredRecipes = result;
    return result;
  }

  void _invalidateCache() {
    _cachedFilteredRecipes = null;
  }

  void _openPaywallModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PaywallModal(),
    );
  }

  void _openRecipeDetail(Recipe recipe) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RecipeDetailSheet(
        recipe: recipe,
        selectedIngredientIds: _selectedIngredientIds,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recipes = _filteredRecipes;
    final selectedCount = _selectedIngredientIds.length;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // A. HEADER & BANNER
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildMascotBanner(selectedCount),
                    const SizedBox(height: 12),
                    _buildAICameraTriggerButton(),
                  ],
                ),
              ),
            ),

            // B. SEARCH BAR
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildSearchBar(),
              ),
            ),

            // C. PREP TIME & MEAL TYPE FILTERS
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('⏱️ Hazırlık Süresi Filtresi', 'Sana uygun hızda tarif seç!'),
                    const SizedBox(height: 8),
                    _buildPrepTimeChips(),
                    const SizedBox(height: 16),
                    _buildSectionHeader('🥐 Öğün Seçimi', 'Hangi öğünü hazırlıyoruz?'),
                    const SizedBox(height: 8),
                    _buildMealTypeChips(),
                  ],
                ),
              ),
            ),

            // D. INGREDIENT SELECTION AREA
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('🧊 Dolabındaki Malzemeler', 'Tıkla, dolabındakileri seç! ✨'),
                    const SizedBox(height: 8),
                    _buildCategoryTabs(),
                    const SizedBox(height: 12),
                    _buildIngredientChipsGrid(),
                  ],
                ),
              ),
            ),

            // E. MATCH SUMMARY & RECIPE LIST HEADER
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text('🍲 ', style: TextStyle(fontSize: 22)),
                        Text(
                          'Sana Özel Tarifler (${recipes.length})',
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: KawaiiColors.textDark,
                          ),
                        ),
                      ],
                    ),
                    if (selectedCount > 0)
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _selectedIngredientIds.clear();
                            _invalidateCache();
                          });
                        },
                        icon: const Icon(Icons.refresh_rounded, size: 16, color: KawaiiColors.coral),
                        label: const Text(
                          'Temizle',
                          style: TextStyle(color: KawaiiColors.coral, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // F. RECIPE CARDS LIST
            recipes.isEmpty
                ? SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.all(24),
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: KawaiiColors.cardBorder, width: 1.5),
                      ),
                      child: const Column(
                        children: [
                          Text('🧐', style: TextStyle(fontSize: 48)),
                          SizedBox(height: 12),
                          Text(
                            'Aradığın Kriterde Tarif Bulunamadı!',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: KawaiiColors.textDark),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Biraz daha malzeme seçmeyi veya filtreleri değiştirmeyi deneyebilirsin şefim! ✨',
                            style: TextStyle(fontSize: 13, color: KawaiiColors.textMuted),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final recipe = recipes[index];
                          return _buildRecipeCard(recipe);
                        },
                        childCount: recipes.length,
                      ),
                    ),
                  ),

            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------
  // WIDGET BUILDERS
  // ------------------------------------------

  Widget _buildMascotBanner(int selectedCount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [KawaiiColors.peach, KawaiiColors.peach.withOpacity(0.85), KawaiiColors.lavender.withOpacity(0.6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28.0),
        border: Border.all(color: Colors.white, width: 2.0),
        boxShadow: [
          BoxShadow(
            color: KawaiiColors.peach.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('👩‍🍳 ', style: TextStyle(fontSize: 14)),
                          Text(
                            'Mutfak Perisi Yanında!',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: KawaiiColors.textDark),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Bugün Mutfakta Ne Harikalar Yaratıyoruz? 🍳',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: KawaiiColors.butter,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.amber.shade200, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🧊 ', style: TextStyle(fontSize: 14)),
                          Text(
                            'Dolabında $selectedCount Malzeme Seçili! ✨',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: KawaiiColors.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.pink.shade100, width: 2),
                ),
                child: const Center(
                  child: Text('👩‍🍳', style: TextStyle(fontSize: 40)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAICameraTriggerButton() {
    return InkWell(
      onTap: _openPaywallModal,
      borderRadius: BorderRadius.circular(28.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28.0),
          border: Border.all(color: KawaiiColors.peach, width: 1.8),
          boxShadow: [
            BoxShadow(
              color: KawaiiColors.peach.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: KawaiiColors.butter,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.amber.shade300, width: 1),
              ),
              child: const Text('📸', style: TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Fotoğrafını Çek, Şak Diye Algılayalım!',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: KawaiiColors.textDark,
                        ),
                      ),
                      SizedBox(width: 4),
                      Text('👑', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Mutfak Perisi AI Kamerası ile Otomatik Malzeme Tanıma',
                    style: TextStyle(fontSize: 11, color: KawaiiColors.textMuted),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: KawaiiColors.coral),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28.0),
        border: Border.all(color: KawaiiColors.cardBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        onChanged: (val) {
          setState(() {
            _searchQuery = val;
            _invalidateCache();
          });
        },
        decoration: InputDecoration(
          hintText: '200 tarif veya malzeme ara... (Örn: Köfte, Mercimek, Revani)',
          hintStyle: const TextStyle(fontSize: 13, color: KawaiiColors.textMuted),
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 16, right: 8),
            child: Text('🔍', style: TextStyle(fontSize: 18)),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 18, color: KawaiiColors.textMuted),
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                      _invalidateCache();
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: KawaiiColors.textDark,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 11, color: KawaiiColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildPrepTimeChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: PrepTimeFilter.values.map((filter) {
          final isSelected = _selectedTimeFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedTimeFilter = filter;
                  _invalidateCache();
                });
              },
              borderRadius: BorderRadius.circular(28),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? KawaiiColors.peach : Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: isSelected ? KawaiiColors.peach : KawaiiColors.cardBorder,
                    width: 1.5,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: KawaiiColors.peach.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                child: Text(
                  filter.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? Colors.white : KawaiiColors.textDark,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMealTypeChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: MealTypeFilter.values.map((meal) {
          final isSelected = _selectedMealFilter == meal;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedMealFilter = meal;
                  _invalidateCache();
                });
              },
              borderRadius: BorderRadius.circular(28),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? KawaiiColors.lavender : Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: isSelected ? KawaiiColors.lavender : KawaiiColors.cardBorder,
                    width: 1.5,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: KawaiiColors.lavender.withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                child: Text(
                  meal.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? Colors.white : KawaiiColors.textDark,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: IngredientCategory.values.map((cat) {
          final isSelected = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedCategory = cat;
                });
              },
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? KawaiiColors.mint : Colors.white,
                  borderRadius: BorderRadius.circular(24),
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
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
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
    );
  }

  Widget _buildIngredientChipsGrid() {
    final currentCategoryIngredients = IngredientsData.ingredients
        .where((ing) => ing.category == _selectedCategory)
        .toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: currentCategoryIngredients.map((ing) {
          final isSelected = _selectedIngredientIds.contains(ing.id);

          return InkWell(
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedIngredientIds.remove(ing.id);
                } else {
                  _selectedIngredientIds.add(ing.id);
                }
                _invalidateCache();
              });
            },
            borderRadius: BorderRadius.circular(28.0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? KawaiiColors.mint : Colors.white,
                borderRadius: BorderRadius.circular(28.0),
                border: Border.all(
                  color: isSelected ? KawaiiColors.mint : KawaiiColors.cardBorder,
                  width: 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: KawaiiColors.mint.withOpacity(0.4),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
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
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: KawaiiColors.textDark,
                    ),
                  ),
                  if (isSelected) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.check_circle_rounded, size: 16, color: KawaiiColors.textDark),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRecipeCard(Recipe recipe) {
    final matchCount = _getMatchCount(recipe);
    final totalCount = recipe.requiredIngredients.length;
    final missingCount = _getMissingCount(recipe);
    final is100Percent = missingCount == 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28.0),
        border: Border.all(
          color: is100Percent ? KawaiiColors.mint : KawaiiColors.cardBorder,
          width: is100Percent ? 2.0 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: is100Percent ? KawaiiColors.mint.withOpacity(0.2) : Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _openRecipeDetail(recipe),
        borderRadius: BorderRadius.circular(28.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // MATCH BADGE AT TOP
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMatchBadge(is100Percent, missingCount),
                  Text(
                    '${recipe.prepTimeMinutes} Dk ⏱️',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: KawaiiColors.textMuted),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // CARD BODY
              Row(
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: is100Percent ? KawaiiColors.lightMint : KawaiiColors.butter,
                      borderRadius: BorderRadius.circular(22.0),
                      border: Border.all(
                        color: is100Percent ? KawaiiColors.mint : Colors.amber.shade200,
                        width: 1.5,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: recipe.imageAsset != null
                          ? Image.asset(
                              recipe.imageAsset!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Center(
                                child: Text(recipe.emoji, style: const TextStyle(fontSize: 32)),
                              ),
                            )
                          : (recipe.imageUrl != null
                              ? Image.network(
                                  recipe.imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Center(
                                    child: Text(recipe.emoji, style: const TextStyle(fontSize: 32)),
                                  ),
                                )
                              : Center(
                                  child: Text(recipe.emoji, style: const TextStyle(fontSize: 32)),
                                )),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Title & Meta
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recipe.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: KawaiiColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              '⭐' * recipe.difficultyStars,
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(width: 8),
                            const Text('•', style: TextStyle(color: KawaiiColors.textMuted)),
                            const SizedBox(width: 8),
                            Text(
                              '${recipe.calories} kcal 🔥',
                              style: const TextStyle(fontSize: 12, color: KawaiiColors.textMuted, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '$matchCount / $totalCount malzeme dolabında var!',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: is100Percent ? Colors.green.shade700 : KawaiiColors.coral,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: recipe.requiredIngredients.take(6).map((ing) {
                  final hasIng = _selectedIngredientIds.contains(ing.id);
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: hasIng ? KawaiiColors.lightMint : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: hasIng ? KawaiiColors.mint : Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(ing.emoji, style: const TextStyle(fontSize: 11)),
                        const SizedBox(width: 4),
                        Text(
                          ing.name,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: hasIng ? FontWeight.bold : FontWeight.normal,
                            color: hasIng ? KawaiiColors.textDark : Colors.grey.shade600,
                            decoration: hasIng ? TextDecoration.none : TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMatchBadge(bool is100Percent, int missingCount) {
    if (is100Percent) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: KawaiiColors.lightMint,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: KawaiiColors.mint, width: 1.5),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🌟 ', style: TextStyle(fontSize: 12)),
            Text(
              'Süper! Bütün malzemeler hazır!',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.green),
            ),
          ],
        ),
      );
    } else if (missingCount <= 2) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: KawaiiColors.lightYellow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.amber.shade300, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🛒 ', style: TextStyle(fontSize: 12)),
            Text(
              'Sadece $missingCount eksik kaldı!',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.amber),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.pink.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.pink.shade200, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🔍 ', style: TextStyle(fontSize: 12)),
            Text(
              '$missingCount malzeme eksik',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: KawaiiColors.coral),
            ),
          ],
        ),
      );
    }
  }
}
