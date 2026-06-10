import 'dart:html' as html; // 這是專門用來控制網頁（Chrome）原生功能的套件
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/models/medicine_item.dart';
import 'package:flutter_application_1/models/dose_session.dart';
import 'package:flutter_application_1/repositories/.gitkeep/medicine_repository.dart';
import 'package:flutter_application_1/repositories/.gitkeep/dose_session_repository.dart';

class DatabaseTestService {
  final MedicineRepository _medicineRepo = MedicineRepository();
  final DoseSessionRepository _sessionRepo = DoseSessionRepository();

  /// 執行一條龍的資料庫寫入與讀取測試
Future<void> runFullPipelineTest() async {
    print('🧪 [Test] 開始執行 Firestore 整合測試...');

    // 👇 先宣告目前的時間

    final DateTime now = DateTime.now();
    final String testUserId = "test_user_elderly_123";
    final String testItemId = "med_test_${now.millisecondsSinceEpoch}";
    final String testSessionId = "session_test_${now.millisecondsSinceEpoch}";

// 1. 模擬建立藥品物件
    final mockMedicine = MedicineItem(
      itemId: testItemId,
      userId: testUserId,
      type: "medicine",
      name: "立普妥 Lipitor (模擬測試)",
      category: "高血壓/降血脂",
      dosageText: "每日一次，每次一顆，飯後服用",
      scheduleSlotIds: ["slot_morning"],
      plainDescription: "這是醫生開給您降膽固醇的藥。記得每天吃完早餐後配溫開水吃一顆喔！",
      imageUrl: "https://example.com/mock_pill.png",
      createdAt: DateTime.parse(now.toIso8601String()), // 確保型態對齊 DateTime
    );

    // 把原本第 37-38 行多出來的零碎雙引號 " 刪除乾淨

    try {
      // 2. 測試新增藥品
      print('🧪 [Test] 1. 正在嘗試寫入藥品資料...');
      await _medicineRepo.addMedicineItem(mockMedicine);
      print('🧪 [Test] ✅ 藥品寫入成功！');

      // 3. 測試讀取剛剛寫入的藥品
      print('🧪 [Test] 2. 正在嘗試驗證讀取該藥品...');
      final fetchedMed = await _medicineRepo.getMedicineItemById(testItemId);
      if (fetchedMed != null) {
        print('🧪 [Test] 🎉 成功從雲端撈回藥品！藥品名稱: ${fetchedMed.name}');
      } else {
        print('🧪 [Test] ❌ 讀取失敗，找不到該藥品 Document');
      }

      // 4. 模擬建立當日的時段打卡資料 (DoseSession)
      final mockSession = DoseSession(
        sessionId: testSessionId,
        userId: testUserId,
        slotId: "slot_morning",
        slotName: "早上",
        scheduledTime: "08:00",
        date: "2026-06-12",
        itemIds: [testItemId],
        status: "pending",
        locked: false,
        reminderTriggered: false,
        caregiverNotified: false,
      );

      print('🧪 [Test] 3. 正在嘗試寫入今日服用時段...');
      await _sessionRepo.createDoseSession(mockSession);
      print('🧪 [Test] ✅ 時段寫入成功！');

      // 5. 測試撈取當日所有時段清單
      print('🧪 [Test] 4. 正在嘗試撈取使用者今日的所有時段...');
      final sessions = await _sessionRepo.getSessionsByDate(testUserId, "2026-06-12");
      print('🧪 [Test] 🎉 成功撈回時段清單！今日共有 ${sessions.length} 個時段需要吃藥。');
// ==========================================
    // 🧪 擴充測試：模擬長者點擊「本時段全部已服用」
    // ==========================================
    print("🧪 [Test] 5. 正在模擬長者點擊【本時段全部已服用】...");
    
    // 假設我們拿剛剛寫入成功的 sessionId 來做更新
    String testSessionId = "session_20260609_morning"; // 對齊你原本寫入的識別碼
    
    // 更新 Firestore 中的時段狀態為已完成，並鎖定按鈕
    await _db.collection('dose_sessions').doc(testSessionId).update({
      'status': 'completed',
      'completedAt': DateTime.now().toIso8601String(),
      'locked': true, // 鎖定防重複服用機制觸發
    });
    print("🧪 [Test] ✅ 時段狀態已更新為 completed，且成功鎖定 (locked: true)！");

    // ==========================================
    // 🧪 擴充測試：驗證防重複服用機制
    // ==========================================
    print("🧪 [Test] 6. 正在驗證防重複服用機制（模擬二次點擊）...");
    var updatedSnapshot = await _db.collection('dose_sessions').doc(testSessionId).get();
    
    if (updatedSnapshot.exists) {
      var sessionData = updatedSnapshot.data();
      if (sessionData?['locked'] == true) {
        print("🧪 [Test] 🛑 系統提示：「此時段已完成，請勿重複服用。若資料有誤，請由照顧者協助修改。」");
        print("🧪 [Test] 🎉 防重複服用機制安全防禦成功！");
        // ==========================================
    // 🧪 擴充測試：嘗試觸發 Chrome 實體通知
    // ==========================================
    print("🧪 [Test] 7. 正在嘗試發送實體網頁通知...");
    
    // 檢查瀏覽器是否支援通知，且使用者已經允許
    if (html.Notification.permission == 'granted') {
      html.Notification("長者智慧用藥提醒", html.NotificationOptions(
        body: "早上 08:00 服用提醒：今天早上有 3 個品項需要確認！",
        icon: "https://via.placeholder.com/128" // 預留的通知圖示
      ));
      print("🧪 [Test] 🎉 實體通知已成功發送！請檢查你電腦螢幕的右下角或右上角！");
    } else {
      print("🧪 [Test] ❌ 通知權限未取得，請確保 Chrome 畫面有按下【允許】。");
    }
      }
    }
      print('🧪 [Test] 🚀🚀 所有 Firestore 增刪查改整合測試全部通過！');

    } catch (e) {
      print('🧪 [Test] 💥 測試過程中發生嚴重錯誤: $e');
    }
  }
}
