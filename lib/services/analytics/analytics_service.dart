import '../../firebase/firebase_service.dart';

class AnalyticsService {
  final FirebaseService _firebaseService = FirebaseService();

  Future<void> logAnalytics({
    required String ageGroup,
    required String gender,
    required String medicineType,
    required bool taken,
    required String hour,
  }) async {
    await _firebaseService.db.collection('analytics').add({
      'age_group': ageGroup,
      'gender': gender,
      'medicine_type': medicineType,
      'taken': taken,
      'hour': hour,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
}
