
import 'dart:convert';

class Task {
  final String id;
  String title;
  String description;
  bool completed;
  final DateTime createdAt;
  int? priorityScore;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.completed = false,
    required this.createdAt,
    this.priorityScore,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'completed': completed,
      'createdAt': createdAt.toIso8601String(),
      'priorityScore': priorityScore,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      completed: json['completed'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      priorityScore: json['priorityScore'] as int?,
    );
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    bool? completed,
    DateTime? createdAt,
    int? priorityScore,
    bool setPriorityScoreToNull = false,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
      priorityScore: setPriorityScoreToNull ? null : (priorityScore ?? this.priorityScore),
    );
  }
}

// Helper types for AI service
class AiTaskInput {
  final String title;
  final String description;

  AiTaskInput({required this.title, required this.description});

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
      };
}

class AiPrioritizedTask {
  final String title;
  final String description;
  final int priorityScore;

  AiPrioritizedTask({
    required this.title,
    required this.description,
    required this.priorityScore,
  });

  factory AiPrioritizedTask.fromJson(Map<String, dynamic> json) {
    return AiPrioritizedTask(
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      priorityScore: (json['priorityScore'] as num).toInt(),
    );
  }
}

String tasksToJson(List<Task> tasks) {
  return jsonEncode(tasks.map((task) => task.toJson()).toList());
}

List<Task> tasksFromJson(String str) {
  final jsonData = jsonDecode(str) as List<dynamic>;
  return jsonData.map((item) => Task.fromJson(item as Map<String, dynamic>)).toList();
}
