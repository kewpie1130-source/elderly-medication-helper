import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/medicine.dart';
import '../models/taken_record.dart';
import '../services/database_helper.dart';

class HistoryPage extends StatefulWidget {
  final int refreshToken;

  const HistoryPage({super.key, required this.refreshToken});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final DatabaseHelper _database = DatabaseHelper.instance;
  late Future<_HistoryData> _historyData;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant HistoryPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshToken != widget.refreshToken) _load();
  }

  void _load() {
    _historyData = _loadHistoryData();
  }

  Future<_HistoryData> _loadHistoryData() async {
    final results = await Future.wait([
      _database.getMedicines(),
      _database.getTakenRecords(),
    ]);
    return _HistoryData(
      medicines: results[0] as List<Medicine>,
      records: results[1] as List<TakenRecord>,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        title: const Text(
          '用藥紀錄',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<_HistoryData>(
        future: _historyData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _HistoryMessage(text: '紀錄讀取失敗：${snapshot.error}');
          }

          final data = snapshot.data ?? const _HistoryData();
          if (data.medicines.isEmpty && data.records.isEmpty) {
            return const _HistoryMessage(text: '目前尚無用藥紀錄');
          }

          return RefreshIndicator(
            onRefresh: () async => setState(_load),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const _SectionTitle(title: '已儲存用藥資料'),
                if (data.medicines.isEmpty)
                  const _EmptyCard(text: '目前尚無已儲存用藥資料')
                else
                  ...data.medicines.map(_MedicineCard.new),
                const SizedBox(height: 20),
                const _SectionTitle(title: '服藥紀錄'),
                if (data.records.isEmpty)
                  const _EmptyCard(text: '目前尚無服藥紀錄')
                else
                  ...data.records.map(_TakenRecordCard.new),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HistoryData {
  final List<Medicine> medicines;
  final List<TakenRecord> records;

  const _HistoryData({this.medicines = const [], this.records = const []});
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _MedicineCard extends StatelessWidget {
  final Medicine medicine;

  const _MedicineCard(this.medicine);

  @override
  Widget build(BuildContext context) {
    final createdAt = DateTime.tryParse(medicine.createdAt);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: const CircleAvatar(
          radius: 27,
          backgroundColor: Color(0xFFC8E6C9),
          child: Icon(
            Icons.medication_outlined,
            color: Color(0xFF1B5E20),
            size: 29,
          ),
        ),
        title: Text(
          medicine.medicineName,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            [
              if (medicine.dosage.isNotEmpty) medicine.dosage,
              if (medicine.frequency.isNotEmpty) medicine.frequency,
              if (createdAt != null)
                '儲存時間：${DateFormat('yyyy-MM-dd HH:mm').format(createdAt)}',
            ].join('\n'),
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
        ),
      ),
    );
  }
}

class _TakenRecordCard extends StatelessWidget {
  final TakenRecord record;

  const _TakenRecordCard(this.record);

  @override
  Widget build(BuildContext context) {
    final takenAt = DateTime.tryParse(record.takenAt);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: const CircleAvatar(
          radius: 27,
          backgroundColor: Color(0xFFC8E6C9),
          child: Icon(Icons.check, color: Color(0xFF1B5E20), size: 29),
        ),
        title: Text(
          record.medicineName,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            '${record.date}　'
            '${takenAt == null ? '' : DateFormat('HH:mm').format(takenAt)}\n'
            '服用時段：${record.period}',
            style: const TextStyle(fontSize: 17, height: 1.5),
          ),
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String text;

  const _EmptyCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(fontSize: 18, color: Colors.black54),
          ),
        ),
      ),
    );
  }
}

class _HistoryMessage extends StatelessWidget {
  final String text;

  const _HistoryMessage({required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 21, color: Colors.black54),
      ),
    );
  }
}
