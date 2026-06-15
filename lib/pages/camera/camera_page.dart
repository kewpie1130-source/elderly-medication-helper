import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/medicine_model.dart';
import '../../services/gemini/gemini_service.dart';
import '../../services/ocr/ocr_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

// [邱靖喻] 首頁相機拍攝頁，禁止其他組員修改
// 整合第零步備份的相機邏輯
class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  final ImagePicker _imagePicker = ImagePicker();
  final OcrService _ocrService = OcrService();
  final GeminiService _geminiService = GeminiService();

  bool _isProcessing = false;

  Future<void> _pickFromCamera() async {
    if (_isProcessing) return;

    final xFile = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (xFile == null) return;

    await _processImage(xFile);
  }

  Future<void> _pickFromGallery() async {
    if (_isProcessing) return;

    final xFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (xFile == null) return;

    await _processImage(xFile);
  }

  Future<void> _processImage(XFile imageFile) async {
    setState(() => _isProcessing = true);

    try {
      final ocrText = await _ocrService.recognizeText(imageFile);
      final medicine = await _geminiService.parseOcrResult(ocrText);

      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MedicinePlaceholderPage(medicine: medicine),
        ),
      );
      // TODO [組員A]：替換為真正的 MedicineDetailPage
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('辨識失敗：$error'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: Colors.black),
          Center(
            child: SizedBox(
              width: 280,
              height: 180,
              child: CustomPaint(
                painter: const _ScanFramePainter(),
                child: const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      '請對準藥袋／藥盒／保健食品',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text(
                  '長者智慧用藥',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          if (_isProcessing)
            const ColoredBox(
              color: Color(0x99000000),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      '辨識中，請稍候...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        height: 120,
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: _pickFromGallery,
                behavior: HitTestBehavior.opaque,
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.photo_library_outlined,
                      size: 32,
                      color: AppTheme.primary,
                    ),
                    SizedBox(height: 4),
                    Text(
                      '相簿',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: GestureDetector(
                  onTap: _pickFromCamera,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ),
              ),
            ),
            const Expanded(child: SizedBox()),
          ],
        ),
      ),
    );
  }
}

class _ScanFramePainter extends CustomPainter {
  const _ScanFramePainter();

  static const double _cornerLength = 24;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primary
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.square
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(0, _cornerLength)
      ..lineTo(0, 0)
      ..lineTo(_cornerLength, 0)
      ..moveTo(size.width - _cornerLength, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, _cornerLength)
      ..moveTo(size.width, size.height - _cornerLength)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width - _cornerLength, size.height)
      ..moveTo(_cornerLength, size.height)
      ..lineTo(0, size.height)
      ..lineTo(0, size.height - _cornerLength);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ScanFramePainter oldDelegate) => false;
}

// TODO [組員A]：此頁面由組員A實作完整版本後刪除
class MedicinePlaceholderPage extends StatelessWidget {
  final MedicineModel medicine;

  const MedicinePlaceholderPage({
    super.key,
    required this.medicine,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('藥品資訊（暫時頁面）'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _MedicineField(label: '名稱', value: medicine.name),
          const SizedBox(height: 12),
          _MedicineField(label: '類型', value: medicine.type),
          const SizedBox(height: 12),
          _MedicineField(label: '每次劑量', value: medicine.dosage),
          const SizedBox(height: 12),
          _MedicineField(label: '服用頻率', value: medicine.frequency),
          const SizedBox(height: 12),
          _MedicineField(label: '注意事項', value: medicine.notice),
        ],
      ),
    );
  }
}

class _MedicineField extends StatelessWidget {
  final String label;
  final String value;

  const _MedicineField({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.primary,
              fontSize: AppTheme.sectionFontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value.isEmpty ? '未辨識' : value,
            style: const TextStyle(
              color: AppTheme.textDark,
              fontSize: AppTheme.bodyFontSize,
            ),
          ),
        ],
      ),
    );
  }
}
