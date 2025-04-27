import 'package:flutter/material.dart';

class SeparatorPickerDialog extends StatelessWidget {
  final String title;
  final String currentPreference;
  final Map<String, String>
      options; // e.g., {'device': 'Device Default', 'dot': 'Dot (.)'}
  final Function(String) onSelected;

  const SeparatorPickerDialog({
    super.key,
    required this.title,
    required this.currentPreference,
    required this.options,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            ...options.entries.map((entry) {
              final preferenceKey = entry.key;
              final description = entry.value;
              final isSelected = currentPreference == preferenceKey;

              return RadioListTile<String>(
                title: Text(description),
                value: preferenceKey,
                groupValue: currentPreference,
                onChanged: (value) {
                  if (value != null) {
                    onSelected(value);
                    Navigator.pop(context);
                  }
                },
                selected: isSelected,
                activeColor: Theme.of(context).colorScheme.primary,
              );
            }),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
