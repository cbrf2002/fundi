import 'package:intl/intl.dart';
import '../models/transaction_model.dart';

class ExportService {
  // Change return type to String
  Future<String> exportTransactionsToCSV(List<Transaction> transactions) async {
    if (transactions.isEmpty) {
      throw Exception('No transactions to export.');
    }

    // Prepare CSV data (existing code)
    final List<List<String>> csvData = [
      ['ID', 'Date', 'Category', 'Amount', 'Type']
    ];
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    for (var transaction in transactions) {
      csvData.add([
        transaction.id,
        formatter.format(transaction.date),
        transaction.category,
        transaction.amount.toStringAsFixed(2),
        transaction.type.toString().split('.').last
      ]);
    }

    // Convert to CSV string (existing code)
    String csvString =
        csvData.map((row) => row.map(_escapeCsvField).join(',')).join('\n');

    // Remove file saving logic
    /*
    try {
      // Get directory ... (removed)
      // ...
      // Write to file ... (removed)
      // ...
      return filePath; // Now returns csvString
    } catch (e) {
      print('Error exporting CSV: $e');
      throw Exception('Failed to export data: $e');
    }
    */

    // Return the CSV content directly
    return csvString;
  }

  // Helper to escape fields containing commas, quotes, or newlines (existing code)
  String _escapeCsvField(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }
}
