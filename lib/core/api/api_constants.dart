class ApiConstants {
  static const String baseUrl = 'http://localhost:8000/api';

  static const String tasks = '/tasks';
  static String taskById(int id) => '/tasks/$id';
  static const String reorder = '/tasks/reorder';
}