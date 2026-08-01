import 'package:flutter/material.dart';
import '../main.dart';

class PaywallModal extends StatelessWidget {
  const PaywallModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: KawaiiColors.creamBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(36.0)),
      ),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 6,
            decoration: BoxDecoration(
              color: KawaiiColors.cardBorder,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: KawaiiColors.butter,
              shape: BoxShape.circle,
            ),
            child: const Text('👑', style: TextStyle(fontSize: 48)),
          ),
          const SizedBox(height: 12),

          const Text(
            'Mutfak Perisi Premium',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: KawaiiColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Buzdolabının fotoğrafını çek, yapay zeka şefin malzeme taramasını saniyesinde yapsın! ✨',
            style: TextStyle(fontSize: 13, color: KawaiiColors.textMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          _buildFeatureRow('📸 Fotoğraftan Anında Yapay Zeka Malzeme Tanıma'),
          const SizedBox(height: 10),
          _buildFeatureRow('✨ 200+ Gerçek Excel Tarifi & Ölçülü Malzemeler'),
          const SizedBox(height: 10),
          _buildFeatureRow('👩‍🍳 Mutfak Perisi Özel İpuçları & Adım Adım Rehber'),
          const SizedBox(height: 10),
          _buildFeatureRow('🚫 Reklamsız, Şirin ve Kesintisiz Mutfak Keyfi'),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Text('🎉 '),
                        Text('7 Günlük Ücretsiz Denemeniz Başlatıldı!'),
                      ],
                    ),
                    backgroundColor: KawaiiColors.mint,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: KawaiiColors.peach,
                foregroundColor: Colors.white,
                elevation: 4,
                shadowColor: KawaiiColors.peach.withOpacity(0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: const Text(
                '7 Gün Ücretsiz Deneyin! 👑',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'İstediğin zaman iptal et. Sonrasında ₺29.99 / ay',
            style: TextStyle(fontSize: 11, color: KawaiiColors.textMuted),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: KawaiiColors.cardBorder, width: 1.2),
      ),
      child: Row(
        children: [
          const Icon(Icons.stars_rounded, color: KawaiiColors.peach, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: KawaiiColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
