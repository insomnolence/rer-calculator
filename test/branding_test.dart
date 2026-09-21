import 'dart:ui' show Color;

import 'package:flutter_test/flutter_test.dart';
import 'package:rer_calculator/branding.dart';

void main() {
  group('Brand pack parsing', () {
    test('reads a full manifest', () {
      final brand = Brand.fromJson('''
        {
          "appTitle": "Clinic Calculator",
          "primary": "#00A3E0",
          "secondary": "#8DC63F",
          "background": "#BAE9FC",
          "wordmark": "assets/brand/wordmark.png",
          "icon": "assets/brand/icon.png"
        }
      ''');

      expect(brand.appTitle, 'Clinic Calculator');
      expect(brand.primary, const Color(0xFF00A3E0));
      expect(brand.secondary, const Color(0xFF8DC63F));
      expect(brand.background, const Color(0xFFBAE9FC));
      expect(brand.wordmarkAsset, 'assets/brand/wordmark.png');
      expect(brand.iconAsset, 'assets/brand/icon.png');
    });

    test('missing keys fall back to the generic identity', () {
      final brand = Brand.fromJson('{"primary": "#112233"}');

      expect(brand.primary, const Color(0xFF112233));
      expect(brand.appTitle, Brand.generic.appTitle);
      expect(brand.secondary, Brand.generic.secondary);
      expect(brand.background, Brand.generic.background);
      expect(brand.wordmarkAsset, isNull);
      expect(brand.iconAsset, isNull);
    });

    test('accepts the documented colour spellings', () {
      expect(Brand.fromJson('{"primary": "#112233"}').primary,
          const Color(0xFF112233));
      expect(Brand.fromJson('{"primary": "#80112233"}').primary,
          const Color(0x80112233));
      expect(Brand.fromJson('{"primary": "0xFF112233"}').primary,
          const Color(0xFF112233));
    });

    test('unparseable colours fall back rather than throwing', () {
      expect(Brand.fromJson('{"primary": "not a colour"}').primary,
          Brand.generic.primary);
      expect(Brand.fromJson('{"primary": 42}').primary, Brand.generic.primary);
    });

    test('blank strings are treated as absent', () {
      final brand = Brand.fromJson('{"appTitle": "   ", "wordmark": ""}');
      expect(brand.appTitle, Brand.generic.appTitle);
      expect(brand.wordmarkAsset, isNull);
    });

    test('a non-object manifest falls back entirely', () {
      expect(Brand.fromJson('[1, 2, 3]').appTitle, Brand.generic.appTitle);
    });

    test('load() falls back when no pack is bundled', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final brand = await Brand.load(asset: 'assets/brand/does-not-exist.json');
      expect(brand, isNot(isNull));
      expect(brand.appTitle, Brand.generic.appTitle);
      expect(brand.wordmarkAsset, isNull);
    });
  });
}
