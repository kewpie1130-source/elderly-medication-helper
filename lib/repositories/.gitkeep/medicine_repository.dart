import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/medicine_item.dart';

class MedicineRepository {
  // 宣告 Firestore Collection 參考
  final CollectionReference _medicineCollection =
      FirebaseFirestore.instance.collection('medicines');

  /// 1. 新增藥品/保健食品資料 (Create)
  Future<void> addMedicineItem(MedicineItem item) async {
    try {
      await _medicineCollection.doc(item.itemId).set(item.toJson());
      print('🚀 [Firestore] 成功新增藥品品項: ${item.name}');
    } catch (e) {
      print('❌ [Firestore] 新增藥品品項失敗: $e');
      rethrow;
    }
  }

  /// 2. 根據 ID 讀取單一藥品資料 (Read Single)
  Future<MedicineItem?> getMedicineItemById(String itemId) async {
    try {
      DocumentSnapshot doc = await _medicineCollection.doc(itemId).get();
      if (doc.exists && doc.data() != null) {
        return MedicineItem.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('❌ [Firestore] 讀取單一藥品失敗: $e');
      rethrow;
    }
  }

  /// 3. 獲取該名使用者所有的藥品與保健食品清單 (Read List)
  Future<List<MedicineItem>> getMedicineItemsByUserId(String userId) async {
    try {
      QuerySnapshot querySnapshot = await _medicineCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => MedicineItem.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ [Firestore] 獲取使用者藥品清單失敗: $e');
      rethrow;
    }
  }
}