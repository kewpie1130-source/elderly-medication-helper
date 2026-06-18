import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz; 
import '../../services/tts/tts_service.dart';
import '../../services/notification/notification_service.dart';
import 'widgets/reminder_modal.dart';
import 'widgets/contact_modal.dart';

class ReminderPage extends StatefulWidget {
  // 🚀 核心優化：允許從 OCR 辨識結果頁面（畫面 2）將藥物名稱動態傳入
  final String? medicineName;

  const ReminderPage({
    super.key,
    this.medicineName,
  });

  @override
  State<ReminderPage> createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  final TtsService _ttsService = TtsService();
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _ttsService.initTts();
    _notificationService.initialize();

    // 🚀 核心優化：如果這個頁面是被畫面 2 的「打卡」按鈕帶進來的（帶有藥物名稱），一進來就自動觸發官方引導流程！
    if (widget.medicineName != null && widget.medicineName!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _triggerOfficialFlow(context, widget.medicineName!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 如果沒有傳入藥物名稱，則使用預設值
    final String currentMedicine = widget.medicineName ?? "降血壓藥";

    return Scaffold(
      appBar: AppBar(
        title: const Text('智慧用藥助手', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF4CAF50), 
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '當前處理藥物：$currentMedicine',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(290, 85),
                backgroundColor: const Color(0xFF4CAF50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 4,
              ),
              // 點擊按鈕時，將當前的藥物名稱帶入流程
              onPressed: () => _triggerOfficialFlow(context, currentMedicine),
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

  /// 🎯 100% 對齊官方 8 大畫面機制：動態生成藥物通知排程
  void _triggerOfficialFlow(BuildContext context, String targetMedicine) {
    // 1. 觸發畫面 7 引導語音
    _ttsService.speak("是否需要設置用藥提醒？您可以設定時間提醒自己按時服藥。");

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ReminderModal(
        onChoice: (wantsReminder) async { 
          Navigator.of(context).pop(); // 外層精準關閉畫面 7 彈窗
          
          if (wantsReminder) {
            debugPrint("長者選擇：是，前往設定用藥提醒 -> 藥物：$targetMedicine");
        
            final tz.TZDateTime scheduledTime = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 10));
        
            // 🚀 核心優化：使用藥物名稱字串的雜湊值 (hashCode) 當作唯一 ID，確保不同藥物的通知不會互相覆蓋！
            final int notificationId = targetMedicine.hashCode.abs();

            // 呼叫排程方法，並在通知內文中精準放入長者剛辨識出來的藥物名稱
            await _notificationService.zonedSchedule(
              notificationId, 
              "🔔 智慧用藥助手", 
              "阿公，吃藥時間到囉！請記得服用【$targetMedicine】。", // 👈 內文動態帶入藥名，符合畫面6規格
              scheduledTime,
              isDaily: true, 
            );

            Future.delayed(const Duration(milliseconds: 500), () {
              if (!mounted) return;
              
              // 2. 觸發畫面 8 引導語音
              _ttsService.speak("是否要通知聯絡人？設定後，提醒訊息將傳送至聯絡人的 LINE。");
              
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => ContactModal(
                  onSave: (lineId) {
                    debugPrint("長者成功綁定聯絡人 LINE ID: $lineId");
                  },
                  onCancel: () {
                    debugPrint("長者點擊不需要，依據官方設計圖箭頭流程：強制退回畫面 2（內容頁）");
                    Navigator.of(context).pop(); // 關閉 ContactModal 彈窗
                    Navigator.of(context).pop(); // 關閉 ReminderPage，精準回到畫面 2
                  },
                ),
              );
            });
          } else {
            debugPrint("長者選擇：暫時略過用藥提醒");
          }
        },
      ),
    );
  }
}