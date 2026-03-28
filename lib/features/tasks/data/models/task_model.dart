import 'package:intl/intl.dart';
import '../../domain/entities/task.dart';

class TaskModel {
  final int id;
  final String title;
  final String description;
  final String? dueDate;
  final String status;
  final int? blockedById;
  final int orderIndex;
  final bool isBlocked;
  final String createdAt;
  final String updatedAt;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    this.dueDate,
    required this.status,
    this.blockedById,
    required this.orderIndex,
    required this.isBlocked,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) => TaskModel(
        id: json['id'] as int,
        title: json['title'] as String,
        description: json['description'] as String? ?? '',
        dueDate: json['due_date'] as String?,
        status: json['status'] as String,
        blockedById: json['blocked_by_id'] as int?,
        orderIndex: json['order_index'] as int? ?? 0,
        isBlocked: json['is_blocked'] as bool? ?? false,
        createdAt: json['created_at'] as String,
        updatedAt: json['updated_at'] as String,
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'due_date': dueDate,
        'status': status,
        'blocked_by_id': blockedById,
      };

  Task toEntity() => Task(
        id: id,
        title: title,
        description: description,
        dueDate: dueDate != null ? DateTime.tryParse(dueDate!) : null,
        status: TaskStatusExtension.fromString(status),
        blockedById: blockedById,
        orderIndex: orderIndex,
        isBlocked: isBlocked,
        createdAt: DateTime.parse(createdAt),
        updatedAt: DateTime.parse(updatedAt),
      );

  static Map<String, dynamic> toCreateJson({
    required String title,
    required String description,
    DateTime? dueDate,
    required TaskStatus status,
    int? blockedById,
  }) =>
      {
        'title': title,
        'description': description,
        'due_date': dueDate != null
            ? DateFormat('yyyy-MM-dd').format(dueDate)
            : null,
        'status': status.label,
        'blocked_by_id': blockedById,
      };
}