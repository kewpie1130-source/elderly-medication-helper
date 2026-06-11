import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/dose_session.dart';

class DoseSessionRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. 取得或建立今日某時段的資料 (如：session_20260611_morning)
  Future<DoseSession> getOrCreateSession(String sessionId, Map<String, dynamic> defaultData) async {
    var doc = await _db.collection('dose_sessions').doc(sessionId).get();
    
    if (doc.exists) {
      return DoseSession.fromMap(doc.data()!);
    } else {
      // 如果今日該時段在資料庫還不存在，就初始化一筆
      await _db.collection('dose_sessions').doc(sessionId).set(defaultData);
      return DoseSession.fromMap(defaultData);
    }
  }

  // 2. 核心功能：當點擊「本時段全部已服用」時，更新資料庫並鎖定
  Future<void> completeSession(String sessionId) async {
    await _db.collection('dose_sessions').doc(sessionId).update({
      'status': 'completed',
      'locked': true,
    });
  }
}