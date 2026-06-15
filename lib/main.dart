import 'package:flutter/material.dart';

import 'navigation/app_router.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
