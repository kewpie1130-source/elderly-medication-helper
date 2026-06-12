import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import '../models/local_user.dart';
import '../models/medicine.dart';
import '../models/taken_record.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _database;

  final Random _secureRandom = Random.secure();
  LocalUser? _activeUser;

  LocalUser? get activeUser => _activeUser;

  String get activeUserId {
    final user = _activeUser;
    if (user == null) {
      throw StateError('目前沒有登入的使用者');
    }
    return user.userId;
  }

  Future<Database> get database async {
    _database ??= await _openDatabase();
    return _database!;
  }

  Future<Database> _openDatabase() async {
    final databasesPath = await getDatabasesPath();
    return openDatabase(
      path.join(databasesPath, 'smart_medication.db'),
      version: 3,
      onCreate: (db, version) async {
        await _createUserTables(db);
        await db.execute('''
          CREATE TABLE medicines(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            userId TEXT NOT NULL,
            patientName TEXT,
            clinicName TEXT,
            medicineName TEXT,
            dosage TEXT,
            frequency TEXT,
            timingText TEXT,
            morning INTEGER,
            noon INTEGER,
            evening INTEGER,
            beforeSleep INTEGER,
            beforeMeal INTEGER,
            afterMeal INTEGER,
            startDate TEXT,
            endDate TEXT,
            notes TEXT,
            imagePath TEXT,
            ocrText TEXT,
            createdAt TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE taken_records(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            userId TEXT NOT NULL,
            medicineId INTEGER,
            medicineName TEXT,
            period TEXT,
            takenAt TEXT,
            date TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createUserTables(db);
          await db.execute(
            "ALTER TABLE medicines ADD COLUMN userId TEXT "
            "NOT NULL DEFAULT 'legacy_user'",
          );
          await db.execute(
            "ALTER TABLE taken_records ADD COLUMN userId TEXT "
            "NOT NULL DEFAULT 'legacy_user'",
          );
          await db.insert(
            'app_users',
            {
              'userId': 'legacy_user',
              'email': 'legacy@local',
              'displayName': '原本使用者',
              'passwordSalt': '',
              'passwordHash': '',
              'createdAt': DateTime.now().toIso8601String(),
              'lastSignedInAt': DateTime.now().toIso8601String(),
            },
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
        }
        if (oldVersion < 3) {
          await db.execute(
            'ALTER TABLE app_users ADD COLUMN email TEXT NOT NULL DEFAULT ""',
          );
          await db.execute(
            'ALTER TABLE app_users ADD COLUMN passwordSalt TEXT NOT NULL DEFAULT ""',
          );
          await db.execute(
            'ALTER TABLE app_users ADD COLUMN passwordHash TEXT NOT NULL DEFAULT ""',
          );
          await db.execute(
            'ALTER TABLE app_users ADD COLUMN lastSignedInAt TEXT',
          );
          await db.update(
            'app_users',
            {
              'email': 'legacy@local',
              'displayName': '原本使用者',
              'passwordSalt': '',
              'passwordHash': '',
              'lastSignedInAt': DateTime.now().toIso8601String(),
            },
            where: 'userId = ?',
            whereArgs: ['legacy_user'],
          );
          await db.execute(
            'CREATE UNIQUE INDEX IF NOT EXISTS idx_app_users_email '
            'ON app_users(email COLLATE NOCASE)',
          );
        }
      },
    );
  }

  Future<void> _createUserTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS app_users(
        userId TEXT PRIMARY KEY,
        email TEXT NOT NULL UNIQUE COLLATE NOCASE,
        displayName TEXT NOT NULL,
        passwordSalt TEXT NOT NULL,
        passwordHash TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        lastSignedInAt TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS app_settings(
        settingKey TEXT PRIMARY KEY,
        settingValue TEXT
      )
    ''');
    await db.execute(
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_app_users_email '
      'ON app_users(email COLLATE NOCASE)',
    );
  }

  String _normalizeEmail(String email) => email.trim().toLowerCase();

  String _generateSalt() {
    final bytes = List<int>.generate(16, (_) => _secureRandom.nextInt(256));
    return base64UrlEncode(bytes);
  }

  String _hashPassword(String password, String salt) {
    return sha256.convert(utf8.encode('$salt:$password')).toString();
  }

  Future<LocalUser?> _findUserByEmail(String email) async {
    final db = await database;
    final normalizedEmail = _normalizeEmail(email);
    if (normalizedEmail.isEmpty) return null;
    final rows = await db.query(
      'app_users',
      where: 'email = ?',
      whereArgs: [normalizedEmail],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return LocalUser.fromMap(rows.first);
  }

  Future<LocalUser?> restoreActiveUser() async {
    final db = await database;
    final settings = await db.query(
      'app_settings',
      where: 'settingKey = ?',
      whereArgs: ['activeUserId'],
      limit: 1,
    );
    if (settings.isEmpty) return null;

    final userId = settings.first['settingValue'] as String? ?? '';
    if (userId.isEmpty) return null;
    final users = await db.query(
      'app_users',
      where: 'userId = ?',
      whereArgs: [userId],
      limit: 1,
    );
    if (users.isEmpty) return null;

    _activeUser = LocalUser.fromMap(users.first);
    return _activeUser;
  }

  Future<List<LocalUser>> getLocalUsers() async {
    final db = await database;
    final rows = await db.query('app_users', orderBy: 'createdAt ASC');
    return rows.map(LocalUser.fromMap).toList();
  }

  Future<LocalUser> createAccount({
    required String email,
    required String displayName,
    required String password,
  }) async {
    final normalizedEmail = _normalizeEmail(email);
    final trimmedDisplayName = displayName.trim();
    final trimmedPassword = password;
    if (normalizedEmail.isEmpty || !normalizedEmail.contains('@')) {
      throw ArgumentError('請輸入有效的 EMAIL');
    }
    if (trimmedDisplayName.isEmpty) {
      throw ArgumentError('請輸入顯示名稱');
    }
    if (trimmedPassword.length < 6) {
      throw ArgumentError('密碼至少需要 6 個字元');
    }

    final existing = await _findUserByEmail(normalizedEmail);
    if (existing != null) {
      throw StateError('此 EMAIL 已經註冊，請直接登入');
    }

    final timestamp = DateTime.now().toIso8601String();
    final salt = _generateSalt();
    final finalUser = LocalUser(
      userId: 'user_${DateTime.now().microsecondsSinceEpoch}',
      email: normalizedEmail,
      displayName: trimmedDisplayName,
      passwordSalt: salt,
      passwordHash: _hashPassword(trimmedPassword, salt),
      createdAt: timestamp,
      lastSignedInAt: timestamp,
    );

    final db = await database;
    await db.insert('app_users', finalUser.toMap());
    await signInAs(finalUser);
    return finalUser;
  }

  Future<LocalUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = _normalizeEmail(email);
    final user = await _findUserByEmail(normalizedEmail);
    if (user == null) {
      throw StateError('找不到此 EMAIL');
    }

    final expectedHash = _hashPassword(password, user.passwordSalt);
    final isLegacyAccount = user.passwordHash.isEmpty;
    if (!isLegacyAccount && expectedHash != user.passwordHash) {
      throw StateError('密碼錯誤');
    }
    if (isLegacyAccount && password.isNotEmpty) {
      throw StateError('此舊帳號尚未設定密碼，請先使用空白密碼登入或建立新帳號');
    }

    await signInAs(
      user.copyWith(
        lastSignedInAt: DateTime.now().toIso8601String(),
      ),
    );
    return _activeUser ?? user;
  }

  Future<void> signInAs(LocalUser user) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    final updatedUser = user.copyWith(lastSignedInAt: now);
    await db.update(
      'app_users',
      updatedUser.toMap(),
      where: 'userId = ?',
      whereArgs: [updatedUser.userId],
    );
    await db.insert(
      'app_settings',
      {
        'settingKey': 'activeUserId',
        'settingValue': updatedUser.userId,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    _activeUser = updatedUser;
  }

  Future<void> signOut() async {
    final db = await database;
    await db.delete(
      'app_settings',
      where: 'settingKey = ?',
      whereArgs: ['activeUserId'],
    );
    _activeUser = null;
  }

  Future<int> insertMedicine(Medicine medicine) async {
    final db = await database;
    final id = await db.insert('medicines', {
      ...medicine.toMap(),
      'userId': activeUserId,
    });
    debugPrint('SQLite inserted medicines row id=$id');
    return id;
  }

  Future<Medicine?> findPotentialDuplicate(Medicine medicine) async {
    final db = await database;
    final imagePath = medicine.imagePath.trim();
    final rows = await db.query(
      'medicines',
      where:
          'userId = ? AND ('
          "(? != '' AND imagePath = ?) OR "
          '(medicineName = ? AND dosage = ? AND frequency = ?))',
      whereArgs: [
        activeUserId,
        imagePath,
        imagePath,
        medicine.medicineName.trim(),
        medicine.dosage.trim(),
        medicine.frequency.trim(),
      ],
      orderBy: 'createdAt DESC',
      limit: 1,
    );
    return rows.isEmpty ? null : Medicine.fromMap(rows.first);
  }

  Future<int> updateMedicine(Medicine medicine) async {
    if (medicine.id == null) {
      throw ArgumentError('Medicine id is required for update.');
    }
    final db = await database;
    return db.transaction((transaction) async {
      final updatedRows = await transaction.update(
        'medicines',
        medicine.toMap()..remove('id'),
        where: 'id = ? AND userId = ?',
        whereArgs: [medicine.id, activeUserId],
      );
      await transaction.update(
        'taken_records',
        {'medicineName': medicine.medicineName},
        where: 'medicineId = ? AND userId = ?',
        whereArgs: [medicine.id, activeUserId],
      );
      return updatedRows;
    });
  }

  Future<List<Medicine>> getMedicines() async {
    final db = await database;
    final rows = await db.query(
      'medicines',
      where: 'userId = ?',
      whereArgs: [activeUserId],
      orderBy: 'createdAt DESC',
    );
    final medicines = rows.map(Medicine.fromMap).toList();
    debugPrint('SQLite medicines count=${medicines.length}');
    return medicines;
  }

  Future<int> deleteMedicine(int id) async {
    final db = await database;
    return db.transaction((transaction) async {
      await transaction.delete(
        'taken_records',
        where: 'medicineId = ? AND userId = ?',
        whereArgs: [id, activeUserId],
      );
      return transaction.delete(
        'medicines',
        where: 'id = ? AND userId = ?',
        whereArgs: [id, activeUserId],
      );
    });
  }

  Future<int> insertTakenRecord(TakenRecord record) async {
    final db = await database;
    return db.insert('taken_records', {
      ...record.toMap(),
      'userId': activeUserId,
    });
  }

  Future<bool> hasTakenRecord({
    required int medicineId,
    required String period,
    required String date,
  }) async {
    final db = await database;
    final rows = await db.query(
      'taken_records',
      columns: ['id'],
      where: 'userId = ? AND medicineId = ? AND period = ? AND date = ?',
      whereArgs: [activeUserId, medicineId, period, date],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<List<TakenRecord>> getTakenRecords() async {
    final db = await database;
    final rows = await db.query(
      'taken_records',
      where: 'userId = ?',
      whereArgs: [activeUserId],
      orderBy: 'takenAt DESC',
    );
    final records = rows.map(TakenRecord.fromMap).toList();
    debugPrint('SQLite taken_records count=${records.length}');
    return records;
  }

  Future<void> clearAllData() async {
    final db = await database;
    await db.transaction((transaction) async {
      await transaction.delete(
        'taken_records',
        where: 'userId = ?',
        whereArgs: [activeUserId],
      );
      await transaction.delete(
        'medicines',
        where: 'userId = ?',
        whereArgs: [activeUserId],
      );
      final sessionTable = await transaction.rawQuery(
        "SELECT name FROM sqlite_master "
        "WHERE type = 'table' AND name = 'dose_sessions'",
      );
      if (sessionTable.isNotEmpty) {
        final sessions = await transaction.query(
          'dose_sessions',
          columns: ['sessionId'],
          where: 'userId = ?',
          whereArgs: [activeUserId],
        );
        final sessionIds = sessions
            .map((row) => row['sessionId'] as String?)
            .whereType<String>()
            .toList();
        final logTable = await transaction.rawQuery(
          "SELECT name FROM sqlite_master "
          "WHERE type = 'table' AND name = 'dose_item_logs'",
        );
        if (logTable.isNotEmpty) {
          for (final sessionId in sessionIds) {
            await transaction.delete(
              'dose_item_logs',
              where: 'sessionId = ?',
              whereArgs: [sessionId],
            );
          }
        }
        await transaction.delete(
          'dose_sessions',
          where: 'userId = ?',
          whereArgs: [activeUserId],
        );
      }
    });
  }
}
