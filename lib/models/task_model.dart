import 'package:uuid/uuid.dart';

const uuid = Uuid();

class Task {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final DateTime createdAt;
  final int? priorityScore;

  Task({
    String? id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    DateTime? createdAt,
    this.priorityScore,
  })  : id = id ?? uuid.v4(),
        createdAt = createdAt ?? DateTime.now();

  Task copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? createdAt,
    int? priorityScore,
    bool resetPriorityScore = false, // special flag to nullify priority
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      priorityScore: resetPriorityScore ? null : (priorityScore ?? this.priorityScore),
    );
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      isCompleted: json['isCompleted'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      priorityScore: json['priorityScore'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'priorityScore': priorityScore,
    };
  }
}
