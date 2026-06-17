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

class _ContactPageState extends State<ContactModal> {
  final TextEditingController _textController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
      title: const Row(
        children: [
          Icon(Icons.person_add, color: Colors.green, size: 36),
          SizedBox(width: 12),
          Text('綁定照護者 LINE', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
        ],
      ),
      content: SizedBox(
        width: screenWidth * 0.85,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('請輸入照護者的 LINE 唯一識別碼，系統將會在您忘記服藥時主動通知他們。', style: TextStyle(fontSize: 18, color: Colors.black54, height: 1.5)),
              const SizedBox(height: 20),
              TextFormField(
                controller: _textController,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  labelText: '照護者 LINE ID',
                  labelStyle: const TextStyle(fontSize: 18),
                  prefixIcon: const Icon(Icons.key, color: Colors.green),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.0)),
                ),
                validator: (value) => (value == null || value.trim().isEmpty) ? '❌ 請填寫此欄位' : null,
              ),
            ],
          ),
        ),
      ),
      // 核心修正：將原本散落的 actions 改用一個整齊的 Row 包裹，確保按鈕絕對水平完美平行！
      actionsPadding: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // 1. 取消按鈕
            SizedBox(
              width: screenWidth * 0.32, 
              height: 55,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.grey, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('取消', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54)),
              ),
            ),
            // 2. 確定綁定按鈕
            SizedBox(
              width: screenWidth * 0.42, 
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, 
                  foregroundColor: Colors.white, 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                ),
                onPressed: _isSaving ? null : () async {
                  if (!_formKey.currentState!.validate()) return;
                  setState(() => _isSaving = true);
                  widget.onSave(_textController.text.trim());
                  await Future.delayed(const Duration(milliseconds: 300));
                  if (mounted) Navigator.of(context).pop(_textController.text.trim());
                },
                child: const Text('確定綁定', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}