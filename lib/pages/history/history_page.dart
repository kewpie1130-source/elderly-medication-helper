import 'package:flutter/material.dart';
import '../../models/medicine_model.dart';
import '../../repositories/medicine_repository.dart';
import '../medicine/medicine_detail_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key}); // 🛠️ 優化：使用簡化型 super.key

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final MedicineRepository _repository = MedicineRepository();
  List<MedicineModel> _allMedicines = [];
  bool _isLoading = true; // 🛠️ 修正：更換為標準 lowerCamelCase 命名

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

      // 偵錯列印，確認資料庫撈取狀態
      debugPrint('==== 用藥紀錄數據偵錯 ====');
      debugPrint('目前 SQLite 資料庫總筆數: ${data.length}');
      for (var i = 0; i < data.length; i++) {
        debugPrint(
          '第 $i 筆藥品: ${data[i].name}, 建立日期 (createdAt): ${data[i].createdAt}',
        );
      }
      debugPrint('==========================');

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
          backgroundColor: const Color(0xFFD32F2F),
        ),
      );
    }
  }

  // 將資料依據建立日期分組
  Map<String, List<MedicineModel>> _groupMedicines(
    List<MedicineModel> medicines,
  ) {
    Map<String, List<MedicineModel>> groups = {'今日': [], '本週': [], '更早的分組': []};

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sevenDaysAgo = today.subtract(const Duration(days: 7));

    for (var med in medicines) {
      try {
        final createdAtDate = DateTime.parse(med.createdAt);
        final medicineDay = DateTime(
          createdAtDate.year,
          createdAtDate.month,
          createdAtDate.day,
        );

        if (medicineDay.isAtSameMomentAs(today)) {
          groups['今日']!.add(med);
        } else if (medicineDay.isAfter(sevenDaysAgo)) {
          groups['本週']!.add(med);
        } else {
          groups['更早的分組']!.add(med);
        }
      } catch (e) {
        debugPrint('時間解析出錯: ${med.createdAt}，預設歸類至今日。錯誤: $e');
        groups['今日']!.add(med);
      }
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final groupedData = _groupMedicines(_allMedicines);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          '用藥紀錄',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF333333),
        elevation: 0.5,
        centerTitle: true,
        actions: const [],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
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
                if (groupedData['更早的分組']!.isNotEmpty)
                  ..._buildSection('更早的分組', groupedData['更早的分組']!),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                '💡 手動新增功能由其他組員開發中，暫未開放。',
                style: TextStyle(fontSize: 16),
              ),
              duration: Duration(seconds: 2),
            ),
          );
        },
        backgroundColor: const Color(0xFF4CAF50),
        child: const Icon(Icons.add, size: 28, color: Colors.white),
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
            color: Color(0xFF333333),
          ),
        ),
      ),
      ...list.map(
        (medicine) => _buildMedicineCard(medicine),
      ), // 🛠️ 修正：移除多餘的 .toList()
      const SizedBox(height: 12),
    ];
  }

  Widget _buildMedicineCard(MedicineModel medicine) {
    final typeColor = _getTypeColor(medicine.type);

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
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                // 🛠️ 修正：改用新版推薦的顏色彩度設定方式，替代被棄用的 withOpacity
                backgroundColor: typeColor.withAlpha(38),
                child: Icon(
                  _getTypeIcon(medicine.type),
                  color: typeColor,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medicine.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '用法：${medicine.frequency} / ${medicine.dosage}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '預計結束：${medicine.endDate}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 18),
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
          Icon(
            Icons.medical_services_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          const Text(
            '目前沒有藥品紀錄',
            style: TextStyle(
              fontSize: 18,
              color: Color(0xFF333333),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '點擊右下角按鈕手動新增，或使用相機辨識藥袋',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    if (type == '處方藥') return const Color(0xFF4CAF50);
    if (type == '指示藥') return const Color(0xFFF57C00);
    return Colors.blue;
  }

  IconData _getTypeIcon(String type) {
    if (type == '處方藥') return Icons.medication_rounded;
    if (type == '指示藥') return Icons.medication_liquid_rounded;
    return Icons.health_and_safety_rounded;
  }
}
