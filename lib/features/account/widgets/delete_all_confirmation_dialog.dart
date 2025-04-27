import 'package:flutter/material.dart';

class DeleteAllConfirmationDialog extends StatefulWidget {
  final VoidCallback onConfirm;

  const DeleteAllConfirmationDialog({
    super.key,
    required this.onConfirm,
  });

  @override
  State<DeleteAllConfirmationDialog> createState() =>
      _DeleteAllConfirmationDialogState();
}

class _DeleteAllConfirmationDialogState
    extends State<DeleteAllConfirmationDialog> {
  final TextEditingController _confirmationController = TextEditingController();
  bool _canConfirm = false;

  @override
  void initState() {
    super.initState();
    _confirmationController.addListener(() {
      setState(() {
        _canConfirm =
            _confirmationController.text.trim().toLowerCase() == 'yes';
      });
    });
  }

  @override
  void dispose() {
    _confirmationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.warning_amber_rounded,
              color: Theme.of(context).colorScheme.error),
          const SizedBox(width: 8),
          const Text('Confirm Deletion'),
        ],
      ),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            const Text(
                'This action is irreversible and will permanently delete all your transaction data.'),
            const SizedBox(height: 16),
            Text(
              'Please type "yes" below to confirm:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _confirmationController,
              decoration: const InputDecoration(
                hintText: 'yes',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: _canConfirm
                ? Theme.of(context).colorScheme.error
                : Theme.of(context).disabledColor,
          ),
          onPressed: _canConfirm
              ? () {
                  Navigator.of(context).pop(); // Close dialog first
                  widget.onConfirm(); // Execute the confirmation action
                }
              : null, // Disable button if condition not met
          child: const Text('Confirm Delete'),
        ),
      ],
    );
  }
}
