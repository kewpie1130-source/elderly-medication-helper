import 'dart:io';

import 'package:flutter/material.dart';

import '../services/gemini_service.dart';
import 'gemini_result_page.dart';

typedef MedicineImageAnalyzer = Future<String> Function(File imageFile);

class OcrResultPage extends StatefulWidget {
  final File imageFile;
  final MedicineImageAnalyzer? analyzer;

  const OcrResultPage({super.key, required this.imageFile, this.analyzer});

  @override
  State<OcrResultPage> createState() => _OcrResultPageState();
}

class _OcrResultPageState extends State<OcrResultPage> {
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _analyzeImage();
  }

  Future<void> _analyzeImage() async {
    setState(() => _errorMessage = null);

    try {
      final analyzer = widget.analyzer ?? GeminiService().analyzeMedicineImage;
      final result = await analyzer(widget.imageFile);

      if (!mounted) return;
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => GeminiResultPage(
            imageFile: widget.imageFile,
            geminiResult: result,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        title: const Text(
          'OCR 影像辨識',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _errorMessage == null
              ? const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF2E7D32)),
                    SizedBox(height: 24),
                    Text(
                      '正在辨識圖片中的用藥資訊...',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '請稍候，不要關閉此頁面',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 72,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '辨識失敗',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _analyzeImage,
                        icon: const Icon(Icons.refresh),
                        label: const Text(
                          '重新辨識',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
