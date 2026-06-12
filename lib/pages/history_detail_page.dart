import 'package:flutter/material.dart';

import '../models/analytics_model.dart';

class HistoryDetailPage extends StatelessWidget {
  final String categoryName;
  final List<AnalyticsData> data;

  const HistoryDetailPage({
    super.key,
    required this.categoryName,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('詳細紀錄: $categoryName')),
      body: ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          final item = data[index];
          return ListTile(
            leading: Icon(
              item.missedCount > 0 ? Icons.warning : Icons.check_circle,
              color: item.missedCount > 0 ? Colors.red : Colors.green,
            ),
            title: Text('個案: ${item.ageGroup} / ${item.gender}'),
            subtitle: Text('完成率: ${(item.completionRate * 100).toInt()}%'),
            trailing: Text('異常: ${item.missedCount} 筆'),
          );
        },
      ),
    );
  }
}
