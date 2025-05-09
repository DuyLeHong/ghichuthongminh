import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_task_flutter/models/task_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quick_task_flutter/services/ai_service.dart'; // For PrioritizedTask model

const String _tasksStorageKey = 'quickTaskFlutter_tasks';

class TaskListNotifier extends StateNotifier<List<Task>> {
  TaskListNotifier() : super([]) {
    _loadTasks();
  }

  SharedPreferences? _prefs;

  Future<void> _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<void> _loadTasks() async {
    await _initPrefs();
    final tasksJson = _prefs?.getStringList(_tasksStorageKey);
    if (tasksJson != null) {
      state = tasksJson.map((json) => Task.fromJson(jsonDecode(json))).toList();
    }
  }

  Future<void> _saveTasks() async {
    await _initPrefs();
    final tasksJson = state.map((task) => jsonEncode(task.toJson())).toList();
    await _prefs?.setStringList(_tasksStorageKey, tasksJson);
  }

  void addTask(String title, String description) {
    state = [Task(title: title, description: description), ...state];
    _saveTasks();
  }

  void toggleTaskCompletion(String taskId) {
    state = [
      for (final task in state)
        if (task.id == taskId)
          task.copyWith(isCompleted: !task.isCompleted)
        else
          task,
    ];
    _saveTasks();
  }

  void deleteTask(String taskId) {
    state = state.where((task) => task.id != taskId).toList();
    _saveTasks();
  }
  
  void updatePriorities(List<PrioritizedTask> prioritizedTasks) {
    final Map<String, int> priorityMap = {
      for (var pt in prioritizedTasks) pt.title: pt.priorityScore
    };

    state = state.map((task) {
      // Match by title for simplicity, consider more robust matching if titles aren't unique
      if (priorityMap.containsKey(task.title)) {
        return task.copyWith(priorityScore: priorityMap[task.title]);
      }
      return task.copyWith(resetPriorityScore: true); // Reset if not in prioritized list
    }).toList();
    _saveTasks();
  }
}

final taskListProvider = StateNotifierProvider<TaskListNotifier, List<Task>>((ref) {
  return TaskListNotifier();
});
