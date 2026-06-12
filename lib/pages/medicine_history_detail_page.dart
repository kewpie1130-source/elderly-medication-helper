import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/medicine.dart';
import '../services/database_helper.dart';
import 'scan_page.dart';

class MedicineHistoryDetailPage extends StatefulWidget {
  final Medicine medicine;

  const MedicineHistoryDetailPage({super.key, required this.medicine});

  @override
  State<MedicineHistoryDetailPage> createState() =>
      _MedicineHistoryDetailPageState();
}

class _MedicineHistoryDetailPageState extends State<MedicineHistoryDetailPage> {
  final DatabaseHelper _database = DatabaseHelper.instance;
  late Medicine _medicine;

  @override
  void initState() {
    super.initState();
    _medicine = widget.medicine;
  }

  Future<void> _editMedicine() async {
    final updated = await Navigator.of(context).push<Medicine>(
      MaterialPageRoute(
        builder: (context) => ScanPage(initialMedicine: _medicine),
      ),
    );
    if (updated == null || !mounted) return;

    setState(() {
      _medicine = updated;
    });
  }

  Future<void> _deleteMedicine() async {
    final id = _medicine.id;
    if (id == null) return;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('刪除用藥資料'),
        content: Text(
          '確定要刪除「${_medicine.medicineName}」及相關服藥紀錄嗎？'
          '\n\n原始圖片仍會保留在 App 綠色相簿。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('確認刪除'),
          ),
        ],
      ),
    );
    if (shouldDelete != true) return;

    try {
      await _database.deleteMedicine(id);
      if (!mounted) return;
      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('刪除用藥資料失敗：$error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final image = _medicine.imagePath.isEmpty
        ? null
        : File(_medicine.imagePath);
    final createdAt = DateTime.tryParse(_medicine.createdAt);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        title: const Text(
          '用藥資料詳情',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: '編輯',
            onPressed: _editMedicine,
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: '刪除',
            onPressed: _medicine.id == null ? null : _deleteMedicine,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (image != null)
            Card(
              clipBehavior: Clip.antiAlias,
              child: SizedBox(
                height: 240,
                child: Image.file(
                  image,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const Center(
                    child: Text('原始圖片已不存在', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ),
            ),
          _DetailSection(
            title: '用藥資料',
            children: [
              _DetailRow(label: '藥品名稱', value: _medicine.medicineName),
              _DetailRow(label: '醫療院所', value: _medicine.clinicName),
              _DetailRow(label: '病人姓名', value: _medicine.patientName),
              _DetailRow(label: '用量', value: _medicine.dosage),
              _DetailRow(label: '每日頻率', value: _medicine.frequency),
              _DetailRow(label: '完整用法', value: _medicine.timingText),
              _DetailRow(label: '開始日期', value: _medicine.startDate),
              _DetailRow(label: '結束日期', value: _medicine.endDate),
              _DetailRow(label: '備註', value: _medicine.notes),
              if (createdAt != null)
                _DetailRow(
                  label: '儲存時間',
                  value: DateFormat('yyyy-MM-dd HH:mm').format(createdAt),
                ),
            ],
          ),
          _DetailSection(
            title: '服用時段',
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _scheduleLabels(
                  _medicine,
                ).map((label) => Chip(label: Text(label))).toList(),
              ),
            ],
          ),
          if (_medicine.ocrText.isNotEmpty)
            _DetailSection(
              title: 'OCR 原始辨識文字',
              children: [
                SelectableText(
                  _medicine.ocrText,
                  style: const TextStyle(fontSize: 16, height: 1.6),
                ),
              ],
            ),
          const SizedBox(height: 8),
          SizedBox(
            height: 56,
            child: FilledButton.icon(
              onPressed: _editMedicine,
              icon: const Icon(Icons.edit_outlined),
              label: const Text(
                '編輯這筆用藥資料',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _scheduleLabels(Medicine medicine) {
    final labels = <String>[
      if (medicine.morning) '早上',
      if (medicine.noon) '中午',
      if (medicine.evening) '晚上',
      if (medicine.beforeSleep) '睡前',
      if (medicine.beforeMeal) '飯前',
      if (medicine.afterMeal) '飯後',
    ];
    return labels.isEmpty ? ['未設定'] : labels;
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _DetailSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(top: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B5E20),
              ),
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    if (value.trim().isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 88,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 17, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
