import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../rer_calculator.dart';

/// Accepts only text that is still a parseable decimal, so a stray second
/// separator is rejected at the keystroke instead of silently making
/// `double.tryParse` fail and zeroing the result.
final TextInputFormatter decimalOnly = TextInputFormatter.withFunction(
  (oldValue, newValue) =>
      RegExp(r'^\d*\.?\d*$').hasMatch(newValue.text) ? newValue : oldValue,
);

class WeightInput extends StatelessWidget {
  final RerCalculator calculator;
  final TextEditingController controller;

  const WeightInput({
    super.key,
    required this.calculator,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pet Weight', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: TextField(
                      controller: controller,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        decimalOnly,
                        LengthLimitingTextInputFormatter(6),
                      ],
                      decoration: const InputDecoration(
                        hintText: 'e.g. 25',
                      ),
                      onTap: () {
                        controller.selection = TextSelection(
                          baseOffset: 0,
                          extentOffset: controller.text.length,
                        );
                      },
                      onChanged: (value) {
                        final weight = double.tryParse(value) ?? 0.0;
                        calculator.petWeight = weight;
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SegmentedButton<WeightUnit>(
                  segments: const [
                    ButtonSegment(value: WeightUnit.lbs, label: Text('lbs')),
                    ButtonSegment(value: WeightUnit.kgs, label: Text('kgs')),
                  ],
                  selected: {calculator.weightUnit},
                  onSelectionChanged: (selected) {
                    calculator.weightUnit = selected.first;
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
