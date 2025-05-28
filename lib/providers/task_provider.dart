// lib/providers/task_provider.dart
import 'dart:convert'; // For jsonDecode and jsonEncode
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quick_task_flutter/models/task_model.dart';
import 'package:quick_task_flutter/services/ai_service.dart'; // For PrioritizedTask model

const String _tasksStorageKey = 'com.example.quick_task_flutter.tasks_v3';

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
    final tasksJsonStrings = _prefs?.getStringList(_tasksStorageKey);
    if (tasksJsonStrings != null) {
      try {
        final loadedTasks = tasksJsonStrings
            .map((jsonString) {
          try {
            return Task.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
          } catch (e) {
            print("Error decoding individual task: $jsonString, Error: $e");
            return null;
          }})
            .whereType<Task>()
            .toList();
        state = loadedTasks;
      } catch (e) {
        print("Error loading tasks list from SharedPreferences: $e");
        state = [];
      }
    } else {
      state = [];
    }
  }

  Future<void> _saveTasks() async {
    await _initPrefs();
    try {
      final tasksJsonStrings = state.map((task) => jsonEncode(task.toJson())).toList();
      await _prefs?.setStringList(_tasksStorageKey, tasksJsonStrings);
    } catch (e) {
      print("Error saving tasks to SharedPreferences: $e");
    }
  }

  void addTask(Task newTask) {
    state = [newTask, ...state];
    _saveTasks();
  }

  // --- >>> ADD OR ENSURE THIS METHOD IS PRESENT <<< ---
  void editTask(Task updatedTask) {
    state = state.map((task) {
      return task.id == updatedTask.id ? updatedTask : task;
    }).toList();
    _saveTasks();
  }
  // --- >>> END OF editTask METHOD <<< ---

  void toggleTaskCompletion(String taskId) {
    state = state.map((task) {
      if (task.id == taskId) {
        return task.copyWith(isCompleted: !task.isCompleted);
      }
      return task;
    }).toList();
    _saveTasks();
  }

  void deleteTask(String taskId) {
    state = state.where((task) => task.id != taskId).toList();
    _saveTasks();
  }

  void updatePriorities(List<PrioritizedTask> prioritizedTasks) {
    final Map<String, int> priorityMap = {
      for (var pt in prioritizedTasks) pt.title.trim(): pt.priorityScore
    };

    state = state.map((task) {
      final taskTitleTrimmed = task.title.trim();
      if (priorityMap.containsKey(taskTitleTrimmed)) {
        return task.copyWith(priorityScore: priorityMap[taskTitleTrimmed]);
      } else {
        if (task.priorityScore != null) {
          return task.copyWith(resetPriorityScore: true);
        }
        return task;
      }
    }).toList();
    _saveTasks();
  }
}

final taskListProvider = StateNotifierProvider<TaskListNotifier, List<Task>>((ref) {
  return TaskListNotifier();
});