import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz; // 👈 核心關鍵：時區套件，對齊通知服務型態
import '../../services/tts/tts_service.dart';
import '../../services/notification/notification_service.dart';
import 'widgets/reminder_modal.dart';
import 'widgets/contact_modal.dart';

class ReminderPage extends StatefulWidget {
  const ReminderPage({super.key});

  @override
  State<ReminderPage> createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  // 正確初始化核心防區服務
  final TtsService _ttsService = TtsService();
  final NotificationService _notificationService = NotificationService();

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
      appBar: AppBar(
        title: const Text('智慧用藥助手', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF4CAF50), // 100% 對齊官方設計圖的草綠色
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 📢 測試按鈕：模擬官方連續引導視窗流程（畫面 7 + 畫面 8）
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(290, 85),
                backgroundColor: const Color(0xFF4CAF50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 4,
              ),
              onPressed: () => _triggerOfficialFlow(context),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.play_circle_filled, size: 28, color: Colors.white),
                  SizedBox(width: 12),
                  Text('觸發官方引導流程 (畫面7+8)', style: TextStyle(fontSize: 19, color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🎯 100% 實現官方設計圖連動流程：彈出畫面 7 -> 成功後彈出畫面 8 -> 取消則退回畫面 2
  void _triggerOfficialFlow(BuildContext context) {
    // 1. 觸發畫面 7 引導語音播報
    _ttsService.speak("是否需要設置用藥提醒？您可以設定時間提醒自己按時服藥。");

    // 2. 彈出畫面 7 詢問彈窗
    showDialog(
      context: context,
      barrierDismissible: false, // 強制長者必須點擊按鈕
      builder: (context) => ReminderModal(
        onChoice: (wantsReminder) async {
          if (wantsReminder) {
            debugPrint("長者選擇：是，前往設定用藥提醒");
            
            // 計算時區正確的排程時間（測試設定 10 秒後觸發）
            final tz.TZDateTime scheduledTime = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 10));
            
            // 呼叫更新後的位置參數排程方法，並開啟畫面 6 的每天重複功能
            await _notificationService.zonedSchedule(
              101, 
              "🔔 智慧用藥助手", 
              "阿公，吃藥時間到囉！請記得按時服用藥物。", 
              scheduledTime,
              isDaily: true, // 對齊畫面 6 的「每天重複」規格
            );

            // 畫面 7 順利結束後，延遲 500 毫秒，優雅聯動跳出畫面 8
            Future.delayed(const Duration(milliseconds: 500), () {
              if (!mounted) return;
              
              // 3. 觸發畫面 8 引導語音播報
              _ttsService.speak("是否要通知聯絡人？設定後，提醒訊息將傳送至聯絡人的 LINE。");
              
              // 4. 彈出畫面 8 詢問彈窗
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => ContactModal(
                  onSave: (lineId) {
                    debugPrint("長者成功綁定聯絡人 LINE ID: $lineId");
                    // 這裡可以聯動 LineService 儲存 Token
                  },
                  // ✅ 終極流程修正：點擊不需要時，順著圖片箭頭，強制連續 pop 兩次退回畫面 2（內容頁）
                  onCancel: () {
                    debugPrint("長者點擊不需要，依據官方設計圖流程：關閉彈窗並強制退回畫面 2（內容頁）");
                    Navigator.of(context).pop(); // 第一層：關閉 ContactModal 彈窗
                    Navigator.of(context).pop(); // 第二層：關閉 ReminderPage，精準回到上一個頁面（畫面 2）
                  },
                ),
              );
            });
          } else {
            // 如果長者在畫面 7 點擊暫時略過，直接關閉並留在原地或視專案狀況處理
            debugPrint("長者選擇：暫時略過用藥提醒");
          }
        },
      ),
    );
  }
}