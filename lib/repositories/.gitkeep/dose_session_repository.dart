import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/dose_session.dart';

class DoseSessionRepository {
  final CollectionReference _sessionCollection =
      FirebaseFirestore.instance.collection('dose_sessions');

  /// 新增或自動生成一筆時段資料 (DoseSession)
  Future<void> createDoseSession(DoseSession session) async {
    try {
      await _sessionCollection.doc(session.sessionId).set(session.toJson());
      print('📅 [Firestore] 成功建立服用時段: ${session.slotName} (${session.date})');
    } catch (e) {
      print('❌ [Firestore] 建立服用時段失敗: $e');
      rethrow;
    }
  }

  /// 獲取特定使用者在某一天的所有服用時段 (例如早上、中午、晚上)
  Future<List<DoseSession>> getSessionsByDate(String userId, String date) async {
    try {
      QuerySnapshot querySnapshot = await _sessionCollection
          .where('userId', isEqualTo: userId)
          .where('date', isEqualTo: date)
          .get();

      return querySnapshot.docs
          .map((doc) => DoseSession.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ [Firestore] 獲取當日服用時段失敗: $e');
      rethrow;
    }
  }

  /// 更新時段狀態 (例如打卡完成、鎖定按鈕、設定通知已發送等)
  Future<void> updateSessionStatus(DoseSession session) async {
    try {
      await _sessionCollection.doc(session.sessionId).update(session.toJson());
      print('🔄 [Firestore] 時段狀態成功更新: ${session.sessionId} -> ${session.status}');
    } catch (e) {
      print('❌ [Firestore] 更新時段狀態失敗: $e');
      rethrow;
    }
  }
}