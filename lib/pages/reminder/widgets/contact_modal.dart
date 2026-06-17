import 'package:flutter/material.dart';

class ContactModal extends StatefulWidget {
  const ContactModal({super.key});

  @override
  State<ContactModal> createState() => _ContactModalState();
}

class _ContactModalState extends State<ContactModal> {
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
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actions: [
        SizedBox(
          width: screenWidth * 0.35, height: 60,
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            child: const Text('取消', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ),
        ),
        SizedBox(
          width: screenWidth * 0.4, height: 60,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            onPressed: _isSaving ? null : () async {
              if (!_formKey.currentState!.validate()) return;
              setState(() => _isSaving = true);
              await Future.delayed(const Duration(milliseconds: 500));
              if (mounted) Navigator.of(context).pop(_textController.text.trim());
            },
            child: const Text('確定綁定', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}