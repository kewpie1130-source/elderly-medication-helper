import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/medicine.dart';
import '../services/database_helper.dart';

class HomePage extends StatefulWidget {
  final int refreshToken;
  final ValueChanged<int> onSelectTab;

  const HomePage({
    super.key,
    required this.refreshToken,
    required this.onSelectTab,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseHelper _database = DatabaseHelper.instance;
  late Future<List<Medicine>> _medicines;

  @override
  void initState() {
    super.initState();
    _loadMedicines();
  }

  @override
  void didUpdateWidget(covariant HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshToken != widget.refreshToken) {
      _loadMedicines();
    }
  }

  void _loadMedicines() {
    _medicines = _database.getMedicines();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        title: const Text(
          '智慧用藥管理',
          style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => setState(_loadMedicines),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              DateFormat('yyyy 年 M 月 d 日').format(DateTime.now()),
              style: const TextStyle(fontSize: 17, color: Colors.black54),
            ),
            const SizedBox(height: 8),
            const Text(
              '今天應服用藥物摘要',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B5E20),
              ),
            ),
            const SizedBox(height: 12),
            FutureBuilder<List<Medicine>>(
              future: _medicines,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return _SummaryCard(
                    title: '讀取失敗',
                    subtitle: snapshot.error.toString(),
                    icon: Icons.error_outline,
                  );
                }
                final medicines = snapshot.data ?? const <Medicine>[];
                return _TodaySummary(medicines: medicines);
              },
            ),
            const SizedBox(height: 20),
            const Text(
              '主要功能',
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _FeatureCard(
              title: '新增用藥影像',
              subtitle: '拍攝或從相簿匯入藥單',
              icon: Icons.add_a_photo_outlined,
              onTap: () => widget.onSelectTab(1),
            ),
            _FeatureCard(
              title: '今日用藥提醒',
              subtitle: '查看早上、中午、晚上與睡前用藥',
              icon: Icons.alarm_outlined,
              onTap: () => widget.onSelectTab(2),
            ),
            _FeatureCard(
              title: '用藥紀錄',
              subtitle: '查看已服用的時間與藥品',
              icon: Icons.history_outlined,
              onTap: () => widget.onSelectTab(3),
            ),
            _FeatureCard(
              title: 'Dashboard 分析',
              subtitle: '查看完成率、異常數與分類圖表',
              icon: Icons.analytics_outlined,
              onTap: () => widget.onSelectTab(4),
            ),
            _FeatureCard(
              title: '設定',
              subtitle: '管理 SQLite 本機用藥資料',
              icon: Icons.settings_outlined,
              onTap: () => widget.onSelectTab(5),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodaySummary extends StatelessWidget {
  final List<Medicine> medicines;

  const _TodaySummary({required this.medicines});

  @override
  Widget build(BuildContext context) {
    if (medicines.isEmpty) {
      return const _SummaryCard(
        title: '今天尚未設定藥物',
        subtitle: '請先到「新增」拍攝藥單或手動新增藥物。',
        icon: Icons.medication_outlined,
      );
    }

    int count(bool Function(Medicine medicine) match) {
      return medicines.where(match).length;
    }

    final summary = [
      '早上 ${count((medicine) => medicine.morning)} 項',
      '中午 ${count((medicine) => medicine.noon)} 項',
      '晚上 ${count((medicine) => medicine.evening)} 項',
      '睡前 ${count((medicine) => medicine.beforeSleep)} 項',
    ].join('　');

    return _SummaryCard(
      title: '共 ${medicines.length} 筆用藥資料',
      subtitle: summary,
      icon: Icons.medication_liquid_outlined,
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFE8F5E9),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Icon(icon, size: 46, color: const Color(0xFF2E7D32)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 17, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: const Color(0xFFC8E6C9),
                child: Icon(icon, size: 31, color: const Color(0xFF1B5E20)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, size: 32),
            ],
          ),
        ),
      ),
    );
  }
}
