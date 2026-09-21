import 'package:flutter/material.dart';

import 'branding.dart';
import 'rer_calculator.dart';

// Restriction zone colours are semantic, not brand, so they stay fixed across
// brand packs. Each zone has a saturated fill for the slider and comparison
// bar, plus a darkened equivalent that clears 4.5:1 contrast on white for use
// as label text.
const Color zoneAggressiveFill = Color(0xFFE53935);
const Color zoneWeightLossFill = Color(0xFFFB8C00);
const Color zoneMildRestrictionFill = Color(0xFFC0CA33);
const Color zoneMaintenanceFill = Color(0xFF43A047);
const Color zoneWeightGainFill = Color(0xFF1E88E5);

const Color zoneAggressiveText = Color(0xFFC62828);
const Color zoneWeightLossText = Color(0xFFB45309);
const Color zoneMildRestrictionText = Color(0xFF5E7D00);
const Color zoneMaintenanceText = Color(0xFF2E7D32);
const Color zoneWeightGainText = Color(0xFF1565C0);

Color zoneFillColor(RestrictionZone zone) => switch (zone) {
      RestrictionZone.aggressive => zoneAggressiveFill,
      RestrictionZone.weightLoss => zoneWeightLossFill,
      RestrictionZone.mildRestriction => zoneMildRestrictionFill,
      RestrictionZone.maintenance => zoneMaintenanceFill,
      RestrictionZone.weightGain => zoneWeightGainFill,
    };

Color zoneTextColor(RestrictionZone zone) => switch (zone) {
      RestrictionZone.aggressive => zoneAggressiveText,
      RestrictionZone.weightLoss => zoneWeightLossText,
      RestrictionZone.mildRestriction => zoneMildRestrictionText,
      RestrictionZone.maintenance => zoneMaintenanceText,
      RestrictionZone.weightGain => zoneWeightGainText,
    };

ThemeData buildAppTheme(Brand brand) => ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: brand.primary,
        primary: brand.primary,
        secondary: brand.secondary,
        surface: Colors.white,
      ),
      scaffoldBackgroundColor: brand.background,
      appBarTheme: AppBarTheme(
        backgroundColor: brand.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 2,
      ),
      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: brand.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
