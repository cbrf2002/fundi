import 'package:flutter/material.dart';

class DataManagementSection extends StatelessWidget {
  final VoidCallback onExport;
  final VoidCallback onBackup;

  const DataManagementSection({
    super.key,
    required this.onExport,
    required this.onBackup,
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
        ListTile(
          leading: const Icon(Icons.backup),
          title: const Text('Backup Data'),
          onTap: onBackup,
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