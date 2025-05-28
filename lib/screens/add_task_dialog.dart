import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_task_flutter/models/task_model.dart';
import 'package:quick_task_flutter/providers/task_provider.dart';
import 'package:uuid/uuid.dart'; // For generating unique IDs

class CreateTaskDialog extends ConsumerStatefulWidget {
  final Task? taskToEdit; // Null if creating a new task

  const CreateTaskDialog({super.key, this.taskToEdit});

  @override
  ConsumerState<CreateTaskDialog> createState() => _CreateTaskDialogState();
}

class _CreateTaskDialogState extends ConsumerState<CreateTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _imageUrlController; // For image URL

  bool get _isEditing => widget.taskToEdit != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.taskToEdit?.title ?? '');
    _descriptionController = TextEditingController(text: widget.taskToEdit?.description ?? '');
    _imageUrlController = TextEditingController(text: widget.taskToEdit?.imageUrl ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // Triggers onSaved callbacks

      final title = _titleController.text.trim();
      final description = _descriptionController.text.trim();
      final imageUrl = _imageUrlController.text.trim();

      if (_isEditing) {
        final updatedTask = widget.taskToEdit!.copyWith(
          title: title,
          description: description,
          imageUrl: imageUrl.isNotEmpty ? imageUrl : null,
          // Retain other properties like id, createdAt, isCompleted, priorityScore
        );
        ref.read(taskListProvider.notifier).editTask(updatedTask);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"${updatedTask.title}" updated.')),
        );
      } else {
        final newTask = Task(
          id: const Uuid().v4(), // Generate a unique ID
          title: title,
          description: description,
          imageUrl: imageUrl.isNotEmpty ? imageUrl : null,
          createdAt: DateTime.now(),
        );
        ref.read(taskListProvider.notifier).addTask(newTask);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"${newTask.title}" added.')),
        );
      }
      Navigator.of(context).pop(); // Close the dialog
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      title: Text(_isEditing ? 'Edit Task' : 'Create New Task'),
      contentPadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 0), //Adjust padding
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title*',
                  hintText: 'e.g., Grocery Shopping',
                  icon: Icon(Icons.title_rounded),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  if (value.trim().length < 3) {
                    return 'Title must be at least 3 characters';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Add more details (optional)',
                  icon: Icon(Icons.description_outlined),
                ),
                maxLines: 3,
                minLines: 1,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Image URL',
                  hintText: 'e.g., https://example.com/image.png (optional)',
                  icon: Icon(Icons.image_outlined),
                ),
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submitForm(), // Submit on done
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final uri = Uri.tryParse(value);
                    if (uri == null || (!uri.isScheme("HTTP") && !uri.isScheme("HTTPS"))) {
                      return 'Please enter a valid HTTP/HTTPS URL';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20), // Space before buttons
            ],
          ),
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween, // Align buttons
      actionsPadding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton.icon(
          icon: Icon(_isEditing ? Icons.save_alt_outlined : Icons.add_circle_outline),
          label: Text(_isEditing ? 'Save Changes' : 'Add Task'),
          onPressed: _submitForm,
          style: ElevatedButton.styleFrom(
            backgroundColor: isDarkTheme ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).colorScheme.primary,
            foregroundColor: isDarkTheme ? Theme.of(context).colorScheme.onPrimaryContainer : Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ],
    );
  }
}