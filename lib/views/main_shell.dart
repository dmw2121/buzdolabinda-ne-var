import 'package:flutter/material.dart';
import '../main.dart';
import '../models/ingredient.dart';
import '../data/ingredients_data.dart';
import 'home_screen.dart';
import 'fridge_screen.dart';
import 'fairy_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  // Shared state: selected ingredient IDs across all tabs
  final Set<String> _selectedIngredientIds = {
    // Basic pantry staples always assumed
    'tuz', 'karabiber', 'un', 'tereyagi', 'yumurta', 'sut', 'siviyag',
    'sogan', 'sarimsak',
  };

  void _toggleIngredient(String id) {
    setState(() {
      if (_selectedIngredientIds.contains(id)) {
        _selectedIngredientIds.remove(id);
      } else {
        _selectedIngredientIds.add(id);
      }
    });
  }

  void _clearIngredients() {
    setState(() {
      _selectedIngredientIds.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        selectedIngredientIds: _selectedIngredientIds,
      ),
      FridgeScreen(
        selectedIngredientIds: _selectedIngredientIds,
        onToggle: _toggleIngredient,
        onClear: _clearIngredients,
      ),
      FairyScreen(
        selectedCount: _selectedIngredientIds.length,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: KawaiiColors.cardBorder, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.restaurant_menu_rounded, '🍲', 'Tarifler'),
                _buildNavItem(1, Icons.kitchen_rounded, '🧊', 'Dolabım'),
                _buildNavItem(2, Icons.auto_awesome_rounded, '✨', 'Peri'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String emoji, String label) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? KawaiiColors.peach.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              emoji,
              style: TextStyle(
                fontSize: isActive ? 22 : 18,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
                color: isActive ? KawaiiColors.coral : KawaiiColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
