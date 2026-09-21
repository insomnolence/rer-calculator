import 'package:flutter/material.dart';

import '../rer_calculator.dart';
import '../theme.dart';

/// Restricted intake drawn against full RER. The track spans the whole slider
/// range rather than 0-100%, so the weight-gain zone above maintenance is
/// actually visible; a tick marks where 100% of RER falls.
class ComparisonBar extends StatelessWidget {
  final RerCalculator calculator;

  const ComparisonBar({super.key, required this.calculator});

  static const double _trackHeight = 20;

  @override
  Widget build(BuildContext context) {
    if (!calculator.hasResult) return const SizedBox.shrink();

    final fraction = calculator.restrictPercentage / kMaxRestrictPercentage;
    final maintenanceFraction = 100 / kMaxRestrictPercentage;
    final delta = calculator.restrictedCalories - calculator.rerResult;
    final deltaLabel = delta.abs() < 0.5
        ? 'at full RER'
        : '${delta.abs().toStringAsFixed(0)} cal '
            '${delta < 0 ? 'below' : 'above'} RER';
    final labelStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Colors.grey.shade600,
        );

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: _trackHeight,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ColoredBox(color: Colors.grey.shade300),
                  ),
                  FractionallySizedBox(
                    widthFactor: fraction.clamp(0.0, 1.0),
                    // heightFactor is required: FractionallySizedBox only
                    // constrains the axis it is given, and a ColoredBox has no
                    // intrinsic size, so the fill would collapse to zero high.
                    heightFactor: 1.0,
                    child: ColoredBox(
                      color: zoneFillColor(calculator.currentZone),
                    ),
                  ),
                  Align(
                    alignment: Alignment(maintenanceFraction * 2 - 1, 0),
                    child: Container(
                      width: 2,
                      // The tick sits on the fill above maintenance and on the
                      // empty track below it, so it has to switch contrast.
                      color: fraction >= maintenanceFraction
                          ? Colors.white.withValues(alpha: 0.9)
                          : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(deltaLabel, style: labelStyle),
              Text(
                '100% RER = ${calculator.rerResult.toStringAsFixed(0)} cal',
                style: labelStyle,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
