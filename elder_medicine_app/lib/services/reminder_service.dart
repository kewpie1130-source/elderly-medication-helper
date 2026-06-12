import 'package:elder_medicine_app/models/dose_session.dart';

class ReminderService {
  /// 判斷是否需要發送 Line 緊急通知給照顧者
  /// 規則：若超時 30 分鐘且狀態仍為 pending，則回傳 true
  static bool shouldTriggerCaregiverNotification(DoseSession session, DateTime currentTime) {
    if (session.status == 'completed' || session.locked) {
      return false; // 已服用或鎖定，安全退出
    }
    
    // 解析排定的服藥時間 (例如 "08:00")
    final timeParts = session.scheduledTime.split(':');
    final scheduledDateTime = DateTime(
      currentTime.year,
      currentTime.month,
      currentTime.day,
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );

    // 計算時間差（分鐘）
    final difference = currentTime.difference(scheduledDateTime).inMinutes;
    
    // 超時大於等於 30 分鐘，且尚未發送過家屬通知
    return difference >= 30 && !session.caregiverNotified;
  }
}