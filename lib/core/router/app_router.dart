import 'package:go_router/go_router.dart';
import '../../features/tasks/domain/entities/task.dart';
import '../../features/tasks/presentation/screens/task_list_screen.dart';
import '../../features/tasks/presentation/screens/task_form_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const TaskListScreen(),
    ),
    GoRoute(
      path: '/tasks/new',
      builder: (context, state) => const TaskFormScreen(),
    ),
    GoRoute(
      path: '/tasks/:id/edit',
      builder: (context, state) {
        final task = state.extra as Task?;
        return TaskFormScreen(existingTask: task);
      },
    ),
  ],
);