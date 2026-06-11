import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/dose_session.dart';

class DoseSessionRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. 取得或初始化今日某時段的 DoseSession
  Future<DoseSession> getOrCreateSession(String sessionId, Map<String, dynamic> defaultData) async {
    var doc = await _db.collection('dose_sessions').doc(sessionId).get();
    if (doc.exists) {
      return DoseSession.fromMap(doc.data()!);
    } else {
      // 若資料庫還沒有今日這時段的紀錄，就自動初始化一筆
      await _db.collection('dose_sessions').doc(sessionId).set(defaultData);
      return DoseSession.fromMap(defaultData);
    }
  }

  // 2. 更新時段打卡狀態：個別品項打卡
  Future<void> updateItemLogStatus(String sessionId, String itemId, String status) async {
    // 在真實專案中，你可以另外寫到 dose_item_logs 資料夾
    // 這裡示範直接更新時段內的狀態或紀錄
    await _db.collection('dose_item_logs').doc('${sessionId}_$itemId').set({
      'sessionId': sessionId,
      'itemId': itemId,
      'status': status,
      'takenAt': DateTime.now().toIso8601String(),
    });
  }

  // 3. 核心功能：當點擊「本時段全部已服用」時，更新狀態並鎖定按鈕
  Future<void> completeSession(String sessionId) async {
    await _db.collection('dose_sessions').doc(sessionId).update({
      'status': 'completed',
      'locked': true,
      'completedAt': DateTime.now().toIso8601String(),
    });
  }
}