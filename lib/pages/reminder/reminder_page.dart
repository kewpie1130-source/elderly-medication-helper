import 'package:flutter/material.dart';
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
  // 正確初始化三大核心防區服務（使用單例模式）
  final TtsService _ttsService = TtsService();
  final NotificationService _notificationService = NotificationService();
  final LineService _lineService = LineService();

  @override
  void initState() {
    super.initState();
    // 頁面初始化時，同步啟動語音播報與本地通知
    _ttsService.initTts();
    _notificationService.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ 問題修正：已精準改成 Flutter 標準參數名稱 appBar，刪除錯誤的 app_row_bar
      appBar: AppBar(
        title: const Text(
          '長者服藥提醒', 
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 📢 測試按鈕 1：觸發吃藥提醒大字體雙彈窗
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(280, 85),
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 4,
              ),
              onPressed: () {
                // 語音主動播報，引導視力不佳的長者
                _ttsService.speak("阿公，吃藥時間到囉！請服用降血壓藥一顆。");
                
                showDialog(
                  context: context,
                  barrierDismissible: false, // 強制長者必須點擊按鈕才能關閉
                  builder: (context) => ReminderModal(
                    medicineName: "降血壓藥",
                    dosage: "1 顆",
                    // ✅ 問題 1 修正：完美連動並傳入定義好的 onSave 參數
                    onSave: (chosenTime) async {
                      debugPrint("長者成功點擊已吃藥！記錄時間: $chosenTime");
                      // 這裡未來可以聯動本地資料庫，寫入服藥紀錄
                    },
                  ),
                );
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.alarm, size: 30, color: Colors.white),
                  SizedBox(width: 12),
                  Text('測試服藥提醒彈窗', style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 40),
            
            // 💬 測試按鈕 2：觸發 LINE 照護者綁定彈窗
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(280, 85),
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 4,
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => ContactModal(
                    // ✅ 問題 2 修正：完美連動並傳入定義好的 onSave 參數
                    onSave: (String lineUserId) {
                      debugPrint("成功接收到長者輸入的照護者 LINE ID: $lineUserId");
                      // 這裡未來可以聯動 LineService，將 Token 儲存至本地設定
                    },
                  ),
                );
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.share_location, size: 30, color: Colors.white),
                  SizedBox(width: 12),
                  Text('測試 LINE 綁定彈窗', style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}