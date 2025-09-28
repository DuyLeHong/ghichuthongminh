import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:quick_task_flutter/models/task_model.dart';
import 'package:quick_task_flutter/providers/task_provider.dart';
import 'package:quick_task_flutter/widgets/create_task_dialog.dart'; // To openthe edit dialog

class TaskListItem extends ConsumerWidget {
  final Task task;
  //final Task task2; // Flutter

  const TaskListItem({super.key, required this.task});

  void _showTaskDialog(BuildContext context, WidgetRef ref, Task? taskToEdit) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return CreateTaskDialog(taskToEdit: taskToEdit);
      },
    );
  }

  void _showDeleteConfirmationDialog(
      BuildContext context, WidgetRef ref, Task taskToDelete) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Delete Task?'),
        content: Text(
            'Are you sure you want to delete "${taskToDelete.title}"? This action cannot be undone.'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
          TextButton(
            child: Text('Delete',
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
            onPressed: () {
              ref.read(taskListProvider.notifier).deleteTask(taskToDelete.id);
              Navigator.of(dialogContext).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('"${taskToDelete.title}" deleted.')),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formattedDate = DateFormat.yMMMd().add_jm().format(task.createdAt);
    final bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    final Color cardBackgroundColor = task.isCompleted
        ? (isDarkTheme ? Colors.grey[850]! : Colors.grey[200]!)
        : (isDarkTheme ? Colors.grey[800]! : Colors.white);
    final Color baseTextColor = task.isCompleted
        ? (isDarkTheme ? Colors.grey[600]! : Colors.grey[500]!)
        : (isDarkTheme ? Colors.white70 : Colors.black87);
    final Color titleColor = task.isCompleted
        ? (isDarkTheme ? Colors.grey[500]! : Colors.grey[600]!)
        : (isDarkTheme ? Colors.white : Colors.black);

    final Color priorityChipColor;
    final Color priorityChipTextColor;

    if (task.priorityScore != null) {
      if (task.priorityScore! >= 8) {
        priorityChipColor =
            isDarkTheme ? Colors.red.shade700 : Colors.red.shade400;
        priorityChipTextColor = Colors.white;
      } else if (task.priorityScore! >= 5) {
        priorityChipColor =
            isDarkTheme ? Colors.orange.shade700 : Colors.orange.shade400;
        priorityChipTextColor = Colors.black;
      } else {
        priorityChipColor =
            isDarkTheme ? Colors.green.shade700 : Colors.green.shade400;
        priorityChipTextColor = Colors.black;
      }
    } else {
      priorityChipColor = Colors.transparent;
      priorityChipTextColor = Colors.transparent;
    }

    return Card(
      elevation: task.isCompleted ? 0.5 : 2.5,
      margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      color: cardBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: task.isCompleted
            ? BorderSide(
                color: isDarkTheme ? Colors.grey[700]! : Colors.grey[350]!,
                width: 0.5)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () =>
            ref.read(taskListProvider.notifier).toggleTaskCompletion(task.id),
        onLongPress: () => _showTaskDialog(context, ref, task),
        borderRadius: BorderRadius.circular(10.0),
        child: Opacity(
          opacity: task.isCompleted ? 0.65 : 1.0,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 12.0, 8.0, 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (task.imageUrl != null && task.imageUrl!.trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: 10.0, left: 12.0, right: 4.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        task.imageUrl!,
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (ctx, child, progress) => progress ==
                                null
                            ? child
                            : Container(
                                height: 160,
                                alignment: Alignment.center,
                                color: isDarkTheme
                                    ? Colors.grey[700]
                                    : Colors.grey[200],
                                child: CircularProgressIndicator(
                                  value: progress.expectedTotalBytes != null
                                      ? progress.cumulativeBytesLoaded /
                                          progress.expectedTotalBytes!
                                      : null,
                                  strokeWidth: 2.0,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                        errorBuilder: (ctx, error, stackTrace) {
                          print("ImgErr: ${task.imageUrl}, $error");
                          return Container(
                            height: 160,
                            alignment: Alignment.center,
                            color: isDarkTheme
                                ? Colors.grey[700]
                                : Colors.grey[200],
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.broken_image_outlined,
                                      color: isDarkTheme
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                      size: 48),
                                  const SizedBox(height: 8),
                                  Text('Image unavailable',
                                      style: TextStyle(
                                          color: isDarkTheme
                                              ? Colors.grey[400]
                                              : Colors.grey[600],
                                          fontSize: 12)),
                                ]),
                          );
                        },
                      ),
                    ),
                  ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 0.0),
                      // Align checkbox
                      child: Checkbox(
                        value: task.isCompleted,
                        onChanged: (val) => ref
                            .read(taskListProvider.notifier)
                            .toggleTaskCompletion(task.id),
                        activeColor: Theme.of(context).colorScheme.primary,
                        checkColor: Theme.of(context).colorScheme.onPrimary,
                        visualDensity: VisualDensity.compact,
                        side: BorderSide(
                            color: task.isCompleted
                                ? (isDarkTheme
                                    ? Colors.grey[600]!
                                    : Colors.grey[400]!)
                                : (isDarkTheme
                                    ? Colors.grey[400]!
                                    : Colors.grey[600]!),
                            width: 1.5),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 4.0, right: 4.0, top: 10.0),
                        // Top padding to align text with checkbox center
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // (Continuing from Part 5 - inside the Expanded -> Column children)
                            Text(
                              task.title,
                              style: TextStyle(
                                fontSize: 17.0,
                                fontWeight: FontWeight.w600,
                                color: titleColor,
                                decoration: task.isCompleted
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                                decorationColor: titleColor,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (task.description.isNotEmpty) ...[
                              const SizedBox(height: 4.0),
                              Text(
                                task.description,
                                style: TextStyle(
                                  fontSize: 13.5,
                                  color: baseTextColor,
                                  decoration: task.isCompleted
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                  decorationColor: baseTextColor,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            if (task.priorityScore != null) ...[
                              const SizedBox(height: 8.0),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Chip(
                                  label: Text(
                                    'Priority: ${task.priorityScore}',
                                    style: TextStyle(
                                        color: priorityChipTextColor,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  backgroundColor: priorityChipColor,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6.0, vertical: 0.0),
                                  visualDensity: VisualDensity.compact,
                                  labelStyle: TextStyle(height: 1),
                                  // Adjust line height for compact chip
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    // (Row continues with PopupMenuButton)
                    // (Continuing from Part 6 - still inside the main Row children, after Expanded)
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert_rounded, color: baseTextColor),
                      tooltip: "More options",
                      onSelected: (String result) {
                        if (result == 'edit') {
                          _showTaskDialog(context, ref, task);
                        } else if (result == 'delete') {
                          _showDeleteConfirmationDialog(context, ref, task);
                        }
                      },
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'edit',
                          child: ListTile(
                              leading: Icon(Icons.edit_outlined),
                              title: Text('Edit Task')),
                        ),
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: ListTile(
                              leading: Icon(Icons.delete_outline,
                                  color: Colors.redAccent),
                              title: Text('Delete Task',
                                  style: TextStyle(color: Colors.redAccent))),
                        ),
                      ],
                    ),
                  ],
                ),
                // (Column children continue with Date)
                // (Continuing from Part 7 - inside the main Column children, after the Row)
                const SizedBox(height: 8.0),
                Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  // Align with image/text block
                  child: Text(
                    'Created: $formattedDate',
                    style: TextStyle(
                      fontSize: 11.0,
                      fontStyle: FontStyle.italic,
                      color: task.isCompleted
                          ? (isDarkTheme ? Colors.grey[700] : Colors.grey[500])
                          : (isDarkTheme ? Colors.grey[500] : Colors.grey[600]),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  } // End of build method
} // End of TaskListItem class
