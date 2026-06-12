import 'package:flutter_test/flutter_test.dart';
import 'package:elder_medicine_app/models/dose_session.dart';

void main() {
  group('DoseSession Model 完整測試', () {
    
    test('測試 1：基礎欄位建立與讀取', () {
      final session = DoseSession(
        sessionId: 'test_id',
        userId: 'user_123',
        slotId: 'slot_1',
        slotName: 'morning',
        scheduledTime: '08:00',
        date: '2026-06-12',
        itemIds: [],
        status: 'pending',
        locked: false,
        reminderTriggered: false,
        caregiverNotified: false,
      );
      expect(session.sessionId, 'test_id');
      expect(session.status, 'pending');
    });

    test('測試 2：fromJson 應該要能正確解析資料並帶入預設值', () {
      final finalJsonMock = {
        'sessionId': 'session_20260609_morning',
        'userId': 'user_123',
        'slotId': 'slot_morning',
        'slotName': '早上',
        'scheduledTime': '08:00',
        'date': '2026-06-09',
        'itemIds': ['med_01', 'med_02'],
      };

      final session = DoseSession.fromJson(finalJsonMock);

      expect(session.sessionId, 'session_20260609_morning');
      expect(session.slotName, '早上');
      expect(session.itemIds.length, 2);
      expect(session.itemIds[0], 'med_01');
      
      // 驗證 factory 內建的預設值邏輯是否正常
      expect(session.status, 'pending');
      expect(session.locked, false);
    });

    test('測試 3：驗證當用藥狀態為 completed 且已鎖定的狀態組合', () {
      final session = DoseSession(
        sessionId: 'test_id',
        userId: 'user_123',
        slotId: 'slot_1',
        slotName: 'morning',
        scheduledTime: '08:00',
        date: '2026-06-12',
        itemIds: [],
        status: 'completed',
        locked: true,
        reminderTriggered: true,
        caregiverNotified: true,
      );

      // 確保打卡與鎖定的核心旗標符合預期，這攸關鬧鐘聯動
      expect(session.status, equals('completed'));
      expect(session.locked, isTrue);
    });
  });
}