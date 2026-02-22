import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/carbon_entry.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('ecotrack.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _crateDB,
    );
  }

  Future _crateDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT';
    const realType = 'REAL';

    await db.execute('''
    CREATE TABLE carbon_entries ( 
      id $idType, 
      date $textType,
      category $textType,
      amount $realType,
      carbonValue $realType
    )
    ''');
  }

  Future<int> insertEntry(CarbonEntry entry) async {
    final db = await instance.database;
    return await db.insert('carbon_entries', entry.toMap());
  }

  Future<List<CarbonEntry>> getAllEntries() async {
    final db = await instance.database;
    final result = await db.query('carbon_entries');
    return result.map((json) => CarbonEntry.fromMap(json)).toList();
  }

  Future<int> deleteEntry(int id) async {
    final db = await instance.database;
    return await db.delete(
      'carbon_entries',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
