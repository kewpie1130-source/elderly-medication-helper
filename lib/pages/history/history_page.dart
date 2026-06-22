import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/medicine_model.dart';
import '../../repositories/medicine_repository.dart';
import '../../theme/app_theme.dart';
import '../medicine/medicine_detail_page.dart'; // 跳轉至組員A負責的藥品資訊頁
import 'add_medicine_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

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

  // 從 SQLite 本地資料庫撈取歷史紀錄
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('讀取歷史紀錄失敗: $e'), backgroundColor: AppTheme.errorColor),
      );
    }
  }

  // 將資料依據建立日期分組（今日 / 本週 / 更早）
  Map<String, List<MedicineModel>> _groupMedicines(List<MedicineModel> medicines) {
    Map<String, List<MedicineModel>> groups = {
      '今日': [],
      '本週': [],
      '更早的分組': [],
    };

    final now = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(now);
    final sevenDaysAgo = now.subtract(const Duration(days: 7));

    for (var med in medicines) {
      if (med.createdAt.startsWith(todayStr)) {
        groups['今日']!.add(med);
      } else {
        try {
          final createdAtDate = DateTime.parse(med.createdAt);
          if (createdAtDate.isAfter(sevenDaysAgo)) {
            groups['本週']!.add(med);
          } else {
            groups['更早的分組']!.add(med);
          }
        } catch (_) {
          groups['更早的分組']!.add(med);
        }
      }
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final groupedData = _groupMedicines(_allMedicines);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor, // 白色背景
      appBar: AppBar(
        title: const Text('用藥歷史紀錄', style: TextStyle(fontSize: 24, fontWeight: 'bold')),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textColor,
        elevation: 0.5,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 28),
            onPressed: _loadHistoryData,
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : _allMedicines.isEmpty
              ? _buildEmptyState()
              : ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    if (groupedData['今日']!.isNotEmpty) ..._buildSection('今日', groupedData['今日']!),
                    if (groupedData['本週']!.isNotEmpty) ..._buildSection('本週', groupedData['本週']!),
                    if (groupedData['更早的分組']!.isNotEmpty) ..._buildSection('更早的分組', groupedData['更早的分組']!),
                  ],
                ),
      // 長者友善手動新增懸浮按鈕
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // 跳轉至手動新增頁，並等待回傳值以決定是否重新載入
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddMedicinePage()),
          );
          if (result == true) {
            _loadHistoryData();
          }
        },
        backgroundColor: AppTheme.primaryColor, // 草綠主色
        icon: const Icon(Icons.add, size: 28, color: Colors.white),
        label: const Text('手動新增', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: 'bold')),
      ),
    );
  }

  // 建立分組區塊
  List<Widget> _buildSection(String title, List<MedicineModel> list) {
    return [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        child: Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: 'bold', color: AppTheme.textColor),
        ),
      ),
      ...list.map((medicine) => _buildMedicineCard(medicine)).toList(),
      const SizedBox(height: 12),
    ];
  }

  // 依照 UI 規範打造長者友善藥品卡片
  Widget _buildMedicineCard(MedicineModel medicine) {
    return Card(
      elevation: 3, // 陰影規範
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), // 圓角 20px 規範
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          // 點擊紀錄進入組員A負責的藥品詳細頁面
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MedicineDetailPage(medicine: medicine),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: