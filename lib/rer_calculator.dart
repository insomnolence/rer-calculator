import 'dart:math';

import 'package:flutter/foundation.dart';

/// Bounds of the restriction slider and percentage field, in percent of RER.
const double kMinRestrictPercentage = 50.0;
const double kMaxRestrictPercentage = 120.0;

/// Conversion used for pound input. Clinics conventionally divide by 2.2
/// rather than the exact 2.20462; the difference is under 0.2% of RER, well
/// inside the error of the allometric formula itself.
const double kPoundsPerKilogram = 2.2;

enum WeightUnit { lbs, kgs }

enum RestrictionZone {
  aggressive('Aggressive Restriction'),
  weightLoss('Weight Loss Diet'),
  mildRestriction('Mild Restriction'),
  maintenance('Maintenance'),
  weightGain('Weight Gain');

  const RestrictionZone(this.label);

  /// Clinician-facing name for the zone. Lives here so the thresholds in
  /// [RerCalculator.currentZone] and their labels cannot drift apart.
  final String label;
}

class RerCalculator extends ChangeNotifier {
  double _petWeight = 0.0;
  double _restrictPercentage = 100.0;
  double _rerResult = 0.0;
  double _restrictedCalories = 0.0;
  WeightUnit _weightUnit = WeightUnit.lbs;

  double get petWeight => _petWeight;
  double get restrictPercentage => _restrictPercentage;
  double get rerResult => _rerResult;
  double get restrictedCalories => _restrictedCalories;
  WeightUnit get weightUnit => _weightUnit;

  bool get hasResult => _rerResult > 0;

  RestrictionZone get currentZone {
    if (_restrictPercentage < 70) return RestrictionZone.aggressive;
    if (_restrictPercentage <= 85) return RestrictionZone.weightLoss;
    if (_restrictPercentage <= 94) return RestrictionZone.mildRestriction;
    if (_restrictPercentage <= 100) return RestrictionZone.maintenance;
    return RestrictionZone.weightGain;
  }

  double get caloriesPerTwoMeals => _restrictedCalories / 2;
  double get caloriesPerThreeMeals => _restrictedCalories / 3;

  set petWeight(double value) {
    _petWeight = value;
    _calculate();
  }

  set weightUnit(WeightUnit value) {
    _weightUnit = value;
    _calculate();
  }

  set restrictPercentage(double value) {
    _restrictPercentage = value.clamp(kMinRestrictPercentage, kMaxRestrictPercentage);
    _calculate();
  }

  void _calculate() {
    double weight = _petWeight;
    if (_weightUnit == WeightUnit.lbs) {
      weight = _petWeight / kPoundsPerKilogram;
    }

    if (weight <= 0) {
      _rerResult = 0.0;
      _restrictedCalories = 0.0;
    } else {
      _rerResult = pow(weight, 0.75) * 70.0;
      _restrictedCalories = _rerResult * (_restrictPercentage / 100.0);
    }
    notifyListeners();
  }
}
