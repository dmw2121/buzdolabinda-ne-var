import 'package:flutter/material.dart';
import '../main.dart';
import 'paywall_modal.dart';

class FairyScreen extends StatefulWidget {
  final int selectedCount;

  const FairyScreen({super.key, required this.selectedCount});

  @override
  State<FairyScreen> createState() => _FairyScreenState();
}

class _FairyScreenState extends State<FairyScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

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
                  'Mutfak Perisi',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: KawaiiColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Sizin için her zaman burada! ✨',
                  style: TextStyle(fontSize: 14, color: KawaiiColors.textMuted),
                ),

                const SizedBox(height: 32),

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
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: KawaiiColors.peach.withOpacity(0.4),
                          blurRadius: 30,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text('👩‍🍳', style: TextStyle(fontSize: 88)),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

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
                            ? 'Dolabında ${widget.selectedCount} malzeme var, harika!'
                            : 'Dolabım sekmesinden daha fazla malzeme seç!',
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
                        'Sana en iyi tarifleri ben getiriyorum! 💕',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: KawaiiColors.textMuted),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // BASIC PANTRY INFO
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: KawaiiColors.lightMint,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: KawaiiColors.mint, width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Text('🧺 ', style: TextStyle(fontSize: 16)),
                          Text(
                            'Temel Mutfak Malzemeleri',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: KawaiiColors.textDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tuz • Karabiber • Un • Tereyağı\nYumurta • Süt • Sıvı Yağ • Soğan • Sarımsak',
                        style: TextStyle(
                          fontSize: 13,
                          color: KawaiiColors.textMuted,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Bu malzemelerin hep dolabınızda olduğu varsayılır.',
                        style: TextStyle(
                          fontSize: 11,
                          color: KawaiiColors.textMuted,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // AI CAMERA CTA
                GestureDetector(
                  onTap: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => const PaywallModal(),
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [KawaiiColors.peach, KawaiiColors.lavender],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: KawaiiColors.peach.withOpacity(0.4),
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
                                'Dolabınızı fotoğraflayın, Peri tüm malzemeleri tanısın!',
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

                // TIPS
                _buildTipCard('🕐', 'Hızlı Tarifler', 'Dolabım sekmesinde malzeme seç, "15 Dk" filtresine bas.'),
                const SizedBox(height: 10),
                _buildTipCard('🛒', 'Alışveriş İpucu', 'Tarif detayında eksik malzemeleri görüp not alabilirsin.'),
                const SizedBox(height: 10),
                _buildTipCard('🌟', 'Tam Eşleşme', 'Yeşil kenarlıklı tarifler dolabındaki malzemelerle tam uyumlu!'),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTipCard(String emoji, String title, String body) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: KawaiiColors.cardBorder, width: 1.2),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: KawaiiColors.textDark)),
                const SizedBox(height: 2),
                Text(body, style: const TextStyle(fontSize: 12, color: KawaiiColors.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
