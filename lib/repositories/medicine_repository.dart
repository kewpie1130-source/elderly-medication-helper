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

      return List.generate(maps.length, (i) {
        List<String> timings = [];
        if (maps[i]['timing'] != null) {
          try {
            timings = List<String>.from(jsonDecode(maps[i]['timing']));
          } catch (_) {}
        }

        // 🛠️ 完美對齊靖喻規定的 required 欄位格式，補足 indication 欄位映射
        return MedicineModel(
          id: maps[i]['id'] ?? '',
          name: maps[i]['name'] ?? '',
          type: maps[i]['type'] ?? '',
          dosage: maps[i]['dosage'] ?? '',
          frequency: maps[i]['frequency'] ?? '',
          timing: timings,
          notice: maps[i]['notice'] ?? '',
          indication: maps[i]['indication'] ?? '', // 🛠️ 完美對齊修正！
          startDate: maps[i]['startDate'] ?? '',
          endDate: maps[i]['endDate'] ?? '',
          imagePath: maps[i]['imagePath'] ?? '',
          createdAt: maps[i]['createdAt'] ?? '',
        );
      });
    } catch (e) {
      print("getAllMedicines 發生錯誤: $e");
      return [];
    }
  }

  // 🛠️ 補上專案原本要求的 insertDoseLog 實作，讓打卡功能順暢運作
  Future<int> insertDoseLog(DoseLogModel doseLog) async {
    final db = await _dbHelper.database;
    return await db.insert(
      'dose_logs',
      doseLog.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
