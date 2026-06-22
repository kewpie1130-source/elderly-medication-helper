import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          "設定",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.primary,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 20),
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
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 32,
              backgroundColor: AppTheme.primary,
              child: Icon(Icons.person, color: Colors.white, size: 34),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "使用者名稱",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "您好！健康樂活",
                    style: TextStyle(
                      fontSize: 15,
                      color: AppTheme.textDark,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: 接上更改大頭貼流程。
              },
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primary,
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: const Text("更改大頭貼"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem(IconData icon, String title, VoidCallback onTap) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primary),
        title: Text(title, style: const TextStyle(fontSize: 16)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
