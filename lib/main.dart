import 'package:flutter/material.dart';
import 'admin_dashboard/admin_dashboard_page.dart';

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