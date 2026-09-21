import 'package:flutter/material.dart';

import '../rer_calculator.dart';

/// Short, always-visible reminder that the number on screen is an estimate.
///
/// Deliberately not dismissible: the app produces a feeding target for a live
/// patient, so the caveat should travel with the number rather than sit in a
/// README nobody using the app will read.
class DisclaimerFooter extends StatelessWidget {
  const DisclaimerFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.info_outline, size: 15, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'RER is a starting estimate, not a prescription. Feeding plans '
              'should be set and monitored by a veterinarian.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                    height: 1.35,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The fuller explanation, reached from the app bar.
Future<void> showAboutRerDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (context) {
      final body = Theme.of(context).textTheme.bodyMedium;
      final label = Theme.of(context).textTheme.labelLarge;
      return AlertDialog(
        title: const Text('About this calculator'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Resting Energy Requirement is the energy a resting animal '
                'uses in a thermoneutral environment.',
                style: body,
              ),
              const SizedBox(height: 16),
              Text('Formula', style: label),
              const SizedBox(height: 4),
              Text(
                'RER = 70 x (body weight in kg) ^ 0.75',
                style: body?.copyWith(fontFamily: 'DroidSansMono'),
              ),
              const SizedBox(height: 4),
              Text(
                'Pounds are converted at $kPoundsPerKilogram lb per kg, the '
                'usual clinic convention.',
                style: body,
              ),
              const SizedBox(height: 16),
              Text('Restriction', style: label),
              const SizedBox(height: 4),
              Text(
                'The slider applies a fraction of RER as the daily target, '
                'from ${kMinRestrictPercentage.round()}% to '
                '${kMaxRestrictPercentage.round()}%.',
                style: body,
              ),
              const SizedBox(height: 16),
              Text('Important', style: label),
              const SizedBox(height: 4),
              Text(
                'RER is a starting estimate only. Actual energy requirements '
                'vary with age, neuter status, activity, body condition and '
                'illness. A feeding plan should always be set and monitored '
                'by a veterinarian.',
                style: body,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      );
    },
  );
}
