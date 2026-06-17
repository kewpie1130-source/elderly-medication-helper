import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/medicine_model.dart';
import '../../services/gemini/gemini_service.dart';
import '../../services/ocr/ocr_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  final ImagePicker _imagePicker = ImagePicker();
  final OcrService _ocrService = OcrService();
  final GeminiService _geminiService = GeminiService();

  CameraController? _cameraController;
  bool _isCameraReady = false;
  bool _isProcessing = false;
  String? _cameraError;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) {
          setState(() => _cameraError = '找不到可用相機');
        }
        return;
      }

      final controller = CameraController(
        cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await controller.initialize();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _cameraController = controller;
        _isCameraReady = true;
        _cameraError = null;
      });
    } catch (error) {
      if (mounted) {
        setState(() => _cameraError = '相機初始化失敗：$error');
      }
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (_isProcessing || !_isCameraReady) return;

    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) return;

    try {
      final xFile = await controller.takePicture();
      await _processImage(xFile);
    } catch (error) {
      if (!mounted) return;
      _showError('拍攝失敗：$error');
    }
  }

  Future<void> _pickFromGallery() async {
    if (_isProcessing) return;

    try {
      final xFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (xFile == null) return;

      await _processImage(xFile);
    } catch (error) {
      if (!mounted) return;
      _showError('相簿匯入失敗：$error');
    }
  }

  Future<void> _processImage(XFile imageFile) async {
    setState(() => _isProcessing = true);

    var dialogShown = false;
    try {
      _showLoadingDialog();
      dialogShown = true;

      final ocrText = await _ocrService.recognizeText(imageFile);
      final medicine = await _geminiService.parseOcrResult(ocrText);

      if (!mounted) return;
      if (dialogShown) {
        Navigator.of(context, rootNavigator: true).pop();
        dialogShown = false;
      }

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MedicinePlaceholderPage(medicine: medicine),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      if (dialogShown) {
        Navigator.of(context, rootNavigator: true).pop();
        dialogShown = false;
      }
      _showError('辨識失敗：$error');
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showLoadingDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: AppTheme.primary),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildCameraPreview(),
          _buildTopBar(),
          const Center(
            child: SizedBox(
              width: 280,
              height: 200,
              child: CustomPaint(
                painter: _ScanFramePainter(),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 28),
                    child: Text(
                      '請對準 藥袋 / 藥盒 / 保健食品外包裝',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomControls(),
    );
  }

  Widget _buildCameraPreview() {
    final controller = _cameraController;
    if (_cameraError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _cameraError!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      );
    }

    if (!_isCameraReady || controller == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    final previewSize = controller.value.previewSize;
    if (previewSize == null) {
      return CameraPreview(controller);
    }

    return ClipRect(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: previewSize.height,
          height: previewSize.width,
          child: CameraPreview(controller),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Row(
          children: [
            const SizedBox(width: 48),
            const Expanded(
              child: Text(
                '智慧用藥助手',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      height: 140,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: _BottomActionButton(
                icon: Icons.photo_library_outlined,
                label: '相簿匯入',
                onTap: _pickFromGallery,
              ),
            ),
            Expanded(
              child: Center(
                child: GestureDetector(
                  onTap: _isProcessing ? null : _takePicture,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x33000000),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(6),
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
            ),
            Expanded(
              child: const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _BottomActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppTheme.primary, size: 32),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.primary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanFramePainter extends CustomPainter {
  const _ScanFramePainter();

  static const double _cornerLength = 20;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primary
      ..strokeWidth = 3
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

// TODO [組員A]：此暫時頁面將由 MedicineDetailPage 取代
class MedicinePlaceholderPage extends StatefulWidget {
  final MedicineModel medicine;

  const MedicinePlaceholderPage({super.key, required this.medicine});

  @override
  State<MedicinePlaceholderPage> createState() =>
      _MedicinePlaceholderPageState();
}

class _MedicinePlaceholderPageState extends State<MedicinePlaceholderPage> {
  bool _isTtsEnabled = false;

  MedicineModel get medicine => widget.medicine;

  void _recordDose() {
    // TODO [組員A]：之後串接 DoseLog 儲存
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ 已記錄服藥！')),
    );
  }

  void _toggleTts() {
    // TODO [組員B]：之後串接 TtsService
    setState(() => _isTtsEnabled = !_isTtsEnabled);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '辨識結果',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _MedicineField(
              label: '藥品名稱',
              value: medicine.name,
              contentFontSize: 18,
            ),
            if (medicine.indication.isNotEmpty) ...[
              const SizedBox(height: 12),
              _MedicineField(
                label: '適應症（治療什麼）',
                value: medicine.indication,
              ),
            ],
            const SizedBox(height: 12),
            _MedicineField(label: '藥物類型', value: medicine.type),
            const SizedBox(height: 12),
            _MedicineField(label: '用法用量', value: medicine.dosage),
            const SizedBox(height: 12),
            _MedicineField(label: '使用頻率', value: medicine.frequency),
            if (medicine.timing.isNotEmpty) ...[
              const SizedBox(height: 12),
              _MedicineField(
                label: '服用時間',
                value: medicine.timing.join('、'),
              ),
            ],
            if (medicine.notice.isNotEmpty) ...[
              const SizedBox(height: 12),
              _MedicineField(label: '注意事項', value: medicine.notice),
            ],
            if (medicine.endDate.isNotEmpty) ...[
              const SizedBox(height: 12),
              _MedicineField(label: '預計用完日期', value: medicine.endDate),
            ],
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _recordDose,
                    icon: const Icon(Icons.check_circle),
                    label: const Text('打卡（已服藥）'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _toggleTts,
                    icon: Icon(
                      _isTtsEnabled ? Icons.volume_up : Icons.volume_off,
                    ),
                    label: Text(_isTtsEnabled ? '播報開啟' : '播報關閉'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primary,
                      side: const BorderSide(color: AppTheme.primary),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MedicineField extends StatelessWidget {
  final String label;
  final String value;
  final double contentFontSize;

  const _MedicineField({
    required this.label,
    required this.value,
    this.contentFontSize = 16,
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
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value.isEmpty ? '尚未辨識' : value,
            style: TextStyle(
              color: AppTheme.textDark,
              fontSize: contentFontSize,
            ),
          ),
        ],
      ),
    );
  }
}
