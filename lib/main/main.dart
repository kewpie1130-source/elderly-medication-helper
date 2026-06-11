import 'package:flutter/material.dart';
// 因為檔案在 lib/main/ 下，要往上跳一層到 lib，再進入 admin_dashboard
import '../admin_dashboard/admin_dashboard_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'D組後台',
      home: AdminDashboardPage(),
    );
  }
}