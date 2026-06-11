import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class GeminiService {
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

  Future<String> analyzeMedicineImage(File imageFile) async {
    final apiKey = AppConfig.geminiApiKey;
    if (apiKey.isEmpty) throw Exception('Gemini API Key 未設定');

    final imageBytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(imageBytes);
    final mimeType = 'image/jpeg';

    final prompt = '''
這是一張藥袋、藥盒或保健食品包裝的照片，請辨識圖片中的文字，並用繁體中文、白話文整理成以下格式：

【藥品／保健品名稱】
【用法用量】
【服用時間】
【注意事項】
【副作用（如有）】

如果圖片不清楚或無法辨識，請說明原因。
''';

    final response = await http.post(
      Uri.parse('$_baseUrl?key=$apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {
                'inline_data': {'mime_type': mimeType, 'data': base64Image},
              },
              {'text': prompt},
            ],
          },
        ],
        'generationConfig': {'temperature': 0.3, 'maxOutputTokens': 1024},
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text'] as String;
    } else {
      throw Exception('Gemini API 錯誤：${response.statusCode}\n${response.body}');
    }
  }
}
