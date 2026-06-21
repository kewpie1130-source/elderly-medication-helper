import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("設定", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF4CAF50),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 20),
          _buildSettingsItem(Icons.login, "登入", () {
            // TODO: 接上正式登入流程。
          }),
          _buildSettingsItem(Icons.person, "使用者資訊編輯", () {}),
          _buildSettingsItem(Icons.contacts, "聯絡人設定", () {}),
          _buildSettingsItem(Icons.language, "語言設定", () {}),
          _buildSettingsItem(Icons.logout, "登出", () {}),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: const ListTile(
        leading: CircleAvatar(backgroundColor: Color(0xFF4CAF50), child: Icon(Icons.person, color: Colors.white)),
        title: Text("使用者名稱", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        subtitle: Text("編輯個人檔案"),
      ),
    );
  }

  Widget _buildSettingsItem(IconData icon, String title, VoidCallback onTap) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF4CAF50)),
        title: Text(title, style: const TextStyle(fontSize: 16)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
