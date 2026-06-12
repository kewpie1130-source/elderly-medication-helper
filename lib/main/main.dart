import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // 1. 記得引入這個
import '../admin_dashboard/admin_dashboard_page.dart';
import 'firebase_options.dart'; // 2. 這是你執行 flutterfire configure 後產生的檔案

void main() async {
  // 3. 確保 Flutter 引擎啟動完成
  WidgetsFlutterBinding.ensureInitialized();
  
  // 4. 初始化 Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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