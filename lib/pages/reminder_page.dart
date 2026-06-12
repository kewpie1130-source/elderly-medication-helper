import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/medicine.dart';
import '../models/taken_record.dart';
import '../services/database_helper.dart';
import 'dose_session_page.dart';

class ReminderPage extends StatefulWidget {
  final int refreshToken;
  final VoidCallback onDataChanged;

  const ReminderPage({
    super.key,
    required this.refreshToken,
    required this.onDataChanged,
  });

  @override
  State<ReminderPage> createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  final DatabaseHelper _database = DatabaseHelper.instance;
  late Future<List<Medicine>> _medicines;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant ReminderPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshToken != widget.refreshToken) _load();
  }

  void _load() {
    _medicines = _database.getMedicines();
  }

  Future<void> _markTaken(Medicine medicine, String period) async {
    final medicineId = medicine.id;
    if (medicineId == null) return;

    try {
      final now = DateTime.now();
      final date = DateFormat('yyyy-MM-dd').format(now);
      final exists = await _database.hasTakenRecord(
        medicineId: medicineId,
        period: period,
        date: date,
      );

      if (exists && mounted) {
        final continueRecording = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('可能重複服藥'),
            content: const Text('今天這個時段已經記錄過，請確認是否重複服藥'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('取消'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('仍然記錄'),
              ),
            ],
          ),
        );
        if (continueRecording != true) return;
      }

      await _database.insertTakenRecord(
        TakenRecord(
          medicineId: medicineId,
          medicineName: medicine.medicineName,
          period: period,
          takenAt: now.toIso8601String(),
          date: date,
        ),
      );
      widget.onDataChanged();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${medicine.medicineName}已記錄為服用'),
          backgroundColor: const Color(0xFF2E7D32),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('服藥紀錄寫入失敗：$error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        title: const Text(
          '今日用藥提醒',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: FilledButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => const DoseSessionPage(),
                ),
              ),
              icon: const Icon(Icons.fact_check_outlined),
              label: const Text(
                '開始本時段用藥打卡',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Medicine>>(
              future: _medicines,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return _Message(text: '用藥資料讀取失敗：${snapshot.error}');
                }

                final medicines = snapshot.data ?? const <Medicine>[];
                if (medicines.isEmpty) {
                  return const _Message(text: '目前尚無用藥資料');
                }

                return RefreshIndicator(
                  onRefresh: () async => setState(_load),
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _PeriodSection(
                        title: '早上',
                        icon: Icons.wb_sunny,
                        color: Colors.orange,
                        medicines: medicines
                            .where((item) => item.morning)
                            .toList(),
                        onTaken: (medicine) => _markTaken(medicine, '早上'),
                      ),
                      _PeriodSection(
                        title: '中午',
                        icon: Icons.wb_sunny_outlined,
                        color: Colors.amber.shade700,
                        medicines: medicines
                            .where((item) => item.noon)
                            .toList(),
                        onTaken: (medicine) => _markTaken(medicine, '中午'),
                      ),
                      _PeriodSection(
                        title: '晚上',
                        icon: Icons.nights_stay,
                        color: Colors.indigo,
                        medicines: medicines
                            .where((item) => item.evening)
                            .toList(),
                        onTaken: (medicine) => _markTaken(medicine, '晚上'),
                      ),
                      _PeriodSection(
                        title: '睡前',
                        icon: Icons.bedtime,
                        color: Colors.purple,
                        medicines: medicines
                            .where((item) => item.beforeSleep)
                            .toList(),
                        onTaken: (medicine) => _markTaken(medicine, '睡前'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<Medicine> medicines;
  final ValueChanged<Medicine> onTaken;

  const _PeriodSection({
    required this.title,
    required this.icon,
    required this.color,
    required this.medicines,
    required this.onTaken,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 31),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            if (medicines.isEmpty)
              const Text(
                '此時段沒有設定藥物',
                style: TextStyle(fontSize: 17, color: Colors.black54),
              )
            else
              ...medicines.map(
                (medicine) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              medicine.medicineName,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (medicine.dosage.isNotEmpty)
                              Text(
                                medicine.dosage,
                                style: const TextStyle(fontSize: 16),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 48,
                        child: FilledButton.icon(
                          onPressed: () => onTaken(medicine),
                          icon: const Icon(Icons.check),
                          label: const Text(
                            '已服用',
                            style: TextStyle(fontSize: 17),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  final String text;

  const _Message({required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, color: Colors.black54),
        ),
      ),
    );
  }
}
