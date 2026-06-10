import 'package:flutter/material.dart'; // ✅ 確保開頭是標準的 import
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application_1/firebase_options.dart';
import 'package:flutter_application_1/services/.gitkeep/database_test_service.dart';

void main() async {
  // 1. 確保 Flutter 引擎元件已完全初始化
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. 正式初始化 Firebase 雲端連接
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  print("🔥 正在啟動 6/12 C同學 資料庫整合測試...");
  
  // 3. 執行我們寫好的時段打卡、防重複服用與實體通知測試
  await DatabaseTestService().runFullPipelineTest();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) { // ✅ 修正為小寫 c
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(
            '用藥助手測試中\n請查看瀏覽器主控台與通知提示',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}