import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _currentLanguage = "繁體中文";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text("設定", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 使用者資訊區塊
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const CircleAvatar(radius: 35, backgroundColor: AppTheme.primary, child: Icon(Icons.person, size: 40, color: Colors.white)),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("使用者名稱", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      GestureDetector(
                        onTap: () => print("跳轉至編輯個人資料"),
                        child: const Text("編輯個人資料", style: TextStyle(fontSize: 16, color: Colors.grey)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // 設定清單
          _buildSettingsTile(Icons.login, "登入 / 登出", () => print("執行登入/登出")),
          _buildSettingsTile(Icons.image, "大頭貼更改", () => print("開啟相簿")),
          _buildSettingsTile(Icons.contacts, "聯絡人設定", () => print("設定 LINE 聯絡人")),
          _buildSettingsTile(Icons.notifications_active, "通知偏好設定", () => print("進入通知設定")),
          _buildSettingsTile(Icons.text_fields, "調整字體大小", () => print("調整字體")),
          _buildSettingsTile(Icons.language, "語言設定: ", _showLanguageDialog),
          _buildSettingsTile(Icons.info_outline, "關於與隱私權", () => print("查看關於頁")),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, VoidCallback onTap) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Icon(icon, color: AppTheme.primary, size: 32),
        title: Text(title, style: const TextStyle(fontSize: 18)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
        onTap: onTap,
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("選擇語言"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ["繁體中文", "English"].map((lang) => ListTile(
            title: Text(lang),
            onTap: () {
              setState(() => _currentLanguage = lang);
              Navigator.pop(context);
            },
          )).toList(),
        ),
      ),
    );
  }
}
