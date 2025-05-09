import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_task_flutter/providers/task_provider.dart';

class CreateTaskDialog extends ConsumerStatefulWidget {
  const CreateTaskDialog({super.key});

  @override
  ConsumerState<CreateTaskDialog> createState() => _CreateTaskDialogState();
}

class _CreateTaskDialogState extends ConsumerState<CreateTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      ref.read(taskListProvider.notifier).addTask(_title, _description);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"${_title}" has been added.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create New Task'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView( // Added for potentially longer content
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter task title (e.g., Grocery Shopping)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title.';
                  }
                  if (value.trim().length < 3) {
                    return 'Title must be at least 3 characters.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _title = value ?? '';
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'Add more details about the task...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                onSaved: (value) {
                  _description = value ?? '';
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
          onPressed: _submit,
          child: const Text('Add Task'),
        ),
      ],
    );
  }
}
