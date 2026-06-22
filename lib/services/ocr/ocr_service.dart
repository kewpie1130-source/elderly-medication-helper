import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

// [邱靖喻] OCR 辨識服務，禁止其他組員修改
// 整合第零步備份的舊 OCR 邏輯
class OcrService {
  Future<String> recognizeText(XFile imageFile) async {
    final inputImage = InputImage.fromFilePath(imageFile.path);
    final recognizer = TextRecognizer(
      script: TextRecognitionScript.chinese,
    );

    try {
      final RecognizedText result = await recognizer.processImage(inputImage);
      return result.text;
    } catch (error) {
      debugPrint('OCR錯誤：$error');
      return '';
    } finally {
      await recognizer.close();
    }
  }
}
