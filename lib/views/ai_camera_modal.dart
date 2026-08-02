import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../main.dart';
import '../models/ingredient.dart';
import '../services/ai_camera_service.dart';

class AiCameraModal extends StatefulWidget {
  final void Function(List<String> detectedIds) onIngredientsDetected;

  const AiCameraModal({
    super.key,
    required this.onIngredientsDetected,
  });

  @override
  State<AiCameraModal> createState() => _AiCameraModalState();
}

class _AiCameraModalState extends State<AiCameraModal> {
  final ImagePicker _picker = ImagePicker();
  int _remainingScans = 20;
  bool _isScanning = false;
  bool _hasScannedOnce = false;
  String? _currentApiKey;
  List<Ingredient> _detectedIngredients = [];

  @override
  void initState() {
    super.initState();
    _loadInitialState();
  }

  Future<void> _loadInitialState() async {
    final remaining = await AiCameraService.getRemainingScans();
    final key = await AiCameraService.getApiKey();
    if (mounted) {
      setState(() {
        _remainingScans = remaining;
        _currentApiKey = key;
      });
    }
  }

  void _showApiKeyDialog() {
    final controller = TextEditingController(text: _currentApiKey ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        title: const Row(
          children: [
            Text('🔑 '),
            Text(
              'Gemini API Key Girin',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Fotoğraftan %100 gerçek yapay zeka tespiti yapmak için ücretsiz Google Gemini API Key kullanabilirsiniz.',
              style: TextStyle(fontSize: 12, color: KawaiiColors.textMuted),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'AIzaSy...',
                labelText: 'API Anahtarı',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                filled: true,
                fillColor: KawaiiColors.creamBg,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'aistudio.google.com adresinden saniyeler içinde ücretsiz alabilirsiniz.',
              style: TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal', style: TextStyle(color: KawaiiColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () async {
              final newKey = controller.text.trim();
              await AiCameraService.saveApiKey(newKey);
              setState(() {
                _currentApiKey = newKey;
              });
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Gemini API Key başarıyla kaydedildi! ✨'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: KawaiiColors.coral,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndScanImage(ImageSource source) async {
    if (_remainingScans <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Bugünlük AI tarama hakkınızı doldurdunuz.'),
          backgroundColor: KawaiiColors.coral,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
      return;
    }

    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (file == null) return;

      final bytes = await file.readAsBytes();

      setState(() {
        _isScanning = true;
        _hasScannedOnce = true;
        _detectedIngredients = [];
      });

      // Hak düş
      final newRemaining = await AiCameraService.useScanCredit();

      // GERÇEK GEMINI API TARAMASI
      final results = await AiCameraService.scanFridgeImage(bytes);

      if (mounted) {
        setState(() {
          _remainingScans = newRemaining;
          _isScanning = false;
          _detectedIngredients = results;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fotoğraf seçilemedi: $e'),
            backgroundColor: KawaiiColors.coral,
          ),
        );
      }
    }
  }

  void _applyDetectedIngredients() {
    if (_detectedIngredients.isEmpty) return;
    final ids = _detectedIngredients.map((i) => i.id).toList();
    widget.onIngredientsDetected(ids);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Text('✨ '),
            Text('${_detectedIngredients.length} malzeme dolabınıza eklendi!'),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasKey = _currentApiKey != null && _currentApiKey!.trim().isNotEmpty;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: KawaiiColors.creamBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(36.0)),
      ),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // HANDLE
          Container(
            width: 48,
            height: 6,
            decoration: BoxDecoration(
              color: KawaiiColors.cardBorder,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 16),

          // TITLE & API KEY BUTTON
          Row(
            children: [
              const Text('📸 ', style: TextStyle(fontSize: 22)),
              const Expanded(
                child: Text(
                  'Fotoğraf Çek & Malzeme Tespit Et',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: KawaiiColors.textDark,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),
          const Text(
            'Buzdolabınızın fotoğrafını çekin, yapay zeka malzemeleri anında tespit etsin!',
            style: TextStyle(fontSize: 12, color: KawaiiColors.textMuted),
          ),

          const SizedBox(height: 20),

          // MAIN CONTENT AREA
          if (_isScanning) ...[
            // SCANNING ANIMATION STATE
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: KawaiiColors.cardBorder, width: 1.5),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: CircularProgressIndicator(
                      color: KawaiiColors.peach,
                      strokeWidth: 3.5,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Gemini Yapay Zeka fotoğrafı inceliyor… 🔍',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: KawaiiColors.textDark,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Gerçek malzemeler tespit ediliyor',
                    style: TextStyle(fontSize: 12, color: KawaiiColors.textMuted),
                  ),
                ],
              ),
            ),
          ] else if (_detectedIngredients.isNotEmpty) ...[
            // RESULTS LIST
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: KawaiiColors.mint, width: 1.8),
                boxShadow: [
                  BoxShadow(
                    color: KawaiiColors.mint.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('🎉 ', style: TextStyle(fontSize: 18)),
                      Expanded(
                        child: Text(
                          '${_detectedIngredients.length} Malzeme Tespit Edildi!',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: KawaiiColors.textDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _detectedIngredients.map((ing) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: KawaiiColors.lightMint,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: KawaiiColors.mint, width: 1.2),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(ing.emoji, style: const TextStyle(fontSize: 15)),
                            const SizedBox(width: 6),
                            Text(
                              ing.name,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: KawaiiColors.textDark,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.check_circle_rounded, size: 14, color: Colors.green),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _applyDetectedIngredients,
                icon: const Icon(Icons.restaurant_menu_rounded),
                label: const Text(
                  'Dolabıma Ekle & Tarif Bul 🍲',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: KawaiiColors.coral,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 3,
                ),
              ),
            ),
          ] else ...[
            // IF SCANNING HAS FINISHED AND NO INGREDIENTS DETECTED (HONEST EMPTY STATE)
            if (_hasScannedOnce && _detectedIngredients.isEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.amber.shade400, width: 1.5),
                ),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Text('🤔 ', style: TextStyle(fontSize: 18)),
                        Expanded(
                          child: Text(
                            'Fotoğrafta malzeme tespit edilemedi veya API Key eksik.',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF8B5E00),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (!hasKey)
                      ElevatedButton.icon(
                        onPressed: _showApiKeyDialog,
                        icon: const Icon(Icons.key_rounded, size: 16),
                        label: const Text('Ücretsiz Gemini API Key Ekle (10 Sn)'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber.shade700,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],

            // ACTION BUTTONS TO CHOOSE IMAGE
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 110,
                    child: ElevatedButton(
                      onPressed: () => _pickAndScanImage(ImageSource.camera),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: KawaiiColors.textDark,
                        elevation: 0,
                        side: const BorderSide(color: KawaiiColors.cardBorder, width: 1.8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('📷', style: TextStyle(fontSize: 32)),
                          SizedBox(height: 6),
                          Text(
                            'Fotoğraf Çek',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: SizedBox(
                    height: 110,
                    child: ElevatedButton(
                      onPressed: () => _pickAndScanImage(ImageSource.gallery),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: KawaiiColors.textDark,
                        elevation: 0,
                        side: const BorderSide(color: KawaiiColors.cardBorder, width: 1.8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('🖼️', style: TextStyle(fontSize: 32)),
                          SizedBox(height: 6),
                          Text(
                            'Galeriden Seç',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
