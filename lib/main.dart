import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'views/onboarding_screen.dart';
import 'views/welcome_splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BuzdolabimApp());
}

// ==========================================
// KAWAII COLOR PALETTE
// ==========================================
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

class BuzdolabimApp extends StatefulWidget {
  const BuzdolabimApp({super.key});

  @override
  State<BuzdolabimApp> createState() => _BuzdolabimAppState();
}

class _BuzdolabimAppState extends State<BuzdolabimApp> {
  bool _isLoading = true;
  bool _seenOnboarding = false;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final seen = prefs.getBool('seen_onboarding_v1') ?? false;
      setState(() {
        _seenOnboarding = seen;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _seenOnboarding = false;
        _isLoading = false;
      });
    }
  }

  Future<void> _completeOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('seen_onboarding_v1', true);
    } catch (_) {}
    setState(() {
      _seenOnboarding = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Buzdolabımdan Yemek Tarifleri',
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
      ),
      home: _isLoading
          ? const Scaffold(
              backgroundColor: KawaiiColors.creamBg,
              body: Center(
                child: CircularProgressIndicator(color: KawaiiColors.coral),
              ),
            )
          : (_seenOnboarding
              ? const WelcomeSplashScreen()
              : OnboardingScreen(
                  onDone: _completeOnboarding,
                )),
    );
  }
}
