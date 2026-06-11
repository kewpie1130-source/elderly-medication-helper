import 'package:flutter/material.dart';

import '../models/medicine.dart';
import '../services/database_helper.dart';

class SettingsPage extends StatefulWidget {
  final int refreshToken;
  final VoidCallback onDataChanged;

  const SettingsPage({
    super.key,
    required this.refreshToken,
    required this.onDataChanged,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final DatabaseHelper _database = DatabaseHelper.instance;
  late Future<List<Medicine>> _medicines;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant SettingsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshToken != widget.refreshToken) _load();
  }

  void _load() {
    _medicines = _database.getMedicines();
  }

  Future<void> _addMedicine() async {
    final medicine = await showDialog<Medicine>(
      context: context,
      builder: (_) => const _ManualMedicineDialog(),
    );
    if (medicine == null) return;

    try {
      await _database.insertMedicine(medicine);
      widget.onDataChanged();
      if (!mounted) return;
      setState(_load);
      _showMessage('藥物已新增');
    } catch (error) {
      if (!mounted) return;
      _showMessage('新增藥物失敗：$error', isError: true);
    }
  }

  Future<void> _deleteMedicine(Medicine medicine) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('刪除藥物'),
        content: Text('確定要刪除「${medicine.medicineName}」嗎？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('刪除'),
          ),
        ],
      ),
    );
    if (confirmed != true || medicine.id == null) return;

    try {
      await _database.deleteMedicine(medicine.id!);
      widget.onDataChanged();
      if (!mounted) return;
      setState(_load);
    } catch (error) {
      if (!mounted) return;
      _showMessage('刪除藥物失敗：$error', isError: true);
    }
  }

  Future<void> _clearData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除測試資料'),
        content: const Text('這會刪除所有用藥資料與服藥紀錄，確定要繼續嗎？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('全部清除'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _database.clearAllData();
      widget.onDataChanged();
      if (!mounted) return;
      setState(_load);
      _showMessage('測試資料已清除');
    } catch (error) {
      if (!mounted) return;
      _showMessage('清除資料失敗：$error', isError: true);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Colors.red.shade700
            : const Color(0xFF2E7D32),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        title: const Text('設定', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: FutureBuilder<List<Medicine>>(
        future: _medicines,
        builder: (context, snapshot) {
          final medicines = snapshot.data ?? const <Medicine>[];
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SizedBox(
                height: 58,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _addMedicine,
                  icon: const Icon(Icons.add, size: 28),
                  label: const Text('手動新增藥物', style: TextStyle(fontSize: 19)),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '目前儲存的用藥清單',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              if (snapshot.connectionState == ConnectionState.waiting)
                const Center(child: CircularProgressIndicator())
              else if (snapshot.hasError)
                Text(
                  '用藥清單讀取失敗：${snapshot.error}',
                  style: const TextStyle(fontSize: 18, color: Colors.red),
                )
              else if (medicines.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      '目前尚無用藥資料',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                )
              else
                ...medicines.map(
                  (medicine) => Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(14),
                      title: Text(
                        medicine.medicineName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        [
                          medicine.dosage,
                          medicine.frequency,
                        ].where((text) => text.isNotEmpty).join('　'),
                        style: const TextStyle(fontSize: 16),
                      ),
                      trailing: IconButton(
                        tooltip: '刪除',
                        onPressed: () => _deleteMedicine(medicine),
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              SizedBox(
                height: 56,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red.shade700,
                    side: BorderSide(color: Colors.red.shade700, width: 2),
                  ),
                  onPressed: _clearData,
                  icon: const Icon(Icons.delete_sweep_outlined),
                  label: const Text('清除測試資料', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ManualMedicineDialog extends StatefulWidget {
  const _ManualMedicineDialog();

  @override
  State<_ManualMedicineDialog> createState() => _ManualMedicineDialogState();
}

class _ManualMedicineDialogState extends State<_ManualMedicineDialog> {
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _frequencyController = TextEditingController();
  bool _morning = true;
  bool _noon = false;
  bool _evening = false;
  bool _beforeSleep = false;

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _frequencyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('手動新增藥物'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              autofocus: true,
              decoration: const InputDecoration(labelText: '藥品名稱 *'),
            ),
            TextField(
              controller: _dosageController,
              decoration: const InputDecoration(labelText: '用量'),
            ),
            TextField(
              controller: _frequencyController,
              decoration: const InputDecoration(labelText: '每日頻率'),
            ),
            CheckboxListTile(
              value: _morning,
              onChanged: (value) => setState(() => _morning = value ?? false),
              title: const Text('早上'),
            ),
            CheckboxListTile(
              value: _noon,
              onChanged: (value) => setState(() => _noon = value ?? false),
              title: const Text('中午'),
            ),
            CheckboxListTile(
              value: _evening,
              onChanged: (value) => setState(() => _evening = value ?? false),
              title: const Text('晚上'),
            ),
            CheckboxListTile(
              value: _beforeSleep,
              onChanged: (value) =>
                  setState(() => _beforeSleep = value ?? false),
              title: const Text('睡前'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () {
            final name = _nameController.text.trim();
            if (name.isEmpty) return;
            Navigator.pop(
              context,
              Medicine(
                medicineName: name,
                dosage: _dosageController.text.trim(),
                frequency: _frequencyController.text.trim(),
                morning: _morning,
                noon: _noon,
                evening: _evening,
                beforeSleep: _beforeSleep,
                createdAt: DateTime.now().toIso8601String(),
              ),
            );
          },
          child: const Text('儲存'),
        ),
      ],
    );
  }
}
