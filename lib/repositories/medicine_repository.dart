import 'package:sqflite/sqflite.dart';
import '../database/db_helper.dart';
import '../models/medicine_model.dart';
import '../models/dose_log_model.dart'; // 🛠️ 補上導入
import 'dart:convert';

class MedicineRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // 1. 取得所有藥品紀錄
  Future<List<MedicineModel>> getAllMedicines() async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'medicines',
        orderBy: 'createdAt DESC',
      );
      print('===查詢結果===');
      print('資料庫查詢到的藥物數量: ${maps.length}');

      return List.generate(maps.length, (i) {
        List<String> timings = [];
        if (maps[i]['timing'] != null) {
          try {
            timings = List<String>.from(jsonDecode(maps[i]['timing']));
          } catch (_) {}
        }

        return MedicineModel(
          id: maps[i]['id'] ?? '',
          name: maps[i]['name'] ?? '',
          type: maps[i]['type'] ?? '',
          dosage: maps[i]['dosage'] ?? '',
          frequency: maps[i]['frequency'] ?? '',
          timing: timings,
          notice: maps[i]['notice'] ?? '',
          indication: maps[i]['indication'] as String? ?? '',
          startDate: maps[i]['startDate'] ?? '',
          endDate: maps[i]['endDate'] ?? '',
          imagePath: maps[i]['imagePath'] ?? '',
          createdAt: maps[i]['createdAt'] ?? '',
        );
      });
    } catch (e) {
      print("Error in getAllMedicines: $e");
      return [];
    }
  }

  // 2. 新增藥品紀錄
  Future<bool> insertMedicine(MedicineModel medicine) async {
    try {
      final db = await _dbHelper.database;

      print('===準備寫入藥物===');
      print('藥物名稱: ${medicine.name}, ID: ${medicine.id}');
      final result = await db.insert(
        'medicines',
        medicine.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('===寫入完成，回傳row id: $result===');
      return true;
    } catch (e) {
      print("Error inserting medicine: $e");
      return false;
    }
  }

  // 3. 🛠️ 補上：新增服藥打卡紀錄（DoseLog）的方法
  Future<bool> insertDoseLog(DoseLogModel log) async {
    try {
      final db = await _dbHelper.database;

      final Map<String, dynamic> row = {
        'id': log.id,
        'medicineId': log.medicineId,
        'scheduledTime': log.scheduledTime,
        'takenTime': log.takenTime,
        'status': log.status,
        'createdAt': log.createdAt,
      };

      await db.insert(
        'dose_logs',
        row,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return true;
    } catch (e) {
      print("Error inserting dose log: $e");
      return false;
    }
  }
}
