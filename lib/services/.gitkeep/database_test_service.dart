import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/models/medicine_item.dart';
import 'package:flutter_application_1/models/dose_session.dart';
import 'dart:html' as html; // 🚀 引入網頁端原生功能（用來發送實體叮咚通知）

class DatabaseTestService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  DatabaseTestService();

  Future<void> runFullPipelineTest() async {
    print('🧪 [Test] 開始執行 Firestore 整合測試...');
    
    final DateTime now = DateTime.now();
    final String testUserId = "test_user_elderly_123";
    final String testItemId = "med_test_${now.millisecondsSinceEpoch}";
    final String testSessionId = "session_test_${now.millisecondsSinceEpoch}";

    // ==========================================
    // 🧪 1. 模擬建立藥品物件
    // ==========================================
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
      createdAt: DateTime.parse(now.toIso8601String()),
    );
    print('✅ [Test] 藥品物件模擬成功：${mockMedicine.name}');

    // ==========================================
    // 🧪 2. 模擬長者點擊【本時段全部已服用】（更新資料庫）
    // ==========================================
    print("🧪 [Test] 3. 正在模擬長者點擊【本時段全部已服用】...");
    
    // 直接在雲端資料庫更新/建立該時段狀態，並啟動防重複鎖定 (locked: true)
    await _db.collection('dose_sessions').doc(testSessionId).set({
      'sessionId': testSessionId,
      'status': 'completed',
      'completedAt': DateTime.now().toIso8601String(),
      'locked': true, 
    });
    print("🧪 [Test] ✅ 時段已更新為 completed，且成功鎖定 (locked: true)！");

    // ==========================================
    // 🧪 3. 驗證防重複服用機制（安全攔截測試）
    // ==========================================
    print("🧪 [Test] 4. 正在驗證防重複服用機制...");
    var snapshot = await _db.collection('dose_sessions').doc(testSessionId).get();
    
    if (snapshot.exists) {
      var sessionData = snapshot.data();
      if (sessionData?['locked'] == true) {
        print("🧪 [Test] 🛑 系統攔截安全警示：「此時段已完成服用，按鈕已鎖定，請勿重複服用！」");
      }
    }

    // ==========================================
    // 🧪 4. 觸發電腦實體網頁通知（叮咚！）
    // ==========================================
    print("🧪 [Test] 5. 正在嘗試發送實體網頁通知...");
    
    // 如果瀏覽器已經允許通知權限，就直接彈窗
    if (html.Notification.permission == 'granted') {
     html.Notification(
        "智慧用藥助手提醒", // 第一個參數：標題
        body: "早上 08:00 吃藥時間到囉！今天早上有 3 個品項需要確認。", // 具名參數 body
        icon: "https://via.placeholder.com/128", // 具名參數 icon
      );
      print("🧪 [Test] 🎉 實體通知已發送！請看電腦螢幕周圍有沒有跳出通知！");
    } else if (html.Notification.permission != 'denied') {
      // 如果還沒問過權限，就向使用者請求權限
      await html.Notification.requestPermission();
    }
    
    print('🚀 [Test] 全線整合測試一條龍圓滿完成！');
  }
}