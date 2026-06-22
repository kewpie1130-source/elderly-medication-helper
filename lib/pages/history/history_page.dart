import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/medicine_model.dart';
import '../../repositories/medicine_repository.dart';
import '../../theme/app_theme.dart';
import '../medicine/medicine_detail_page.dart';
import 'add_medicine_page.dart';

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

  Map<String, List<MedicineModel>> _groupMedicines(
    List<MedicineModel> medicines,
  ) {
    final groups = <String, List<MedicineModel>>{
      '今日': [],
      '本週': [],
      '更早': [],
    };

    final now = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(now);
    final sevenDaysAgo = now.subtract(const Duration(days: 7));

    for (final med in medicines) {
      if (med.createdAt.startsWith(todayStr)) {
        groups['今日']!.add(med);
      } else {
        try {
          final createdAtDate = DateTime.parse(med.createdAt);
          if (createdAtDate.isAfter(sevenDaysAgo)) {
            groups['本週']!.add(med);
          } else {
            groups['更早']!.add(med);
          }
        } catch (_) {
          groups['更早']!.add(med);
        }
      }
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final groupedData = _groupMedicines(_allMedicines);

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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 28),
            onPressed: _loadHistoryData,
          ),
        ],
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddMedicinePage()),
          );
          _loadHistoryData();
        },
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add, size: 28, color: Colors.white),
        label: const Text(
          '手動新增',
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSection(String title, List<MedicineModel> list) {
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
      ...list.map((medicine) => _buildMedicineCard(medicine)),
      const SizedBox(height: 12),
    ];
  }

  Widget _buildMedicineCard(MedicineModel medicine) {
    String scanTime = '未知';
    try {
      scanTime = DateFormat('HH:mm').format(DateTime.parse(medicine.createdAt));
    } catch (_) {}

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MedicineDetailPage(medicine: medicine),
            ),
          ).then((_) => _loadHistoryData());
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
                child: const Icon(
                  Icons.calendar_today,
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
                      medicine.name,
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
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '預計用完：${medicine.endDate}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
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
