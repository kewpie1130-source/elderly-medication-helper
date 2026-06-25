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

  Future<List<MedicineModel>> parseOcrResult(String ocrText) async {
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
- indication：適應症（此藥品用於治療什麼症狀，用白話文說明，如：感冒、發燒、高血壓、胃痛、補充鈣質等，若無法判斷填空字串）
- startDate：開始日期（無法判斷填空字串）
- endDate：預計用完日期（無法判斷填空字串）

重要：絕對不要包含姓名、醫院名稱、診所名稱等個人資訊。
只回傳 JSON，不要其他任何文字。

請辨識圖片中的藥袋/藥盒/保健食品外包裝，
一張圖片中可能包含多種藥品，
請針對每一種藥品分別建立一筆資料，
重要說明：即使OCR文字裡沒有明確寫出「適應症」或「副作用/注意事項」，
你仍然必須根據「藥品名稱」本身的醫學知識，主動推斷並填寫：
- indication欄位：根據藥名判斷這個藥通常用於治療什麼症狀
  （例如：普拿疼類藥物通常用於止痛退燒）
- notice欄位：根據藥名判斷常見的副作用或服用注意事項
  （例如：可能引起嗜睡、避免空腹服用等）
只有在你完全無法辨識出藥品名稱、無法判斷其用途時，
才將該欄位留空字串，否則都應該根據藥名盡力填寫合理的醫學資訊。

並回傳一個JSON陣列（即使只有一種藥品，也要包成陣列），
格式為：
[
  { "name": "...", "type": "...", "dosage": "...",
    "frequency": "...", "timing": [...], "notice": "...",
    "indication": "...", "startDate": "...", "endDate": "..." }
]
不要用markdown格式，只回傳純JSON陣列，不要有其他文字說明。

OCR 文字：
$ocrText
''';

    http.Response? response;
    int attempts = 0;
    const maxAttempts = 3;

    while (attempts < maxAttempts) {
      attempts++;
      response = await http.post(
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

      if (response.statusCode == 200) break;

      if ((response.statusCode == 503 || response.statusCode == 429) &&
          attempts < maxAttempts) {
        await Future.delayed(const Duration(milliseconds: 1500));
        continue;
      }

      break;
    }

    if (response == null || response.statusCode != 200) {
      throw Exception('Gemini API 錯誤：${response?.statusCode}（已重試$attempts次）');
    }

    final data = jsonDecode(response.body);
    final text =
        data['candidates'][0]['content']['parts'][0]['text'] as String;
    final cleanJson = text
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();
    final decoded = jsonDecode(cleanJson);
    final List<dynamic> list = decoded is List ? decoded : [decoded];

    return list.map((item) {
      final m = item as Map<String, dynamic>;
      return MedicineModel(
        id: const Uuid().v4(),
        name: m['name'] ?? '',
        type: m['type'] ?? '',
        dosage: m['dosage'] ?? '',
        frequency: m['frequency'] ?? '',
        timing: List<String>.from(m['timing'] ?? []),
        notice: m['notice'] ?? '',
        indication: m['indication'] ?? '',
        startDate: m['startDate'] ?? '',
        endDate: m['endDate'] ?? '',
        imagePath: '',
        createdAt: DateTime.now().toIso8601String(),
      );
    }).toList();
  }
}
