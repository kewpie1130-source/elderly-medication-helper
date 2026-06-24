import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/medicine_model.dart';
import '../../repositories/medicine_repository.dart';
import '../../theme/app_theme.dart';
import '../medicine/medicine_detail_page.dart';
import 'add_medicine_page.dart';

class MedicineBatch {
  final String batchId;
  final List<MedicineModel> medicines;
  final String createdAt;

  MedicineBatch({
    required this.batchId,
    required this.medicines,
    required this.createdAt,
  });
}

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final MedicineRepository _repository = MedicineRepository();
  List<MedicineModel> _allMedicines = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistoryData();
  }

  Future<void> _loadHistoryData() async {
    setState(() => _isLoading = true);
    try {
      final data = await _repository.getAllMedicines();
      setState(() {
        _allMedicines = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('讀取歷史紀錄失敗: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<MedicineBatch> _groupIntoBatches(List<MedicineModel> medicines) {
    final Map<String, List<MedicineModel>> batchMap = {};

    for (final med in medicines) {
      // 沒有batchId的（手動新增的單筆），各自獨立成一個批次，用自己的id當batchId
      final key = med.batchId.isNotEmpty ? med.batchId : 'single_${med.id}';
      batchMap.putIfAbsent(key, () => []).add(med);
    }

    final batches = batchMap.entries.map((entry) {
      final meds = entry.value;
      // 用該批次第一筆的createdAt代表整批的時間
      return MedicineBatch(
        batchId: entry.key,
        medicines: meds,
        createdAt: meds.first.createdAt,
      );
    }).toList();

    // 依時間新到舊排序
    batches.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return batches;
  }

  Map<String, List<MedicineBatch>> _groupBatchesByTime(
    List<MedicineBatch> batches,
  ) {
    final groups = <String, List<MedicineBatch>>{
      '今日': [],
      '本週': [],
      '更早': [],
    };

    final now = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(now);
    final sevenDaysAgo = now.subtract(const Duration(days: 7));

    for (final batch in batches) {
      if (batch.createdAt.startsWith(todayStr)) {
        groups['今日']!.add(batch);
      } else {
        try {
          final createdAtDate = DateTime.parse(batch.createdAt);
          if (createdAtDate.isAfter(sevenDaysAgo)) {
            groups['本週']!.add(batch);
          } else {
            groups['更早']!.add(batch);
          }
        } catch (_) {
          groups['更早']!.add(batch);
        }
      }
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final batches = _groupIntoBatches(_allMedicines);
    final groupedData = _groupBatchesByTime(batches);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          '用藥歷史紀錄',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textDark,
        elevation: 0.5,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            )
          : _allMedicines.isEmpty
              ? _buildEmptyState()
              : ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    if (groupedData['今日']!.isNotEmpty)
                      ..._buildSection('今日', groupedData['今日']!),
                    if (groupedData['本週']!.isNotEmpty)
                      ..._buildSection('本週', groupedData['本週']!),
                    if (groupedData['更早']!.isNotEmpty)
                      ..._buildSection('更早', groupedData['更早']!),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddMedicinePage()),
          );
          _loadHistoryData();
        },
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add, size: 28, color: Colors.white),
      ),
    );
  }

  List<Widget> _buildSection(String title, List<MedicineBatch> list) {
    return [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
      ),
      ...list.map((batch) => _buildBatchCard(batch)),
      const SizedBox(height: 12),
    ];
  }

  Widget _buildBatchCard(MedicineBatch batch) {
    String scanTime = '未知';
    try {
      scanTime = DateFormat('HH:mm').format(DateTime.parse(batch.createdAt));
    } catch (_) {}

    final count = batch.medicines.length;
    final firstName = batch.medicines.first.name;
    final displayTitle = count > 1 ? '$firstName 等 $count 種藥品' : firstName;

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () async {
          if (count == 1) {
            // 只有一種藥，直接進詳情頁
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    MedicineDetailPage(medicine: batch.medicines.first),
              ),
            );
          } else {
            // 多種藥，進批次清單頁（先用簡單ListView顯示，點擊個別藥品才進詳情）
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    _BatchDetailPage(medicines: batch.medicines),
              ),
            );
          }
          _loadHistoryData();
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  count > 1 ? Icons.medical_services : Icons.calendar_today,
                  size: 21,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '拍攝時間：$scanTime',
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right,
                size: 26,
                color: AppTheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 70, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            '尚未有用藥紀錄喔！',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _BatchDetailPage extends StatelessWidget {
  final List<MedicineModel> medicines;

  const _BatchDetailPage({required this.medicines});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          '本次共 ${medicines.length} 種藥品',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: medicines.length,
        itemBuilder: (context, index) {
          final med = medicines[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: const Icon(Icons.medication, color: AppTheme.primary),
              title: Text(
                med.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle:
                  Text(med.dosage.isEmpty ? med.type : '${med.type} · ${med.dosage}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MedicineDetailPage(medicine: med),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
