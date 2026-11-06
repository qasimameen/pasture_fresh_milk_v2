import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:pasture_fresh_milk/core/theme/app_colors.dart';
import 'package:pasture_fresh_milk/widgets/shift_selector.dart';

void main() {
  Widget buildSubject({
    ShiftType selectedShift = ShiftType.morning,
    ValueChanged<ShiftType>? onShiftChanged,
    int? morningCount,
    int? eveningCount,
    Locale locale = const Locale('en'),
  }) {
    return MaterialApp(
      locale: locale,
      home: Scaffold(
        body: Center(
          child: ShiftSelector(
            selectedShift: selectedShift,
            onShiftChanged: onShiftChanged,
            morningCount: morningCount,
            eveningCount: eveningCount,
          ),
        ),
      ),
    );
  }

  group('ShiftSelector — Layout and Rendering', () {
    testWidgets('renders Morning (AM) and Evening (PM) labels and icons', (tester) async {
      await tester.pumpWidget(buildSubject());

      expect(find.text('Morning (AM)'), findsOneWidget);
      expect(find.text('Evening (PM)'), findsOneWidget);
      expect(find.byIcon(Symbols.wb_sunny), findsOneWidget);
      expect(find.byIcon(Symbols.nights_stay), findsOneWidget);
    });

    testWidgets('renders active state on Morning when selectedShift is morning', (tester) async {
      await tester.pumpWidget(buildSubject(selectedShift: ShiftType.morning));

      final morningText = tester.widget<Text>(find.text('Morning (AM)'));
      final eveningText = tester.widget<Text>(find.text('Evening (PM)'));

      // Active morning text is white (AppColors.card)
      expect(morningText.style?.color, AppColors.card);
      // Inactive evening text is neutralMuted
      expect(eveningText.style?.color, AppColors.neutralMuted);
    });

    testWidgets('renders active state on Evening when selectedShift is evening', (tester) async {
      await tester.pumpWidget(buildSubject(selectedShift: ShiftType.evening));

      final morningText = tester.widget<Text>(find.text('Morning (AM)'));
      final eveningText = tester.widget<Text>(find.text('Evening (PM)'));

      // Inactive morning text is neutralMuted
      expect(morningText.style?.color, AppColors.neutralMuted);
      // Active evening text is white (AppColors.card)
      expect(eveningText.style?.color, AppColors.card);
    });
  });

  group('ShiftSelector — Interactions', () {
    testWidgets('tapping Evening triggers onShiftChanged with ShiftType.evening', (tester) async {
      ShiftType? selected;
      await tester.pumpWidget(
        buildSubject(
          selectedShift: ShiftType.morning,
          onShiftChanged: (shift) => selected = shift,
        ),
      );

      await tester.tap(find.text('Evening (PM)'));
      await tester.pumpAndSettle();

      expect(selected, ShiftType.evening);
    });

    testWidgets('tapping Morning triggers onShiftChanged with ShiftType.morning', (tester) async {
      ShiftType? selected;
      await tester.pumpWidget(
        buildSubject(
          selectedShift: ShiftType.evening,
          onShiftChanged: (shift) => selected = shift,
        ),
      );

      await tester.tap(find.text('Morning (AM)'));
      await tester.pumpAndSettle();

      expect(selected, ShiftType.morning);
    });

    testWidgets('tapping works when onShiftChanged is null without throwing', (tester) async {
      await tester.pumpWidget(
        buildSubject(
          selectedShift: ShiftType.morning,
          onShiftChanged: null,
        ),
      );

      await tester.tap(find.text('Evening (PM)'));
      await tester.pumpAndSettle();
    });
  });

  group('ShiftSelector — Count Badges', () {
    testWidgets('displays count pills when counts are greater than zero', (tester) async {
      await tester.pumpWidget(
        buildSubject(
          morningCount: 14,
          eveningCount: 8,
        ),
      );

      expect(find.text('14'), findsOneWidget);
      expect(find.text('8'), findsOneWidget);
    });

    testWidgets('hides count pills when counts are 0 or null', (tester) async {
      await tester.pumpWidget(
        buildSubject(
          morningCount: 0,
          eveningCount: null,
        ),
      );

      expect(find.text('0'), findsNothing);
    });
  });

  group('ShiftSelector — Urdu Locale & RTL', () {
    testWidgets('renders without overflow in Urdu locale', (tester) async {
      await tester.pumpWidget(
        buildSubject(
          locale: const Locale('ur'),
          morningCount: 5,
          eveningCount: 10,
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Morning (AM)'), findsOneWidget);
      expect(find.text('Evening (PM)'), findsOneWidget);
    });
  });

  group('ShiftSelector — Animation & Semantics', () {
    testWidgets('animates active pill transition with 200ms duration', (tester) async {
      await tester.pumpWidget(
        buildSubject(selectedShift: ShiftType.morning),
      );

      final Finder morningPillFinder = find.ancestor(
        of: find.text('Morning (AM)'),
        matching: find.byType(AnimatedContainer),
      );
      final AnimatedContainer morningPill = tester.widget(morningPillFinder);
      expect(morningPill.duration, const Duration(milliseconds: 200));
      expect(morningPill.curve, Curves.easeInOut);
    });

    testWidgets('provides button and selected semantics for active and inactive segments', (tester) async {
      await tester.pumpWidget(
        buildSubject(
          selectedShift: ShiftType.morning,
        ),
      );

      final morningData = tester.getSemantics(find.text('Morning (AM)')).getSemanticsData();
      expect(morningData.hasFlag(SemanticsFlag.isButton), isTrue);
      expect(morningData.hasFlag(SemanticsFlag.isSelected), isTrue);

      final eveningData = tester.getSemantics(find.text('Evening (PM)')).getSemanticsData();
      expect(eveningData.hasFlag(SemanticsFlag.isButton), isTrue);
      expect(eveningData.hasFlag(SemanticsFlag.isSelected), isFalse);
    });
  });
}

