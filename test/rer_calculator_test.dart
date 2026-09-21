import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:rer_calculator/rer_calculator.dart';

void main() {
  late RerCalculator calc;

  setUp(() {
    calc = RerCalculator();
  });

  tearDown(() {
    calc.dispose();
  });

  group('RER formula', () {
    test('10kg yields correct RER', () {
      calc.weightUnit = WeightUnit.kgs;
      calc.petWeight = 10;

      final expected = pow(10, 0.75) * 70.0;
      expect(calc.rerResult, closeTo(expected, 0.01));
      expect(calc.rerResult, closeTo(393.64, 0.05));
    });

    test('22 lbs converts to 10kg and yields same result', () {
      calc.weightUnit = WeightUnit.lbs;
      calc.petWeight = 22;

      final expectedWeight = 22 / 2.2;
      final expected = pow(expectedWeight, 0.75) * 70.0;
      expect(calc.rerResult, closeTo(expected, 0.01));
      expect(calc.rerResult, closeTo(393.64, 0.05));
    });
  });

  group('Restriction', () {
    test('70% restriction', () {
      calc.weightUnit = WeightUnit.kgs;
      calc.petWeight = 10;
      calc.restrictPercentage = 70;

      final fullRer = pow(10, 0.75) * 70.0;
      expect(calc.restrictedCalories, closeTo(fullRer * 0.7, 0.01));
      expect(calc.restrictedCalories, closeTo(275.55, 0.05));
    });

    test('default restriction is 100%', () {
      expect(calc.restrictPercentage, 100.0);
    });
  });

  group('Percentage clamping', () {
    test('clamps at 50 minimum', () {
      calc.restrictPercentage = 30;
      expect(calc.restrictPercentage, 50.0);
    });

    test('clamps at 120 maximum', () {
      calc.restrictPercentage = 150;
      expect(calc.restrictPercentage, 120.0);
    });

    test('allows values within range', () {
      calc.restrictPercentage = 85;
      expect(calc.restrictPercentage, 85.0);
    });
  });

  group('Zero/empty state', () {
    test('zero weight yields zero result', () {
      calc.petWeight = 0;
      expect(calc.rerResult, 0.0);
      expect(calc.hasResult, false);
    });

    test('initial state has no result', () {
      expect(calc.hasResult, false);
      expect(calc.rerResult, 0.0);
    });
  });

  group('Zone classification', () {
    test('aggressive zone: 50-69%', () {
      calc.restrictPercentage = 50;
      expect(calc.currentZone, RestrictionZone.aggressive);
      calc.restrictPercentage = 69;
      expect(calc.currentZone, RestrictionZone.aggressive);
    });

    test('weight loss zone: 70-85%', () {
      calc.restrictPercentage = 70;
      expect(calc.currentZone, RestrictionZone.weightLoss);
      calc.restrictPercentage = 85;
      expect(calc.currentZone, RestrictionZone.weightLoss);
    });

    test('mild restriction zone: 86-94%', () {
      calc.restrictPercentage = 86;
      expect(calc.currentZone, RestrictionZone.mildRestriction);
      calc.restrictPercentage = 94;
      expect(calc.currentZone, RestrictionZone.mildRestriction);
    });

    test('maintenance zone: 95-100%', () {
      calc.restrictPercentage = 95;
      expect(calc.currentZone, RestrictionZone.maintenance);
      calc.restrictPercentage = 100;
      expect(calc.currentZone, RestrictionZone.maintenance);
    });

    test('weight gain zone: 101-120%', () {
      calc.restrictPercentage = 101;
      expect(calc.currentZone, RestrictionZone.weightGain);
      calc.restrictPercentage = 120;
      expect(calc.currentZone, RestrictionZone.weightGain);
    });
  });

  group('Zone labels', () {
    test('every zone carries its own label', () {
      expect(RestrictionZone.aggressive.label, 'Aggressive Restriction');
      expect(RestrictionZone.weightLoss.label, 'Weight Loss Diet');
      expect(RestrictionZone.mildRestriction.label, 'Mild Restriction');
      expect(RestrictionZone.maintenance.label, 'Maintenance');
      expect(RestrictionZone.weightGain.label, 'Weight Gain');
    });

    test('the label follows the zone the percentage selects', () {
      calc.restrictPercentage = 60;
      expect(calc.currentZone.label, 'Aggressive Restriction');
      calc.restrictPercentage = 80;
      expect(calc.currentZone.label, 'Weight Loss Diet');
      calc.restrictPercentage = 110;
      expect(calc.currentZone.label, 'Weight Gain');
    });
  });

  group('Meal splits', () {
    test('correct divide by 2', () {
      calc.weightUnit = WeightUnit.kgs;
      calc.petWeight = 10;
      calc.restrictPercentage = 100;

      expect(
        calc.caloriesPerTwoMeals,
        closeTo(calc.restrictedCalories / 2, 0.01),
      );
    });

    test('correct divide by 3', () {
      calc.weightUnit = WeightUnit.kgs;
      calc.petWeight = 10;
      calc.restrictPercentage = 100;

      expect(
        calc.caloriesPerThreeMeals,
        closeTo(calc.restrictedCalories / 3, 0.01),
      );
    });
  });

  group('Auto-recalculation', () {
    test('changing weight unit triggers recalculation', () {
      calc.weightUnit = WeightUnit.kgs;
      calc.petWeight = 10;
      final kgResult = calc.rerResult;

      calc.weightUnit = WeightUnit.lbs;
      // 10 lbs < 10 kg, so RER should be different
      expect(calc.rerResult, isNot(closeTo(kgResult, 0.01)));
    });

    test('changing percentage triggers recalculation', () {
      calc.weightUnit = WeightUnit.kgs;
      calc.petWeight = 10;
      calc.restrictPercentage = 100;
      final full = calc.restrictedCalories;

      calc.restrictPercentage = 70;
      expect(calc.restrictedCalories, closeTo(full * 0.7, 0.01));
    });
  });
}
