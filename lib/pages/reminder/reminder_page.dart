import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../services/tts/tts_service.dart';
import '../../services/notification/notification_service.dart';
import '../../services/line/line_service.dart';
import 'widgets/reminder_modal.dart';
import 'widgets/contact_modal.dart';

class ReminderPage extends StatefulWidget {
  const ReminderPage({super.key});

  @override
  State<ReminderPage> createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  // 正確初始化三大核心防區服務
  final TtsService _ttsService = TtsService();
  final NotificationService _notificationService = NotificationService();
  final LineService _lineService = LineService();

  @override
  void initState() {
    super.initState();
    // 初始化語音與通知服務
    _ttsService.initTts();
    _notificationService.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      app_row_bar: AppBar(
        title: const Text('長者服藥提醒', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 測試按鈕 1：觸發吃藥提醒雙彈窗
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(250, 80),
                backgroundColor: Colors.orange,
              ),
              onPressed: () {
                _ttsService.speak("阿公，吃藥時間到囉！請服用降血壓藥一顆。");
                showDialog(
                  context: context,
                  builder: (context) => ReminderModal(
                    medicineName: "降血壓藥",
                    dosage: "1 顆",
                    onSave: (chosenTime) async {
                      debugPrint("長者選擇的服藥時間: $chosenTime");
                    },
                  ),
                );
              },
              child: const Text('測試服藥提醒彈窗', style: TextStyle(fontSize: 22, color: Colors.white)),
            ),
            const SizedBox(height: 30),
            
            // 測試按鈕 2：觸發 LINE 照護者綁定彈窗
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(250, 80),
                backgroundColor: Colors.green,
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => ContactModal(
                    onSave: (String lineUserId) {
                      debugPrint("成功綁定照護者 LINE ID: $lineUserId");
                    },
                  ),
                );
              },
              child: const Text('測試 LINE 綁定彈窗', style: TextStyle(fontSize: 22, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}