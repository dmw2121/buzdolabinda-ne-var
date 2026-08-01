import 'package:flutter/material.dart';
import 'lib/views/home_screen.dart';

void main() {
  runApp(const KawaiiKitchenApp());
}

class KawaiiColors {
  static const Color peach = Color(0xFFFF9EAA);
  static const Color mint = Color(0xFFA2E9C1);
  static const Color butter = Color(0xFFFFF3DA);
  static const Color lavender = Color(0xFFD0BFFF);
  static const Color creamBg = Color(0xFFFFFBF5);
  static const Color cardBorder = Color(0xFFFFC0CB);
  static const Color textDark = Color(0xFF4A3E3D);
  static const Color textMuted = Color(0xFF8C7A78);
  static const Color coral = Color(0xFFFF6B81);
  static const Color lightMint = Color(0xFFE8FAEF);
  static const Color lightYellow = Color(0xFFFFF9E6);
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
