import 'package:task_manager/models/organization.dart';
import 'package:task_manager/models/task.dart';
import 'package:task_manager/services/task_store.dart';

/// An in-memory [TaskStore] for driving [TaskProvider] under test.
///
/// Round-trips everything through `toMap`/`fromMap` so a field the model
/// forgets to serialise fails here rather than only in a real database.
class FakeTaskStore implements TaskStore {
  FakeTaskStore({this.failOnLoad = false});

  /// Makes the three read calls throw, standing in for a platform with no
  /// SQLite plugin.
  final bool failOnLoad;

  final List<Map<String, dynamic>> tasks = [];
  final List<Map<String, dynamic>> areas = [];
  final List<Map<String, dynamic>> projects = [];

  int _nextTaskId = 1;
  int _nextAreaId = 1;
  int _nextProjectId = 1;

  /// Every write the provider made, in order — lets a test assert that it
  /// persisted, not merely that it updated its own list.
  final List<String> writes = [];

  @override
  Future<List<Task>> getAllTasks() async {
    if (failOnLoad) throw StateError('no database');
    return tasks.map(Task.fromMap).toList();
  }

  @override
  Future<int> insertTask(Task task) async {
    final id = _nextTaskId++;
    tasks.add({...task.copyWith(id: id).toMap(), 'id': id});
    writes.add('insertTask:${task.title}');
    return id;
  }

  @override
  Future<int> updateTask(Task task) async {
    final index = tasks.indexWhere((row) => row['id'] == task.id);
    if (index < 0) return 0;
    tasks[index] = task.toMap();
    writes.add('updateTask:${task.id}');
    return 1;
  }

  @override
  Future<int> deleteTask(int id) async {
    tasks.removeWhere((row) => row['id'] == id);
    writes.add('deleteTask:$id');
    return 1;
  }

  @override
  Future<List<Area>> getAreas() async {
    if (failOnLoad) throw StateError('no database');
    return areas.map(Area.fromMap).toList();
  }

  @override
  Future<int> insertArea(Area area) async {
    final id = _nextAreaId++;
    areas.add({...area.copyWith(id: id).toMap(), 'id': id});
    return id;
  }

  @override
  Future<int> updateArea(Area area) async {
    final index = areas.indexWhere((row) => row['id'] == area.id);
    if (index < 0) return 0;
    areas[index] = area.toMap();
    return 1;
  }

  @override
  Future<List<Project>> getProjects() async {
    if (failOnLoad) throw StateError('no database');
    return projects.map(Project.fromMap).toList();
  }

  @override
  Future<int> insertProject(Project project) async {
    final id = _nextProjectId++;
    projects.add({...project.copyWith(id: id).toMap(), 'id': id});
    return id;
  }

  @override
  Future<int> updateProject(Project project) async {
    final index = projects.indexWhere((row) => row['id'] == project.id);
    if (index < 0) return 0;
    projects[index] = project.toMap();
    writes.add('updateProject:${project.id}');
    return 1;
  }

  /// The stored row for a task, as it would come back from disk.
  Task storedTask(int id) =>
      Task.fromMap(tasks.firstWhere((row) => row['id'] == id));

  Project storedProject(int id) =>
      Project.fromMap(projects.firstWhere((row) => row['id'] == id));
}
