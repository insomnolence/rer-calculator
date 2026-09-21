import 'package:flutter/material.dart';

import '../rer_calculator.dart';

class ResultDisplay extends StatelessWidget {
  final RerCalculator calculator;

  const ResultDisplay({super.key, required this.calculator});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Resting Energy Requirement',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            if (!calculator.hasResult)
              Text(
                'Enter weight above',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey,
                    ),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    calculator.rerResult.toStringAsFixed(0),
                    style: const TextStyle(
                      fontFamily: 'DroidSansMono',
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'calories/day',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
