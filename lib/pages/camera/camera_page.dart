import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../models/medicine_model.dart';
import '../../repositories/medicine_repository.dart';
import '../../services/gemini/gemini_service.dart';
import '../../services/ocr/ocr_service.dart';
import '../../services/tts/tts_service.dart';
import '../../theme/app_theme.dart';
import '../reminder/reminder_page.dart';
import '../reminder/widgets/contact_modal.dart';
import '../reminder/widgets/reminder_modal.dart';

// [邱靖喻] 首頁相機拍攝頁，禁止其他組員修改
class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  final ImagePicker _imagePicker = ImagePicker();
  final OcrService _ocrService = OcrService();
  final GeminiService _geminiService = GeminiService();
  final TtsService _ttsService = TtsService();

  CameraController? _cameraController;
  bool _isCameraReady = false;
  bool _isProcessing = false;
  String? _cameraError;

  @override
  void initState() {
    super.initState();
    _ttsService.initTts();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) {
          setState(() => _cameraError = '找不到相機裝置');
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
      _showError('選取圖片失敗：$error');
    }
  }

  Future<void> _processImage(XFile imageFile) async {
    setState(() => _isProcessing = true);
    var dialogShown = false;
    try {
      _showLoadingDialog();
      dialogShown = true;

      final ocrText = await _ocrService.recognizeText(imageFile);
      final rawMedicines = await _geminiService.parseOcrResult(ocrText);

      // 過濾掉name為空的無效辨識結果
      final medicines =
          rawMedicines.where((m) => m.name.trim().isNotEmpty).toList();

      if (!mounted) return;
      if (dialogShown) {
        Navigator.of(context, rootNavigator: true).pop();
        dialogShown = false;
      }

      if (medicines.isEmpty) {
        _showError('未能辨識出有效的藥品資訊，請重新拍攝清晰的藥袋或藥盒照片');
        return;
      }

      final batchId = const Uuid().v4();
      final medicinesWithBatch = medicines
          .map((m) => m.copyWith(batchId: batchId))
          .toList();

      await _ttsService.speak(
        '已為您辨識出${medicinesWithBatch.length}種藥品，請確認資訊是否正確',
      );

      if (!mounted) return;

      final confirmed = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => MedicinePlaceholderPage(medicines: medicinesWithBatch),
        ),
      );

      // 使用者在確認頁按下「確認加入」才會回傳true，才繼續往下走
      if (confirmed != true || !mounted) return;

      await _showReminderPrompt(medicinesWithBatch.first.name);
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

  Future<void> _showReminderPrompt(String medicineName) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => ReminderModal(
        onChoice: (wantsReminder) async {
          Navigator.of(dialogContext).pop();
          if (wantsReminder) {
            if (!mounted) return;
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ReminderPage(medicineName: medicineName),
              ),
            );
            if (!mounted) return;
            await _showContactPrompt();
          }
        },
      ),
    );
  }

  Future<void> _showContactPrompt() async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => ContactModal(
        onSave: (lineId) {
          debugPrint('長者成功綁定聯絡人 LINE ID: $lineId');
          Navigator.of(dialogContext).pop();
        },
        onCancel: () {
          Navigator.of(dialogContext).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 相機預覽
          _buildCameraPreview(),

          // 頂部標題列
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  // 綠色十字 Logo
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '智慧用藥助手',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(color: Colors.black54, blurRadius: 4),
                          ],
                        ),
                      ),
                      Text(
                        '長者智慧用藥辨識 App',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          shadows: [
                            Shadow(color: Colors.black54, blurRadius: 4),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 中央掃描框
          Center(
            child: SizedBox(
              width: 280,
              height: 200,
              child: CustomPaint(
                painter: const _ScanFramePainter(),
              ),
            ),
          ),

          // Loading 遮罩
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppTheme.primary),
                    SizedBox(height: 16),
                    Text(
                      '辨識中，請稍候...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: _buildBottomControls(),
    );
  }

  Widget _buildCameraPreview() {
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

    final controller = _cameraController;
    if (!_isCameraReady || controller == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    final previewSize = controller.value.previewSize;
    if (previewSize == null) return CameraPreview(controller);

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

  Widget _buildBottomControls() {
    return Container(
      height: 140,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // 相簿匯入
            _BottomActionButton(
              icon: Icons.photo_library_outlined,
              label: '相簿匯入',
              onTap: _isProcessing ? () {} : _pickFromGallery,
            ),

            // 拍攝按鈕
            GestureDetector(
              onTap: _isProcessing ? null : _takePicture,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 38,
                ),
              ),
            ),

            // 右側空白（對稱用）
            const SizedBox(width: 80),
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
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppTheme.primary, size: 28),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.primary,
              fontSize: 13,
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

  static const double _cornerLength = 24;
  static const double _cornerRadius = 4;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primary
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // 左上角
    canvas.drawLine(
      const Offset(0, _cornerLength),
      const Offset(0, _cornerRadius),
      paint,
    );
    canvas.drawLine(
      const Offset(_cornerRadius, 0),
      const Offset(_cornerLength, 0),
      paint,
    );

    // 右上角
    canvas.drawLine(
      Offset(size.width - _cornerLength, 0),
      Offset(size.width - _cornerRadius, 0),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, _cornerRadius),
      Offset(size.width, _cornerLength),
      paint,
    );

    // 右下角
    canvas.drawLine(
      Offset(size.width, size.height - _cornerLength),
      Offset(size.width, size.height - _cornerRadius),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - _cornerRadius, size.height),
      Offset(size.width - _cornerLength, size.height),
      paint,
    );

    // 左下角
    canvas.drawLine(
      Offset(_cornerLength, size.height),
      Offset(_cornerRadius, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height - _cornerRadius),
      Offset(0, size.height - _cornerLength),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScanFramePainter oldDelegate) => false;
}

// TODO [組員A]：此暫時頁面將由 MedicineDetailPage 取代
class MedicinePlaceholderPage extends StatefulWidget {
  final List<MedicineModel> medicines;

  const MedicinePlaceholderPage({super.key, required this.medicines});

  @override
  State<MedicinePlaceholderPage> createState() =>
      _MedicinePlaceholderPageState();
}

class _MedicinePlaceholderPageState extends State<MedicinePlaceholderPage> {
  bool _isTtsEnabled = false;
  int _currentIndex = 0;
  final TtsService _ttsService = TtsService();
  final MedicineRepository _repository = MedicineRepository();

  List<MedicineModel> get medicines => widget.medicines;
  MedicineModel get medicine => medicines[_currentIndex];

  @override
  void initState() {
    super.initState();
    _ttsService.initTts();
  }

  Future<void> _confirmAndSave() async {
    for (final med in medicines) {
      await _repository.insertMedicine(med);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ 已將${medicines.length}種藥品加入用藥紀錄！'),
        backgroundColor: const Color(0xFF4CAF50),
      ),
    );
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  Future<void> _toggleTts() async {
    setState(() => _isTtsEnabled = !_isTtsEnabled);
    if (_isTtsEnabled) {
      await _ttsService.speak(
        '${medicine.name}，${medicine.dosage}，${medicine.frequency}',
      );
    } else {
      await _ttsService.stop();
    }
  }

  void _switchMedicine(int index) {
    setState(() {
      _currentIndex = index;
      _isTtsEnabled = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '藥品資訊',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isTtsEnabled ? Icons.volume_up : Icons.volume_off,
              color: Colors.white,
              size: 28,
            ),
            onPressed: _toggleTts,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (medicines.length > 1)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Text(
                      '第${_currentIndex + 1}種藥品（共${medicines.length}種）',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: List.generate(medicines.length, (i) {
                        return GestureDetector(
                          onTap: () => _switchMedicine(i),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: i == _currentIndex
                                  ? AppTheme.primary
                                  : Colors.grey.shade300,
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),

            // 藥品圖示卡片
            Container(
              width: double.infinity,
              height: 160,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.medication,
                  size: 80,
                  color: AppTheme.primary,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 藥品名稱
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                medicine.name.isEmpty ? '未知藥品' : medicine.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF222222),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 資訊卡片
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  if (medicine.indication.isNotEmpty) ...[
                    _InfoRow(
                      icon: Icons.healing,
                      title: '適應症（治療什麼）',
                      value: medicine.indication,
                      isFirst: true,
                    ),
                    const _Divider(),
                  ],
                  if (medicine.dosage.isNotEmpty)
                    _InfoRow(
                      icon: Icons.science,
                      title: '用法與用量',
                      value: medicine.dosage,
                      isFirst: medicine.indication.isEmpty,
                    ),
                  if (medicine.frequency.isNotEmpty) ...[
                    const _Divider(),
                    _InfoRow(
                      icon: Icons.repeat,
                      title: '使用頻率',
                      value: medicine.frequency,
                    ),
                  ],
                  if (medicine.timing.isNotEmpty) ...[
                    const _Divider(),
                    _InfoRow(
                      icon: Icons.schedule,
                      title: '服用時間',
                      value: medicine.timing.join('、'),
                    ),
                  ],
                  if (medicine.type.isNotEmpty) ...[
                    const _Divider(),
                    _InfoRow(
                      icon: Icons.category,
                      title: '藥物類型',
                      value: medicine.type,
                    ),
                  ],
                  if (medicine.notice.isNotEmpty) ...[
                    const _Divider(),
                    _InfoRow(
                      icon: Icons.warning_amber_rounded,
                      title: '注意事項 / 禁忌',
                      value: medicine.notice,
                      isWarning: true,
                    ),
                  ],
                  if (medicine.endDate.isNotEmpty) ...[
                    const _Divider(),
                    _InfoRow(
                      icon: Icons.calendar_today,
                      title: '預計用完日期',
                      value: medicine.endDate,
                      isLast: true,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (medicines.length > 1)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _currentIndex > 0
                            ? () => _switchMedicine(_currentIndex - 1)
                            : null,
                        child: const Text('上一種藥品'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _currentIndex < medicines.length - 1
                            ? () => _switchMedicine(_currentIndex + 1)
                            : null,
                        child: const Text('下一種藥品'),
                      ),
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: SizedBox(
                    height: 60,
                    child: ElevatedButton(
                      onPressed: _confirmAndSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, size: 24),
                          SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              '確認加入紀錄',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 60,
                    child: OutlinedButton(
                      onPressed: _toggleTts,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primary,
                        side: const BorderSide(
                          color: AppTheme.primary,
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isTtsEnabled ? Icons.volume_up : Icons.volume_off,
                            size: 22,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              _isTtsEnabled ? '播報開啟' : '播報關閉',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final bool isWarning;
  final bool isFirst;
  final bool isLast;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
    this.isWarning = false,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        isFirst ? 20 : 16,
        20,
        isLast ? 20 : 16,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: isWarning ? const Color(0xFFFF6B6B) : AppTheme.primary,
            size: 26,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: isWarning
                        ? const Color(0xFFD32F2F)
                        : const Color(0xFF222222),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 1,
      indent: 20,
      endIndent: 20,
      color: Color(0xFFEEEEEE),
    );
  }
}
