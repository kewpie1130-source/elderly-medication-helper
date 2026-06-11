import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  Future<String> recognizeText(File imageFile) async {
    debugPrint('【OCR開始】imagePath=${imageFile.path}');
    final recognizer = TextRecognizer(script: TextRecognitionScript.chinese);
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final recognizedText = await recognizer.processImage(inputImage);
      final text = recognizedText.text.trim();
      debugPrint('【OCR結果】\n$text');
      return text;
    } finally {
      await recognizer.close();
    }
  }
}
