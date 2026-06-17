import 'package:elderly_medication_helper/database/db_helper.dart';
import 'package:elderly_medication_helper/models/medicine_model.dart';
import 'package:elderly_medication_helper/models/dose_log_model.dart';

class MedicineRepository {
  final DbHelper _dbHelper = DbHelper.instance;

  // ==================== 藥品相關 (Medicine) ====================

  // 新增藥品
  Future<int> insertMedicine(MedicineModel medicine) async {
    final db = await _dbHelper.database;
    return await db.insert(
      'medicines',
      medicine.toMap(),
    );
  }

  // 取得所有歷史藥品紀錄（依據建立時間倒序）
  Future<List<MedicineModel>> getAllMedicines() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('medicines', orderBy: 'createdAt DESC');
    
    return List.generate(maps.length, (i) {
      return MedicineModel.fromMap(maps[i]);
    });
  }

  // ==================== 打卡紀錄相關 (DoseLog) ====================

  // 新增服藥打卡紀錄
  Future<int> insertDoseLog(DoseLogModel log) async {
    final db = await _dbHelper.database;
    return await db.insert(
      'dose_logs',
      log.toMap(),
    );
  }

  // 取得特定藥品的所有打卡紀錄
  Future<List<DoseLogModel>> getDoseLogsByMedicine(String medicineId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'dose_logs',
      where: 'medicineId = ?',
      whereArgs: [medicineId],
      orderBy: 'createdAt DESC',
    );
    return maps.map((map) => DoseLogModel.fromMap(map)).toList();
  }
}