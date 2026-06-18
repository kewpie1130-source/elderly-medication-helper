import 'package:flutter/material.dart';

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
        title: const Text(
          "設定", 
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)
        ),
        backgroundColor: const Color(0xFF4CAF50),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 3,
            child: ListTile(
              leading: const CircleAvatar(radius: 30, backgroundColor: Color(0xFF4CAF50), child: Icon(Icons.person, size: 30, color: Colors.white)),
              title: const Text("使用者名稱", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              subtitle: const Text("點擊編輯個人資料"),
              onTap: () => _handleNavigation("個人資料編輯"),
            ),
          ),
          const SizedBox(height: 24),
          _buildSettingsTile(Icons.login, "登出", () => _handleAction("登出系統")),
          _buildSettingsTile(Icons.contacts, "聯絡人設定", () => _handleNavigation("聯絡人設定")),
          _buildSettingsTile(Icons.notifications_active, "通知偏好設定", () => _handleNavigation("通知設定")),
          _buildSettingsTile(Icons.text_fields, "調整字體大小", () => _handleAction("調整字體")),
          _buildSettingsTile(Icons.language, "語言設定: \", _showLanguageDialog),
          _buildSettingsTile(Icons.info_outline, "關於與隱私權", () => _handleNavigation("關於頁")),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, VoidCallback onTap) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF4CAF50), size: 28),
        title: Text(title, style: const TextStyle(fontSize: 18)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  void _handleNavigation(String pageName) {
    print("導航至: \");
  }

  void _handleAction(String actionName) {
    print("執行動作: \");
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
