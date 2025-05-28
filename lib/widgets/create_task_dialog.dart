// lib/widgets/create_task_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_task_flutter/models/task_model.dart';
import 'package:quick_task_flutter/providers/task_provider.dart';

class CreateTaskDialog extends ConsumerStatefulWidget {
  final Task? taskToEdit; // Nullable,if null, we are creating a new task

  const CreateTaskDialog({super.key, this.taskToEdit});

  @override
  ConsumerState<CreateTaskDialog> createState() => _CreateTaskDialogState();
}

class _CreateTaskDialogState extends ConsumerState<CreateTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _imageUrlController; // Controller for the image URL

  bool get _isEditing => widget.taskToEdit != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.taskToEdit?.title ?? '');
    _descriptionController = TextEditingController(text: widget.taskToEdit?.description ?? '');
    _imageUrlController = TextEditingController(text: widget.taskToEdit?.imageUrl ?? ''); // Initialize with existing URL
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose(); // Dispose the new controller
    super.dispose();}

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final title = _titleController.text.trim();
      final description = _descriptionController.text.trim();
      final imageUrl = _imageUrlController.text.trim(); // Get the image URL

      if (_isEditing) {
        // Update existing task
        final updatedTask = widget.taskToEdit!.copyWith(
          title: title,
          description: description,
          imageUrl: imageUrl.isNotEmpty ? imageUrl : null, // Store null if empty
        );
        ref.read(taskListProvider.notifier).editTask(updatedTask);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"${updatedTask.title}" updated.')),
        );
      } else {
        // Create new task
        final newTask = Task(
          title: title,
          description: description,
          imageUrl: imageUrl.isNotEmpty ? imageUrl : null, // Store null if empty
        );
        ref.read(taskListProvider.notifier).addTask(newTask);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"${newTask.title}" created.')),
        );
      }
      Navigator.of(context).pop(); // Close the dialog
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Edit Task' : 'Create New Task'),
      content: SingleChildScrollView( // In case content overflows
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter task title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'Enter task description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16), // <<< ADDED SizedBox
              TextFormField( // <<< ADDED TextFormField for Image URL
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Image URL (Optional)',
                  hintText: 'Enter direct image URL (e.g., .png, .jpg)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.url,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    // Basic URL validation (you might want a more robust one)
                    final uri = Uri.tryParse(value);
                    if (uri == null || !uri.hasAbsolutePath || (!uri.scheme.startsWith('http'))) {
                      return 'Please enter a valid URL (http/https)';
                    }
                  }
                  return null; // Allow empty
                },
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          onPressed: _submitForm,
          child: Text(_isEditing ? 'Save Changes' : 'Create Task'),
        ),
      ],
    );
  }
}