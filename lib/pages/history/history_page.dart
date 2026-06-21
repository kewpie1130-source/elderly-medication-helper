import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/medicine_model.dart';
import '../../repositories/medicine_repository.dart';
import '../../theme/app_theme.dart';
import '../medicine/medicine_detail_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final MedicineRepository _repository = MedicineRepository();
  
  List<MedicineModel> _todayList = [];
  List<MedicineModel> _thisWeekList = [];
  List<MedicineModel> _olderList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistoryData();
  }

  Future<void> _loadHistoryData() async {
    setState(() => _isLoading = true);
    try {
      final allMedicines = await _repository.getAllMedicines();
      final now = DateTime.now();
      final todayStr = DateFormat('yyyy-MM-dd').format(now);
      final sevenDaysAgo = now.subtract(const Duration(days: 7));

      List<MedicineModel> today = [];
      List<MedicineModel> thisWeek = [];
      List<MedicineModel> older = [];

      for (var med in allMedicines) {
        try {
          final createdAt = DateTime.parse(med.createdAt);
          final dateStr = DateFormat('yyyy-MM-dd').format(createdAt);

          if (dateStr == todayStr) {
            today.add(med);
          } else if (createdAt.isAfter(sevenDaysAgo)) {
            thisWeek.add(med);
          } else {
            older.add(med);
          }
        } catch (_) {
          older.add(med);
        }
      }

      setState(() {
        _todayList = today;
        _thisWeekList = thisWeek;
        _olderList = older;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          '用藥紀錄',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.textDark,
          ),
        ),
        backgroundColor: AppTheme.background,
        foregroundColor: AppTheme.textDark,
        elevation: 0,
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: IconButton(
              icon: const Icon(
                Icons.filter_alt_outlined,
                color: AppTheme.primary,
                size: 24,
              ),
              onPressed: _loadHistoryData,
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : _todayList.isEmpty && _thisWeekList.isEmpty && _olderList.isEmpty
              ? _buildEmptyState()
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                  children: [
                    if (_todayList.isNotEmpty) _buildSection('今日', _todayList),
                    if (_thisWeekList.isNotEmpty) _buildSection('本週', _thisWeekList),
                    if (_olderList.isNotEmpty) _buildSection('更早', _olderList),
                  ],
                ),
    );
  }

  Widget _buildSection(String title, List<MedicineModel> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(2, 14, 2, 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppTheme.primary.withValues(alpha: 0.95),
            ),
          ),
        ),
        ...items.map((med) => _buildHistoryCard(med)),
      ],
    );
  }

  Widget _buildHistoryCard(MedicineModel med) {
    String scanTime = '09:15';
    try {
      final parsed = DateTime.parse(med.createdAt);
      scanTime = DateFormat('HH:mm').format(parsed);
    } catch (_) {}

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MedicineDetailPage(medicine: med),
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
                        med.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                        '預計用完：${med.endDate}',
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
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
