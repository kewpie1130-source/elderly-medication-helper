import 'package:flutter/material.dart';
import '../pages/camera/camera_page.dart';
import '../pages/dashboard/dashboard_page.dart'; // 匯入儀表板
import '../pages/settings/settings_page.dart';   // 匯入設定頁
import '../theme/app_theme.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _selectedIndex = 0;

  // 將原本的 Placeholder 替換為實際頁面
  final List<Widget> _pages = [
    const CameraPage(),
    const DashboardPage(), // 替換為你的儀表板 (紀錄頁位置)
    _PlaceholderPage(label: '提醒頁', assignee: '組員B'),
    _PlaceholderPage(label: '相簿頁', assignee: '組員C'),
    const SettingsPage(),  // 替換為你的設定頁
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
        selectedItemColor: AppTheme.primary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: '拍攝'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: '紀錄'),
          BottomNavigationBarItem(icon: Icon(Icons.alarm), label: '提醒'),
          BottomNavigationBarItem(icon: Icon(Icons.photo_library), label: '相簿'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '設定'),
        ],
      ),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  final String label;
  final String assignee;

  const _PlaceholderPage({required this.label, required this.assignee});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('$label\n由 $assignee 實作中', textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
      ),
    );
  }
}