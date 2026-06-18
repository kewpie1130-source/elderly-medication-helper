import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz; 
import '../../services/tts/tts_service.dart';
import '../../services/notification/notification_service.dart';
import '../../theme/app_theme.dart'; 
import 'widgets/reminder_modal.dart';
import 'widgets/contact_modal.dart';

class ReminderPage extends StatefulWidget {
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

    if (widget.medicineName != null && widget.medicineName!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _triggerOfficialFlow(context, widget.medicineName!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String currentMedicine = widget.medicineName ?? "降血壓藥";

    return Scaffold(
      appBar: AppBar(
        title: const Text('智慧用藥助手', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: AppTheme.primary, 
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '當前處理藥物：$currentMedicine',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textDark), 
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(290, 85),
                backgroundColor: AppTheme.primary, 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 4,
              ),
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

  void _triggerOfficialFlow(BuildContext context, String targetMedicine) {
    _ttsService.speak("是否需要設置用藥提醒？您可以設定時間提醒自己按時服藥。");

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => ReminderModal(
        onChoice: (wantsReminder) async { 
          Navigator.of(dialogContext).pop(); 
          
          if (wantsReminder) {
            debugPrint("長者選擇：是，前往設定用藥提醒 -> 藥物：$targetMedicine");
        
            final tz.TZDateTime scheduledTime = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 10));
            final int notificationId = targetMedicine.hashCode.abs();

            await _notificationService.zonedSchedule(
              notificationId, 
              "🔔 智慧用藥助手", 
              "阿公，吃藥時間到囉！請記得服用【$targetMedicine】。", 
              scheduledTime,
              isDaily: true, 
            );

            Future.delayed(const Duration(milliseconds: 500), () {
              // ✅ 核心修正：非同步時序延遲後，先進行 mounted 檢查
              if (!mounted) return;
              
              _ttsService.speak("是否要通知聯絡人？設定後，提醒訊息將傳送至聯絡人的 LINE。");
              
              // ✅ 核心修正：在 showDialog 中，直接使用當前 State 的無風險對象 `this.context`，徹底清除跨 async gaps 警告！
              if (this.context.mounted) {
                showDialog(
                  context: this.context, 
                  barrierDismissible: false,
                  builder: (context) => ContactModal(
                    onSave: (lineId) {
                      debugPrint("長者成功綁定聯絡人 LINE ID: $lineId");
                    },
                    onCancel: () {
                      debugPrint("長者點擊不需要，依據官方設計圖流程：強制退回畫面 2");
                      Navigator.of(context).pop(); 
                      Navigator.of(context).pop(); 
                    },
                  ),
                );
              }
            });
          }
        },
      ),
    );
  }
}