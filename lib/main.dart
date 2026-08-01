import 'package:flutter/material.dart';
import 'views/home_screen.dart';

void main() {
  runApp(const KawaiiKitchenApp());
}

// ==========================================
// 🎨 KAWAII COLOR PALETTE & DESIGN TOKENS
// ==========================================
class KawaiiColors {
  static const Color peach = Color(0xFFFF9EAA); // Dominant Peach Pink
  static const Color mint = Color(0xFFA2E9C1); // Secondary Soft Mint Green
  static const Color butter = Color(0xFFFFF3DA); // Butter Yellow
  static const Color lavender = Color(0xFFD0BFFF); // Sweet Lavender
  static const Color creamBg = Color(0xFFFFFBF5); // Milk Foam Cream Background
  static const Color cardBorder = Color(0xFFFFC0CB); // Soft Pink Border
  static const Color textDark = Color(0xFF4A3E3D); // Soft Warm Dark Brown/Text
  static const Color textMuted = Color(0xFF8C7A78); // Muted Dark Brown
  static const Color coral = Color(0xFFFF6B81); // Bright Accent Coral
  static const Color lightMint = Color(0xFFE8FAEF); // Light Mint Tint
  static const Color lightYellow = Color(0xFFFFF9E6); // Light Yellow Tint
}

class KawaiiKitchenApp extends StatelessWidget {
  const KawaiiKitchenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Buzdolabında Ne Var?',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: KawaiiColors.creamBg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: KawaiiColors.peach,
          primary: KawaiiColors.peach,
          secondary: KawaiiColors.mint,
          surface: Colors.white,
        ),
        fontFamily: 'sans-serif',
      ),
      home: const HomeScreen(),
    );
  }
}
