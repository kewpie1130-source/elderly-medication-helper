import 'dart:convert';

import '../models/dose_session.dart';
import '../services/database_helper.dart';

class DoseSessionRepository {
  final DatabaseHelper _databaseHelper;

  DoseSessionRepository({DatabaseHelper? databaseHelper})
    : _databaseHelper = databaseHelper ?? DatabaseHelper.instance;

  Future<void> _ensureTable() async {
    final database = await _databaseHelper.database;
    await database.execute('''
      CREATE TABLE IF NOT EXISTS dose_sessions(
        sessionId TEXT PRIMARY KEY,
        userId TEXT,
        slotId TEXT,
        slotName TEXT,
        scheduledTime TEXT,
        date TEXT,
        itemIds TEXT,
        status TEXT,
        completedAt TEXT,
        locked INTEGER,
        reminderTriggered INTEGER,
        caregiverNotified INTEGER
      )
    ''');
  }

  Future<DoseSession> getOrCreateSession(
    String sessionId,
    Map<String, dynamic> defaultData,
  ) async {
    await _ensureTable();
    final database = await _databaseHelper.database;
    final rows = await database.query(
      'dose_sessions',
      where: 'sessionId = ?',
      whereArgs: [sessionId],
      limit: 1,
    );

    if (rows.isNotEmpty) {
      return DoseSession.fromMap(_decodeRow(rows.first));
    }

    final session = DoseSession.fromMap(defaultData);
    await database.insert('dose_sessions', _encodeSession(session));
    return session;
  }

  Future<List<DoseSession>> getSessionsByDate(
    String userId,
    String date,
  ) async {
    await _ensureTable();
    final database = await _databaseHelper.database;
    final rows = await database.query(
      'dose_sessions',
      where: 'userId = ? AND date = ?',
      whereArgs: [userId, date],
      orderBy: 'scheduledTime ASC',
    );
    return rows.map((row) => DoseSession.fromMap(_decodeRow(row))).toList();
  }

  Future<void> completeSession(String sessionId) async {
    await _ensureTable();
    final database = await _databaseHelper.database;
    await database.update(
      'dose_sessions',
      {
        'status': 'completed',
        'locked': 1,
        'completedAt': DateTime.now().toIso8601String(),
      },
      where: 'sessionId = ?',
      whereArgs: [sessionId],
    );
  }

  Map<String, Object?> _encodeSession(DoseSession session) {
    final map = session.toMap();
    return {
      ...map,
      'itemIds': jsonEncode(session.itemIds),
      'locked': session.locked ? 1 : 0,
      'reminderTriggered': session.reminderTriggered ? 1 : 0,
      'caregiverNotified': session.caregiverNotified ? 1 : 0,
    };
  }

  Map<String, dynamic> _decodeRow(Map<String, Object?> row) {
    final encodedItemIds = row['itemIds'] as String? ?? '[]';
    return {
      ...row,
      'itemIds': List<String>.from(jsonDecode(encodedItemIds) as List),
      'locked': (row['locked'] as int? ?? 0) == 1,
      'reminderTriggered': (row['reminderTriggered'] as int? ?? 0) == 1,
      'caregiverNotified': (row['caregiverNotified'] as int? ?? 0) == 1,
    };
  }
}
