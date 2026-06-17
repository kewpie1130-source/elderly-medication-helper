import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("健康趨勢分析", style: TextStyle(fontSize: AppTheme.titleFontSize)),
        backgroundColor: AppTheme.primary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 模擬數據卡片
          _buildDataCard("今日服藥率", "85%", Icons.check_circle_outline),
          const SizedBox(height: 16),
          _buildDataCard("本週服藥趨勢", "穩定成長", Icons.trending_up),
          const SizedBox(height: 16),
          _buildDataCard("待服藥提醒", "3 次", Icons.alarm),
        ],
      ),
    );
  }

  Widget _buildDataCard(String title, String value, IconData icon) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 3,
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primary, size: 40),
        title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        trailing: Text(value, style: const TextStyle(fontSize: 20, color: AppTheme.primary, fontWeight: FontWeight.bold)),
      ),
    );
  }
}