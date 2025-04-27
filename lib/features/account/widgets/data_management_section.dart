import 'package:flutter/material.dart';

class DataManagementSection extends StatelessWidget {
  final VoidCallback onExport;
  // Add callback for delete all
  final VoidCallback onDeleteAll;

  const DataManagementSection({
    super.key,
    required this.onExport,
    required this.onDeleteAll, // Require the new callback
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Data Management'),
        ListTile(
          leading: const Icon(Icons.download),
          title: const Text('Export Data'),
          subtitle: const Text('Export your transactions as CSV'),
          onTap: onExport,
        ),
        // Add Delete All option
        ListTile(
          leading: Icon(Icons.delete_forever_rounded,
              color: Theme.of(context).colorScheme.error),
          title: Text('Delete All Transactions',
              style: TextStyle(color: Theme.of(context).colorScheme.error)),
          subtitle: Text('Permanently remove all transaction data',
              style: TextStyle(color: Theme.of(context).colorScheme.error)),
          onTap: onDeleteAll,
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}
