import 'package:flutter/material.dart';

import '../pages/camera/camera_page.dart';
import '../pages/gallery/gallery_page.dart';
import '../pages/settings/settings_page.dart';
import '../theme/app_theme.dart';

// [邱靖喻] 全組統一導覽結構
// 禁止其他組員修改此檔案結構
// 各組員只需將 Placeholder 替換為自己的頁面
class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = [
    CameraPage(),
    _PlaceholderPage(label: '紀錄頁', assignee: '組員A'),
    _PlaceholderPage(label: '提醒頁', assignee: '組員B'),
    GalleryPage(),
    SettingsPage(),
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
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: '拍攝',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: '紀錄',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.alarm),
            label: '提醒',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_library),
            label: '相簿',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '設定',
          ),
        ],
      ),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  final String label;
  final String assignee;

  const _PlaceholderPage({
    required this.label,
    required this.assignee,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          '$label\n由 $assignee 實作中',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: AppTheme.bodyFontSize,
          ),
        ),
      ),
    );
  }
}
