
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quick_task_flutter/models/task.dart';

const String _tasksStorageKey = 'quickTask_tasks';

class LocalStorageService {
  Future<List<Task>> loadTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? tasksJson = prefs.getString(_tasksStorageKey);
      if (tasksJson != null && tasksJson.isNotEmpty) {
        return tasksFromJson(tasksJson);
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error loading tasks from SharedPreferences: $e');
      // Optionally, clear corrupted data
      // await clearTasks();
    }
    return [];
  }

  Future<void> saveTasks(List<Task> tasks) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String tasksJson = tasksToJson(tasks);
      await prefs.setString(_tasksStorageKey, tasksJson);
    } catch (e) {
      // ignore: avoid_print
      print('Error saving tasks to SharedPreferences: $e');
    }
  }

  Future<void> clearTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tasksStorageKey);
  }
}
