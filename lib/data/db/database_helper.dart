import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/restaurant.dart';
import '../model/reminder.dart';

class DatabaseHelper {
  static DatabaseHelper? _instance;
  static Database? _database;

  DatabaseHelper._internal() {
    _instance = this;
  }

  factory DatabaseHelper() => _instance ?? DatabaseHelper._internal();

  static const String _tblFavorite = 'favorites';
  static const String _tblReminder = 'reminders';

  Future<Database> _getDatabase() async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'restaurant.db');

    return await openDatabase(
      path,
      version: 2, // Incremented version for reminder table
      onCreate: (db, version) async {
        await _createTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createReminderTable(db);
        }
      },
    );
  }

  Future<void> _createTables(Database db) async {
    await _createFavoriteTable(db);
    await _createReminderTable(db);
  }

  Future<void> _createFavoriteTable(Database db) async {
    await db.execute('''
      CREATE TABLE $_tblFavorite (
        id TEXT PRIMARY KEY,
        name TEXT,
        description TEXT,
        pictureId TEXT,
        city TEXT,
        rating REAL
      )
    ''');
  }

  Future<void> _createReminderTable(Database db) async {
    await db.execute('''
      CREATE TABLE $_tblReminder (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        restaurant_id TEXT NOT NULL,
        restaurant_name TEXT NOT NULL,
        hour INTEGER NOT NULL,
        minute INTEGER NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        notification_message TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  // Favorite methods
  Future<void> insertFavorite(Restaurant restaurant) async {
    final db = await _getDatabase();
    await db.insert(_tblFavorite, restaurant.toMap());
  }

  Future<List<Restaurant>> getFavorites() async {
    final db = await _getDatabase();
    List<Map<String, dynamic>> results = await db.query(_tblFavorite);

    return results.map((res) => Restaurant.fromJson(res)).toList();
  }

  Future<Map> getFavoriteById(String id) async {
    final db = await _getDatabase();

    List<Map<String, dynamic>> results = await db.query(
      _tblFavorite,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (results.isNotEmpty) {
      return results.first;
    } else {
      return {};
    }
  }

  Future<void> removeFavorite(String id) async {
    final db = await _getDatabase();

    await db.delete(
      _tblFavorite,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Restaurant>> getFavoritesByName(String name) async {
    final db = await _getDatabase();
    List<Map<String, dynamic>> results = await db.query(
      _tblFavorite,
      where: 'name LIKE ?',
      whereArgs: ['%$name%'],
    );

    return results.map((res) => Restaurant.fromJson(res)).toList();
  }

  // Reminder methods
  Future<int> insertReminder(Reminder reminder) async {
    final db = await _getDatabase();
    return await db.insert(_tblReminder, reminder.toMap());
  }

  Future<List<Reminder>> getReminders() async {
    final db = await _getDatabase();
    List<Map<String, dynamic>> results = await db.query(
      _tblReminder,
      orderBy: 'hour ASC, minute ASC',
    );

    return results.map((res) => Reminder.fromMap(res)).toList();
  }

  Future<List<Reminder>> getActiveReminders() async {
    final db = await _getDatabase();
    List<Map<String, dynamic>> results = await db.query(
      _tblReminder,
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'hour ASC, minute ASC',
    );

    return results.map((res) => Reminder.fromMap(res)).toList();
  }

  Future<Reminder?> getReminderByRestaurantId(String restaurantId) async {
    final db = await _getDatabase();
    List<Map<String, dynamic>> results = await db.query(
      _tblReminder,
      where: 'restaurant_id = ? AND is_active = ?',
      whereArgs: [restaurantId, 1],
    );

    if (results.isNotEmpty) {
      return Reminder.fromMap(results.first);
    }
    return null;
  }

  Future<void> updateReminder(Reminder reminder) async {
    final db = await _getDatabase();
    await db.update(
      _tblReminder,
      reminder.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [reminder.id],
    );
  }

  Future<void> deleteReminder(int id) async {
    final db = await _getDatabase();
    await db.delete(
      _tblReminder,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteReminderByRestaurantId(String restaurantId) async {
    final db = await _getDatabase();
    await db.delete(
      _tblReminder,
      where: 'restaurant_id = ?',
      whereArgs: [restaurantId],
    );
  }

  Future<bool> hasActiveReminderForRestaurant(String restaurantId) async {
    final reminder = await getReminderByRestaurantId(restaurantId);
    return reminder != null;
  }

  Future<void> toggleReminderStatus(int id, bool isActive) async {
    final db = await _getDatabase();
    await db.update(
      _tblReminder,
      {
        'is_active': isActive ? 1 : 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}