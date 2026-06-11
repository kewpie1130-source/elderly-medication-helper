import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/chart_service.dart';
import '../models/analytics_model.dart';
import '../pages/history_detail_page.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final ChartService _chartService = ChartService();
  List<AnalyticsData> _analyticsData = [];
  bool _isLoading = true;
  String _dateRange = "本週"; // 新增篩選狀態

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await _chartService.getMockAnalytics();
    if (mounted) {
      setState(() {
        _analyticsData = data;
        _isLoading = false;
      });
    }
  }

  // 1. 異常警示樣式：如果異常數 > 0，卡片變紅
  Widget _buildStatCard(String title, String value, Color color, {bool isWarning = false}) {
    return Card(
      elevation: 4,
      color: isWarning ? Colors.red.shade50 : null,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isWarning) const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20),
          Text(title, style: const TextStyle(fontSize: 14)),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildSplitCategoryList() {
    return Row(
      children: [
        Expanded(child: _buildCategoryCard("藥品 (病名)", "medicine")),
        Expanded(child: _buildCategoryCard("保健食品", "supplement")),
      ],
    );
  }

  Widget _buildCategoryCard(String title, String type) {
    final filtered = _analyticsData.where((e) => e.itemType == type).take(5);
    return Card(
      margin: const EdgeInsets.all(10),
      child: Column(
        children: [
          Padding(padding: const EdgeInsets.all(10), child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold))),
          ...filtered.map((e) => ListTile(
            title: Text(e.category, style: const TextStyle(fontSize: 12)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 12),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => 
              HistoryDetailPage(categoryName: e.category, data: _analyticsData.where((d) => d.category == e.category).toList()))),
          )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int totalMissed = _analyticsData.fold(0, (p, e) => p + e.missedCount);
    
    return Scaffold(
      appBar: AppBar(
        title: Text("D組 - 後台管理系統 ($_dateRange)"),
        actions: [
          // 2. 日期篩選功能
          PopupMenuButton<String>(
            icon: const Icon(Icons.calendar_today),
            onSelected: (val) => setState(() => _dateRange = val),
            itemBuilder: (context) => ["本週", "上週", "本月"].map((r) => PopupMenuItem(value: r, child: Text(r))).toList(),
          )
        ],
      ),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              height: 100,
              child: Row(
                children: [
                  Expanded(child: _buildStatCard("樣本總數", "${_analyticsData.length} 組", Colors.blue)),
                  Expanded(child: _buildStatCard("平均完成率", "${(_analyticsData.fold(0.0, (p, e) => p + e.completionRate) / _analyticsData.length * 100).toInt()}%", Colors.green)),
                  // 異常總數加入警告樣式
                  Expanded(child: _buildStatCard("異常總數", "$totalMissed 筆", Colors.red, isWarning: totalMissed > 0)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildSplitCategoryList(),
            SizedBox(
              height: 350,
              child: Card(
                margin: const EdgeInsets.symmetric(vertical: 20),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(40, 40, 24, 40),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Positioned(left: -30, top: -35, child: Text("完成率 (%)", style: TextStyle(fontWeight: FontWeight.bold))),
                      LineChart(LineChartData(
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, interval: 10, reservedSize: 35)),
                          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) => Text(['週一','週二','週三','週四','週五'][v.toInt() % 5]))),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: _analyticsData.asMap().entries.map((e) => FlSpot(e.key.toDouble() % 5, e.value.completionRate * 100)).toList(),
                            isCurved: true, color: Colors.blue, dotData: const FlDotData(show: true),
                          ),
                        ],
                      )),
                      const Positioned(right: 0, bottom: -20, child: Text("日期", style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}