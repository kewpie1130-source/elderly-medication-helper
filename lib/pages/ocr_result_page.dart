import 'dart:io';
import 'package:flutter/material.dart';

// ✨ 這行就是先前多寫了單字導致網頁編譯失敗的地方，現在已經修正好囉！
class OcrResultPage extends StatefulWidget {
  final File imageFile;

  const OcrResultPage({super.key, required this.imageFile});

  @override
  State<OcrResultPage> createState() => _OcrResultPageState();
}

class _OcrResultPageState extends State<OcrResultPage> {
  final TextEditingController _textController = TextEditingController();
  final bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 預設填入模擬 OCR 辨識出來的文字成果
    _textController.text = """
衛署藥輸字第025432號
藥品名稱：立普妥膜衣錠 10毫克 (Lipitor 10mg)
適應症：高膽固醇血症、高三酸甘油脂血症。
用法用量：每日一次，每次一片。建議於早餐後配水服用。
警語：孕婦禁用。若出現不明原因肌肉疼痛請立即就醫。""";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('確認辨識文字')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('AI 辨識出的文字（如有錯誤可點擊直接修改）：',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      maxLines: null,
                      expands: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('已鎖定文字！下週將交由 Gemini 進行白話化處理...')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 55),
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('確認文字，下一步送交 AI 分析', style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ],
              ),
            ),
    );
  }
}