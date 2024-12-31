import 'package:flutter/material.dart';

class CurrencyPickerDialog extends StatelessWidget {
  final String selectedCurrency;
  final Function(String) onCurrencySelected;

  const CurrencyPickerDialog({
    super.key,
    required this.selectedCurrency,
    required this.onCurrencySelected,
  });

  @override
  Widget build(BuildContext context) {
    final currencies = {
      'USD': '\$',
      'EUR': '€',
      'GBP': '£',
      'JPY': '¥',
      'PHP': '₱',
    };

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text(
                'Select Currency',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...currencies.entries.map((entry) {
              final isSelected = selectedCurrency == entry.key;
              return InkWell(
                onTap: () {
                  onCurrencySelected(entry.key);
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline.withAlpha((0.5 * 255).toInt()),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            entry.value,
                            style: TextStyle(
                              fontSize: 20,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.key,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${entry.value} ${entry.key}',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
