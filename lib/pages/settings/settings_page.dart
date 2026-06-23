import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<Map<String, String>> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'userName': prefs.getString('userName') ?? '未設定',
      'lineId': prefs.getString('lineId') ?? '未設定',
    };
  }

  Future<void> _saveData(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  void _showEditDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    showDialog(context: context, builder: (_) => AlertDialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), title: const Text("編輯名稱"), content: TextField(controller: controller), actions: [TextButton(onPressed: () async { await _saveData('userName', controller.text); if(context.mounted) Navigator.pop(context); }, child: const Text("儲存"))]));
  }

  void _showContactDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    showDialog(context: context, builder: (_) => AlertDialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), title: const Text("編輯LINE ID"), content: TextField(controller: controller), actions: [TextButton(onPressed: () async { await _saveData('lineId', controller.text); if(context.mounted) Navigator.pop(context); }, child: const Text("儲存"))]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("設定")),
      body: FutureBuilder<Map<String, String>>(
        future: _loadData(),
        builder: (context, snapshot) {
          final data = snapshot.data ?? {'userName': '載入中...', 'lineId': '載入中...'};
          return ListView(
            children: [
              ListTile(title: const Text("使用者名稱"), subtitle: Text(data['userName']!), onTap: () => _showEditDialog(context)),
              ListTile(title: const Text("LINE ID"), subtitle: Text(data['lineId']!), onTap: () => _showContactDialog(context)),
              ListTile(title: const Text("登出"), onTap: () => Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false)),
            ],
          );
        },
      ),
    );
  }
}
