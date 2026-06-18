import 'package:flutter/material.dart';

class ContactModal extends StatefulWidget {
  final Function(String) onSave;

  const ContactModal({
    super.key,
    required this.onSave,
  });

  @override
  State<ContactModal> createState() => _ContactModalState();
}

class _ContactModalState extends State<ContactModal> {
  final TextEditingController _textController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _showInputForm = false; // 控制是否進入第二階段輸入 LINE ID

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    // 階段二：如果長者點了「是，前往設定」，就展現輸入 LINE ID 的輸入框
    if (_showInputForm) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
        title: const Row(
          children: [
            Icon(Icons.person_add, color: Color(0xFF4CAF50), size: 32),
            SizedBox(width: 12),
            Text('請輸入聯絡人 LINE', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ],
        ),
        content: SizedBox(
          width: screenWidth * 0.85,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _textController,
                  style: const TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                    labelText: '照護者 LINE ID / Token',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    prefixIcon: const Icon(Icons.link, color: Color(0xFF4CAF50)),
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty) ? '❌ 請填寫此欄位' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OutlinedButton(
                onPressed: () => setState(() => _showInputForm = false),
                child: const Text('返回'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50), foregroundColor: Colors.white),
                onPressed: () {
                  if (!_formKey.currentState!.validate()) return;
                  widget.onSave(_textController.text.trim());
                  Navigator.of(context).pop();
                },
                child: const Text('儲存綁定'),
              ),
            ],
          )
        ],
      );
    }

    // 階段一：100% 还原官方設計圖畫面 8
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.0)),
      backgroundColor: Colors.white,
      contentPadding: const EdgeInsets.all(28.0),
      content: SizedBox(
        width: screenWidth * 0.85,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. 官方設計圖綠色雙人圖標
            const CircleAvatar(
              radius: 40,
              backgroundColor: Color(0xFFE8F5E9),
              child: Icon(Icons.people, color: Color(0xFF4CAF50), size: 50),
            ),
            const SizedBox(height: 24),
            
            // 2. 官方標題：是否要通知聯絡人？
            const Text(
              '是否要通知聯絡人？',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            
            // 3. 官方副標題
            const Text(
              '設定後，提醒訊息將傳送至\n聯絡人的 LINE',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.black54, height: 1.4),
            ),
            const SizedBox(height: 32),
            
            // 4. 按鈕 1：是，前往設定（綠底大按鈕）
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                onPressed: () {
                  setState(() {
                    _showInputForm = true; // 切換到第二階段輸入
                  });
                },
                child: const Text('是，前往設定', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 12),
            
            // 5. 按鈕 2：不需要（灰底大按鈕）
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEEEEEE),
                  foregroundColor: Colors.black54,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('不需要', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}