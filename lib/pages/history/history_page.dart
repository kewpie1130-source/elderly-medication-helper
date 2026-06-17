import 'package:flutter/material.dart';
import 'package:elderly_medication_helper/models/medicine_model.dart';
import 'package:elderly_medication_helper/repositories/medicine_repository.dart';
import 'package:elderly_medication_helper/theme/app_theme.dart';
import 'package:elderly_medication_helper/pages/medicine/medicine_detail_page.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

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
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('用藥紀錄', style: TextStyle(fontSize: 24, fontWeight: 'bold')), // 仿照設計圖標題
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textColor,
        elevation: 0.5,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt_outlined, color: AppTheme.primaryColor, size: 28), // 設計圖右上角綠色篩選圖示
            onPressed: _loadHistoryData, 
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : _todayList.isEmpty && _thisWeekList.isEmpty && _olderList.isEmpty
              ? _buildEmptyState()
              : ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  children: [
                    if (_todayList.isNotEmpty) _buildSection('今日', _todayList), // 對齊設計圖乾淨分類
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
          padding: const EdgeInsets.only(top: 16, bottom: 8, left: 4),
          child: Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: 'bold', color: AppTheme.textColor),
          ),
        ),
        ...items.map((med) => _buildHistoryCard(med)).toList(),
      ],
    );
  }

  // 仿照設計圖3的單條歷史紀錄外觀（內含時鐘圖示與右側箭頭）
  Widget _buildHistoryCard(MedicineModel med) {
    String scanTime = '09:15';
    String scanDate = med.startDate;
    try {
      final parsed = DateTime.parse(med.createdAt);
      scanTime = DateFormat('HH:mm').format(parsed);
      scanDate = DateFormat('yyyy/MM/dd\n(一)').format(parsed); // 模擬設計圖星期顯示
    } catch (_) {}

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onPressed: () {
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
              // 左側日期文字
              Text(
                scanDate,
                textAlign: Center,
                style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: 'w500'),
              ),
              const SizedBox(width: 16),
              
              // 中間綠色小圓行事曆圖示（跟設計圖一致）
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.calendar_today, size: 24, color: AppTheme.primaryColor),
              ),
              const SizedBox(width: 16),
              
              // 藥品主要資訊
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      med.name,
                      style: const TextStyle(fontSize: 18, fontWeight: 'bold', color: AppTheme.textColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text('拍攝時間：$scanTime', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                    Text('預計用完：${med.endDate}', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                ),
              ),
              
              // 右側箭頭（綠色 `>`）
              const Icon(Icons.arrow_forward_ios, size: 20, color: AppTheme.primaryColor),
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
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600, fontWeight: 'bold'),
          ),
        ],
      ),
    );
  }
}