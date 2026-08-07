import '../models/organization.dart';
import '../models/task.dart';

/// What [TaskProvider] needs from storage.
///
/// Declared separately from [DatabaseHelper] so the provider can be driven
/// against an in-memory store. `implements DatabaseHelper` would not compile
/// from another library: its private instance methods are part of its implicit
/// interface and cannot be satisfied outside `database_helper.dart`.
abstract class TaskStore {
  Future<List<Task>> getAllTasks();
  Future<int> insertTask(Task task);
  Future<int> updateTask(Task task);
  Future<int> deleteTask(int id);

  Future<List<Area>> getAreas();
  Future<int> insertArea(Area area);
  Future<int> updateArea(Area area);

  Future<List<Project>> getProjects();
  Future<int> insertProject(Project project);
  Future<int> updateProject(Project project);
}
