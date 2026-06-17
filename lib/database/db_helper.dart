import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DbHelper {
  static const _databaseName = "elderly_medication.db";
  static const _databaseVersion = 1;

  DbHelper._privateConstructor();
  static final DbHelper instance = DbHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);
    
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    // 1. 藥品表（配合組長新規範，已加入 indication 欄位）
    await db.execute('''
      CREATE TABLE medicines (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT,
        dosage TEXT,
        frequency TEXT,
        timing TEXT,  -- JSON array string
        notice TEXT,
        startDate TEXT,
        endDate TEXT,
        imagePath TEXT,
        createdAt TEXT NOT NULL,
        indication TEXT DEFAULT ''
      )
    ''');

    // 2. 提醒表 (保留給組員 B 使用)
    await db.execute('''
      CREATE TABLE reminders (
        id TEXT PRIMARY KEY,
        medicineId TEXT NOT NULL,
        time TEXT NOT NULL,
        repeatType TEXT NOT NULL,
        enabled INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (medicineId) REFERENCES medicines(id)
      )
    ''');

    // 3. 服藥紀錄表 (組員 A 打卡核心)
    await db.execute('''
      CREATE TABLE dose_logs (
        id TEXT PRIMARY KEY,
        medicineId NOT NULL,
        scheduledTime TEXT NOT NULL,
        takenTime TEXT,
        status TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (medicineId) REFERENCES medicines(id)
      )
    ''');
  }
}