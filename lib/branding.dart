import 'dart:convert';
import 'dart:ui' show Color;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

/// Location of the optional brand pack.
///
/// Everything under `assets/brand/` is gitignored, so a fresh clone of this
/// repository has no pack and always renders [Brand.generic]. Dropping a
/// `brand.json` (plus any images it names) into that folder re-skins the app
/// without touching tracked source. See `assets/brand/README.md`.
const String brandManifestAsset = 'assets/brand/brand.json';

/// Colours, title and logos for one visual identity.
@immutable
class Brand {
  const Brand({
    required this.appTitle,
    required this.primary,
    required this.secondary,
    required this.background,
    this.wordmarkAsset,
    this.iconAsset,
  });

  final String appTitle;
  final Color primary;
  final Color secondary;
  final Color background;

  /// Wide logo shown above the calculator. Null draws the built-in wordmark.
  final String? wordmarkAsset;

  /// Square mark shown in the app bar. Null draws the built-in paw.
  final String? iconAsset;

  /// The identity this repository ships with. Deliberately unbranded.
  static const Brand generic = Brand(
    appTitle: 'RER Calculator',
    primary: Color(0xFF0E7C86),
    secondary: Color(0xFFF2A65A),
    background: Color(0xFFE8F2F3),
  );

  /// Reads the brand pack, falling back to [generic] when it is missing or
  /// malformed. Never throws: a broken pack must not stop the app opening.
  static Future<Brand> load({String asset = brandManifestAsset}) async {
    try {
      return fromJson(await rootBundle.loadString(asset));
    } catch (_) {
      return generic;
    }
  }

  /// Parses a brand manifest, using [generic] for any field that is absent or
  /// unreadable. Exposed separately from [load] so it can be tested directly.
  static Brand fromJson(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! Map<String, dynamic>) return generic;
    return Brand(
      appTitle: _string(decoded['appTitle']) ?? generic.appTitle,
      primary: _color(decoded['primary']) ?? generic.primary,
      secondary: _color(decoded['secondary']) ?? generic.secondary,
      background: _color(decoded['background']) ?? generic.background,
      wordmarkAsset: _string(decoded['wordmark']),
      iconAsset: _string(decoded['icon']),
    );
  }
}

String? _string(Object? value) {
  if (value is! String) return null;
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

/// Parses `#RRGGBB`, `#AARRGGBB` or `0xAARRGGBB`.
Color? _color(Object? value) {
  var hex = _string(value);
  if (hex == null) return null;
  if (hex.startsWith('#')) hex = hex.substring(1);
  if (hex.startsWith('0x') || hex.startsWith('0X')) hex = hex.substring(2);
  if (hex.length == 6) hex = 'FF$hex';
  if (hex.length != 8) return null;
  final parsed = int.tryParse(hex, radix: 16);
  return parsed == null ? null : Color(parsed);
}
