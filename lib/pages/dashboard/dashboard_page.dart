import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'dashboard_data.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  DashboardAnalytics _getMockData() {
    return DashboardAnalytics(
      totalTaken: 85,
      totalMissed: 5,
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = _getMockData();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text("用藥統計儀表板", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildDataCard("服藥達成率", "\%", Icons.check_circle_outline),
          const SizedBox(height: 16),
          _buildDataCard("今日已服藥", "\ 次", Icons.trending_up),
          const SizedBox(height: 16),
          _buildDataCard("今日未服藥", "\ 次", Icons.alarm),
        ],
      ),
    );
  }

  Widget _buildDataCard(String title, String value, IconData icon) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListTile(
          leading: Icon(icon, color: AppTheme.primary, size: 40),
          title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          trailing: Text(value, style: const TextStyle(fontSize: 20, color: AppTheme.primary, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
