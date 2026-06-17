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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("設定", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primary,
      ),
      body: ListView(
        children: [
          _buildHeader(),
          const Divider(thickness: 1),
          _buildSettingsItem(Icons.login, "登入 / 登出", () {}),
          _buildSettingsItem(Icons.person_outline, "使用者資訊", () {}),
          _buildSettingsItem(Icons.contacts, "聯絡人設定", () {}),
          _buildSettingsItem(Icons.language, "語言設定: \", () {
            _showLanguageDialog();
          }),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 60)),
          const SizedBox(height: 16),
          const Text("您好！健康樂活", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              // 之後可串接 ImagePicker 套件
              print("開啟相簿更改大頭貼");
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
            child: const Text("更改大頭貼"),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primary, size: 30),
      title: Text(title, style: const TextStyle(fontSize: 18)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
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
