import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart' as model;
import 'firestore_service.dart';

class ExportService {
  final FirestoreService _firestoreService = FirestoreService();

  Future<String?> exportTransactionsToCSV() async {
    try {
      // Request storage permission
      if (!await _requestStoragePermission()) {
        throw Exception('Storage permission denied');
      }

      // Get transactions
      final transactions = await _firestoreService.getAllTransactions();
      if (transactions.isEmpty) {
        throw Exception('No transactions to export');
      }

      // Create CSV content
      final csvData = _createCSVContent(transactions);

      // Get downloads directory
      final downloadsDir = await _getDownloadsDirectory();
      if (downloadsDir == null) {
        throw Exception('Could not access downloads directory');
      }

      // Create file name with timestamp
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'fundi_transactions_$timestamp.csv';
      final file = File('${downloadsDir.path}/$fileName');

      // Write to file
      await file.writeAsString(csvData);
      return file.path;
    } catch (e) {
      print('Error exporting transactions: $e');
      return null;
    }
  }

  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      return status.isGranted;
    }
    return true; // iOS doesn't need explicit permission for downloads directory
  }

  Future<Directory?> _getDownloadsDirectory() async {
    if (Platform.isAndroid) {
      return Directory('/storage/emulated/0/Download');
    } else {
      return await getApplicationDocumentsDirectory();
    }
  }

  String _createCSVContent(List<model.Transaction> transactions) {
    final buffer = StringBuffer();
    
    // Add header
    buffer.writeln('Date,Type,Category,Amount');
    
    // Add transactions
    for (var transaction in transactions) {
      final date = DateFormat('yyyy-MM-dd HH:mm:ss').format(transaction.date);
      final amount = transaction.amount.toStringAsFixed(2);
      
      buffer.writeln('$date,${transaction.type},${transaction.category},$amount');
    }
    
    return buffer.toString();
  }
}
