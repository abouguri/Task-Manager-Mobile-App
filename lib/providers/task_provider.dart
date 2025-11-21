import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../services/database_helper.dart';

/// Provider class for managing task state and operations
class TaskProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  
  List<Task> _tasks = [];
  List<Task> _filteredTasks = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String? _filterPriority;
  String? _filterCategory;
  bool? _filterCompleted;

  // Getters
  List<Task> get tasks => _filteredTasks.isEmpty && _searchQuery.isEmpty 
      ? _tasks 
      : _filteredTasks;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String? get filterPriority => _filterPriority;
  String? get filterCategory => _filterCategory;
  bool? get filterCompleted => _filterCompleted;

  /// Load all tasks from database
  Future<void> loadTasks() async {
    _isLoading = true;
    notifyListeners();

    try {
      _tasks = await _dbHelper.getAllTasks();
      _applyFilters();
    } catch (e) {
      debugPrint('Error loading tasks: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add a new task
  Future<void> addTask(Task task) async {
    _isLoading = true;
    notifyListeners();

    try {
      final id = await _dbHelper.insertTask(task);
      final newTask = task.copyWith(id: id);
      _tasks.add(newTask);
      _applyFilters();
    } catch (e) {
      debugPrint('Error adding task: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update an existing task
  Future<void> updateTask(Task task) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _dbHelper.updateTask(task);
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = task;
        _applyFilters();
      }
    } catch (e) {
      debugPrint('Error updating task: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete a task
  Future<void> deleteTask(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _dbHelper.deleteTask(id);
      _tasks.removeWhere((task) => task.id == id);
      _applyFilters();
    } catch (e) {
      debugPrint('Error deleting task: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Toggle task completion status
  Future<void> toggleTaskCompletion(Task task) async {
    final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
    await updateTask(updatedTask);
  }

  /// Search tasks by title or description
  void searchTasks(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  /// Filter tasks by priority
  void filterByPriority(String? priority) {
    _filterPriority = priority;
    _applyFilters();
    notifyListeners();
  }

  /// Filter tasks by category
  void filterByCategory(String? category) {
    _filterCategory = category;
    _applyFilters();
    notifyListeners();
  }

  /// Filter tasks by completion status
  void filterByCompletion(bool? isCompleted) {
    _filterCompleted = isCompleted;
    _applyFilters();
    notifyListeners();
  }

  /// Clear all filters
  void clearFilters() {
    _searchQuery = '';
    _filterPriority = null;
    _filterCategory = null;
    _filterCompleted = null;
    _applyFilters();
    notifyListeners();
  }

  /// Apply all active filters
  void _applyFilters() {
    _filteredTasks = List.from(_tasks);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      _filteredTasks = _filteredTasks.where((task) {
        return task.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (task.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      }).toList();
    }

    // Apply priority filter
    if (_filterPriority != null) {
      _filteredTasks = _filteredTasks.where((task) {
        return task.priority == _filterPriority;
      }).toList();
    }

    // Apply category filter
    if (_filterCategory != null) {
      _filteredTasks = _filteredTasks.where((task) {
        return task.category == _filterCategory;
      }).toList();
    }

    // Apply completion status filter
    if (_filterCompleted != null) {
      _filteredTasks = _filteredTasks.where((task) {
        return task.isCompleted == _filterCompleted;
      }).toList();
    }

    // Sort tasks: incomplete first, then by due date, then by priority
    _filteredTasks.sort((a, b) {
      // First, sort by completion status (incomplete tasks first)
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }

      // Then sort by due date (tasks with due date first, null dates last)
      if (a.dueDate != null && b.dueDate != null) {
        return a.dueDate!.compareTo(b.dueDate!);
      } else if (a.dueDate != null) {
        return -1;
      } else if (b.dueDate != null) {
        return 1;
      }

      // Finally, sort by priority (High > Medium > Low)
      final priorityOrder = {'High': 0, 'Medium': 1, 'Low': 2};
      final aPriority = priorityOrder[a.priority] ?? 3;
      final bPriority = priorityOrder[b.priority] ?? 3;
      return aPriority.compareTo(bPriority);
    });
  }

  /// Get task by ID
  Task? getTaskById(int id) {
    try {
      return _tasks.firstWhere((task) => task.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get tasks count statistics
  Map<String, int> getTaskStats() {
    return {
      'total': _tasks.length,
      'completed': _tasks.where((t) => t.isCompleted).length,
      'pending': _tasks.where((t) => !t.isCompleted).length,
      'high': _tasks.where((t) => t.priority == 'High').length,
      'medium': _tasks.where((t) => t.priority == 'Medium').length,
      'low': _tasks.where((t) => t.priority == 'Low').length,
    };
  }
}
