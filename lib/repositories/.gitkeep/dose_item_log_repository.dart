import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/dose_item_log.dart';

class DoseItemLogRepository {
  final CollectionReference _logCollection =
      FirebaseFirestore.instance.collection('dose_item_logs');

  /// 寫入一筆藥品服用紀錄 (Taken / Missed)
  Future<void> logItemStatus(DoseItemLog log) async {
    try {
      await _logCollection.doc(log.logId).set(log.toJson());
      print('📝 [Firestore] 記錄藥品狀態成功: Item ${log.itemId} -> ${log.status}');
    } catch (e) {
      print('❌ [Firestore] 記錄藥品狀態失敗: $e');
      rethrow;
    }
  }

  /// 獲取某個特定時段 (DoseSession) 底下的所有藥品打卡紀錄
  Future<List<DoseItemLog>> getLogsBySessionId(String sessionId) async {
    try {
      QuerySnapshot querySnapshot = await _logCollection
          .where('sessionId', isEqualTo: sessionId)
          .get();

      return querySnapshot.docs
          .map((doc) => DoseItemLog.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ [Firestore] 獲取時段打卡紀錄失敗: $e');
      rethrow;
    }
  }
}