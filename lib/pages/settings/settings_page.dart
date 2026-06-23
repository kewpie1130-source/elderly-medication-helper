import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> _saveData(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  void _showEditDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("編輯名稱", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
        content: TextField(controller: controller, decoration: const InputDecoration(hintText: "請輸入姓名")),
        actions: [
          TextButton(
            onPressed: () async {
              await _saveData('userName', controller.text);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("姓名已儲存！"), backgroundColor: Colors.green));
              }
            },
            child: const Text("儲存", style: TextStyle(color: Colors.green)),
          )
        ],
      ),
    );
  }

  void _showContactDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("輸入聯絡人 LINE ID", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
        content: TextField(controller: controller, decoration: const InputDecoration(hintText: "請輸入 ID")),
        actions: [
          TextButton(
            onPressed: () async {
              await _saveData('lineId', controller.text);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("LINE ID 已儲存！"), backgroundColor: Colors.green));
              }
            },
            child: const Text("儲存", style: TextStyle(color: Colors.green)),
          )
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => SimpleDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("選擇語言", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
        children: [
          SimpleDialogOption(child: const Text("繁體中文"), onPressed: () => Navigator.pop(context)),
          SimpleDialogOption(child: const Text("English"), onPressed: () => Navigator.pop(context))
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("確定要登出嗎？", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
        actions: [
          TextButton(onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false), child: const Text("確定", style: TextStyle(color: Colors.green))),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("取消", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

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
}
