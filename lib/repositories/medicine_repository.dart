import '../models/medicine.dart';
import '../models/medicine_item.dart';
import '../services/database_helper.dart';

class MedicineRepository {
  final DatabaseHelper _databaseHelper;

  MedicineRepository({DatabaseHelper? databaseHelper})
    : _databaseHelper = databaseHelper ?? DatabaseHelper.instance;

  Future<MedicineItem?> getMedicineItemById(String itemId) async {
    final medicines = await _databaseHelper.getMedicines();
    for (final medicine in medicines) {
      if (medicine.id?.toString() == itemId) {
        return _toMedicineItem(medicine);
      }
    }
    return null;
  }

  Future<List<MedicineItem>> getMedicineItemsForSlot(String slotId) async {
    final medicines = await _databaseHelper.getMedicines();
    return medicines
        .where((medicine) => _matchesSlot(medicine, slotId))
        .where((medicine) => medicine.id != null)
        .map(_toMedicineItem)
        .toList();
  }

  Future<List<MedicineItem>> getMedicineItemsByUserId(String userId) async {
    final medicines = await _databaseHelper.getMedicines();
    return medicines
        .where((medicine) => medicine.id != null)
        .map(_toMedicineItem)
        .toList();
  }

  bool _matchesSlot(Medicine medicine, String slotId) {
    return switch (slotId) {
      'morning' => medicine.morning,
      'noon' => medicine.noon,
      'evening' => medicine.evening,
      'before_sleep' => medicine.beforeSleep,
      _ => false,
    };
  }

  MedicineItem _toMedicineItem(Medicine medicine) {
    return MedicineItem(
      itemId: medicine.id.toString(),
      userId: medicine.patientName,
      type: 'medicine',
      name: medicine.medicineName,
      category: medicine.clinicName,
      dosageText: medicine.dosage,
      plainDescription: medicine.notes,
      imageUrl: medicine.imagePath,
      createdAt:
          DateTime.tryParse(medicine.createdAt) ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
