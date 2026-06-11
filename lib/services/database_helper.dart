import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import '../models/medicine.dart';
import '../models/taken_record.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _database;

  Future<Database> get database async {
    _database ??= await _openDatabase();
    return _database!;
  }

  Future<Database> _openDatabase() async {
    final databasesPath = await getDatabasesPath();
    return openDatabase(
      path.join(databasesPath, 'smart_medication.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE medicines(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
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
            medicineId INTEGER,
            medicineName TEXT,
            period TEXT,
            takenAt TEXT,
            date TEXT
          )
        ''');
      },
    );
  }

  Future<int> insertMedicine(Medicine medicine) async {
    final db = await database;
    final id = await db.insert('medicines', medicine.toMap());
    debugPrint('【SQLite寫入成功】table=medicines id=$id');
    return id;
  }

  Future<int> updateMedicine(Medicine medicine) async {
    if (medicine.id == null) {
      throw ArgumentError('Medicine id is required for update.');
    }
    final db = await database;
    return db.update(
      'medicines',
      medicine.toMap()..remove('id'),
      where: 'id = ?',
      whereArgs: [medicine.id],
    );
  }

  Future<List<Medicine>> getMedicines() async {
    final db = await database;
    final rows = await db.query('medicines', orderBy: 'createdAt DESC');
    final medicines = rows.map(Medicine.fromMap).toList();
    debugPrint('【SQLite讀取成功】table=medicines count=${medicines.length}');
    return medicines;
  }

  Future<int> deleteMedicine(int id) async {
    final db = await database;
    return db.transaction((transaction) async {
      await transaction.delete(
        'taken_records',
        where: 'medicineId = ?',
        whereArgs: [id],
      );
      return transaction.delete('medicines', where: 'id = ?', whereArgs: [id]);
    });
  }

  Future<int> insertTakenRecord(TakenRecord record) async {
    final db = await database;
    return db.insert('taken_records', record.toMap());
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
      where: 'medicineId = ? AND period = ? AND date = ?',
      whereArgs: [medicineId, period, date],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<List<TakenRecord>> getTakenRecords() async {
    final db = await database;
    final rows = await db.query('taken_records', orderBy: 'takenAt DESC');
    final records = rows.map(TakenRecord.fromMap).toList();
    debugPrint('【SQLite讀取成功】table=taken_records count=${records.length}');
    return records;
  }

  Future<void> clearAllData() async {
    final db = await database;
    await db.transaction((transaction) async {
      await transaction.delete('taken_records');
      await transaction.delete('medicines');
    });
  }
}
