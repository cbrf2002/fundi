import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/models/transaction_model.dart';
import '../../../core/providers/formatting_provider.dart';
import 'calculator_widget.dart';
import '../controllers/calculator_controller.dart'; // Import the controller

class AddTransactionDialog extends StatefulWidget {
  const AddTransactionDialog({super.key});

  @override
  AddTransactionDialogState createState() => AddTransactionDialogState();
}

class AddTransactionDialogState extends State<AddTransactionDialog> {
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  TransactionType _transactionType = TransactionType.expense;
  bool _showCalculator = false;

  // Create and manage the controller instance
  late final CalculatorController _calculatorController;

  // Categories lists remain here
  final List<String> _expenseCategories = [
    'Food',
    'Transport',
    'Utilities',
    'Shopping',
    'Entertainment',
    'Health',
    'Education',
    'Rent'
  ];

  final List<String> _incomeCategories = [
    'Salary',
    'Business',
    'Investment',
    'Freelance',
    'Others'
  ];

  List<String> get _presetCategories =>
      _transactionType == TransactionType.expense
          ? _expenseCategories
          : _incomeCategories;

  @override
  void initState() {
    super.initState();
    _calculatorController = CalculatorController();
    // Listen to the controller to update the amount field when a result is calculated
    _calculatorController.addListener(_onCalculatorUpdate);
  }

  @override
  void dispose() {
    _calculatorController.removeListener(_onCalculatorUpdate);
    _calculatorController.dispose();
    _categoryController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _onCalculatorUpdate() {
    // Check if the last action resulted in a final calculation
    if (_calculatorController.lastResult != null) {
      final formattingProvider =
          Provider.of<FormattingProvider>(context, listen: false);
      // Format the result without grouping separators for the text field
      String resultText =
          formattingProvider.formatAmountRaw(_calculatorController.lastResult!);
      String groupSep = formattingProvider.getThousandsSeparator();
      if (groupSep.isNotEmpty) {
        resultText = resultText.replaceAll(groupSep, '');
      }
      _amountController.text = resultText;
    }
    setState(() {});
  }

  void _addTransaction() async {
    final String category = _categoryController.text;
    final formattingProvider =
        Provider.of<FormattingProvider>(context, listen: false);
    final decimalSeparator = formattingProvider.getDecimalSeparator();
    final thousandsSeparator = formattingProvider.getThousandsSeparator();

    double parsedAmount = 0.0;
    try {
      String cleanedAmount = _amountController.text;
      if (thousandsSeparator.isNotEmpty) {
        cleanedAmount = cleanedAmount.replaceAll(thousandsSeparator, '');
      }
      cleanedAmount = cleanedAmount.replaceAll(decimalSeparator, '.');
      parsedAmount = double.parse(cleanedAmount);
    } catch (e) {
      parsedAmount = 0.0;
      print("Error parsing amount: $e");
    }

    // Ensure the amount is positive (absolute value)
    final double amount = parsedAmount.abs();

    if (category.isEmpty || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid details.')),
      );
      return;
    }

    final transaction = Transaction(
      id: '', // ID will be assigned in FirestoreService
      category: category,
      amount: amount, // Use the absolute amount
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
          Icon(Icons.add,
              color: Theme.of(context).colorScheme.primary, size: 48),
          const SizedBox(height: 8),
          Text('Add New Transaction',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center),
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
                    value: _categoryController.text.isEmpty
                        ? null
                        : _categoryController.text,
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
                suffixIcon: IconButton(
                  icon: Icon(
                    Icons.calculate_outlined,
                    color: _showCalculator
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  tooltip: 'Toggle Calculator',
                  onPressed: () {
                    setState(() {
                      _showCalculator = !_showCalculator;
                      if (_showCalculator) {
                        // Sync calculator with amount field when opening
                        _calculatorController.setAmountFromField(
                            context, _amountController.text);
                      }
                    });
                  },
                ),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              // Make field read-only when calculator is shown to avoid conflicts
              readOnly: _showCalculator,
              onTap: () {
                // Hide calculator if user taps into the field manually
                if (_showCalculator) {
                  setState(() {
                    _showCalculator = false;
                  });
                }
              },
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Visibility(
                visible: _showCalculator,
                child: Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  // Use CalculatorWidget connected to the controller
                  child: CalculatorWidget(
                    // Get display value from controller
                    displayValue: _calculatorController.output,
                    // Pass button presses to controller
                    onButtonPressed: (buttonText) => _calculatorController
                        .buttonPressed(context, buttonText),
                  ),
                ),
              ),
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
