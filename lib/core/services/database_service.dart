import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../features/user_profile/models/user_profile_model.dart';
import '../../features/usage_data/models/usage_data_model.dart';

/// Database Service for local data storage
class DatabaseService {
  static final DatabaseService instance = DatabaseService._internal();
  static Database? _database;

  DatabaseService._internal();

  /// Get database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize database
  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'carbon_footprint.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Create database tables
  Future<void> _onCreate(Database db, int version) async {
    // User Profile Table
    await db.execute('''
      CREATE TABLE user_profiles (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        age INTEGER NOT NULL,
        city TEXT NOT NULL,
        region TEXT NOT NULL,
        lifestyle_type TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        baseline_emission_factor REAL NOT NULL
      )
    ''');

    // Usage Data Entries Table
    await db.execute('''
      CREATE TABLE usage_entries (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        category TEXT NOT NULL,
        type TEXT NOT NULL,
        value REAL NOT NULL,
        unit TEXT NOT NULL,
        date TEXT NOT NULL,
        created_at TEXT NOT NULL,
        notes TEXT,
        co2_emission REAL NOT NULL,
        FOREIGN KEY (user_id) REFERENCES user_profiles (id)
      )
    ''');

    // Create indexes for faster queries
    await db.execute('''
      CREATE INDEX idx_usage_entries_user_id ON usage_entries (user_id)
    ''');
    await db.execute('''
      CREATE INDEX idx_usage_entries_date ON usage_entries (date)
    ''');
    await db.execute('''
      CREATE INDEX idx_usage_entries_category ON usage_entries (category)
    ''');
  }

  /// Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Drop old tables and recreate
    if (oldVersion < 2) {
      await db.execute('DROP TABLE IF EXISTS user_profiles');
      await db.execute('DROP TABLE IF EXISTS usage_entries');
      await _onCreate(db, newVersion);
    }
  }

  // ==================== User Profile Operations ====================

  /// Insert or update user profile
  Future<void> saveUserProfile(UserProfile profile) async {
    final db = await database;
    await db.insert(
      'user_profiles',
      profile.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get user profile by ID
  Future<UserProfile?> getUserProfile(String id) async {
    final db = await database;
    final maps = await db.query(
      'user_profiles',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return UserProfile.fromMap(maps.first);
    }
    return null;
  }

  /// Get current user profile (first one)
  Future<UserProfile?> getCurrentUserProfile() async {
    final db = await database;
    final maps = await db.query(
      'user_profiles',
      orderBy: 'created_at DESC',
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return UserProfile.fromMap(maps.first);
    }
    return null;
  }

  /// Get all user profiles
  Future<List<UserProfile>> getAllUserProfiles() async {
    final db = await database;
    final maps = await db.query('user_profiles', orderBy: 'created_at DESC');
    return maps.map((map) => UserProfile.fromMap(map)).toList();
  }

  /// Delete user profile
  Future<void> deleteUserProfile(String id) async {
    final db = await database;
    await db.delete(
      'user_profiles',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== Usage Data Operations ====================

  /// Insert usage data entry
  Future<void> saveUsageEntry(UsageDataEntry entry) async {
    final db = await database;
    await db.insert(
      'usage_entries',
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Insert multiple usage entries
  Future<void> saveUsageEntries(List<UsageDataEntry> entries) async {
    final db = await database;
    final batch = db.batch();
    for (final entry in entries) {
      batch.insert(
        'usage_entries',
        entry.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  /// Get usage entry by ID
  Future<UsageDataEntry?> getUsageEntry(String id) async {
    final db = await database;
    final maps = await db.query(
      'usage_entries',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return UsageDataEntry.fromMap(maps.first);
    }
    return null;
  }

  /// Get all usage entries for a user
  Future<List<UsageDataEntry>> getUserUsageEntries(String userId) async {
    final db = await database;
    final maps = await db.query(
      'usage_entries',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC, created_at DESC',
    );
    return maps.map((map) => UsageDataEntry.fromMap(map)).toList();
  }

  /// Get usage entries by category
  Future<List<UsageDataEntry>> getUsageEntriesByCategory(
    String userId,
    UsageCategory category,
  ) async {
    final db = await database;
    final maps = await db.query(
      'usage_entries',
      where: 'user_id = ? AND category = ?',
      whereArgs: [userId, category.name],
      orderBy: 'date DESC',
    );
    return maps.map((map) => UsageDataEntry.fromMap(map)).toList();
  }

  /// Get usage entries for date range
  Future<List<UsageDataEntry>> getUsageEntriesForDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await database;
    final maps = await db.query(
      'usage_entries',
      where: 'user_id = ? AND date >= ? AND date <= ?',
      whereArgs: [
        userId,
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
      orderBy: 'date DESC',
    );
    return maps.map((map) => UsageDataEntry.fromMap(map)).toList();
  }

  /// Get today's usage entries
  Future<List<UsageDataEntry>> getTodayUsageEntries(String userId) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return getUsageEntriesForDateRange(userId, startOfDay, endOfDay);
  }

  /// Get this week's usage entries
  Future<List<UsageDataEntry>> getThisWeekUsageEntries(String userId) async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startDate = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    return getUsageEntriesForDateRange(userId, startDate, now);
  }

  /// Delete usage entry
  Future<void> deleteUsageEntry(String id) async {
    final db = await database;
    await db.delete(
      'usage_entries',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Delete all usage entries for a user
  Future<void> deleteAllUserUsageEntries(String userId) async {
    final db = await database;
    await db.delete(
      'usage_entries',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  /// Get total CO2 emission for a user
  Future<double> getTotalCO2Emission(String userId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(co2_emission) as total FROM usage_entries WHERE user_id = ?',
      [userId],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  /// Get CO2 emission by category
  Future<Map<UsageCategory, double>> getCO2EmissionByCategory(
    String userId,
  ) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT category, SUM(co2_emission) as total 
      FROM usage_entries 
      WHERE user_id = ? 
      GROUP BY category
    ''', [userId]);

    final Map<UsageCategory, double> emissions = {};
    for (final row in result) {
      final category = UsageCategory.values.firstWhere(
        (c) => c.name == row['category'],
        orElse: () => UsageCategory.electricity,
      );
      emissions[category] = (row['total'] as num?)?.toDouble() ?? 0.0;
    }
    return emissions;
  }

  /// Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
