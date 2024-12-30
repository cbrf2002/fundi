import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/models/transaction_model.dart' as model;

class AddTransactionDialog extends StatefulWidget {
  const AddTransactionDialog({Key? key}) : super(key: key);

  @override
  _AddTransactionDialogState createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<AddTransactionDialog> {
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  String _transactionType = 'expense';

  final List<String> _expenseCategories = [
    'Food', 'Transport', 'Utilities', 'Shopping', 'Entertainment', 'Health', 'Education', 'Rent'
  ];

  final List<String> _incomeCategories = [
    'Salary', 'Business', 'Investment', 'Freelance', 'Others'
  ];

  List<String> get _presetCategories {
    return _transactionType == 'expense' ? _expenseCategories : _incomeCategories;
  }

  void _addTransaction() async {
    final String category = _categoryController.text;
    final double amount = double.tryParse(_amountController.text) ?? 0.0;
    final String type = _transactionType;

    if (category.isEmpty || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid details.')),
      );
      return;
    }

    final transaction = model.Transaction(
      id: '', // Firestore will generate this
      category: category,
      amount: amount,
      date: DateTime.now(),
      type: type,
    );

    await FirebaseFirestore.instance.collection('transactions').add(transaction.toMap());

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transaction added successfully.')),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Column(
        children: [
          Icon(Icons.add, color: Theme.of(context).colorScheme.primary, size: 48),
          const SizedBox(height: 8),
          Text('Add New Transaction', style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('Expense'),
                  value: 'expense',
                  groupValue: _transactionType,
                  onChanged: (value) {
                    setState(() {
                      _transactionType = value!;
                      _categoryController.clear(); // Clear category when type changes
                    });
                  },
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('Income'),
                  value: 'income',
                  groupValue: _transactionType,
                  onChanged: (value) {
                    setState(() {
                      _transactionType = value!;
                      _categoryController.clear(); // Clear category when type changes
                    });
                  },
                ),
              ),
            ],
          ),
          TextField(
            controller: _categoryController,
            decoration: InputDecoration(
              labelText: 'Custom Category',
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
            decoration: const InputDecoration(labelText: 'Amount'),
            keyboardType: TextInputType.number,
          ),
        ],
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
