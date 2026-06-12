import 'package:flutter_test/flutter_test.dart';
import 'package:elder_medicine_app/models/dose_session.dart';
import 'package:elder_medicine_app/services/reminder_service.dart'; // 引入剛剛建立的正式檔案

void main() {
  group('Line 聯動鬧鐘提醒邏輯測試 (正式整合)', () {

    test('【正常安全機制】如果長輩已經吃過藥，就算超時 1 小時，也絕對不能發送 Line 騷擾家屬', () {
      final session = DoseSession(
        sessionId: 's_01',
        userId: 'u_123',
        slotId: 'slot_1',
        slotName: '早上',
        scheduledTime: '08:00',
        date: '2026-06-12',
        itemIds: ['med_1'],
        status: 'completed',
        locked: true,
        reminderTriggered: true,
        caregiverNotified: false,
      );

      final mockCurrentTime = DateTime(2026, 6, 12, 9, 0);
      
      // 改呼叫 ReminderService 的靜態方法
      final triggerLine = ReminderService.shouldTriggerCaregiverNotification(session, mockCurrentTime);
      expect(triggerLine, isFalse);
    });

    test('【緊急異常機制】如果狀態為 pending 且超時 35 分鐘，必須立刻觸發 Line 通知給家屬', () {
      final session = DoseSession(
        sessionId: 's_02',
        userId: 'u_123',
        slotId: 'slot_1',
        slotName: '早上',
        scheduledTime: '08:00',
        date: '2026-06-12',
        itemIds: ['med_1'],
        status: 'pending',
        locked: false,
        reminderTriggered: true,
        caregiverNotified: false,
      );

      final mockCurrentTime = DateTime(2026, 6, 12, 8, 35);
      
      // 改呼叫 ReminderService 的靜態方法
      final triggerLine = ReminderService.shouldTriggerCaregiverNotification(session, mockCurrentTime);
      expect(triggerLine, isTrue);
    });
  });
}