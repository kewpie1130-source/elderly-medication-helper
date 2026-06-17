import 'package:flutter/material.dart';
import 'package:elderly_medication_helper/theme/app_theme.dart';
// 1. 引入組員 A 實作的歷史紀錄頁
import 'package:elderly_medication_helper/pages/history/history_page.dart'; 
// 引入其他組員負責的頁面（此處根據標準專案結構模擬，請保留原有的 import）
import 'package:elderly_medication_helper/pages/camera/camera_page.dart';
import 'package:elderly_medication_helper/pages/reminder/reminder_page.dart';
import 'package:elderly_medication_helper/pages/gallery/gallery_page.dart';
import 'package:elderly_medication_helper/pages/settings/settings_page.dart';

class AppRouter extends StatefulWidget {
  const AppRouter({Key? key}) : super(key: key);

  @override
  State<AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<AppRouter> {
  int _currentIndex = 1; // 預設停在紀錄頁方便你們目前進行實機測試

  // 2. 核心修正：將各分頁對應的 Widget 串接起來
  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        // 首頁 - 拍攝辨識頁（組員 B / C 守備範圍）
        return const CameraPage(); 
      case 1:
        // 紀錄頁 - 歷史紀錄頁（組員 A 守備範圍，完美對齊 ui_reference.png）
        return const HistoryPage(); 
      case 2:
        // 提醒頁（組員 B 守備範圍）
        return const ReminderPage();
      case 3:
        // 相簿頁（組員 C 守備範圍）
        return const GalleryPage();
      case 4:
        // 設定頁（共通/其餘組員守備範圍）
        return const SettingsPage();
      default:
        return const HistoryPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: List.generate(5, (index) => _buildPage(index)),
      ),
      // 底部導覽列（對齊實機畫面的 5 個 Icons 順序與名稱）
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 14,
        unselectedFontSize: 14,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
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