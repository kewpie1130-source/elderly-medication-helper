import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../services/chart_service.dart';
import '../models/analytics_model.dart';
import 'history_detail_page.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final ChartService _chartService = ChartService();
  List<AnalyticsData> _analyticsData = [];
  bool _isLoading = true;
  String _dateRange = '本週';

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

  Widget _buildStatCard(
    String title,
    String value,
    Color color, {
    bool isWarning = false,
  }) {
    return Card(
      elevation: 4,
      color: isWarning ? Colors.red.shade50 : null,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isWarning)
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.red,
              size: 20,
            ),
          Text(title, style: const TextStyle(fontSize: 14)),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSplitCategoryList() {
    return Row(
      children: [
        Expanded(child: _buildCategoryCard('藥品 (病名)', 'medicine')),
        Expanded(child: _buildCategoryCard('保健食品', 'supplement')),
      ],
    );
  }

  Widget _buildCategoryCard(String title, String type) {
    final filtered = _analyticsData
        .where((item) => item.itemType == type)
        .take(5);
    return Card(
      margin: const EdgeInsets.all(10),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          ...filtered.map(
            (item) => ListTile(
              title: Text(item.category, style: const TextStyle(fontSize: 12)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 12),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => HistoryDetailPage(
                    categoryName: item.category,
                    data: _analyticsData
                        .where((data) => data.category == item.category)
                        .toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalMissed = _analyticsData.fold(
      0,
      (total, item) => total + item.missedCount,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard 分析 - 示範資料 ($_dateRange)'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.calendar_today),
            onSelected: (value) => setState(() => _dateRange = value),
            itemBuilder: (context) => ['本週', '上週', '本月']
                .map((range) => PopupMenuItem(value: range, child: Text(range)))
                .toList(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SizedBox(
                    height: 100,
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            '樣本總數',
                            '${_analyticsData.length} 組',
                            Colors.blue,
                          ),
                        ),
                        Expanded(
                          child: _buildStatCard(
                            '平均完成率',
                            '${(_analyticsData.fold(0.0, (total, item) => total + item.completionRate) / _analyticsData.length * 100).toInt()}%',
                            Colors.green,
                          ),
                        ),
                        Expanded(
                          child: _buildStatCard(
                            '異常總數',
                            '$totalMissed 筆',
                            Colors.red,
                            isWarning: totalMissed > 0,
                          ),
                        ),
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
                            const Positioned(
                              left: -30,
                              top: -35,
                              child: Text(
                                '完成率 (%)',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            LineChart(
                              LineChartData(
                                titlesData: FlTitlesData(
                                  leftTitles: const AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      interval: 10,
                                      reservedSize: 35,
                                    ),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) => Text(
                                        [
                                          '週一',
                                          '週二',
                                          '週三',
                                          '週四',
                                          '週五',
                                        ][value.toInt() % 5],
                                      ),
                                    ),
                                  ),
                                  topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  rightTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                ),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: _analyticsData
                                        .asMap()
                                        .entries
                                        .map(
                                          (entry) => FlSpot(
                                            entry.key.toDouble() % 5,
                                            entry.value.completionRate * 100,
                                          ),
                                        )
                                        .toList(),
                                    isCurved: true,
                                    color: Colors.blue,
                                    dotData: const FlDotData(show: true),
                                  ),
                                ],
                              ),
                            ),
                            const Positioned(
                              right: 0,
                              bottom: -20,
                              child: Text(
                                '日期',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
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
