import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../models/medicine.dart';
import '../services/database_helper.dart';
import '../services/local_image_repository.dart';
import '../services/medicine_parser_service.dart';
import '../services/ocr_service.dart';
import 'image_history_page.dart';

class ScanPage extends StatefulWidget {
  final File? initialImage;
  final VoidCallback? onDataChanged;

  const ScanPage({super.key, this.initialImage, this.onDataChanged});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  static const _green = Color(0xFF2E7D32);

  final ImagePicker _picker = ImagePicker();
  final LocalImageRepository _imageRepository = LocalImageRepository();
  final OcrService _ocrService = OcrService();
  final MedicineParserService _parser = MedicineParserService();
  final DatabaseHelper _database = DatabaseHelper.instance;

  final _patientNameController = TextEditingController();
  final _clinicNameController = TextEditingController();
  final _medicineNameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _frequencyController = TextEditingController();
  final _timingTextController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _notesController = TextEditingController();
  final _ocrTextController = TextEditingController();

  File? _selectedImage;
  bool _isBusy = false;
  bool _hasOcrResult = false;
  bool _morning = false;
  bool _noon = false;
  bool _evening = false;
  bool _beforeSleep = false;
  bool _beforeMeal = false;
  bool _afterMeal = false;

  @override
  void initState() {
    super.initState();
    _selectedImage = widget.initialImage;
    if (_selectedImage == null) {
      _loadSampleImage();
    }
  }

  @override
  void dispose() {
    _patientNameController.dispose();
    _clinicNameController.dispose();
    _medicineNameController.dispose();
    _dosageController.dispose();
    _frequencyController.dispose();
    _timingTextController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _notesController.dispose();
    _ocrTextController.dispose();
    super.dispose();
  }

  Future<void> _loadSampleImage() async {
    try {
      final data = await rootBundle.load(
        'assets/sample/mock_prescription_zh_tw.png',
      );
      final file = await _imageRepository.saveBytes(
        data.buffer.asUint8List(),
        'mock_prescription_zh_tw.png',
      );
      if (!mounted) return;
      setState(() => _selectedImage = file);
    } catch (error) {
      if (!mounted) return;
      _showError('範例藥單載入失敗：$error');
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    setState(() => _isBusy = true);
    try {
      final image = await _picker.pickImage(source: source, imageQuality: 90);
      if (image == null) return;
      final savedImage = await _imageRepository.save(File(image.path));
      if (!mounted) return;
      setState(() {
        _selectedImage = savedImage;
        _hasOcrResult = false;
        _ocrTextController.clear();
      });
      _showMessage('圖片已存入 App 綠色相簿');
    } catch (error) {
      if (!mounted) return;
      _showError(
        source == ImageSource.camera ? '拍照失敗：$error' : '相簿圖片選取失敗：$error',
      );
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _runOcr() async {
    final image = _selectedImage;
    if (image == null) {
      _showError('請先拍攝或選擇圖片');
      return;
    }

    setState(() => _isBusy = true);
    try {
      final text = await _ocrService.recognizeText(image);
      if (!mounted) return;
      if (text.isEmpty) {
        _showError('沒有辨識到文字，請換一張較清楚的圖片');
        return;
      }
      _ocrTextController.text = text;
      _applyParsedMedicine(_parser.parse(text, imagePath: image.path));
      setState(() => _hasOcrResult = true);
    } catch (error) {
      if (!mounted) return;
      _showError('OCR 辨識失敗：$error');
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  void _parseEditedText() {
    final text = _ocrTextController.text.trim();
    if (text.isEmpty) {
      _showError('OCR 文字不可為空白');
      return;
    }
    _applyParsedMedicine(
      _parser.parse(text, imagePath: _selectedImage?.path ?? ''),
    );
    _showMessage('已重新整理用藥欄位');
  }

  void _applyParsedMedicine(Medicine medicine) {
    _patientNameController.text = medicine.patientName;
    _clinicNameController.text = medicine.clinicName;
    _medicineNameController.text = medicine.medicineName;
    _dosageController.text = medicine.dosage;
    _frequencyController.text = medicine.frequency;
    _timingTextController.text = medicine.timingText;
    _startDateController.text = medicine.startDate;
    _endDateController.text = medicine.endDate;
    _notesController.text = medicine.notes;
    setState(() {
      _morning = medicine.morning;
      _noon = medicine.noon;
      _evening = medicine.evening;
      _beforeSleep = medicine.beforeSleep;
      _beforeMeal = medicine.beforeMeal;
      _afterMeal = medicine.afterMeal;
    });
  }

  Future<void> _saveMedicine() async {
    if (_medicineNameController.text.trim().isEmpty) {
      _showError('請至少輸入藥品名稱');
      return;
    }

    setState(() => _isBusy = true);
    try {
      final medicine = Medicine(
        patientName: _patientNameController.text.trim(),
        clinicName: _clinicNameController.text.trim(),
        medicineName: _medicineNameController.text.trim(),
        dosage: _dosageController.text.trim(),
        frequency: _frequencyController.text.trim(),
        timingText: _timingTextController.text.trim(),
        morning: _morning,
        noon: _noon,
        evening: _evening,
        beforeSleep: _beforeSleep,
        beforeMeal: _beforeMeal,
        afterMeal: _afterMeal,
        startDate: _startDateController.text.trim(),
        endDate: _endDateController.text.trim(),
        notes: _notesController.text.trim(),
        imagePath: _selectedImage?.path ?? '',
        ocrText: _ocrTextController.text.trim(),
        createdAt: DateTime.now().toIso8601String(),
      );
      debugPrint('【Medicine建立成功】${medicine.toMap()}');
      await _database.insertMedicine(medicine);
      widget.onDataChanged?.call();
      if (!mounted) return;
      _showMessage('用藥資料已儲存');
    } catch (error) {
      if (!mounted) return;
      _showError('用藥資料儲存失敗：$error');
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  void _openAppAlbum() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ImageHistoryPage()),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: _green));
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade700),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8F4),
      appBar: AppBar(
        automaticallyImplyLeading: Navigator.canPop(context),
        backgroundColor: _green,
        foregroundColor: Colors.white,
        title: const Text(
          '新增用藥影像',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'App 綠色相簿',
            onPressed: _openAppAlbum,
            icon: const Icon(Icons.photo_album_outlined),
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              _buildImagePreview(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _SourceButton(
                      icon: Icons.camera_alt_outlined,
                      label: '拍攝圖片',
                      onPressed: () => _pickImage(ImageSource.camera),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SourceButton(
                      icon: Icons.photo_library_outlined,
                      label: '手機相簿',
                      onPressed: () => _pickImage(ImageSource.gallery),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 56,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _green,
                    side: const BorderSide(color: _green, width: 2),
                  ),
                  onPressed: _openAppAlbum,
                  icon: const Icon(Icons.photo_album_outlined),
                  label: const Text(
                    '開啟 App 綠色相簿',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 60,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _green,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _selectedImage == null ? null : _runOcr,
                  icon: const Icon(Icons.document_scanner_outlined, size: 28),
                  label: const Text(
                    '開始 OCR 辨識',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              if (_hasOcrResult) ...[
                const SizedBox(height: 24),
                _buildOcrEditor(),
                const SizedBox(height: 16),
                _buildMedicineForm(),
                const SizedBox(height: 16),
                SizedBox(
                  height: 60,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _green,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _saveMedicine,
                    icon: const Icon(Icons.save_outlined, size: 28),
                    label: const Text(
                      '儲存用藥資料',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (_isBusy)
            const ColoredBox(
              color: Color(0x66000000),
              child: Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: _green),
                        SizedBox(height: 16),
                        Text('處理中，請稍候...', style: TextStyle(fontSize: 18)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: 320,
        child: _selectedImage == null
            ? const Center(
                child: Text(
                  '請拍攝或選擇藥單、藥盒、保健食品圖片',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 19, color: Color(0xFF1B5E20)),
                ),
              )
            : Image.file(
                _selectedImage!,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Center(
                  child: Text('圖片預覽失敗', style: TextStyle(fontSize: 18)),
                ),
              ),
      ),
    );
  }

  Widget _buildOcrEditor() {
    return _SectionCard(
      title: 'OCR 原始辨識文字',
      child: Column(
        children: [
          TextField(
            controller: _ocrTextController,
            minLines: 8,
            maxLines: 16,
            style: const TextStyle(fontSize: 17, height: 1.5),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: '可在此確認或修改 OCR 文字',
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: _parseEditedText,
              icon: const Icon(Icons.auto_fix_high),
              label: const Text('依修改後文字重新整理欄位', style: TextStyle(fontSize: 17)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicineForm() {
    return _SectionCard(
      title: '確認用藥資料',
      child: Column(
        children: [
          _field(_clinicNameController, '診所／醫院名稱'),
          _field(_patientNameController, '病人姓名'),
          _field(_medicineNameController, '藥品名稱 *'),
          _field(_dosageController, '用量'),
          _field(_frequencyController, '每日頻率'),
          _field(_timingTextController, '完整用法'),
          _field(_startDateController, '開始日期', hint: '例如 2026-06-11'),
          _field(_endDateController, '結束日期', hint: '可留空'),
          _field(_notesController, '備註', maxLines: 3),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '服用時段',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              _timeChip('早上', _morning, (value) => _morning = value),
              _timeChip('中午', _noon, (value) => _noon = value),
              _timeChip('晚上', _evening, (value) => _evening = value),
              _timeChip('睡前', _beforeSleep, (value) => _beforeSleep = value),
              _timeChip('飯前', _beforeMeal, (value) => _beforeMeal = value),
              _timeChip('飯後', _afterMeal, (value) => _afterMeal = value),
            ],
          ),
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    String? hint,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 18),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _timeChip(String label, bool selected, ValueChanged<bool> update) {
    return FilterChip(
      label: Text(label, style: const TextStyle(fontSize: 17)),
      selected: selected,
      selectedColor: const Color(0xFFC8E6C9),
      onSelected: (value) => setState(() => update(value)),
    );
  }
}

class _SourceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _SourceButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE8F5E9),
          foregroundColor: const Color(0xFF1B5E20),
          elevation: 0,
        ),
        onPressed: onPressed,
        icon: Icon(icon, size: 26),
        label: Text(label, style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B5E20),
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
