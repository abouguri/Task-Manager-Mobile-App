import 'package:flutter/foundation.dart' show kIsWeb;
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

  // In-memory storage for web platform
  static final List<Task> _webStorage = [];
  static int _webNextId = 1;

  // Database configuration
  static const String _databaseName = 'task_manager.db';
  static const int _databaseVersion = 5;
  static const String _tableName = 'tasks';

  /// Get database instance (create if doesn't exist)
  Future<Database> get database async {
    if (kIsWeb) {
      throw UnsupportedError('SQLite not supported on web');
    }
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
        priority TEXT NOT NULL DEFAULT 'None',
        category TEXT NOT NULL DEFAULT 'Inbox',
        tags TEXT NOT NULL DEFAULT '',
        checklist TEXT NOT NULL DEFAULT '[]',
        effortMinutes INTEGER NOT NULL DEFAULT 0,
        energyLevel TEXT NOT NULL DEFAULT 'Flexible',
        dueDate TEXT,
        whenValue TEXT NOT NULL DEFAULT 'inbox',
        scheduledFor TEXT,
        deadline TEXT,
        projectId TEXT,
        areaId TEXT,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        completedAt TEXT,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  /// Handle database upgrade
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      await db.execute(
          'ALTER TABLE $_tableName ADD COLUMN tags TEXT NOT NULL DEFAULT ""');
      await db.execute(
          'ALTER TABLE $_tableName ADD COLUMN effortMinutes INTEGER NOT NULL DEFAULT 15');
      await db.execute(
          'ALTER TABLE $_tableName ADD COLUMN energyLevel TEXT NOT NULL DEFAULT "Flexible"');
      await db.execute('ALTER TABLE $_tableName ADD COLUMN completedAt TEXT');
    }
    if (oldVersion < 4) {
      await db.execute(
          "ALTER TABLE $_tableName ADD COLUMN whenValue TEXT NOT NULL DEFAULT 'inbox'");
      await db.execute('ALTER TABLE $_tableName ADD COLUMN scheduledFor TEXT');
      await db.execute('ALTER TABLE $_tableName ADD COLUMN deadline TEXT');
      await db.execute('ALTER TABLE $_tableName ADD COLUMN projectId TEXT');
      await db.execute('ALTER TABLE $_tableName ADD COLUMN areaId TEXT');
      await db.execute(
          "UPDATE $_tableName SET scheduledFor = dueDate, whenValue = CASE WHEN dueDate IS NULL THEN 'inbox' ELSE 'date' END");
    }
    if (oldVersion < 5) {
      await db.execute(
          "ALTER TABLE $_tableName ADD COLUMN checklist TEXT NOT NULL DEFAULT '[]'");
    }
  }

  /// Insert a new task into the database
  Future<int> insertTask(Task task) async {
    try {
      if (kIsWeb) {
        // Web platform: use in-memory storage
        final newTask = task.copyWith(id: _webNextId++);
        _webStorage.add(newTask);
        return newTask.id!;
      }

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
      if (kIsWeb) {
        // Web platform: update in-memory storage
        final index = _webStorage.indexWhere((t) => t.id == task.id);
        if (index != -1) {
          _webStorage[index] = task;
          return 1;
        }
        return 0;
      }

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
      if (kIsWeb) {
        // Web platform: remove from in-memory storage
        final initialLength = _webStorage.length;
        _webStorage.removeWhere((task) => task.id == id);
        return initialLength - _webStorage.length;
      }

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
      if (kIsWeb) {
        // Web platform: return sorted in-memory storage
        final sortedTasks = List<Task>.from(_webStorage);
        sortedTasks.sort((a, b) {
          if (a.scheduledFor != null && b.scheduledFor != null) {
            return a.scheduledFor!.compareTo(b.scheduledFor!);
          } else if (a.scheduledFor != null) {
            return -1;
          } else if (b.dueDate != null) {
            return 1;
          }
          return b.createdAt.compareTo(a.createdAt);
        });
        return sortedTasks;
      }

      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        orderBy: 'scheduledFor ASC, createdAt DESC',
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
      if (kIsWeb) {
        // Web platform: search in-memory storage
        try {
          return _webStorage.firstWhere((task) => task.id == id);
        } catch (e) {
          return null;
        }
      }

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
      if (kIsWeb) {
        return _webStorage
            .where((task) => task.isCompleted == isCompleted)
            .toList();
      }

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
      if (kIsWeb) {
        return _webStorage.where((task) => task.priority == priority).toList();
      }

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
      if (kIsWeb) {
        return _webStorage.where((task) => task.category == category).toList();
      }

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
      if (kIsWeb) {
        return _webStorage.where((task) {
          return task.title.toLowerCase().contains(query.toLowerCase()) ||
              (task.description?.toLowerCase().contains(query.toLowerCase()) ??
                  false);
        }).toList();
      }

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
      if (kIsWeb) {
        _webStorage.clear();
        _webNextId = 1;
        return;
      }

      final db = await database;
      await db.delete(_tableName);
    } catch (e) {
      throw Exception('Error deleting all tasks: $e');
    }
  }

  /// Close the database
  Future<void> close() async {
    if (kIsWeb) {
      // No need to close anything on web
      return;
    }

    final db = await database;
    await db.close();
    _database = null;
  }
}
