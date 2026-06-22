import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("設定")),
      body: ListView(
        children: [
          ListTile(title: const Text("使用者資訊編輯"), onTap: () => _showEditDialog(context)),
          ListTile(title: const Text("聯絡人設定"), onTap: () => _showContactDialog(context)),
          ListTile(title: const Text("語言設定"), onTap: () => _showLanguageDialog(context)),
          ListTile(title: const Text("登出"), onTap: () => _showLogoutDialog(context)),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    showDialog(context: context, builder: (_) => AlertDialog(title: const Text("編輯名稱"), content: const TextField(), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("儲存"))]));
  }

  void _showContactDialog(BuildContext context) {
    showDialog(context: context, builder: (_) => AlertDialog(title: const Text("輸入聯絡人 LINE ID"), content: const TextField()));
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(context: context, builder: (_) => SimpleDialog(title: const Text("選擇語言"), children: [SimpleDialogOption(child: const Text("繁體中文")), SimpleDialogOption(child: const Text("English"))]));
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(context: context, builder: (_) => AlertDialog(title: const Text("確定要登出嗎？"), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("確定"))]));
  }
}
