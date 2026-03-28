import '../datasources/task_remote_datasource.dart';
import '../../domain/entities/task.dart';

class TaskRepository {
  final _remote = TaskRemoteDataSource();

  Future<List<Task>> getTasks({String? search, TaskStatus? status}) async {
    final models = await _remote.getTasks(search: search, status: status);
    return models.map((m) => m.toEntity()).toList();
  }

  Future<Task> createTask({
    required String title,
    required String description,
    DateTime? dueDate,
    required TaskStatus status,
    int? blockedById,
  }) async {
    final model = await _remote.createTask(
      title: title,
      description: description,
      dueDate: dueDate,
      status: status,
      blockedById: blockedById,
    );
    return model.toEntity();
  }

  Future<Task> updateTask({
    required int id,
    required String title,
    required String description,
    DateTime? dueDate,
    required TaskStatus status,
    int? blockedById,
  }) async {
    final model = await _remote.updateTask(
      id: id,
      title: title,
      description: description,
      dueDate: dueDate,
      status: status,
      blockedById: blockedById,
    );
    return model.toEntity();
  }

  Future<void> deleteTask(int id) => _remote.deleteTask(id);

  Future<List<Task>> reorderTasks(List<int> orderedIds) async {
    final models = await _remote.reorderTasks(orderedIds);
    return models.map((m) => m.toEntity()).toList();
  }
}