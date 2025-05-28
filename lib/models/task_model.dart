// lib/models/task_model.dart
import 'package:uuid/uuid.dart';

const uuid = Uuid();

class Task {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final bool isCompleted;
  final int? priorityScore; // Nullable, as it's assigned by AI or can be reset
  final String? imageUrl;   // Nullable, as images are optional

  Task({
    required this.title,
    this.description = '',
    DateTime? createdAt,
    this.isCompleted = false,
    this.priorityScore,
    this.imageUrl,
    String? id, // Allow providing an ID, e.g., when deserializing or for testing
  })  : id = id ?? uuid.v4(),
        createdAt = createdAt ?? DateTime.now();

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
    bool? isCompleted,
    int? priorityScore,      // Use this to set a new score
    bool? resetPriorityScore, // Set to true to explicitly make priorityScore null
    String? imageUrl,
  }) {
    return Task(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        createdAt: createdAt ?? this.createdAt,
        isCompleted: isCompleted ?? this.isCompleted,
        priorityScore: (resetPriorityScore == true)
        ? null // If resetPriorityScore is explicitly true, set score to null
        : (priorityScore ?? this.priorityScore), // Otherwise, use new or existing score
    imageUrl: imageUrl ?? this.imageUrl); // Use new or existing imageUrl);
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '', // Handle if description is missing
      createdAt: DateTime.parse(json['createdAt'] as String),
      isCompleted: json['isCompleted'] as bool? ?? false, // Handle if isCompleted is missing
      priorityScore: json['priorityScore'] as int?, // Nullable
      imageUrl: json['imageUrl'] as String?,      // Nullable
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'isCompleted': isCompleted,
      'priorityScore': priorityScore,
      'imageUrl': imageUrl,
    };
  }

  // Optional: For easier debugging and logging
  @override
  String toString() {
    return 'Task(id: $id, title: "$title", completed: $isCompleted, priority: $priorityScore, imageUrl: "$imageUrl")';
  }
}