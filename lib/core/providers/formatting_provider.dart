import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class FormattingProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  String _currency = 'USD';
  bool _showCents = true;
  String? _userId;

  String get currency => _currency;
  bool get showCents => _showCents;

  Future<void> initializeFormatting(String userId) async {
    _userId = userId;
    try {
      final preferences = await _firestoreService.getUserPreferences();
      _currency = preferences.currency;
      _showCents = preferences.showCents;
      notifyListeners();
    } catch (e) {
      print('Error loading formatting preferences: $e');
    }
  }

  Future<void> setCurrency(String currency) async {
    if (_userId == null) return;
    
    _currency = currency;
    notifyListeners();

    try {
      final currentPreferences = await _firestoreService.getUserPreferences();
      final updatedPreferences = currentPreferences.copyWith(
        currency: currency,
      );
      await _firestoreService.saveUserPreferences(updatedPreferences);
    } catch (e) {
      print('Error saving currency preference: $e');
    }
  }

  Future<void> setShowCents(bool showCents) async {
    if (_userId == null) return;
    
    _showCents = showCents;
    notifyListeners();

    try {
      final currentPreferences = await _firestoreService.getUserPreferences();
      final updatedPreferences = currentPreferences.copyWith(
        showCents: showCents,
      );
      await _firestoreService.saveUserPreferences(updatedPreferences);
    } catch (e) {
      print('Error saving showCents preference: $e');
    }
  }

  String formatAmount(double amount) {
    final isNegative = amount < 0;
    final absAmount = amount.abs();
    
    String symbol = getCurrencySymbol();
    String formattedNumber = _showCents 
        ? absAmount.toStringAsFixed(2) 
        : absAmount.toStringAsFixed(0);
    
    // Add thousand separators
    final parts = formattedNumber.split('.');
    parts[0] = _addThousandSeparators(parts[0]);
    formattedNumber = parts.join('.');

    return '${isNegative ? '-' : ''}$symbol$formattedNumber';
  }

  String _addThousandSeparators(String number) {
    final buffer = StringBuffer();
    final length = number.length;
    
    for (var i = 0; i < length; i++) {
      if (i > 0 && (length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(number[i]);
    }
    
    return buffer.toString();
  }

  String getCurrencySymbol() {
    switch (_currency.toUpperCase()) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      case 'PHP':
        return '₱';
      default:
        return '\$';
    }
  }
}
