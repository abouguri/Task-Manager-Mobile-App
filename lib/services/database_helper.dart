import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task.dart';

/// Singleton class to manage SQLite database operations
class DatabaseHelper {
  // Singleton instance
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  // Database instance
  static Database? _database;

  // Database configuration
  static const String _databaseName = 'task_manager.db';
  static const int _databaseVersion = 1;
  static const String _tableName = 'tasks';

  /// Get database instance (create if doesn't exist)
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize database
  Future<Database> _initDatabase() async {
    // Get the path to the database
    String path = join(await getDatabasesPath(), _databaseName);
    
    // Open the database
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Create database table
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        priority TEXT NOT NULL,
        category TEXT NOT NULL,
        dueDate TEXT,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  /// Handle database upgrade
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations here if needed in future versions
    if (oldVersion < newVersion) {
      // Example: Add new column
      // await db.execute('ALTER TABLE $_tableName ADD COLUMN newColumn TEXT');
    }
  }

  /// Insert a new task into the database
  Future<int> insertTask(Task task) async {
    try {
      final db = await database;
      return await db.insert(
        _tableName,
        task.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception('Error inserting task: $e');
    }
  }

  /// Update an existing task in the database
  Future<int> updateTask(Task task) async {
    try {
      final db = await database;
      return await db.update(
        _tableName,
        task.toMap(),
        where: 'id = ?',
        whereArgs: [task.id],
      );
    } catch (e) {
      throw Exception('Error updating task: $e');
    }
  }

  /// Delete a task from the database
  Future<int> deleteTask(int id) async {
    try {
      final db = await database;
      return await db.delete(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Error deleting task: $e');
    }
  }

  /// Get all tasks from the database
  Future<List<Task>> getAllTasks() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        orderBy: 'dueDate ASC, createdAt DESC',
      );

      return List.generate(maps.length, (i) {
        return Task.fromMap(maps[i]);
      });
    } catch (e) {
      throw Exception('Error getting all tasks: $e');
    }
  }

  /// Get a specific task by ID
  Future<Task?> getTaskById(int id) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (maps.isEmpty) return null;
      return Task.fromMap(maps.first);
    } catch (e) {
      throw Exception('Error getting task by ID: $e');
    }
  }

  /// Get tasks by completion status
  Future<List<Task>> getTasksByStatus(bool isCompleted) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'isCompleted = ?',
        whereArgs: [isCompleted ? 1 : 0],
        orderBy: 'dueDate ASC, createdAt DESC',
      );

      return List.generate(maps.length, (i) {
        return Task.fromMap(maps[i]);
      });
    } catch (e) {
      throw Exception('Error getting tasks by status: $e');
    }
  }

  /// Get tasks by priority
  Future<List<Task>> getTasksByPriority(String priority) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'priority = ?',
        whereArgs: [priority],
        orderBy: 'dueDate ASC, createdAt DESC',
      );

      return List.generate(maps.length, (i) {
        return Task.fromMap(maps[i]);
      });
    } catch (e) {
      throw Exception('Error getting tasks by priority: $e');
    }
  }

  /// Get tasks by category
  Future<List<Task>> getTasksByCategory(String category) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'category = ?',
        whereArgs: [category],
        orderBy: 'dueDate ASC, createdAt DESC',
      );

      return List.generate(maps.length, (i) {
        return Task.fromMap(maps[i]);
      });
    } catch (e) {
      throw Exception('Error getting tasks by category: $e');
    }
  }

  /// Search tasks by title or description
  Future<List<Task>> searchTasks(String query) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'title LIKE ? OR description LIKE ?',
        whereArgs: ['%$query%', '%$query%'],
        orderBy: 'dueDate ASC, createdAt DESC',
      );

      return List.generate(maps.length, (i) {
        return Task.fromMap(maps[i]);
      });
    } catch (e) {
      throw Exception('Error searching tasks: $e');
    }
  }

  /// Delete all tasks (for testing purposes)
  Future<void> deleteAllTasks() async {
    try {
      final db = await database;
      await db.delete(_tableName);
    } catch (e) {
      throw Exception('Error deleting all tasks: $e');
    }
  }

  /// Close the database
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
