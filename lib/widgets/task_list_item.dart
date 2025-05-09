import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:quick_task_flutter/models/task_model.dart';
import 'package:quick_task_flutter/providers/task_provider.dart';

class TaskListItem extends ConsumerWidget {
  final Task task;

  const TaskListItem({super.key, required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeAgo = DateFormat.yMMMd().add_jm().format(task.createdAt);
    final bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: task.isCompleted ? 0.5 : 2.0,
      color: task.isCompleted
          ? (isDarkTheme ? Colors.grey[700] : Colors.grey[300])
          : (isDarkTheme ? Colors.grey[800] : Colors.white),
      child: Opacity(
        opacity: task.isCompleted ? 0.7 : 1.0,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          leading: Checkbox(
            value: task.isCompleted,
            onChanged: (bool? value) {
              ref.read(taskListProvider.notifier).toggleTaskCompletion(task.id);
            },
            // activeColor: Theme.of(context).colorScheme.primary,
          ),
          title: Text(
            task.title,
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w500,
              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
              color: task.isCompleted
                  ? (isDarkTheme ? Colors.grey[500] : Colors.grey[600])
                  : (isDarkTheme ? Colors.white : Colors.black87),
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (task.description.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
                  child: Text(
                    task.description,
                    style: TextStyle(
                      fontSize: 14.0,
                      decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                      color: task.isCompleted
                          ? (isDarkTheme ? Colors.grey[500] : Colors.grey[600])
                          : (isDarkTheme ? Colors.grey[300] : Colors.grey[700]),
                    ),
                  ),
                ),
              Text(
                'Created: $timeAgo',
                style: TextStyle(
                  fontSize: 12.0,
                  color: task.isCompleted
                      ? (isDarkTheme ? Colors.grey[600] : Colors.grey[500])
                      : (isDarkTheme ? Colors.grey[400] : Colors.grey[600]),
                ),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (task.priorityScore != null)
                Chip(
                  avatar: Icon(Icons.star, 
                    size: 16, 
                    color: task.priorityScore! > 7 
                           ? Colors.redAccent 
                           : (task.priorityScore! > 4 ? Colors.orangeAccent : Colors.greenAccent)
                  ),
                  label: Text('${task.priorityScore}', style: const TextStyle(fontSize: 12)),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  backgroundColor: task.isCompleted 
                    ? (isDarkTheme ? Colors.grey[650] : Colors.grey[200])
                    : (isDarkTheme ? Colors.grey[700] : Colors.grey[100]),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                const SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                onPressed: () {
                  ref.read(taskListProvider.notifier).deleteTask(task.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('"${task.title}" deleted.'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                },
                tooltip: 'Delete Task',
              ),
            ],
          ),
          onTap: () {
             // Optional: Could open a task detail screen here
          },
        ),
      ),
    );
  }
}
