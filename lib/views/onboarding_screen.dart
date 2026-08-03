import 'package:flutter/material.dart';
import '../main.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onDone;
  const OnboardingScreen({super.key, required this.onDone});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingPage> _pages = [
    _OnboardingPage(
      emoji: null,
      isLogo: true,
      title: 'Buzdolabımdan\nYemek Tarifleri',
      subtitle: 'Dolabınızdaki malzemelere göre\nsizi bekleyen 450+ nefis tarif!',
      bgColor: Color(0xFFFFF0F3),
      accentColor: KawaiiColors.peach,
    ),
    _OnboardingPage(
      emoji: '📸',
      isLogo: false,
      title: 'Fotoğraf Çek &\nMalzemeleri Tespit Et',
      subtitle: 'Dolabınızın veya tezgahınızın fotoğrafını çekin,\nyapay zeka malzemelerinizi saniyeler içinde\notomatik olarak dolabınıza eklesin!',
      bgColor: Color(0xFFF0FAF5),
      accentColor: KawaiiColors.mint,
    ),
    _OnboardingPage(
      emoji: '👨‍🍳',
      isLogo: false,
      title: 'Yardımcı Şef &\nMutfak İpuçları',
      subtitle: '300+ mutfak malzemesi, günün yemek tavsiyesi\nve lezzetli püf noktalarıyla mutfaktaki\nen büyük yardımcınız!',
      bgColor: Color(0xFFFFFAF0),
      accentColor: KawaiiColors.coral,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KawaiiColors.getBg(context),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, i) => _buildPage(_pages[i]),
              ),
            ),

            // Page Indicator + Buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Column(
                children: [
                  // Dot indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (i) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == i ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == i
                              ? _pages[_currentPage].accentColor
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),

                  // Next / Done button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage < _pages.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          widget.onDone();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _pages[_currentPage].accentColor,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor: _pages[_currentPage].accentColor.withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: Text(
                        _currentPage < _pages.length - 1
                            ? 'Devam Et →'
                            : 'Haydi Başlayalım! 🍳',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),

                  if (_currentPage < _pages.length - 1) ...[
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: widget.onDone,
                      child: const Text(
                        'Geç',
                        style: TextStyle(
                          fontSize: 14,
                          color: KawaiiColors.textMuted,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(_OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Visual
          if (page.isLogo)
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: KawaiiColors.peach.withOpacity(0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(38),
                child: Image.asset(
                  'assets/fridge_logo.png',
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => const Center(
                    child: Text('🍳', style: TextStyle(fontSize: 72)),
                  ),
                ),
              ),
            )
          else
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(36),
                boxShadow: [
                  BoxShadow(
                    color: page.accentColor.withOpacity(0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  page.emoji!,
                  style: const TextStyle(fontSize: 64),
                ),
              ),
            ),
          const SizedBox(height: 36),

          Text(
            page.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: KawaiiColors.textDark,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            page.subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: KawaiiColors.textMuted,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage {
  final String? emoji;
  final bool isLogo;
  final String title;
  final String subtitle;
  final Color bgColor;
  final Color accentColor;

  const _OnboardingPage({
    required this.emoji,
    required this.isLogo,
    required this.title,
    required this.subtitle,
    required this.bgColor,
    required this.accentColor,
  });
}
