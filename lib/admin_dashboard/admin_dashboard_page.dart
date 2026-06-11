import 'package:flutter/material.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("D組 - 後台管理系統"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: GridView.count(
          crossAxisCount: 3, // 設定每行顯示 3 個統計卡片
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: [
            _buildStatCard("總用藥人數", "128 人", Colors.blue),
            _buildStatCard("今日服藥達成率", "85%", Colors.green),
            _buildStatCard("異常警報", "3 件", Colors.red),
          ],
        ),
      ),
    );
  }

  // 建立統計卡片的小幫手函式
  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      elevation: 4,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 10),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}