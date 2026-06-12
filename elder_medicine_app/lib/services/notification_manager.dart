import 'dart:async';
import 'dart:convert'; // 引入 JSON 轉換庫
import 'package:http/http.dart' as http; // 引入 HTTP 套件
import 'package:elder_medicine_app/models/dose_session.dart';
import 'package:elder_medicine_app/services/reminder_service.dart';
import 'package:elder_medicine_app/services/alarm_service.dart'; // 引入鬧鐘服務

class NotificationManager {
  Timer? _pollingTimer;

  /// 啟動背景定時檢查（例如每 60 秒執行一次）
  void startReminderPolling() {
    // 確保不會重複啟動多個計時器
    _pollingTimer?.cancel();
    
    _pollingTimer = Timer.periodic(const Duration(seconds: 60), (timer) async {
      await checkAndTriggerReminders();
    });
    print('⏰ 藥物超時監控定時器已啟動...');
  }

  /// 核心檢查邏輯
  Future<void> checkAndTriggerReminders() async {
    final currentTime = DateTime.now();
    
    // 1. 模擬從本地資料庫 (Sqlite/Hive) 或 Provider 撈出今天「尚未完成」的用藥排程
    // (這部分 C 同學後續可以改為接上專案的 Repository/Database)
    List<DoseSession> activeSessions = await _fetchActiveSessionsFromStorage();

    for (var session in activeSessions) {
      
      // ======= A. 本機鬧鐘觸發點 =======
      // 如果時間到了，且本機鬧鐘還沒響過 (reminderTriggered == false)，就立刻響鈴
      // ======= A. 本機鬧鐘觸發點 =======
      // 如果時間到了，且本機鬧鐘還沒響過，就立刻響鈴
      if (session.status == 'pending' && !session.reminderTriggered) {
        await AlarmService().triggerImmediateAlarm(
          id: session.sessionId.hashCode,
          title: '⏰ 長輩該吃藥囉！',
          body: '現在是 ${session.slotName} 用藥時間 (${session.scheduledTime})，請記得服用。',
        );
        
        final updatedSession = session.copyWith(reminderTriggered: true);
        await _updateSessionInStorage(updatedSession);
      } 
      // ======= B. LINE 照顧者通知觸發點 =======
      // 用 else if 確保：如果剛響完本機鬧鐘，這分鐘就不會同時去灌 LINE 訊息
      else {
        bool needToNotify = ReminderService.shouldTriggerCaregiverNotification(session, currentTime);
        if (needToNotify) {
          print('🚨 發現長輩用藥超時！正在發送 LINE 官方帳號通知');
          bool success = await _sendLineNotifyRequest(session);
          if (success) {
            final updatedSession = session.copyWith(caregiverNotified: true);
            await _updateSessionInStorage(updatedSession);
          }
        }
      }

      // ======= B. LINE 照顧者通知觸發點 =======
      // 調用我們測試通過的超時演算法（檢查是否已超時 30 分鐘且尚未吃藥）
      bool needToNotify = ReminderService.shouldTriggerCaregiverNotification(session, currentTime);
      
      if (needToNotify) {
        print('🚨 發現長輩用藥超時！正在發送 LINE 官方帳號通知, SessionId: ${session.sessionId}');
        
        // 執行發送 LINE 官方帳號訊息
        bool success = await _sendLineNotifyRequest(session);
        
        if (success) {
          // 發送成功後，將本機狀態標記為已通知，避免重複發送
          final updatedSession = session.copyWith(caregiverNotified: true);
          await _updateSessionInStorage(updatedSession);
        }
      }
    }
  }

  /// 停止定時器（例如使用者登出或 App 關閉時呼叫）
  void stopReminderPolling() {
    _pollingTimer?.cancel();
    print('🛑 藥物超時監控定時器已停止。');
  }

  // =================== 以下為 C 同學待對接的 API / 資料庫介面 ===================

  Future<List<DoseSession>> _fetchActiveSessionsFromStorage() async {
    // TODO: 之後由 C 同學改為串接本地資料庫 (例如：SELECT * FROM dose_sessions WHERE status = 'pending')
    return []; 
  }

  Future<void> _updateSessionInStorage(DoseSession session) async {
    // TODO: 之後由 C 同學改為寫回資料庫，把狀態更新落實
  }

  /// 實際呼叫 LINE Messaging API 發送推播通知（取代已停用的 LINE Notify）
  Future<bool> _sendLineNotifyRequest(DoseSession session) async {
    // 1. 這是你剛才在 LINE Developers 順利測試成功的長期 Token
    const String channelAccessToken = 'XiIdc8AZa+gTVNpJT6Ygl6ZBekscA6w4ON8hKFdVnEGjMrB//z1fC/04YJIGbwVpz+AD8K9frH+mscEL+mVu0FImVvSfn2xZdOJtFBr4DCvt2uTzaBunWoh/jktXXLCwMGHRneU+jhn1sFHM5xJNdwdB04t89/1O/w1cDnyilFU=';

    // 2. 正確格式的接收者 LINE User ID 
    const String targetUserId = 'Ud420232cfec36811d9f9d8397c0ed636';

    // 依照企劃書規範組裝訊息內容
    final String messageContent = '[緊急通知] 長輩今日 ${session.slotName} (${session.scheduledTime}) 的藥物尚未服用，請協助確認！';

    try {
      // 官方帳號推播訊息的 API 網址
      final url = Uri.parse('https://api.line.me/v2/bot/message/push');
      
      // 發送 POST 請求，格式為符合 LINE 規範的 JSON
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
              'text': messageContent,
            }
          ],
        }),
      );

      if (response.statusCode == 200) {
        print('✅ LINE 官方帳號通知發送成功！');
        return true;
      } else {
        print('❌ LINE 發送失敗，狀態碼: ${response.statusCode}, 回傳內容: ${response.body}');
        return false;
      }
    } catch (e) {
      print('💥 發送 LINE 通知時