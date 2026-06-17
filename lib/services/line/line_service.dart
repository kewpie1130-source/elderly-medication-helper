import 'dart:convert';
import 'package:http/http.dart' as http;

class LineService {
  static final LineService _instance = LineService._internal();
  factory LineService() => _instance;
  LineService._internal();

  final String _channelAccessToken = 'YOUR_LINE_CHANNEL_ACCESS_TOKEN';
  String? _targetUserId;

  void setTargetUserId(String userId) {
    _targetUserId = userId;
  }

  Future<bool> sendNotification(String messageText) async {
    if (_targetUserId == null || _targetUserId!.isEmpty || _targetUserId == 'YOUR_LINE_CHANNEL_ACCESS_TOKEN') {
      return false;
    }

    final url = Uri.parse('https://api.line.me/v2/bot/message/push');
    
    final Map<String, dynamic> requestBody = {
      'to': _targetUserId,
      'messages': [
        {
          'type': 'text',
          'text': messageText,
        }
      ]
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_channelAccessToken',
        },
        body: jsonEncode(requestBody),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> notifyMedicationTaken({
    required String elderName,
    required String medicineName,
    required String time,
  }) {
    final String message = "💚【智慧用藥助手 - 服藥回報】\n\n您的家人 $elderName 已經在 $time 準時服用【$medicineName】囉！請照護者放心。";
    return sendNotification(message);
  }

  Future<bool> notifyMedicationMissed({
    required String elderName,
    required String medicineName,
    required String scheduledTime,
  }) {
    final String message = "⚠️【智慧用藥助手 - 緊急提醒】\n\n注意：您的家人 $elderName 預計於 $scheduledTime 服用的【$medicineName】，目前「逾時未服藥打卡」，請盡快關心狀況！";
    return sendNotification(message);
  }
}