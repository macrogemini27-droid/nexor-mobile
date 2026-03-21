import 'package:flutter/material.dart';

class NewSessionDialog extends StatefulWidget {
  const NewSessionDialog({super.key});

  @override
  State<NewSessionDialog> createState() => _NewSessionDialogState();
}

class _NewSessionDialogState extends State<NewSessionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _directoryController = TextEditingController(text: '/home/user');

  @override
  void dispose() {
    _titleController.dispose();
    _directoryController.dispose();
    super.dispose();
  }

  void _create() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop({
        'title': _titleController.text.trim(),
        'directory': _directoryController.text.trim(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Session'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Session Title',
                hintText: 'e.g., Fix login bug',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _directoryController,
              decoration: const InputDecoration(
                labelText: 'Working Directory',
                hintText: '/home/user/project',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.folder),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a directory';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _create,
          child: const Text('Create'),
        ),
      ],
    );
  }
}
