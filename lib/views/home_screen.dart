import 'package:flutter/material.dart';
import '../main.dart';
import '../models/recipe.dart';
import '../data/recipes_data.dart';
import 'recipe_detail_sheet.dart';

class HomeScreen extends StatefulWidget {
  final Set<String> selectedIngredientIds;
  final VoidCallback? onOpenFridge;

  const HomeScreen({
    super.key,
    required this.selectedIngredientIds,
    this.onOpenFridge,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PrepTimeFilter _selectedTimeFilter = PrepTimeFilter.all;
  MealTypeFilter _selectedMealFilter = MealTypeFilter.all;
  String _searchQuery = '';

  // Cache
  List<Recipe>? _cachedRecipes;
  String _cacheKey = '';

  String _buildCacheKey() {
    return '${widget.selectedIngredientIds.join(",")}_${_selectedTimeFilter.name}_${_selectedMealFilter.name}_$_searchQuery';
  }

  int _getMatchCount(Recipe recipe) {
    int count = 0;
    for (var ing in recipe.requiredIngredients) {
      if (widget.selectedIngredientIds.contains(ing.id)) count++;
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
    final key = _buildCacheKey();
    if (_cachedRecipes != null && _cacheKey == key) return _cachedRecipes!;

    final query = _searchQuery.toLowerCase().trim();

    final result = RecipesData.recipes.where((recipe) {
      if (query.isNotEmpty) {
        final matchesTitle = recipe.title.toLowerCase().contains(query);
        final matchesIng = recipe.ingredientsText.any((t) => t.toLowerCase().contains(query)) ||
            recipe.requiredIngredients.any((i) => i.name.toLowerCase().contains(query));
        if (!matchesTitle && !matchesIng) return false;
      }
      if (_selectedTimeFilter == PrepTimeFilter.quick && recipe.prepTimeMinutes > 15) return false;
      if (_selectedTimeFilter == PrepTimeFilter.medium && (recipe.prepTimeMinutes <= 15 || recipe.prepTimeMinutes > 30)) return false;
      if (_selectedTimeFilter == PrepTimeFilter.long && recipe.prepTimeMinutes <= 30) return false;
      if (_selectedMealFilter != MealTypeFilter.all && recipe.mealType != _selectedMealFilter) return false;
      return true;
    }).toList()
      ..sort((a, b) {
        final pA = _getMatchPercentage(a);
        final pB = _getMatchPercentage(b);
        if (pA != pB) return pB.compareTo(pA);
        return _getMissingCount(a).compareTo(_getMissingCount(b));
      });

    _cacheKey = key;
    _cachedRecipes = result;
    return result;
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
  Widget build(BuildContext context) {
    final recipes = _filteredRecipes;
    final selectedCount = widget.selectedIngredientIds.length;

    return Scaffold(
      backgroundColor: KawaiiColors.creamBg,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // HEADER
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: _buildHeader(selectedCount),
              ),
            ),

            // SEARCH
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: _buildSearchBar(),
              ),
            ),

            // FILTERS
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: _buildFilters(),
              ),
            ),

            // RECIPE COUNT HEADER
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Text(
                  '${recipes.length} tarif bulundu',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: KawaiiColors.textMuted,
                  ),
                ),
              ),
            ),

            // RECIPE LIST
            recipes.isEmpty
                ? SliverToBoxAdapter(child: _buildEmptyState())
                : SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildRecipeCard(recipes[index]),
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

  Widget _buildHeader(int selectedCount) {
    return Row(
      children: [
        // Logo
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: KawaiiColors.peach.withOpacity(0.25),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(
              'assets/logo.png',
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => const Center(child: Text('🍳', style: TextStyle(fontSize: 28))),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Buzdolabımdan',
                style: TextStyle(
                  fontSize: 13,
                  color: KawaiiColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Text(
                'Yemek Tarifleri',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: KawaiiColors.textDark,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
        // Dark mode toggle button
        ValueListenableBuilder<ThemeMode>(
          valueListenable: themeNotifier,
          builder: (context, mode, child) {
            final isDark = mode == ThemeMode.dark;
            return GestureDetector(
              onTap: () {
                themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
              },
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF3B2F44) : KawaiiColors.lightYellow,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? const Color(0xFF6B537E) : const Color(0xFFFFD54F),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  isDark ? '🌙' : '☀️',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            );
          },
        ),
        // Ingredient count badge (tappable to open Fridge)
        GestureDetector(
          onTap: widget.onOpenFridge,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: KawaiiColors.mint.withOpacity(0.25),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: KawaiiColors.mint, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: KawaiiColors.mint.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🧊 ', style: TextStyle(fontSize: 14)),
                Text(
                  '$selectedCount',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: KawaiiColors.textDark,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.add_circle_outline_rounded, size: 16, color: KawaiiColors.coral),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
        onChanged: (val) => setState(() {
          _searchQuery = val;
          _cachedRecipes = null;
        }),
        decoration: InputDecoration(
          hintText: 'Tarif veya malzeme ara… (600 tarif)',
          hintStyle: const TextStyle(fontSize: 13, color: KawaiiColors.textMuted),
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 14, right: 8),
            child: Icon(Icons.search_rounded, color: KawaiiColors.textMuted, size: 20),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 40),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 18, color: KawaiiColors.textMuted),
                  onPressed: () => setState(() {
                    _searchQuery = '';
                    _cachedRecipes = null;
                  }),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: PrepTimeFilter.values.map((f) => _filterChip(
              f.label, f == _selectedTimeFilter, KawaiiColors.peach,
              () => setState(() { _selectedTimeFilter = f; _cachedRecipes = null; }),
            )).toList(),
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: MealTypeFilter.values.map((m) => _filterChip(
              m.label, m == _selectedMealFilter, KawaiiColors.lavender,
              () => setState(() { _selectedMealFilter = m; _cachedRecipes = null; }),
            )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _filterChip(String label, bool isSelected, Color color, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isSelected ? color : KawaiiColors.cardBorder, width: 1.5),
            boxShadow: isSelected
                ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 3))]
                : [],
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
              color: isSelected ? Colors.white : KawaiiColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecipeCard(Recipe recipe) {
    final matchCount = _getMatchCount(recipe);
    final totalCount = recipe.requiredIngredients.length;
    final missingCount = _getMissingCount(recipe);
    final isFullMatch = missingCount == 0;

    return GestureDetector(
      onTap: () => _openRecipeDetail(recipe),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isFullMatch ? KawaiiColors.mint : KawaiiColors.cardBorder,
            width: isFullMatch ? 2 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isFullMatch
                  ? KawaiiColors.mint.withOpacity(0.18)
                  : Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            // LARGE IMAGE
            Hero(
              tag: 'recipe_img_${recipe.id}',
              child: GestureDetector(
                onTap: () => _showImagePopup(context, recipe),
                child: Container(
                  width: 96,
                  height: 96,
                  margin: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isFullMatch ? KawaiiColors.lightMint : KawaiiColors.butter,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isFullMatch ? KawaiiColors.mint : Colors.amber.shade200,
                      width: 1.5,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: _buildRecipeImage(recipe),
                  ),
                ),
              ),
            ),

            // INFO
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 14, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Match badge
                    _buildMatchBadge(isFullMatch, missingCount),
                    const SizedBox(height: 6),

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
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          recipe.prepTimeMinutes <= 20
                              ? '🕐'
                              : (recipe.prepTimeMinutes <= 40 ? '🕑' : '🕒'),
                          style: const TextStyle(fontSize: 13),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${recipe.prepTimeMinutes} dk • ${recipe.calories} kcal',
                          style: const TextStyle(fontSize: 11, color: KawaiiColors.textMuted, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$matchCount/$totalCount malzeme var',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isFullMatch ? Colors.green.shade600 : KawaiiColors.coral,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeImage(Recipe recipe) {
    if (recipe.imageAsset != null) {
      return Image.asset(
        recipe.imageAsset!,
        fit: BoxFit.cover,
        errorBuilder: (c, e, s) => Center(child: Text(recipe.emoji, style: const TextStyle(fontSize: 38))),
      );
    }
    if (recipe.imageUrl != null) {
      return Image.network(
        recipe.imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (c, e, s) => Center(child: Text(recipe.emoji, style: const TextStyle(fontSize: 38))),
      );
    }
    return Center(child: Text(recipe.emoji, style: const TextStyle(fontSize: 38)));
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
                child: Hero(
                  tag: 'recipe_img_${recipe.id}',
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
      ),
    );
  }

  Widget _buildMatchBadge(bool isFullMatch, int missingCount) {
    if (isFullMatch) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: KawaiiColors.lightMint,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: KawaiiColors.mint, width: 1),
        ),
        child: const Text('🌟 Tüm malzemeler hazır!',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.green)),
      );
    } else if (missingCount <= 2) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: KawaiiColors.lightYellow,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.amber.shade300, width: 1),
        ),
        child: Text('🛒 $missingCount eksik',
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.orange)),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.pink.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.pink.shade200, width: 1),
        ),
        child: Text('🔍 $missingCount eksik',
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: KawaiiColors.coral)),
      );
    }
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: KawaiiColors.cardBorder, width: 1.5),
      ),
      child: const Column(
        children: [
          Text('🧐', style: TextStyle(fontSize: 48)),
          SizedBox(height: 12),
          Text('Tarif bulunamadı!',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: KawaiiColors.textDark)),
          SizedBox(height: 6),
          Text('Filtreleri değiştirmeyi veya başka bir malzeme aramayı deneyin.',
              style: TextStyle(fontSize: 13, color: KawaiiColors.textMuted), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
