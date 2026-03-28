import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_constants.dart';
import '../models/task_model.dart';
import '../../domain/entities/task.dart';

class TaskRemoteDataSource {
  final Dio _dio = apiClient;

  Future<List<TaskModel>> getTasks({String? search, TaskStatus? status}) async {
    final params = <String, dynamic>{};
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (status != null) params['status'] = status.label;

    final response = await _dio.get(ApiConstants.tasks, queryParameters: params);
    final List data = response.data['tasks'] as List;
    return data.map((e) => TaskModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<TaskModel> createTask({
    required String title,
    required String description,
    DateTime? dueDate,
    required TaskStatus status,
    int? blockedById,
  }) async {
    final body = TaskModel.toCreateJson(
      title: title,
      description: description,
      dueDate: dueDate,
      status: status,
      blockedById: blockedById,
    );
    final response = await _dio.post(ApiConstants.tasks, data: body);
    return TaskModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<TaskModel> updateTask({
    required int id,
    required String title,
    required String description,
    DateTime? dueDate,
    required TaskStatus status,
    int? blockedById,
  }) async {
    final body = TaskModel.toCreateJson(
      title: title,
      description: description,
      dueDate: dueDate,
      status: status,
      blockedById: blockedById,
    );
    final response = await _dio.put(ApiConstants.taskById(id), data: body);
    return TaskModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteTask(int id) async {
    await _dio.delete(ApiConstants.taskById(id));
  }

  Future<List<TaskModel>> reorderTasks(List<int> orderedIds) async {
    final response = await _dio.patch(
      ApiConstants.reorder,
      data: {'ordered_ids': orderedIds},
    );
    final List data = response.data as List;
    return data.map((e) => TaskModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}