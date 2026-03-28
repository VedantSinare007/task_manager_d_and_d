import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/datasources/draft_cache_service.dart';
import '../../domain/entities/task.dart';
import '../providers/task_providers.dart';

class TaskFormScreen extends ConsumerStatefulWidget {
  final Task? existingTask; // null = create mode

  const TaskFormScreen({super.key, this.existingTask});

  @override
  ConsumerState<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends ConsumerState<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _draftService = DraftCacheService();

  TaskStatus _status = TaskStatus.todo;
  DateTime? _dueDate;
  int? _blockedById;
  bool _draftLoaded = false;

  bool get _isEdit => widget.existingTask != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      // Pre-fill from existing task
      final t = widget.existingTask!;
      _titleController.text = t.title;
      _descController.text = t.description;
      _status = t.status;
      _dueDate = t.dueDate;
      _blockedById = t.blockedById;
      _draftLoaded = true;
    } else {
      _loadDraft();
    }
    // Save draft on every keystroke
    _titleController.addListener(_saveDraft);
    _descController.addListener(_saveDraft);
  }

  Future<void> _loadDraft() async {
    final draft = await _draftService.loadDraft();
    if (draft != null && mounted) {
      setState(() {
        _titleController.text = draft['title'] as String;
        _descController.text = draft['description'] as String;
        _status = TaskStatusExtension.fromString(draft['status'] as String);
        _dueDate = draft['due_date'] as DateTime?;
        _blockedById = draft['blocked_by_id'] as int?;
        _draftLoaded = true;
      });
    } else {
      setState(() => _draftLoaded = true);
    }
  }

  void _saveDraft() {
    if (_isEdit) return; // don't pollute draft with edit session
    _draftService.saveDraft(
      title: _titleController.text,
      description: _descController.text,
      dueDate: _dueDate,
      status: _status.label,
      blockedById: _blockedById,
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(saveTaskProvider.notifier);
    bool success;

    if (_isEdit) {
      success = await notifier.updateTask(
        id: widget.existingTask!.id,
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        dueDate: _dueDate,
        status: _status,
        blockedById: _blockedById,
      );
    } else {
      success = await notifier.createTask(
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        dueDate: _dueDate,
        status: _status,
        blockedById: _blockedById,
      );
    }

    if (success && mounted) {
      if (!_isEdit) await _draftService.clearDraft();
      context.pop();
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppTheme.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
      _saveDraft();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final saveState = ref.watch(saveTaskProvider);
    final isSaving = saveState.isLoading;

    // Show error snackbar if save fails
    ref.listen(saveTaskProvider, (_, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${next.error}'),
            backgroundColor: Colors.red.shade400,
          ),
        );
      }
    });

    if (!_draftLoaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Task' : 'New Task'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: isSaving ? null : () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Title
            _SectionLabel('Title'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleController,
              enabled: !isSaving,
              decoration: const InputDecoration(hintText: 'Task title...'),
              textCapitalization: TextCapitalization.sentences,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Title is required' : null,
            ),
            const SizedBox(height: 20),

            // Description
            _SectionLabel('Description'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descController,
              enabled: !isSaving,
              decoration: const InputDecoration(hintText: 'Add details...'),
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 20),

            // Status dropdown
            _SectionLabel('Status'),
            const SizedBox(height: 8),
            DropdownButtonFormField<TaskStatus>(
              value: _status,
              decoration: const InputDecoration(),
              items: TaskStatus.values
                  .map((s) => DropdownMenuItem(value: s, child: Text(s.label)))
                  .toList(),
              onChanged: isSaving
                  ? null
                  : (val) {
                      if (val != null) {
                        setState(() => _status = val);
                        _saveDraft();
                      }
                    },
            ),
            const SizedBox(height: 20),

            // Due date
            _SectionLabel('Due Date'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: isSaving ? null : _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 18, color: AppTheme.textSecondary),
                    const SizedBox(width: 12),
                    Text(
                      _dueDate != null
                          ? DateFormat('MMMM d, yyyy').format(_dueDate!)
                          : 'Select a due date',
                      style: TextStyle(
                        color: _dueDate != null
                            ? AppTheme.textPrimary
                            : AppTheme.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    if (_dueDate != null)
                      GestureDetector(
                        onTap: () {
                          setState(() => _dueDate = null);
                          _saveDraft();
                        },
                        child: const Icon(Icons.clear_rounded,
                            size: 18, color: AppTheme.textSecondary),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Blocked by — loaded from task list
            _BlockedByField(
              currentTaskId: widget.existingTask?.id,
              selectedId: _blockedById,
              isSaving: isSaving,
              onChanged: (val) {
                setState(() => _blockedById = val);
                _saveDraft();
              },
            ),
            const SizedBox(height: 36),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSaving ? null : _submit,
                child: isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(_isEdit ? 'Save Changes' : 'Create Task'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Blocked-by dropdown (loads tasks from provider) ──────────────────────────
class _BlockedByField extends ConsumerWidget {
  final int? currentTaskId;
  final int? selectedId;
  final bool isSaving;
  final ValueChanged<int?> onChanged;

  const _BlockedByField({
    required this.currentTaskId,
    required this.selectedId,
    required this.isSaving,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(taskListProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel('Blocked By (optional)'),
        const SizedBox(height: 4),
        const Text(
          'This task won\'t be editable until the selected task is Done.',
          style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 8),
        tasksAsync.when(
          loading: () => const LinearProgressIndicator(),
          error: (_, __) => const Text('Could not load tasks',
              style: TextStyle(color: Colors.red)),
          data: (tasks) {
            // Exclude the task itself from the list
            final eligible = tasks
                .where((t) => t.id != currentTaskId)
                .toList();

            return DropdownButtonFormField<int?>(
              value: selectedId,
              decoration: const InputDecoration(hintText: 'None'),
              items: [
                const DropdownMenuItem(value: null, child: Text('None')),
                ...eligible.map(
                  (t) => DropdownMenuItem(value: t.id, child: Text(t.title)),
                ),
              ],
              onChanged: isSaving ? null : onChanged,
            );
          },
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppTheme.textSecondary,
          letterSpacing: 0.3,
        ),
      );
}