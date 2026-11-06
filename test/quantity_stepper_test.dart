// B-M7 behavior + render verification for QuantityStepper (plan.md B-M7).
//
// Confirms single-tap increment/decrement, step amount (0.5 default),
// bounds clamping (never below min, never above max), unit label, and
// token-derived styling (container bg, button size/shadow, value style).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:pasture_fresh_milk/core/l10n/app_localizations.dart';
import 'package:pasture_fresh_milk/core/theme/app_colors.dart';
import 'package:pasture_fresh_milk/core/theme/app_shadows.dart';
import 'package:pasture_fresh_milk/core/theme/app_spacing.dart';
import 'package:pasture_fresh_milk/core/theme/app_theme.dart';
import 'package:pasture_fresh_milk/widgets/quantity_stepper.dart';

MaterialApp _app(Widget child) {
  return MaterialApp(
    title: 'QuantityStepper Test',
    theme: AppTheme.lightTheme,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}

/// A simple stateful wrapper that keeps [value] in sync with onChanged
/// so every tap produces a fresh [value] prop (mirrors a real parent).
class _StepperHost extends StatefulWidget {
  const _StepperHost({
    required this.initialValue,
    this.step = 0.5,
    this.min = 0.0,
    this.max = 99.0,
    this.onChanged,
  });

  final double initialValue;
  final double step;
  final double min;
  final double max;
  final ValueChanged<double>? onChanged;

  @override
  State<_StepperHost> createState() => _StepperHostState();
}

class _StepperHostState extends State<_StepperHost> {
  late double value;

  @override
  void initState() {
    super.initState();
    value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return QuantityStepper(
      value: value,
      step: widget.step,
      min: widget.min,
      max: widget.max,
      onChanged: (double v) {
        setState(() => value = v);
        widget.onChanged?.call(v);
      },
    );
  }
}

void main() {
  group('QuantityStepper', () {
    testWidgets('renders initial value', (tester) async {
      await tester.pumpWidget(
        _app(QuantityStepper(value: 0.5, onChanged: (_) {})),
      );
      await tester.pump();

      expect(find.text('0.5'), findsOneWidget);
      expect(find.byIcon(Symbols.remove), findsOneWidget);
      expect(find.byIcon(Symbols.add), findsOneWidget);
    });



    testWidgets('tap + increments by step (0.5)', (tester) async {
      final List<double> recorded = [];
      await tester.pumpWidget(
        _app(_StepperHost(initialValue: 1.0, onChanged: recorded.add)),
      );
      await tester.pump();

      await tester.tap(find.byIcon(Symbols.add));
      await tester.pump();

      expect(recorded, [1.5]);
      expect(find.text('1.5'), findsOneWidget);
    });

    testWidgets('tap - decrements by step (0.5)', (tester) async {
      final List<double> recorded = [];
      await tester.pumpWidget(
        _app(_StepperHost(initialValue: 1.0, onChanged: recorded.add)),
      );
      await tester.pump();

      await tester.tap(find.byIcon(Symbols.remove));
      await tester.pump();

      expect(recorded, [0.5]);
      expect(find.text('0.5'), findsOneWidget);
    });

    testWidgets('increment clamps at max — no onChanged call', (tester) async {
      final List<double> recorded = [];
      await tester.pumpWidget(
        _app(
          _StepperHost(
            initialValue: 99.0,
            min: 0.0,
            max: 99.0,
            onChanged: recorded.add,
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.byIcon(Symbols.add));
      await tester.pump();

      expect(recorded, isEmpty);
      final Text display = tester.widget<Text>(
        find
            .descendant(
              of: find.byType(QuantityStepper),
              matching: find.byType(Text),
            )
            .first,
      );
      expect(display.data, startsWith('99'));
    });

    testWidgets('decrement clamps at min — no onChanged call', (tester) async {
      final List<double> recorded = [];
      await tester.pumpWidget(
        _app(
          _StepperHost(
            initialValue: 0.0,
            min: 0.0,
            max: 99.0,
            onChanged: recorded.add,
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.byIcon(Symbols.remove));
      await tester.pump();

      expect(recorded, isEmpty);
      final Text display = tester.widget<Text>(
        find
            .descendant(
              of: find.byType(QuantityStepper),
              matching: find.byType(Text),
            )
            .first,
      );
      expect(display.data, startsWith('0'));
    });

    testWidgets('clamping snaps to exact bound on overshoot', (tester) async {
      final List<double> recorded = [];
      await tester.pumpWidget(
        _app(
          _StepperHost(
            initialValue: 98.5,
            step: 0.5,
            max: 99.0,
            onChanged: recorded.add,
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.byIcon(Symbols.add));
      await tester.pump();

      expect(recorded, [99.0]);
    });

    testWidgets('custom step amount works', (tester) async {
      final List<double> recorded = [];
      await tester.pumpWidget(
        _app(
          _StepperHost(initialValue: 10.0, step: 1.0, onChanged: recorded.add),
        ),
      );
      await tester.pump();

      await tester.tap(find.byIcon(Symbols.add));
      await tester.pump();

      expect(recorded, [11.0]);
    });

    testWidgets('value label uses bodySm (13px/w500, neutralTitle)', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(QuantityStepper(value: 0.5, onChanged: (_) {})),
      );
      await tester.pump();

      final Text valueText = tester.widget<Text>(find.text('0.5'));
      expect(valueText.style?.fontSize, 13);
      expect(valueText.style?.fontWeight, FontWeight.w500);
      expect(valueText.style?.color, AppColors.neutralTitle);
    });

    testWidgets('outer container has scaffold bg and 16px radius', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(QuantityStepper(value: 0.5, onChanged: (_) {})),
      );
      await tester.pump();

      final Container outer = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(QuantityStepper),
              matching: find.byType(Container),
            )
            .first,
      );
      final BoxDecoration deco = outer.decoration! as BoxDecoration;
      expect(deco.color, AppColors.scaffold);
      expect(deco.borderRadius, BorderRadius.circular(16));
    });

    testWidgets('buttons are 32x32 with card bg, shadowSoft, 12px radius', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(QuantityStepper(value: 0.5, onChanged: (_) {})),
      );
      await tester.pump();

      final Iterable<Container> allContainers = tester.widgetList<Container>(
        find.descendant(
          of: find.byType(QuantityStepper),
          matching: find.byType(Container),
        ),
      );

      final Iterable<Container> buttons = allContainers.where((Container c) {
        final BoxDecoration? dec = c.decoration as BoxDecoration?;
        return dec != null &&
            dec.color == AppColors.card &&
            dec.boxShadow == AppShadows.shadowSoft;
      });
      expect(buttons.length, 2);

      for (final Container btn in buttons) {
        expect(btn.constraints?.maxWidth, AppSpacing.space2xl);
        expect(btn.constraints?.maxHeight, AppSpacing.space2xl);
        final BoxDecoration dec = btn.decoration! as BoxDecoration;
        expect(dec.borderRadius, BorderRadius.circular(12));
      }
    });

    testWidgets('multiple taps compose from latest value', (tester) async {
      final List<double> recorded = [];
      await tester.pumpWidget(
        _app(_StepperHost(initialValue: 0.5, onChanged: recorded.add)),
      );
      await tester.pump();

      await tester.tap(find.byIcon(Symbols.add));
      await tester.pump();
      await tester.tap(find.byIcon(Symbols.add));
      await tester.pump();
      await tester.tap(find.byIcon(Symbols.remove));
      await tester.pump();

      expect(recorded, [1.0, 1.5, 1.0]);
    });
  });
}
