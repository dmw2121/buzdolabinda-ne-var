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
  bool _isLoadingScans = true;
  bool _isScanning = false;
  Uint8List? _selectedImageBytes;
  List<Ingredient> _detectedIngredients = [];

  @override
  void initState() {
    super.initState();
    _loadDailyLimit();
  }

  Future<void> _loadDailyLimit() async {
    final remaining = await AiCameraService.getRemainingScans();
    if (mounted) {
      setState(() {
        _remainingScans = remaining;
        _isLoadingScans = false;
      });
    }
  }

  Future<void> _pickAndScanImage(ImageSource source) async {
    if (_remainingScans <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Text('🛑 '),
              Expanded(
                child: Text('Bugünlük 20 AI tarama hakkınızı doldurdunuz. Gece 00:00\'da 20 yeni hak yüklenecektir!'),
              ),
            ],
          ),
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
        _selectedImageBytes = bytes;
        _isScanning = true;
        _detectedIngredients = [];
      });

      // Hak düş
      final newRemaining = await AiCameraService.useScanCredit();

      // Görseli AI taramadan geçir
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
            Text('${ids.length} malzeme dolabınıza eklendi!'),
          ],
        ),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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

          // TITLE & DAILY LIMIT BADGE
          Row(
            children: [
              const Text('📸 ', style: TextStyle(fontSize: 22)),
              const Expanded(
                child: Text(
                  'AI Buzdolabı Taraması',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: KawaiiColors.textDark,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: KawaiiColors.lightMint,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: KawaiiColors.mint, width: 1.2),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome_rounded, size: 14, color: Colors.green),
                    SizedBox(width: 4),
                    Text(
                      'Akıllı Tarama',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: Colors.green,
                      ),
                    ),
                  ],
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
                    'Yapay zeka buzdolabınızı inceliyor… 🔍',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: KawaiiColors.textDark,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Fotoğraftaki malzemeler taranıyor',
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
            // ACTION BUTTONS TO CHOOSE IMAGE
            if (_remainingScans <= 0) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.pink.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: KawaiiColors.coral, width: 1.5),
                ),
                child: const Row(
                  children: [
                    Text('🛑 ', style: TextStyle(fontSize: 20)),
                    Expanded(
                      child: Text(
                        'Bugünlük 20 AI tarama hakkınızı kullandınız. Yarın gece 00:00\'da 20 yeni hakkınız yüklenecektir!',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: KawaiiColors.coral),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
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
          ],

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
