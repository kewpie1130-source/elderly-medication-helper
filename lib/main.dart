import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase/firebase_service.dart';
import 'navigation/app_router.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await FirebaseService.initialize();
  } catch (e) {
    print('Firebase初始化失敗（可能缺少google-services.json）: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '長者智慧用藥',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.appTheme,
      home: const MainNavigationPage(),
    );
  }
}
