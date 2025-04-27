import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/models/transaction_model.dart';
import '../../../core/providers/formatting_provider.dart';
import '../../dashboard/widgets/calculator_widget.dart'; // Reuse calculator
import '../../dashboard/controllers/calculator_controller.dart'; // Reuse controller

class EditTransactionDialog extends StatefulWidget {
  final Transaction transaction;

  const EditTransactionDialog({super.key, required this.transaction});

  @override
  EditTransactionDialogState createState() => EditTransactionDialogState();
}

class EditTransactionDialogState extends State<EditTransactionDialog> {
  late final TextEditingController _categoryController;
  late final TextEditingController _amountController;
  late TransactionType _transactionType;
  late DateTime _selectedDate;
  bool _showCalculator = false;

  late final CalculatorController _calculatorController;

  // Categories lists (same as AddTransactionDialog)
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
    // Initialize state from the existing transaction
    _categoryController =
        TextEditingController(text: widget.transaction.category);
    _transactionType = widget.transaction.type;
    _selectedDate = widget.transaction.date;

    // Initialize amount controller with formatted existing amount
    final formattingProvider =
        Provider.of<FormattingProvider>(context, listen: false);
    String initialAmountText =
        formattingProvider.formatAmountRaw(widget.transaction.amount);
    String groupSep = formattingProvider.getThousandsSeparator();
    if (groupSep.isNotEmpty) {
      initialAmountText = initialAmountText.replaceAll(groupSep, '');
    }
    _amountController = TextEditingController(text: initialAmountText);

    _calculatorController = CalculatorController();
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
    if (_calculatorController.lastResult != null) {
      final formattingProvider =
          Provider.of<FormattingProvider>(context, listen: false);
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000), // Adjust range as needed
      lastDate:
          DateTime.now().add(const Duration(days: 365)), // Allow future dates?
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _updateTransaction() async {
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

    final double amount = parsedAmount.abs();

    if (category.isEmpty || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid details.')),
      );
      return;
    }

    // Create updated transaction, keeping the original ID
    final updatedTransaction = Transaction(
      id: widget.transaction.id, // Keep original ID
      category: category,
      amount: amount,
      date: _selectedDate, // Use selected date
      type: _transactionType,
    );

    try {
      final firestoreService = FirestoreService();
      await firestoreService.updateTransaction(updatedTransaction);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction updated successfully.')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating transaction: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattingProvider = Provider.of<FormattingProvider>(context);
    final dateFormat = DateFormat.yMd(); // Date format for display

    return AlertDialog(
      title: Column(
        children: [
          Icon(Icons.edit_note_rounded,
              color: Theme.of(context).colorScheme.primary, size: 48),
          const SizedBox(height: 8),
          Text('Edit Transaction',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Type Selection (Radio Buttons)
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
            // Category Field with Dropdown
            TextField(
              controller: _categoryController,
              decoration: InputDecoration(
                labelText: 'Category',
                prefixIcon: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    icon: const Icon(Icons.arrow_drop_down),
                    value: _presetCategories.contains(_categoryController.text)
                        ? _categoryController.text
                        : null,
                    hint: const Text('Select Category'),
                    onChanged: (value) {
                      setState(() {
                        _categoryController.text = value!;
                      });
                    },
                    items: _presetCategories
                        .map((category) => DropdownMenuItem(
                            value: category, child: Text(category)))
                        .toList(),
                  ),
                ),
                suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _categoryController.clear();
                    }),
              ),
            ),
            const SizedBox(height: 8),
            // Amount Field with Calculator Toggle
            TextField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Amount',
                prefixText: formattingProvider.getCurrencySymbol(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.calculate_outlined,
                      color: _showCalculator
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant),
                  tooltip: 'Toggle Calculator',
                  onPressed: () {
                    setState(() {
                      _showCalculator = !_showCalculator;
                      if (_showCalculator) {
                        _calculatorController.setAmountFromField(
                            context, _amountController.text);
                      }
                    });
                  },
                ),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              readOnly: _showCalculator,
              onTap: () {
                if (_showCalculator) {
                  setState(() {
                    _showCalculator = false;
                  });
                }
              },
            ),
            // Calculator Widget (Animated)
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Visibility(
                visible: _showCalculator,
                child: Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: CalculatorWidget(
                    displayValue: _calculatorController.output,
                    onButtonPressed: (buttonText) => _calculatorController
                        .buttonPressed(context, buttonText),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Date Picker Input
            InkWell(
              onTap: () => _selectDate(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date',
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(), // Match TextField style
                ),
                child: Text(dateFormat.format(_selectedDate)),
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
          onPressed: _updateTransaction,
          child: const Text('Save Changes'),
        ),
      ],
    );
  }
}
