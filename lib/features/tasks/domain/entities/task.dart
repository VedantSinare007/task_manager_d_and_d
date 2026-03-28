import 'package:flutter/foundation.dart';

enum TaskStatus { todo, inProgress, done }

extension TaskStatusExtension on TaskStatus {
  String get label {
    switch (this) {
      case TaskStatus.todo:
        return 'To-Do';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.done:
        return 'Done';
    }
  }

  static TaskStatus fromString(String s) {
    switch (s) {
      case 'In Progress':
        return TaskStatus.inProgress;
      case 'Done':
        return TaskStatus.done;
      default:
        return TaskStatus.todo;
    }
  }
}

@immutable
class Task {
  final int id;
  final String title;
  final String description;
  final DateTime? dueDate;
  final TaskStatus status;
  final int? blockedById;
  final int orderIndex;
  final bool isBlocked;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Task({
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

  Task copyWith({
    String? title,
    String? description,
    DateTime? dueDate,
    TaskStatus? status,
    int? blockedById,
    bool clearBlockedBy = false,
    int? orderIndex,
    bool? isBlocked,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      blockedById: clearBlockedBy ? null : (blockedById ?? this.blockedById),
      orderIndex: orderIndex ?? this.orderIndex,
      isBlocked: isBlocked ?? this.isBlocked,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}