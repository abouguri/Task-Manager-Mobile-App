import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../services/database_helper.dart';
import '../services/natural_language_schedule.dart';

class TaskProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Task> _tasks = [];
  bool _isLoading = false;
  String _searchQuery = '';

  List<Task> get allTasks => List.unmodifiable(_tasks);
  List<Task> get tasks => _visible(_tasks);
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  List<Task> forWhen(TaskWhen when) => _visible(
      _tasks.where((task) => task.when == when && !task.isCompleted).toList());
  List<Task> get logbook =>
      _visible(_tasks.where((task) => task.isCompleted).toList()
        ..sort((a, b) => (b.completedAt ?? b.createdAt)
            .compareTo(a.completedAt ?? a.createdAt)));

  List<Task> _visible(List<Task> source) {
    final query = _searchQuery.trim().toLowerCase();
    final results = query.isEmpty
        ? List<Task>.from(source)
        : source
            .where((task) =>
                task.title.toLowerCase().contains(query) ||
                (task.description?.toLowerCase().contains(query) ?? false) ||
                task.tags.any((tag) => tag.toLowerCase().contains(query)))
            .toList();
    results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return results;
  }

  Future<void> loadTasks() async {
    _isLoading = true;
    notifyListeners();
    try {
      _tasks = await _dbHelper.getAllTasks();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTask(Task task) async {
    final id = await _dbHelper.insertTask(task);
    _tasks.add(task.copyWith(id: id));
    notifyListeners();
  }

  Future<void> updateTask(Task task) async {
    await _dbHelper.updateTask(task);
    final index = _tasks.indexWhere((item) => item.id == task.id);
    if (index >= 0) _tasks[index] = task;
    notifyListeners();
  }

  Future<void> deleteTask(int id) async {
    await _dbHelper.deleteTask(id);
    _tasks.removeWhere((task) => task.id == id);
    notifyListeners();
  }

  Task? getTaskById(int id) {
    for (final task in _tasks) {
      if (task.id == id) return task;
    }
    return null;
  }

  Future<void> toggleTaskCompletion(Task task) async {
    final completing = !task.isCompleted;
    await updateTask(task.copyWith(
        isCompleted: completing,
        completedAt: completing ? DateTime.now() : null,
        clearCompletedAt: !completing));
    if (completing && task.recurrence != null) {
      final nextDate = NaturalLanguageSchedule.nextOccurrence(
          task.recurrence!, task.scheduledFor ?? DateTime.now());
      await addTask(Task(
          title: task.title,
          description: task.description,
          checklist: task.checklist
              .map((item) => ChecklistItem(title: item.title))
              .toList(),
          tags: task.tags,
          when: TaskWhen.date,
          scheduledFor: nextDate,
          deadline: task.deadline,
          projectId: task.projectId,
          areaId: task.areaId,
          recurrence: task.recurrence));
    }
  }

  Future<void> moveTo(Task task, TaskWhen when, {DateTime? date}) =>
      updateTask(task.copyWith(
          when: when,
          scheduledFor: date,
          clearScheduledFor: when != TaskWhen.date));
  void searchTasks(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearFilters() => searchTasks('');
}
