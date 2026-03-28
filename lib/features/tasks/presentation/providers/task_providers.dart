import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/task_repository.dart';
import '../../domain/entities/task.dart';

// ── Repository provider ──────────────────────────────────────────────────────
final taskRepositoryProvider = Provider<TaskRepository>((ref) => TaskRepository());

// ── Search & filter state ────────────────────────────────────────────────────
final searchQueryProvider = StateProvider<String>((ref) => '');
final statusFilterProvider = StateProvider<TaskStatus?>((ref) => null);

// ── Task list provider ───────────────────────────────────────────────────────
final taskListProvider = FutureProvider.autoDispose<List<Task>>((ref) async {
  final repo = ref.watch(taskRepositoryProvider);
  final search = ref.watch(searchQueryProvider);
  final status = ref.watch(statusFilterProvider);
  return repo.getTasks(
    search: search.isEmpty ? null : search,
    status: status,
  );
});

// ── Save task notifier (handles create + update + loading state) ─────────────
class SaveTaskNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> createTask({
    required String title,
    required String description,
    DateTime? dueDate,
    required TaskStatus status,
    int? blockedById,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(taskRepositoryProvider).createTask(
          title: title,
          description: description,
          dueDate: dueDate,
          status: status,
          blockedById: blockedById,
        ));
    if (!state.hasError) {
      ref.invalidate(taskListProvider);
      return true;
    }
    return false;
  }

  Future<bool> updateTask({
    required int id,
    required String title,
    required String description,
    DateTime? dueDate,
    required TaskStatus status,
    int? blockedById,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(taskRepositoryProvider).updateTask(
          id: id,
          title: title,
          description: description,
          dueDate: dueDate,
          status: status,
          blockedById: blockedById,
        ));
    if (!state.hasError) {
      ref.invalidate(taskListProvider);
      return true;
    }
    return false;
  }
}

final saveTaskProvider = AsyncNotifierProvider<SaveTaskNotifier, void>(SaveTaskNotifier.new);

// ── Delete task notifier ─────────────────────────────────────────────────────
class DeleteTaskNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> deleteTask(int id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(taskRepositoryProvider).deleteTask(id),
    );
    if (!state.hasError) ref.invalidate(taskListProvider);
  }
}

final deleteTaskProvider = AsyncNotifierProvider<DeleteTaskNotifier, void>(DeleteTaskNotifier.new);

// ── Reorder notifier ─────────────────────────────────────────────────────────
class ReorderTaskNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> reorder(List<int> orderedIds) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(taskRepositoryProvider).reorderTasks(orderedIds),
    );
    if (!state.hasError) ref.invalidate(taskListProvider);
  }
}

final reorderTaskProvider = AsyncNotifierProvider<ReorderTaskNotifier, void>(ReorderTaskNotifier.new);