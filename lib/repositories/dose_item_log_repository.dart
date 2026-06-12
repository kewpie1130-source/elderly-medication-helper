import 'package:sqflite/sqflite.dart' show ConflictAlgorithm;

import '../models/dose_item_log.dart';
import '../services/database_helper.dart';

class DoseItemLogRepository {
  final DatabaseHelper _databaseHelper;

  DoseItemLogRepository({DatabaseHelper? databaseHelper})
    : _databaseHelper = databaseHelper ?? DatabaseHelper.instance;

  Future<void> _ensureTable() async {
    final database = await _databaseHelper.database;
    await database.execute('''
      CREATE TABLE IF NOT EXISTS dose_item_logs(
        logId TEXT PRIMARY KEY,
        sessionId TEXT,
        itemId TEXT,
        status TEXT,
        takenAt TEXT
      )
    ''');
  }

  Future<void> logItemStatus(DoseItemLog log) async {
    await _ensureTable();
    final database = await _databaseHelper.database;
    await database.insert(
      'dose_item_logs',
      log.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<DoseItemLog>> getLogsBySessionId(String sessionId) async {
    await _ensureTable();
    final database = await _databaseHelper.database;
    final rows = await database.query(
      'dose_item_logs',
      where: 'sessionId = ?',
      whereArgs: [sessionId],
      orderBy: 'takenAt DESC',
    );
    return rows.map(DoseItemLog.fromMap).toList();
  }
}
