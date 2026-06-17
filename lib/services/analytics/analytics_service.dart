import 'package:cloud_firestore/cloud_firestore.dart';

class AnalyticsService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 將匿名用藥紀錄上傳至 Firestore
  Future<void> logDoseAnalytics({
    required String ageGroup,
    required String gender,
    required String medicineType,
    required bool taken,
    required String hour,
  }) async {
    try {
      await _db.collection('analytics').add({
        'age_group': ageGroup,
        'gender': gender,
        'medicine_type': medicineType,
        'taken': taken,
        'hour': hour,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error logging analytics: \");
    }
  }
}
