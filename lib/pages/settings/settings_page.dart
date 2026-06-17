import 'package:flutter/material.dart';
import '../../theme/app_theme.dart'; 

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text("設定", style: TextStyle(fontSize: AppTheme.titleFontSize, fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 使用者資訊卡片
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.borderRadius)),
            elevation: AppTheme.cardElevation,
            child: const ListTile(
              leading: CircleAvatar(
                radius: 30,
                backgroundColor: AppTheme.primary,
                child: Icon(Icons.person, size: 40, color: Colors.white),
              ),
              title: Text("使用者名稱", style: TextStyle(fontSize: AppTheme.sectionFontSize, fontWeight: FontWeight.bold)),
              subtitle: Text("點擊編輯個人資料", style: TextStyle(fontSize: AppTheme.bodyFontSize)),
            ),
          ),
          const SizedBox(height: 20),
          
          // 設定清單
          _buildSettingsTile(Icons.notifications, "聯絡人設定", () {}),
          _buildSettingsTile(Icons.language, "語言設定", () {}),
          _buildSettingsTile(Icons.logout, "登出", () {}),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, VoidCallback onTap) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.borderRadius)),
      elevation: AppTheme.cardElevation,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primary, size: 30),
        title: Text(title, style: const TextStyle(fontSize: AppTheme.buttonFontSize)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
        onTap: onTap,
      ),
    );
  }
}