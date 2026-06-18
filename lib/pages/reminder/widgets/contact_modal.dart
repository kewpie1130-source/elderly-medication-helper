import 'package:flutter/material.dart';

class ContactModal extends StatefulWidget {
  final Function(String) onSave;
  final VoidCallback onCancel; // ✅ 實打實補上這個遺漏的參數！

  const ContactModal({
    super.key,
    required this.onSave,
    required this.onCancel, // ✅ 納入建構子
  });

  @override
  State<ContactModal> createState() => _ContactModalState();
}

class _ContactModalState extends State<ContactModal> {
  final TextEditingController _textController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _showInputForm = false; 

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

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
            child: TextFormField(
              controller: _textController,
              decoration: InputDecoration(
                labelText: '請輸入聯絡人 LINE ID',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
              validator: (value) => (value == null || value.trim().isEmpty) ? '❌ 請填寫此欄位' : null,
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

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.0)),
      content: SizedBox(
        width: screenWidth * 0.85,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Color(0xFFE8F5E9),
              child: Icon(Icons.people, color: Color(0xFF4CAF50), size: 50),
            ),
            const SizedBox(height: 24),
            const Text('是否要通知聯絡人？', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text('設定後，提醒訊息將傳送至\n聯絡人的 LINE', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, color: Colors.black54)),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50), foregroundColor: Colors.white),
                onPressed: () => setState(() => _showInputForm = true),
                child: const Text('是，前往設定', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEEEEEE), foregroundColor: Colors.black54),
                // ✅ 100% 呼叫外層傳入的 onCancel，完美串接雙 pop 路由流程！
                onPressed: widget.onCancel, 
                child: const Text('不需要', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}