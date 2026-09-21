import 'package:flutter/material.dart';

import '../rer_calculator.dart';

class MealBreakdown extends StatelessWidget {
  final RerCalculator calculator;

  const MealBreakdown({super.key, required this.calculator});

  @override
  Widget build(BuildContext context) {
    if (!calculator.hasResult) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _mealChip(
            context,
            '~${calculator.caloriesPerTwoMeals.toStringAsFixed(0)} cal/meal',
            '÷2',
          ),
          _mealChip(
            context,
            '~${calculator.caloriesPerThreeMeals.toStringAsFixed(0)} cal/meal',
            '÷3',
          ),
        ],
      ),
    );
  }

  Widget _mealChip(BuildContext context, String calories, String divider) {
    return Column(
      children: [
        Text(
          divider,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.grey.shade500,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          calories,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
        ),
      ],
    );
  }
}
