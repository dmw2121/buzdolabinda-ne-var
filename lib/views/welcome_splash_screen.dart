import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../main.dart';
import 'main_shell.dart';

class WelcomeSplashScreen extends StatefulWidget {
  const WelcomeSplashScreen({super.key});

  @override
  State<WelcomeSplashScreen> createState() => _WelcomeSplashScreenState();
}

class _WelcomeSplashScreenState extends State<WelcomeSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Map<String, String> _dailyTrivia;
  Timer? _navigationTimer;

  final List<Map<String, String>> _triviaList = [
    {
      'title': '🥚 Taze Yumurta Testi',
      'fact': 'Yumurtanın taze olup olmadığını anlamak için su dolu kaba atın. Dibe çökerse taze, suyun üstüne çıkarsa bayattır!'
    },
    {
      'title': '🍋 Daha Bol Limon Suyu',
      'fact': 'Limonun daha bol su vermesi için sıkmadan önce tezgahın üzerinde avucunuzla hafifçe bastırarak yuvarlayın!'
    },
    {
      'title': '🧅 Göz Yaşartmayan Soğan',
      'fact': 'Soğan doğrarken gözlerinizin yaşarmaması için soğanı doğramadan önce 10 dakika buzdolabında bekletebilirsiniz!'
    },
    {
      'title': '🥔 Fazla Tuzu Çeken Patates',
      'fact': 'Aşırı tuzlu olan çorba ve sulu yemeklere soyulmuş yarım patates atarsanız patates fazla tuzu hemen çekecektir!'
    },
    {
      'title': '🥖 Taptaze Bayat Ekmekler',
      'fact': 'Bayat ekmeklerin üzerine hafifçe su serpip fırında 5 dakika ısıtırsanız fırından yeni çıkmış gibi taptaze olur!'
    },
    {
      'title': '🧀 Yapışmayan Kaşar Rendesi',
      'fact': 'Kaşar peynirini rendelemeden önce 10 dakika dondurucuda bekletirseniz rendeye yapışmadan kolayca rendelenir!'
    },
    {
      'title': '🌿 Uzun Ömürlü Yeşillikler',
      'fact': 'Maydanoz ve nane gibi yeşillikleri yıkayıp kağıt havluya sararak saklarsanız 2 kat daha uzun süre taze kalır!'
    },
    {
      'title': '🍚 Bembeyaz Tane Tane Pilav',
      'fact': 'Pirinç pilavının kar gibi bembeyaz olması için pişirirken içine 2-3 damla limon suyu damlatabilirsiniz!'
    },
    {
      'title': '🥩 Lokum Gibi Yumuşak Et',
      'fact': 'Et sote yaparken eti tencereye koyduktan sonra ilk 5 dakika tuz eklemeyin; tuz eti sertleştirebilir!'
    },
    {
      'title': '🧄 Kolay Soyulan Sarımsak',
      'fact': 'Sarımsak kabuklarını saniyeler içinde soymak için sarımsak dişlerini bıçağın yan tarafıyla hafifçe ezebilirsiniz!'
    },
    {
      'title': '☕ Kahve Telvesinin Gücü',
      'fact': 'Buzdolabındaki istenmeyen kokuları gidermek için küçük bir kase kurutulmuş kahve telvesi koyabilirsiniz!'
    },
    {
      'title': '🍅 Kolay Soyulan Domates',
      'fact': 'Domateslerin kabuğunu zahmetsizce soymak için alt kısımlarına çapraz çizik atıp 30 saniye kaynar suda bekletin!'
    },
  ];

  @override
  void initState() {
    super.initState();
    _pickRandomTrivia();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _pickRandomTrivia() {
    final rnd = Random();
    _dailyTrivia = _triviaList[rnd.nextInt(_triviaList.length)];
  }

  void _goToHome() {
    if (!mounted) return;
    _navigationTimer?.cancel();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const MainShell(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          child: Column(
            children: [
              const Spacer(),

              // ANIMATED LOGO / EMOJI
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: KawaiiColors.peach.withOpacity(0.35),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(60),
                    child: Image.asset(
                      'assets/logo.png',
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => const Center(
                        child: Text('👨‍🍳', style: TextStyle(fontSize: 64)),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // APP TITLE
              const Text(
                'Buzdolabımdan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: KawaiiColors.textMuted,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Yemek Tarifleri',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: KawaiiColors.textDark,
                  letterSpacing: -0.5,
                ),
              ),

              const Spacer(),

              // 💡 BİLİYOR MUSUNUZ? KITCHEN TRIVIA CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFFFD1DC), width: 1.8),
                  boxShadow: [
                    BoxShadow(
                      color: KawaiiColors.peach.withOpacity(0.18),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('💡 ', style: TextStyle(fontSize: 20)),
                        Expanded(
                          child: Text(
                            'BİLİYOR MUSUNUZ?',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: KawaiiColors.coral,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: KawaiiColors.lightYellow,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Şefin İpucu ✨',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFB8860B),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _dailyTrivia['title']!,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: KawaiiColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _dailyTrivia['fact']!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: KawaiiColors.textMuted,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // LOADING / PROCEED BUTTON
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _goToHome,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: KawaiiColors.coral,
                    foregroundColor: Colors.white,
                    elevation: 3,
                    shadowColor: KawaiiColors.coral.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'Mutfağa Gir 🚀',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
