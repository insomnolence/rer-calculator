import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rer_calculator/main.dart';
import 'package:rer_calculator/widgets/app_logo.dart';
import 'package:rer_calculator/widgets/comparison_bar.dart';
import 'package:rer_calculator/widgets/weight_input.dart';

void main() {
  Finder weightField() => find.byType(TextField).at(0);
  Finder percentageField() => find.byType(TextField).at(1);

  TextEditingController controllerOf(WidgetTester tester, Finder field) =>
      tester.widget<TextField>(field).controller!;

  testWidgets('App renders without crashing', (tester) async {
    await tester.pumpWidget(const RerApp());
    expect(find.text('RER Calculator'), findsWidgets);
  });

  testWidgets('with no brand pack it draws the built-in mark, loads no image',
      (tester) async {
    await tester.pumpWidget(const RerApp());

    expect(find.byType(PawMark), findsWidgets);
    expect(find.byType(Image), findsNothing);
  });

  group('Weight input', () {
    testWidgets('a stray second decimal point is rejected, not silently zeroing'
        ' the result', (tester) async {
      await tester.pumpWidget(const RerApp());

      await tester.enterText(weightField(), '25.');
      await tester.pump();
      expect(find.text('Enter weight above'), findsNothing);

      // The keystroke that used to make double.tryParse fail.
      await tester.enterText(weightField(), '25..');
      await tester.pump();

      expect(controllerOf(tester, weightField()).text, '25.');
      expect(find.text('Enter weight above'), findsNothing,
          reason: 'result must survive the rejected keystroke');
    });

    testWidgets('accepts an ordinary decimal weight', (tester) async {
      await tester.pumpWidget(const RerApp());

      await tester.enterText(weightField(), '25.5');
      await tester.pump();

      expect(controllerOf(tester, weightField()).text, '25.5');
      expect(find.text('Enter weight above'), findsNothing);
    });

    test('decimalOnly formatter keeps text parseable', () {
      TextEditingValue value(String text) => TextEditingValue(
            text: text,
            selection: TextSelection.collapsed(offset: text.length),
          );

      expect(decimalOnly.formatEditUpdate(value('25.'), value('25..')).text,
          '25.');
      expect(decimalOnly.formatEditUpdate(value('25'), value('25.')).text, '25.');
      expect(
          decimalOnly.formatEditUpdate(value('25.5'), value('25.5')).text, '25.5');
      expect(decimalOnly.formatEditUpdate(value('2'), value('2a')).text, '2');
    });
  });

  group('Disclaimer', () {
    testWidgets('the footer caveat is always visible', (tester) async {
      await tester.pumpWidget(const RerApp());

      expect(
        find.textContaining('not a prescription'),
        findsOneWidget,
        reason: 'the caveat must travel with the number, not be dismissible',
      );

      // Still there once a real target is on screen.
      await tester.enterText(weightField(), '25');
      await tester.pump();
      expect(find.textContaining('monitored by a veterinarian'), findsOneWidget);
    });

    testWidgets('the about dialog explains the formula and the limits',
        (tester) async {
      await tester.pumpWidget(const RerApp());

      await tester.tap(find.byTooltip('About this calculator'));
      await tester.pumpAndSettle();

      expect(find.text('About this calculator'), findsOneWidget);
      expect(find.textContaining('70 x (body weight in kg) ^ 0.75'),
          findsOneWidget);
      expect(find.textContaining('2.2 lb per kg'), findsOneWidget);
      expect(find.textContaining('starting estimate only'), findsOneWidget);

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      expect(find.text('About this calculator'), findsNothing);
    });
  });

  group('Comparison bar', () {
    testWidgets('the fill is actually drawn, at the right fraction',
        (tester) async {
      await tester.pumpWidget(const RerApp());
      await tester.enterText(weightField(), '25');
      await tester.enterText(percentageField(), '60');
      await tester.pump();

      // The background is the first ColoredBox in the bar, the fill the
      // second. FractionallySizedBox shrink-wraps its child under a Stack's
      // loose constraints, so it cannot be used as the track reference.
      final boxes = find.descendant(
        of: find.byType(ComparisonBar),
        matching: find.byType(ColoredBox),
      );
      final trackSize = tester.getSize(boxes.at(0));
      final fillSize = tester.getSize(boxes.at(1));

      // A ColoredBox has no intrinsic size, so a missing heightFactor silently
      // collapses the fill and the bar renders empty.
      expect(fillSize.height, trackSize.height);
      expect(fillSize.height, greaterThan(0));
      // 60% along a 0-120 track.
      expect(fillSize.width / trackSize.width, closeTo(60 / 120, 0.01));
    });

    testWidgets('the fill grows past maintenance into the gain zone',
        (tester) async {
      await tester.pumpWidget(const RerApp());
      await tester.enterText(weightField(), '25');
      await tester.enterText(percentageField(), '120');
      await tester.pump();

      final boxes = find.descendant(
        of: find.byType(ComparisonBar),
        matching: find.byType(ColoredBox),
      );

      expect(
        tester.getSize(boxes.at(1)).width / tester.getSize(boxes.at(0)).width,
        closeTo(1.0, 0.01),
      );
    });
  });

  group('Restriction percentage', () {
    testWidgets('half-typed input does not clamp the slider out from under you',
        (tester) async {
      await tester.pumpWidget(const RerApp());
      await tester.enterText(weightField(), '25');
      await tester.pump();

      // "9" on the way to "95" is below the 50% minimum. It must not be
      // applied yet, or the slider jumps to 50 while the field reads 9.
      await tester.enterText(percentageField(), '9');
      await tester.pump();

      expect(find.text('Maintenance'), findsOneWidget);
      expect(find.text('Aggressive Restriction'), findsNothing);

      await tester.enterText(percentageField(), '95');
      await tester.pump();

      expect(find.text('Maintenance'), findsOneWidget);
      expect(controllerOf(tester, percentageField()).text, '95');
    });

    testWidgets('an out-of-range value is clamped and written back on blur',
        (tester) async {
      await tester.pumpWidget(const RerApp());
      await tester.enterText(weightField(), '25');
      await tester.pump();

      await tester.enterText(percentageField(), '150');
      await tester.pump();

      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();

      expect(controllerOf(tester, percentageField()).text, '120',
          reason: 'field must agree with the clamped model');
      expect(find.text('Weight Gain'), findsOneWidget);
    });

    testWidgets('a below-range value is clamped and written back on blur',
        (tester) async {
      await tester.pumpWidget(const RerApp());
      await tester.enterText(weightField(), '25');
      await tester.pump();

      await tester.enterText(percentageField(), '9');
      await tester.pump();

      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();

      expect(controllerOf(tester, percentageField()).text, '50');
      expect(find.text('Aggressive Restriction'), findsOneWidget);
    });

    testWidgets('clearing the field restores the current value on blur',
        (tester) async {
      await tester.pumpWidget(const RerApp());
      await tester.enterText(weightField(), '25');
      await tester.enterText(percentageField(), '80');
      await tester.pump();

      await tester.enterText(percentageField(), '');
      await tester.pump();

      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();

      expect(controllerOf(tester, percentageField()).text, '80');
    });
  });
}
