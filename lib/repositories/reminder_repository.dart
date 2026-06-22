import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
// ✅ 終極修正：由 repositories 出發向上退一層 (../)，精準命中 database 資料夾與 models
import '../database/db_helper.dart';
import '../models/reminder_model.dart';

class ReminderRepository {
  static final ReminderRepository _instance = ReminderRepository._internal();
  factory ReminderRepository() => _instance;
  ReminderRepository._internal();

  final DbHelper _dbHelper = DbHelper();

  Future<int> insertReminder(ReminderModel reminder) async {
    try {
      final Database db = await _dbHelper.database;
      return await db.insert('reminders', {
        'id': reminder.id,
        'medicineId': reminder.medicineId,
        'time': reminder.time,
        'repeatType': reminder.repeatType,
        'enabled': reminder.enabled ? 1 : 0,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      debugPrint("❌ [ReminderRepository] 寫入 reminders 失敗: $e");
      return -1;
    }
  }

  Future<List<ReminderModel>> getAllReminders() async {
    try {
      final Database db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query('reminders');

      return List.generate(maps.length, (i) {
        return ReminderModel(
          id: maps[i]['id'] as String,
          medicineId: maps[i]['medicineId'] as String,
          time: maps[i]['time'] as String,
          repeatType: maps[i]['repeatType'] as String,
          enabled: (maps[i]['enabled'] as int) == 1,
        );
      });
    } catch (e) {
      debugPrint("❌ [ReminderRepository] 讀取 reminders 失敗: $e");
      return [];
    }
  }

  Future<int> deleteReminder(String id) async {
    try {
      final Database db = await _dbHelper.database;
      return await db.delete('reminders', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      debugPrint("❌ [ReminderRepository] 刪除資料失敗: $e");
      return -1;
    }
  }

  Future<int> updateReminderEnabled(String id, bool enabled) async {
    try {
      final Database db = await _dbHelper.database;
      return await db.update(
        'reminders',
        {'enabled': enabled ? 1 : 0},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      debugPrint("❌ [ReminderRepository] 更新開關狀態失敗: $e");
      return -1;
    }
  }
}
