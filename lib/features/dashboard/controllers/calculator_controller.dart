import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/formatting_provider.dart';

class CalculatorController extends ChangeNotifier {
  String _output = '0';
  String _currentInput = '';
  double _operand1 = 0;
  String? _operator;
  double? _lastResult; // Store the last calculated result

  String get output => _output;
  double? get lastResult => _lastResult;

  // Method to initialize/sync calculator with an amount string
  void setAmountFromField(BuildContext context, String amountText) {
    final formattingProvider =
        Provider.of<FormattingProvider>(context, listen: false);
    final decimalSeparator = formattingProvider.getDecimalSeparator();
    final thousandsSeparator = formattingProvider.getThousandsSeparator();

    if (amountText.isEmpty) {
      reset();
      return;
    }
    try {
      String cleanedAmount = amountText;
      if (thousandsSeparator.isNotEmpty) {
        cleanedAmount = cleanedAmount.replaceAll(thousandsSeparator, '');
      }
      cleanedAmount = cleanedAmount.replaceAll(decimalSeparator, '.');
      double currentAmount = double.parse(cleanedAmount);

      _output = _formatNumber(context, currentAmount, includeGrouping: true);
      _currentInput =
          cleanedAmount; // Store raw number string (using '.' as decimal sep internally)
      _operand1 = 0; // Reset calculation state
      _operator = null;
      _lastResult = null;
      notifyListeners();
    } catch (e) {
      print("Error setting amount from field: $e");
      reset(); // Reset on error
    }
  }

  void buttonPressed(BuildContext context, String buttonText) {
    final formattingProvider =
        Provider.of<FormattingProvider>(context, listen: false);
    final decimalSeparator = formattingProvider.getDecimalSeparator();
    final thousandsSeparator = formattingProvider.getThousandsSeparator();
    _lastResult = null; // Reset last result on any button press except '='

    if (buttonText == 'Backspace') {
      _handleBackspace(context, decimalSeparator, thousandsSeparator);
    } else if (buttonText == 'C') {
      reset();
    } else if (buttonText == 'CE') {
      _handleClearEntry(context);
    } else if (buttonText == '.') {
      _handleDecimal(decimalSeparator);
    } else if (RegExp(r'[0-9]').hasMatch(buttonText)) {
      _handleDigit(context, buttonText, decimalSeparator, thousandsSeparator);
    } else if (buttonText == '=') {
      _calculateResult(context);
    } else if (buttonText == '+' ||
        buttonText == '-' ||
        buttonText == '*' ||
        buttonText == '/') {
      _handleOperator(
          context, buttonText, decimalSeparator, thousandsSeparator);
    }
    notifyListeners();
  }

  void reset() {
    _output = '0';
    _currentInput = '';
    _operand1 = 0;
    _operator = null;
    _lastResult = null;
    notifyListeners();
  }

  void _handleBackspace(BuildContext context, String decimalSeparator,
      String thousandsSeparator) {
    if (_currentInput.isNotEmpty) {
      _currentInput = _currentInput.substring(0, _currentInput.length - 1);
      if (_currentInput.isEmpty) {
        _output = '0';
      } else {
        _updateOutputFromInput(context, decimalSeparator, thousandsSeparator);
      }
    }
  }

  void _handleClearEntry(BuildContext context) {
    _currentInput = '';
    _output = (_operator != null)
        ? _formatNumber(context, _operand1, includeGrouping: true) + _operator!
        : '0';
  }

  void _handleDecimal(String decimalSeparator) {
    if (!_currentInput.contains('.')) {
      // Internal representation uses '.'
      _currentInput = (_currentInput.isEmpty || _currentInput == '0')
          ? '0.'
          : '$_currentInput.';
      // Display uses the correct separator
      _output = _currentInput.replaceAll('.', decimalSeparator);
    }
  }

  void _handleDigit(BuildContext context, String digit, String decimalSeparator,
      String thousandsSeparator) {
    if (_currentInput == '0') {
      _currentInput = digit;
    } else {
      _currentInput += digit;
    }
    _updateOutputFromInput(context, decimalSeparator, thousandsSeparator);
  }

  void _handleOperator(BuildContext context, String op, String decimalSeparator,
      String thousandsSeparator) {
    if (_currentInput.isNotEmpty) {
      if (_operator != null) {
        _calculateResult(context); // Perform intermediate calculation
        // If result calculation was successful, _operand1 is updated
      }
      // Parse _currentInput to set _operand1
      try {
        // Internal _currentInput uses '.' as decimal separator
        _operand1 = double.parse(_currentInput);
      } catch (e) {
        print("Error parsing operand1: $e");
        _output = 'Error';
        _currentInput = '';
        _operand1 = 0;
        _operator = null;
        return;
      }
    }
    // Set operator if operand1 is valid (or if input was just parsed into it)
    if (_operand1 != 0 || _currentInput.isNotEmpty) {
      _operator = op;
      _output = _formatNumber(context, _operand1, includeGrouping: true) +
          (_operator ?? '');
      _currentInput = ''; // Clear for next input
    }
  }

  void _updateOutputFromInput(BuildContext context, String decimalSeparator,
      String thousandsSeparator) {
    // Formats _currentInput (which uses '.' internally) for display
    try {
      bool endsWithDecimal = _currentInput.endsWith('.');
      String parsableInput = endsWithDecimal
          ? _currentInput.substring(0, _currentInput.length - 1)
          : _currentInput;

      if (parsableInput.isEmpty || parsableInput == '-') {
        _output = _currentInput.replaceAll(
            '.', decimalSeparator); // Show raw input like '0,' or '-'
        if (parsableInput.isEmpty) _output = '0';
      } else {
        double numberValue = double.parse(parsableInput);
        _output = _formatNumber(context, numberValue, includeGrouping: true);
        if (endsWithDecimal) {
          _output += decimalSeparator;
        }
      }
    } catch (e) {
      _output = _currentInput.replaceAll(
          '.', decimalSeparator); // Fallback to raw on error
      print("Error formatting calculator input: $e");
    }
  }

  void _calculateResult(BuildContext context) {
    final formattingProvider =
        Provider.of<FormattingProvider>(context, listen: false);
    final decimalSeparator = formattingProvider.getDecimalSeparator();
    final thousandsSeparator = formattingProvider.getThousandsSeparator();

    if (_operator != null && _currentInput.isNotEmpty) {
      // Internal _currentInput uses '.'
      double operand2 = double.parse(_currentInput);
      double result = 0;
      try {
        if (_operator == '+') {
          result = _operand1 + operand2;
        } else if (_operator == '-')
          result = _operand1 - operand2;
        else if (_operator == '*')
          result = _operand1 * operand2;
        else if (_operator == '/') {
          if (operand2 == 0) throw const FormatException('Division by zero');
          result = _operand1 / operand2;
        }

        if (!result.isFinite) {
          throw const FormatException('Result is not finite');
        }

        _output = _formatNumber(context, result, includeGrouping: true);
        _operand1 = result;
        _currentInput = result
            .toString(); // Store raw result string (might have ., e.g., 1.5)
        _operator = null;
        _lastResult = result; // Store the result
      } catch (e) {
        _output = 'Error';
        _currentInput = '';
        _operand1 = 0;
        _operator = null;
        _lastResult = null;
        print("Error calculating result: $e");
      }
    }
  }

  String _formatNumber(BuildContext context, double number,
      {bool includeGrouping = true}) {
    final formattingProvider =
        Provider.of<FormattingProvider>(context, listen: false);
    String formatted = formattingProvider.formatAmountRaw(number);
    if (!includeGrouping) {
      String groupSep = formattingProvider.getThousandsSeparator();
      if (groupSep.isNotEmpty) {
        formatted = formatted.replaceAll(groupSep, '');
      }
    }
    return formatted;
  }
}
