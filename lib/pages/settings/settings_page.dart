import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("設定", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primary,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        children: [
          _buildHeader(),
          const Divider(thickness: 1, height: 30),
          _buildSettingsItem(Icons.login, "登入 / 登出"),
          _buildSettingsItem(Icons.person_outline, "使用者資訊"),
          _buildSettingsItem(Icons.image, "大頭貼更改"),
          _buildSettingsItem(Icons.contacts, "聯絡人設定"),
          _buildSettingsItem(Icons.language, "語言設定 (中文繁體)"),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 60)),
        const SizedBox(height: 16),
        const Text("您好！健康樂活", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
          child: const Text("更改大頭貼"),
        ),
      ],
    );
  }

  Widget _buildSettingsItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primary, size: 30),
      title: Text(title, style: const TextStyle(fontSize: 18)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {},
    );
  }
}
