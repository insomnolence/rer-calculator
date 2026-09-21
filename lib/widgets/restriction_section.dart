import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../rer_calculator.dart';
import '../theme.dart';
import 'comparison_bar.dart';
import 'meal_breakdown.dart';

class RestrictionSection extends StatefulWidget {
  final RerCalculator calculator;
  final TextEditingController percentageController;

  const RestrictionSection({
    super.key,
    required this.calculator,
    required this.percentageController,
  });

  @override
  State<RestrictionSection> createState() => _RestrictionSectionState();
}

class _RestrictionSectionState extends State<RestrictionSection> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()..addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus) _commit();
  }

  /// Applies a typed value only once it is in range. Half-finished input (the
  /// "9" on the way to "95") would otherwise clamp to the minimum and yank the
  /// slider away under the user's finger.
  void _handleChanged(String value) {
    final pct = double.tryParse(value);
    if (pct == null) return;
    if (pct < kMinRestrictPercentage || pct > kMaxRestrictPercentage) return;
    widget.calculator.restrictPercentage = pct;
  }

  /// On blur or submit, settle up: clamp whatever was typed and rewrite the
  /// field so it can never disagree with the slider.
  void _commit() {
    final pct = double.tryParse(widget.percentageController.text);
    if (pct != null) widget.calculator.restrictPercentage = pct;
    final settled = widget.calculator.restrictPercentage.round().toString();
    if (widget.percentageController.text != settled) {
      widget.percentageController.text = settled;
    }
  }

  @override
  Widget build(BuildContext context) {
    final calculator = widget.calculator;
    final zone = calculator.currentZone;
    final fill = zoneFillColor(zone);
    final textColor = zoneTextColor(zone);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              zone.label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            if (calculator.hasResult) ...[
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      calculator.restrictedCalories.toStringAsFixed(0),
                      style: TextStyle(
                        fontFamily: 'DroidSansMono',
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'cal/day',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                Expanded(
                  child: SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: fill,
                      thumbColor: fill,
                      inactiveTrackColor: fill.withValues(alpha: 0.3),
                    ),
                    child: Slider(
                      value: calculator.restrictPercentage,
                      min: kMinRestrictPercentage,
                      max: kMaxRestrictPercentage,
                      divisions:
                          (kMaxRestrictPercentage - kMinRestrictPercentage).round(),
                      label: '${calculator.restrictPercentage.round()}%',
                      onChanged: (value) {
                        calculator.restrictPercentage = value;
                        widget.percentageController.text =
                            value.round().toString();
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 72,
                  height: 48,
                  child: TextField(
                    controller: widget.percentageController,
                    focusNode: _focusNode,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(3),
                    ],
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      suffixText: '%',
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                    ),
                    onTap: () {
                      widget.percentageController.selection = TextSelection(
                        baseOffset: 0,
                        extentOffset: widget.percentageController.text.length,
                      );
                    },
                    onChanged: _handleChanged,
                    onSubmitted: (_) => _commit(),
                  ),
                ),
              ],
            ),
            ComparisonBar(calculator: calculator),
            MealBreakdown(calculator: calculator),
          ],
        ),
      ),
    );
  }
}
