// 執行方式：
// flutter run --dart-define=GEMINI_API_KEY=你的真實Key

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../../models/medicine_model.dart';

// [邱靖喻] Gemini AI 解析服務，禁止其他組員修改
class GeminiService {
  static const String _apiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );
  // TODO [邱靖喻]：flutter run 前填入真實 API Key

  static const String _endpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/'
      'gemini-2.5-flash:generateContent?key=$_apiKey';

  Future<MedicineModel> parseOcrResult(String ocrText) async {
    if (ocrText.trim().isEmpty) {
      throw Exception('OCR 結果為空，無法解析');
    }

    final prompt = '''
你是一個藥品資訊解析助手。
以下是從藥袋、藥盒或保健食品外包裝辨識出的文字。
請解析後只回傳 JSON 格式，不要加任何說明文字或 markdown 符號。

JSON 欄位：
- name：藥品或保健食品名稱
- type：類型（處方藥 / 指示藥 / 保健食品）
- dosage：每次劑量
- frequency：服用頻率（如：每日三次）
- timing：服用時間 array（如：["早餐後","午餐後","晚餐後"]）
- notice：注意事項或禁忌
- startDate：開始日期（無法判斷填空字串）
- endDate：預計用完日期（無法判斷填空字串）

重要：絕對不要包含姓名、醫院名稱、診所名稱等個人資訊。
只回傳 JSON，不要其他任何文字。

OCR 文字：
$ocrText
''';

    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt},
            ],
          },
        ],
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Gemini API 錯誤：${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    final text =
        data['candidates'][0]['content']['parts'][0]['text'] as String;
    final cleanJson = text
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();
    final map = jsonDecode(cleanJson) as Map<String, dynamic>;

    return MedicineModel(
      id: const Uuid().v4(),
      name: map['name'] ?? '',
      type: map['type'] ?? '',
      dosage: map['dosage'] ?? '',
      frequency: map['frequency'] ?? '',
      timing: List<String>.from(map['timing'] ?? []),
      notice: map['notice'] ?? '',
      startDate: map['startDate'] ?? '',
      endDate: map['endDate'] ?? '',
      imagePath: '',
      createdAt: DateTime.now().toIso8601String(),
    );
  }
}
