import 'package:flutter/material.dart';

class CalculatorWidget extends StatelessWidget {
  final String displayValue;
  final Function(String) onButtonPressed;

  const CalculatorWidget({
    super.key,
    required this.displayValue,
    required this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final buttonStyle = ElevatedButton.styleFrom(
      foregroundColor: colorScheme.onPrimaryContainer,
      backgroundColor:
          colorScheme.primaryContainer.withAlpha((0.6 * 255).toInt()),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.all(12),
      textStyle: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
    final operatorStyle = ElevatedButton.styleFrom(
      foregroundColor: colorScheme.onSecondaryContainer,
      backgroundColor:
          colorScheme.secondaryContainer.withAlpha((0.8 * 255).toInt()),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.all(12),
      textStyle: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
    final clearStyle = ElevatedButton.styleFrom(
      // Style for C and CE
      foregroundColor: colorScheme.onErrorContainer,
      backgroundColor:
          colorScheme.errorContainer.withAlpha((0.8 * 255).toInt()),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.all(12),
      textStyle: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
    final equalsStyle = ElevatedButton.styleFrom(
      foregroundColor: colorScheme.onPrimary,
      backgroundColor: colorScheme.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.all(12),
      textStyle: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );

    // Helper to build buttons
    Widget buildButton(String text, {ButtonStyle? style, Widget? child}) {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.all(3.0),
          child: ElevatedButton(
            style: style ?? buttonStyle,
            onPressed: () => onButtonPressed(text),
            // Use child if provided (for icon), otherwise use text
            child: child ?? Text(text),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color:
            colorScheme.surfaceContainerHighest.withAlpha((0.3 * 255).toInt()),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Display Area
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: colorScheme.surface.withAlpha((0.5 * 255).toInt()),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              displayValue,
              style: textTheme.headlineSmall
                  ?.copyWith(color: colorScheme.onSurface),
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Buttons Grid (4x4)
          Row(
            children: [
              buildButton('C', style: clearStyle), // Clear All
              buildButton('CE', style: clearStyle), // Clear Entry
              // Replace one placeholder with Backspace button
              buildButton(
                'Backspace', // Identifier for the button press
                style: operatorStyle, // Use operator style or a dedicated one
                child: const Icon(Icons.backspace_outlined,
                    size: 20), // Use an icon
              ),
              buildButton('/', style: operatorStyle),
            ],
          ),
          Row(
            children: [
              buildButton('7'),
              buildButton('8'),
              buildButton('9'),
              buildButton('*', style: operatorStyle),
            ],
          ),
          Row(
            children: [
              buildButton('4'),
              buildButton('5'),
              buildButton('6'),
              buildButton('-', style: operatorStyle),
            ],
          ),
          Row(
            children: [
              buildButton('1'),
              buildButton('2'),
              buildButton('3'),
              buildButton('+', style: operatorStyle),
            ],
          ),
          Row(
            children: [
              buildButton(''), // Placeholder
              buildButton('0'),
              buildButton('.'),
              buildButton('=', style: equalsStyle),
            ],
          ),
        ],
      ),
    );
  }
}
