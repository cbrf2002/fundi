import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/models/transaction_model.dart';
import '../../../core/providers/formatting_provider.dart';

class AddTransactionDialog extends StatefulWidget {
  const AddTransactionDialog({super.key});

  @override
  AddTransactionDialogState createState() => AddTransactionDialogState();
}

class AddTransactionDialogState extends State<AddTransactionDialog> {
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  TransactionType _transactionType = TransactionType.expense;

  final List<String> _expenseCategories = [
    'Food', 'Transport', 'Utilities', 'Shopping', 'Entertainment', 'Health', 'Education', 'Rent'
  ];

  final List<String> _incomeCategories = [
    'Salary', 'Business', 'Investment', 'Freelance', 'Others'
  ];

  List<String> get _presetCategories {
    return _transactionType == TransactionType.expense ? _expenseCategories : _incomeCategories;
  }

  void _addTransaction() async {
    final String category = _categoryController.text;
    final double amount = double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0.0;

    if (category.isEmpty || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid details.')),
      );
      return;
    }

    final transaction = Transaction(
      id: '', // ID will be assigned in FirestoreService
      category: category,
      amount: amount,
      date: DateTime.now(),
      type: _transactionType,
    );

    try {
      final firestoreService = FirestoreService();
      await firestoreService.addTransaction(transaction);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction added successfully.')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding transaction: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattingProvider = Provider.of<FormattingProvider>(context);
    
    return AlertDialog(
      title: Column(
        children: [
          Icon(Icons.add, color: Theme.of(context).colorScheme.primary, size: 48),
          const SizedBox(height: 8),
          Text('Add New Transaction', style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: RadioListTile<TransactionType>(
                    title: const Text('Expense'),
                    value: TransactionType.expense,
                    groupValue: _transactionType,
                    onChanged: (value) {
                      setState(() {
                        _transactionType = value!;
                        _categoryController.clear();
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<TransactionType>(
                    title: const Text('Income'),
                    value: TransactionType.income,
                    groupValue: _transactionType,
                    onChanged: (value) {
                      setState(() {
                        _transactionType = value!;
                        _categoryController.clear();
                      });
                    },
                  ),
                ),
              ],
            ),
            TextField(
              controller: _categoryController,
              decoration: InputDecoration(
                labelText: 'Category',
                prefixIcon: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    icon: const Icon(Icons.arrow_drop_down),
                    value: _categoryController.text.isEmpty ? null : _categoryController.text,
                    hint: const Text('Select Category'),
                    onChanged: (value) {
                      setState(() {
                        _categoryController.text = value!;
                      });
                    },
                    items: _presetCategories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                  ),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _categoryController.clear();
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Amount',
                prefixText: formattingProvider.getCurrencySymbol(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _addTransaction,
          child: const Text('Add'),
        ),
      ],
    );
  }
}
