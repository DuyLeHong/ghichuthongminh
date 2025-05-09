import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_task_flutter/models/task_model.dart';
import 'package:quick_task_flutter/providers/task_provider.dart';
import 'package:quick_task_flutter/services/ai_service.dart';
import 'package:quick_task_flutter/widgets/task_list_item.dart';
import 'package:quick_task_flutter/widgets/create_task_dialog.dart';

class TaskListScreen extends ConsumerStatefulWidget {
  const TaskListScreen({super.key});

  @override
  ConsumerState<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends ConsumerState<TaskListScreen> {
  bool _isPrioritizing = false;

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const CreateTaskDialog();
      },
    );
  }

  Future<void> _prioritizeTasks() async {
    final tasks = ref.read(taskListProvider);
    if (tasks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add some tasks before prioritizing.')),
      );
      return;
    }

    setState(() {
      _isPrioritizing = true;
    });

    try {
      final aiService = ref.read(aiServiceProvider);
      final prioritizedTasks = await aiService.prioritizeTasks(tasks);
      ref.read(taskListProvider.notifier).updatePriorities(prioritizedTasks);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tasks prioritized by AI!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error prioritizing tasks: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isPrioritizing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(taskListProvider);

    // Sort tasks: incomplete first, then by priority (higher first), then by creation date (newest first)
    final sortedTasks = List<Task>.from(tasks);
    sortedTasks.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      if (a.priorityScore != null && b.priorityScore != null) {
        if (a.priorityScore != b.priorityScore) {
          return b.priorityScore!.compareTo(a.priorityScore!);
        }
      } else if (a.priorityScore != null) {
        return -1; // a has priority, b doesn't
      } else if (b.priorityScore != null) {
        return 1; // b has priority, a doesn't
      }
      return b.createdAt.compareTo(a.createdAt);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('QuickTask'),
        actions: [
          IconButton(
            icon: _isPrioritizing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.auto_awesome_outlined), // Using a different AI icon
            onPressed: _isPrioritizing ? null : _prioritizeTasks,
            tooltip: 'AI Prioritize Tasks',
          ),
        ],
      ),
      body: tasks.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No tasks yet!',
                    style: TextStyle(fontSize: 20, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add a new task to get started.',
                    style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: sortedTasks.length,
              itemBuilder: (context, index) {
                final task = sortedTasks[index];
                return TaskListItem(task: task);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        tooltip: 'Add Task',
        child: const Icon(Icons.add),
      ),
    );
  }
}
