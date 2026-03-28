import 'package:shared_preferences/shared_preferences.dart';

/// Persists task form draft so the user never loses typed text
/// when they minimize the app or accidentally swipe back.
class DraftCacheService {
  static const _keyTitle = 'draft_title';
  static const _keyDescription = 'draft_description';
  static const _keyDueDate = 'draft_due_date';
  static const _keyStatus = 'draft_status';
  static const _keyBlockedById = 'draft_blocked_by_id';

  Future<void> saveDraft({
    required String title,
    required String description,
    DateTime? dueDate,
    required String status,
    int? blockedById,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyTitle, title);
    await prefs.setString(_keyDescription, description);
    await prefs.setString(_keyStatus, status);
    if (dueDate != null) {
      await prefs.setString(_keyDueDate, dueDate.toIso8601String());
    } else {
      await prefs.remove(_keyDueDate);
    }
    if (blockedById != null) {
      await prefs.setInt(_keyBlockedById, blockedById);
    } else {
      await prefs.remove(_keyBlockedById);
    }
  }

  Future<Map<String, dynamic>?> loadDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final title = prefs.getString(_keyTitle);
    if (title == null || title.isEmpty) return null;

    return {
      'title': title,
      'description': prefs.getString(_keyDescription) ?? '',
      'due_date': prefs.getString(_keyDueDate) != null
          ? DateTime.tryParse(prefs.getString(_keyDueDate)!)
          : null,
      'status': prefs.getString(_keyStatus) ?? 'To-Do',
      'blocked_by_id': prefs.getInt(_keyBlockedById),
    };
  }

  Future<void> clearDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyTitle);
    await prefs.remove(_keyDescription);
    await prefs.remove(_keyDueDate);
    await prefs.remove(_keyStatus);
    await prefs.remove(_keyBlockedById);
  }
}