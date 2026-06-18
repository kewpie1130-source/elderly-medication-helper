import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart'; // ✅ 引入專案規格主題

class ContactModal extends StatefulWidget {
  final Function(String) onSave;
  final VoidCallback onCancel; // ✅ 修正編譯錯誤：實打實定義成員變數

  const ContactModal({
    super.key,
    required this.onSave,
    required this.onCancel, // ✅ 修正編譯錯誤：設為必填具名參數
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
        // ✅ 修正圓角：24.0 -> 一律改為符合規範的 20.0
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        backgroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(Icons.person_add, color: AppTheme.primary, size: 32), // ✅ 統一 AppTheme
            SizedBox(width: 12),
            Text('請輸入聯絡人 LINE', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
          ],
        ),
        content: SizedBox(
          width: screenWidth * 0.85,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('請輸入照護者的 LINE 唯一識別碼，系統將會在長者忘記服藥時主動通知。', style: TextStyle(fontSize: 16, color: AppTheme.textDark)),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _textController,
                  style: const TextStyle(fontSize: 18),
                  decoration: InputDecoration(
                    labelText: '請輸入聯絡人 LINE ID',
                    labelStyle: const TextStyle(color: AppTheme.textDark), // ✅ 統一 AppTheme
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppTheme.primary, width: 2), // ✅ 統一 AppTheme
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty) ? '❌ 請填寫此欄位' : null,
                ),
              ],
            ),
          ),
        ),
        actionsPadding: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: screenWidth * 0.32,
                child: OutlinedButton(
                  onPressed: () => setState(() => _showInputForm = false),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56), // ✅ 補齊無障礙 56px 最小高度
                    side: const BorderSide(color: Colors.grey, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('返回', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                ),
              ),
              SizedBox(
                width: screenWidth * 0.42,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56), // ✅ 補齊無障礙 56px 最小高度
                    backgroundColor: AppTheme.primary, // ✅ 統一 AppTheme
                    foregroundColor: Colors.white, 
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    if (!_formKey.currentState!.validate()) return;
                    widget.onSave(_textController.text.trim());
                    Navigator.of(context).pop();
                  },
                  child: const Text('儲存綁定', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          )
        ],
      );
    }

    return AlertDialog(
      // ✅ 修正圓角：28.0 -> 一律改為符合規範的 20.0
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      backgroundColor: Colors.white,
      contentPadding: const EdgeInsets.all(28.0),
      content: SizedBox(
        width: screenWidth * 0.85,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Color(0xFFE8F5E9),
              child: Icon(Icons.people, color: AppTheme.primary, size: 50), // ✅ 統一 AppTheme
            ),
            const SizedBox(height: 24),
            const Text('是否要通知聯絡人？', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
            const SizedBox(height: 16),
            const Text('設定後，提醒訊息將傳送至\n聯絡人的 LINE', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, color: AppTheme.textDark, height: 1.4)),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary, // ✅ 統一 AppTheme
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                onPressed: () => setState(() => _showInputForm = true),
                child: const Text('是，前往設定', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEEEEEE),
                  foregroundColor: AppTheme.textDark, // ✅ 統一 AppTheme
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                // ✅ 修正第 151 行：改為優先直接呼叫組長準備好的關閉回呼邏輯
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