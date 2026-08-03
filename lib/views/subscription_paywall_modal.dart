import 'package:flutter/material.dart';
import '../main.dart';
import '../services/ai_camera_service.dart';

class SubscriptionPaywallModal extends StatefulWidget {
  const SubscriptionPaywallModal({super.key});

  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SubscriptionPaywallModal(),
    );
  }

  @override
  State<SubscriptionPaywallModal> createState() => _SubscriptionPaywallModalState();
}

class _SubscriptionPaywallModalState extends State<SubscriptionPaywallModal> {
  String _selectedPlan = '3_months'; // Default popular plan
  bool _isLoading = false;

  final List<Map<String, dynamic>> _plans = [
    {
      'id': 'monthly',
      'title': 'Aylık Paket',
      'price': '79 ₺',
      'subtitle': 'Her ay yenilenir',
      'period': '/ ay',
      'badge': null,
      'color': KawaiiColors.softPink,
    },
    {
      'id': '3_months',
      'title': '3 Aylık Paket',
      'price': '179 ₺',
      'subtitle': '3 ayda bir ödenir (59 ₺/ay)',
      'period': '/ 3 ay',
      'badge': '🔥 En Popüler',
      'color': KawaiiColors.peach,
    },
    {
      'id': 'yearly',
      'title': 'Yıllık Paket',
      'price': '399 ₺',
      'subtitle': 'Yılda bir ödenir (33 ₺/ay)',
      'period': '/ yıl',
      'badge': '🌟 %58 İndirim',
      'color': KawaiiColors.mint,
    },
  ];

  Future<void> _subscribe() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 600));
    await AiCameraService.subscribe(_selectedPlan);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Tebrikler! Kawaii Şef Premium Aboneliğiniz Başarıyla Aktif Edildi!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: KawaiiColors.getSurface(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Header Icon & Title
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: KawaiiColors.lightMint,
                shape: BoxShape.circle,
              ),
              child: const Text('👑', style: TextStyle(fontSize: 44)),
            ),
            const SizedBox(height: 12),
            Text(
              'Ücretsiz 3 Hak Sınırına Ulaştınız',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: KawaiiColors.getTextPrimary(context),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Fotoğrafla sınırsız malzeme tespiti yapmak ve Akıllı Şef özelliklerini kilit olmadan kullanmak için hemen üye olun!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: KawaiiColors.getTextPrimary(context).withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 20),

            // Benefits checklist
            _buildBenefitItem('📸 Sınırsız AI Kamera Malzeme Tespiti'),
            _buildBenefitItem('👩‍🍳 Tüm Akıllı Şef Tavsiyelerine Öncelikli Erişim'),
            _buildBenefitItem('⚡ Işık Hızında Fotoğraf Analizi & Reklamsız Deneyim'),
            const SizedBox(height: 24),

            // Package Cards
            Column(
              children: _plans.map((plan) {
                final isSelected = _selectedPlan == plan['id'];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedPlan = plan['id'];
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark ? plan['color'].withOpacity(0.2) : plan['color'].withOpacity(0.3))
                          : KawaiiColors.getCardBg(context),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? plan['color'] : KawaiiColors.cardBorder,
                        width: isSelected ? 2.4 : 1.2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Radio<String>(
                          value: plan['id'],
                          groupValue: _selectedPlan,
                          activeColor: plan['color'],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedPlan = val;
                              });
                            }
                          },
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    plan['title'],
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: KawaiiColors.getTextPrimary(context),
                                    ),
                                  ),
                                  if (plan['badge'] != null) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: plan['color'],
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        plan['badge'],
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                plan['subtitle'],
                                style: TextStyle(
                                  fontSize: 11,
                                  color: KawaiiColors.getTextPrimary(context).withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              plan['price'],
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: KawaiiColors.getTextPrimary(context),
                              ),
                            ),
                            Text(
                              plan['period'],
                              style: TextStyle(
                                fontSize: 10,
                                color: KawaiiColors.getTextPrimary(context).withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 18),

            // Action Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _subscribe,
                style: ElevatedButton.styleFrom(
                  backgroundColor: KawaiiColors.peach,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : const Text(
                        'ABONE OL & SINIRSIZ KULLAN 🚀',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'İstediğiniz zaman iptal edebilirsiniz. Güvenli ödeme.',
              style: TextStyle(fontSize: 11, color: KawaiiColors.getTextPrimary(context).withOpacity(0.5)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: Colors.green, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: KawaiiColors.getTextPrimary(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
