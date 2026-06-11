import 'dart:io';
import 'package:flutter/material.dart';

class GeminiResultPage extends StatelessWidget {
  final File imageFile;
  final String geminiResult;

  const GeminiResultPage({
    super.key,
    required this.imageFile,
    required this.geminiResult,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'AI 白話化結果',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                imageFile,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.smart_toy, color: Color(0xFF2E7D32)),
                        SizedBox(width: 8),
                        Text(
                          'AI 分析結果',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Text(
                      geminiResult,
                      style: const TextStyle(fontSize: 16, height: 1.8),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.save, size: 24),
                label: const Text(
                  '儲存藥品資料',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  // TODO: 串接 Firebase
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('儲存功能即將完成！'),
                      backgroundColor: Color(0xFF2E7D32),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
