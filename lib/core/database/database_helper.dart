import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('savings_app.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 2, // bumped from 1 → 2 to trigger onUpgrade for indexes
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS goals (
        id          TEXT PRIMARY KEY,
        name        TEXT NOT NULL,
        targetAmount REAL NOT NULL,
        savedAmount  REAL NOT NULL DEFAULT 0,
        createdDate  TEXT,
        targetDate   TEXT,
        description  TEXT,
        iconCode     INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS transactions (
        id          TEXT PRIMARY KEY,
        goalId      TEXT NOT NULL,
        goalName    TEXT,
        description TEXT,
        amount      REAL NOT NULL,
        type        TEXT NOT NULL,
        date        TEXT NOT NULL,
        deletedDate TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS settings (
        key   TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS completed_history (
        id            INTEGER PRIMARY KEY AUTOINCREMENT,
        goalData      TEXT NOT NULL,
        completedDate TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS deleted_history (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        goalData    TEXT NOT NULL,
        deletedDate TEXT NOT NULL
      )
    ''');

    await _createIndexes(db);
  }

  // Called when version bumps (e.g. 1 → 2).
  // Safe to re-run — all statements use IF NOT EXISTS.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createIndexes(db);
    }
  }

  // FIX #4 (perf): indexes on hot query columns.
  // Speeds up per-goal filters, date range scans, deleted lookups, monthly GROUP BY.
  Future<void> _createIndexes(Database db) async {
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_txn_goalId  ON transactions(goalId)');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_txn_date    ON transactions(date)');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_txn_deleted ON transactions(deletedDate)');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_txn_type    ON transactions(type)');
  }

  // ── Core helpers ──

  Future<int> insert(
    String table,
    Map<String, dynamic> data, {
    ConflictAlgorithm conflictAlgorithm = ConflictAlgorithm.replace,
  }) async {
    final db = await database;
    return await db.insert(table, data, conflictAlgorithm: conflictAlgorithm);
  }

  Future<List<Map<String, dynamic>>> queryAll(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    final db = await database;
    return await db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  Future<Map<String, dynamic>?> queryFirst(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    final results = await db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> update(
    String table,
    Map<String, dynamic> data, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    return await db.update(table, data, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<dynamic>? args,
  ]) async {
    final db = await database;
    return await db.rawQuery(sql, args);
  }

  Future<int> rawUpdate(String sql, [List<dynamic>? args]) async {
    final db = await database;
    return await db.rawUpdate(sql, args);
  }

  // FIX #4: batch.commit() is properly awaited here.
  // Without await, callers' await resolves before disk write — silent data loss.
  Future<void> transaction(void Function(Batch batch) actions) async {
    final db = await database;
    final batch = db.batch();
    actions(batch);
    await batch.commit(noResult: true);
  }

  Future<void> clearTable(String table) async {
    final db = await database;
    await db.delete(table);
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
