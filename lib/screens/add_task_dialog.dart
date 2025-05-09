
import 'package:flutter/material.dart';

class AddTaskDialog extends StatefulWidget {
  final Function(String title, String description) onAddTask;

  const AddTaskDialog({super.key, required this.onAddTask});

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      widget.onAddTask(_title, _description);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create New Task'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView( // To prevent overflow if keyboard appears
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'e.g., Grocery Shopping',
                  icon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  if (value.length < 3) {
                    return 'Title must be at least 3 characters';
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
                  icon: Icon(Icons.description),
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
        ElevatedButton.icon(
          icon: const Icon(Icons.add_circle_outline),
          label: const Text('Add Task'),
          onPressed: _submit,
        ),
      ],
    );
  }
}
