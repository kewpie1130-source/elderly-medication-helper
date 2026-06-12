import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
void main() {
  test('發送 LINE 官方帳號真實測試', () async {
    const String channelAccessToken = 'XiIdc8AZa+gTVNpJT6Ygl6ZBekscA6w4ON8hKFdVnEGjMrB//z1fC/04YJIGbwVpz+AD8K9frH+mscEL+mVu0FImVvSfn2xZdOJtFBr4DCvt2uTzaBunWoh/jktXXLCwMGHRneU+jhn1sFHM5xJNdwdB04t89/1O/w1cDnyilFU=';
    const String targetUserId = 'Ud420232cfec36811d9f9d8397c0ed636';
    
    final url = Uri.parse('https://api.line.me/v2/bot/message/push');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $channelAccessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'to': targetUserId,
        'messages': [
          {
            'type': 'text',
            'text': '\n[恭喜通關] C 同學的 LINE 官方帳號推播模組測試成功！',
          }
        ],
      }),
    );

    print('📡 伺服器回應狀態碼: ${response.statusCode}');
    print('📡 伺服器回應內容: ${response.body}');
    
    expect(response.statusCode, 200);
  });
}