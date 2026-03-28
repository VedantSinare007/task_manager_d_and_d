import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/task.dart';
import '../providers/task_providers.dart';

class TaskCard extends ConsumerWidget {
  final Task task;
  final VoidCallback onTap;

  const TaskCard({super.key, required this.task, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBlocked = task.isBlocked;

    return Slidable(
      key: ValueKey(task.id),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.22,
        children: [
          SlidableAction(
            onPressed: (_) async {
              final confirmed = await _confirmDelete(context);
              if (confirmed) {
                ref.read(deleteTaskProvider.notifier).deleteTask(task.id);
              }
            },
            backgroundColor: Colors.red.shade400,
            foregroundColor: Colors.white,
            icon: Icons.delete_outline_rounded,
            borderRadius: const BorderRadius.horizontal(right: Radius.circular(14)),
          ),
        ],
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isBlocked ? AppTheme.blocked : AppTheme.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isBlocked ? Colors.grey.shade300 : Colors.grey.shade200,
          ),
        ),
        child: InkWell(
          onTap: isBlocked ? null : onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isBlocked ? AppTheme.blockedText : AppTheme.textPrimary,
                          decoration: task.status == TaskStatus.done
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ),
                    _StatusBadge(status: task.status, isBlocked: isBlocked),
                  ],
                ),
                if (task.description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    task.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: isBlocked ? AppTheme.blockedText : AppTheme.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  children: [
                    if (task.dueDate != null) ...[
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 13,
                        color: isBlocked ? AppTheme.blockedText : AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('MMM d, yyyy').format(task.dueDate!),
                        style: TextStyle(
                          fontSize: 12,
                          color: isBlocked ? AppTheme.blockedText : AppTheme.textSecondary,
                        ),
                      ),
                    ],
                    const Spacer(),
                    if (isBlocked) _BlockedChip(),
                    if (!isBlocked)
                      Icon(Icons.chevron_right_rounded,
                          size: 18, color: AppTheme.textSecondary),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Delete task?'),
            content: Text('Are you sure you want to delete "${task.title}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
  }
}

class _StatusBadge extends StatelessWidget {
  final TaskStatus status;
  final bool isBlocked;

  const _StatusBadge({required this.status, required this.isBlocked});

  @override
  Widget build(BuildContext context) {
    final color = isBlocked ? AppTheme.blockedText : AppTheme.statusColor(status.label);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isBlocked ? 'Blocked' : status.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _BlockedChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Icon(Icons.lock_outline_rounded, size: 13, color: AppTheme.blockedText),
        SizedBox(width: 4),
        Text(
          'Waiting on another task',
          style: TextStyle(fontSize: 11, color: AppTheme.blockedText),
        ),
      ],
    );
  }
}