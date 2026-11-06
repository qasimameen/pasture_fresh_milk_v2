// B-M16 verification for DateSelector (plan.md B-M16; Section 6
// "DateSelector").
//
// Groups 1-3 (static layout, label formats, arrow navigation) were the
// first sub-task; group 4 covers the follow-up behavior: Urdu `intl ur`
// day/month names when the app locale is 'ur', and the future-date limit —
// the right arrow inert + dimmed exactly from the today+7 boundary.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:pasture_fresh_milk/core/l10n/app_localizations.dart';
import 'package:pasture_fresh_milk/core/theme/app_colors.dart';
import 'package:pasture_fresh_milk/core/theme/app_shadows.dart';
import 'package:pasture_fresh_milk/core/theme/app_spacing.dart';
import 'package:pasture_fresh_milk/widgets/date_selector.dart';

final DateTime _kDate = DateTime(2024, 10, 15); // a Tuesday

Widget _app(Widget child) {
  return MaterialApp(home: Scaffold(body: Center(child: child)));
}

DateSelector _selector({
  DateTime? date,
  ValueChanged<DateTime>? onDateChanged,
  bool showToday = false,
}) {
  return DateSelector(
    selectedDate: date ?? _kDate,
    onDateChanged: onDateChanged ?? (_) {},
    showToday: showToday,
  );
}

/// The pill container — the only decorated Container in the widget (arrows
/// use SizedBox, the center uses Icon/Text).
Finder _pill() => find.descendant(
  of: find.byType(DateSelector),
  matching: find.byType(Container),
).first;

Finder _arrowBox(IconData icon) => find
    .ancestor(
      of: find.byIcon(icon),
      matching: find.byType(SizedBox),
    )
    .first;

void main() {
  group('DateSelector (static layout)', () {
    testWidgets('pill: white bg, shadowSoft, 16px radius', (tester) async {
      await tester.pumpWidget(_app(_selector()));
      await tester.pump();

      final Container pill = tester.widget<Container>(_pill());
      final BoxDecoration deco = pill.decoration! as BoxDecoration;
      expect(deco.color, AppColors.card); // white
      expect(deco.borderRadius, BorderRadius.circular(16)); // radiusXl
      expect(deco.boxShadow, same(AppShadows.shadowSoft));
      // 4px (space2xs) pill padding — documented convention fill.
      expect(pill.padding, const EdgeInsets.all(AppSpacing.space2xs));
    });

    testWidgets('arrows: 28x28 boxes, 16px chevrons in neutralFaint', (
      tester,
    ) async {
      await tester.pumpWidget(_app(_selector()));
      await tester.pump();

      for (final IconData icon in <IconData>[
        Symbols.chevron_left,
        Symbols.chevron_right,
      ]) {
        final Icon chevron = tester.widget<Icon>(find.byIcon(icon));
        expect(chevron.size, 16);
        expect(chevron.color, AppColors.neutralFaint);

        final Rect boxRect = tester.getRect(_arrowBox(icon));
        expect(boxRect.width, 28);
        expect(boxRect.height, 28);
      }
    });

    testWidgets('center: 14px calendar icon + 12px/w600 label in brandPrimary', (
      tester,
    ) async {
      await tester.pumpWidget(_app(_selector()));
      await tester.pump();

      final Icon calendar = tester.widget<Icon>(
        find.byIcon(Symbols.calendar_today),
      );
      expect(calendar.size, 14);
      expect(calendar.color, AppColors.brandPrimary);

      final Text label = tester.widget<Text>(find.text('Tue, 15 Oct'));
      expect(label.style?.fontSize, 12);
      expect(label.style?.fontWeight, FontWeight.w600);
      expect(label.style?.color, AppColors.brandPrimary);
    });
  });

  group('DateSelector (label formats)', () {
    testWidgets('past date: "Day, DD MMM" (weekday abbreviation)', (
      tester,
    ) async {
      // 2024-10-15 is a Tuesday (English/Gregorian, MaterialApp default en).
      await tester.pumpWidget(_app(_selector(date: _kDate)));
      await tester.pump();

      expect(find.text('Tue, 15 Oct'), findsOneWidget);
    });

    testWidgets('showToday + today: "Today, DD MMM"', (tester) async {
      final DateTime now = DateTime.now();
      await tester.pumpWidget(_app(_selector(date: now, showToday: true)));
      await tester.pump();

      final String expected = 'Today, ${DateFormat('d MMM').format(now)}';
      expect(find.text(expected), findsOneWidget);
    });

    testWidgets('today without showToday: weekday form (no "Today")', (
      tester,
    ) async {
      final DateTime now = DateTime.now();
      await tester.pumpWidget(_app(_selector(date: now)));
      await tester.pump();

      final String expected =
          '${DateFormat('EEE').format(now)}, ${DateFormat('d MMM').format(now)}';
      expect(find.text(expected), findsOneWidget);
      expect(find.textContaining('Today,'), findsNothing);
    });

    testWidgets('showToday on a non-today date: still the weekday form', (
      tester,
    ) async {
      await tester.pumpWidget(_app(_selector(date: _kDate, showToday: true)));
      await tester.pump();

      expect(find.text('Tue, 15 Oct'), findsOneWidget);
      expect(find.textContaining('Today,'), findsNothing);
    });
  });

  group('DateSelector (arrow navigation)', () {
    testWidgets('left arrow fires onDateChanged with the previous day', (
      tester,
    ) async {
      DateTime? changed;
      await tester.pumpWidget(
        _app(
          _selector(
            date: _kDate,
            onDateChanged: (DateTime d) => changed = d,
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.byIcon(Symbols.chevron_left));
      await tester.pump();
      expect(changed, DateTime(2024, 10, 14));
    });

    testWidgets('right arrow fires onDateChanged with the next day', (
      tester,
    ) async {
      DateTime? changed;
      await tester.pumpWidget(
        _app(
          _selector(
            date: _kDate,
            onDateChanged: (DateTime d) => changed = d,
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.byIcon(Symbols.chevron_right));
      await tester.pump();
      expect(changed, DateTime(2024, 10, 16));
    });

    testWidgets('month/year roll over via day-0/day-overflow normalization', (
      tester,
    ) async {
      // Nov 1 - 1 day → Oct 31; Oct 31 + 1 day → Nov 1.
      DateTime? prevResult;
      DateTime? nextResult;
      await tester.pumpWidget(
        _app(
          Column(
            children: <Widget>[
              DateSelector(
                selectedDate: DateTime(2024, 11, 1),
                onDateChanged: (DateTime d) => prevResult = d,
              ),
              DateSelector(
                selectedDate: DateTime(2024, 10, 31),
                onDateChanged: (DateTime d) => nextResult = d,
              ),
            ],
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.byIcon(Symbols.chevron_left).first);
      await tester.pump();
      expect(prevResult, DateTime(2024, 10, 31));

      await tester.tap(find.byIcon(Symbols.chevron_right).last);
      await tester.pump();
      expect(nextResult, DateTime(2024, 11, 1));
    });
  });

  group('DateSelector (Urdu locale + future limit)', () {
    /// Urdu app wrapper — the real app's l10n delegates support `ur`
    /// (metric_card_test convention).
    Widget urduApp(Widget child) {
      return MaterialApp(
        locale: const Locale('ur'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: Center(child: child)),
      );
    }

    setUpAll(() {
      // intl needs explicit initialization for non-default locales before
      // DateFormat can format in them (the widget does the same).
      initializeDateFormatting('ur', null);
    });

    testWidgets('ur locale: ur day/month names, same label shape', (
      tester,
    ) async {
      await tester.pumpWidget(
        urduApp(_selector(date: _kDate)),
      );
      await tester.pump();

      // Expected shape "Day, DD MMM" with ur-locale names, computed via the
      // same intl call the widget must be making.
      final String expected =
          '${DateFormat('EEE', 'ur').format(_kDate)}, '
          '${DateFormat('d MMM', 'ur').format(_kDate)}';
      expect(expected, isNot('Tue, 15 Oct')); // names really are localized
      expect(find.text(expected), findsOneWidget);
      expect(find.text('Tue, 15 Oct'), findsNothing);
    });

    testWidgets('ur locale + showToday + today: "Today, DD MMM" with ur names', (
      tester,
    ) async {
      final DateTime now = DateTime.now();
      await tester.pumpWidget(
        urduApp(_selector(date: now, showToday: true)),
      );
      await tester.pump();

      final String expected =
          'Today, ${DateFormat('d MMM', 'ur').format(now)}';
      expect(find.text(expected), findsOneWidget);
    });

    testWidgets('en locale unchanged: English names still render', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: Center(child: _selector(date: _kDate))),
        ),
      );
      await tester.pump();

      expect(find.text('Tue, 15 Oct'), findsOneWidget);
    });

    testWidgets('today+6: right arrow enabled (fires, no dimming)', (
      tester,
    ) async {
      final DateTime now = DateTime.now();
      final DateTime today = DateTime(now.year, now.month, now.day);
      DateTime? changed;
      await tester.pumpWidget(
        _app(
          _selector(
            date: today.add(const Duration(days: 6)),
            onDateChanged: (DateTime d) => changed = d,
          ),
        ),
      );
      await tester.pump();

      // Enabled: tappable and NOT dimmed.
      expect(
        find
            .ancestor(
              of: find.byIcon(Symbols.chevron_right),
              matching: find.byType(Opacity),
            ),
        findsNothing,
      );
      await tester.tap(find.byIcon(Symbols.chevron_right));
      await tester.pump();
      expect(changed, today.add(const Duration(days: 7)));
    });

    testWidgets('today+7: right arrow disabled — inert and dimmed', (
      tester,
    ) async {
      final DateTime now = DateTime.now();
      final DateTime today = DateTime(now.year, now.month, now.day);
      DateTime? changed;
      await tester.pumpWidget(
        _app(
          _selector(
            date: today.add(const Duration(days: 7)),
            onDateChanged: (DateTime d) => changed = d,
          ),
        ),
      );
      await tester.pump();

      // Disabled: 0.5 opacity (AppButton/AppIconButton convention)...
      final Opacity dimming = tester.widget<Opacity>(
        find
            .ancestor(
              of: find.byIcon(Symbols.chevron_right),
              matching: find.byType(Opacity),
            )
            .first,
      );
      expect(dimming.opacity, 0.5);
      // ...and inert: tapping changes nothing.
      await tester.tap(find.byIcon(Symbols.chevron_right));
      await tester.pump();
      expect(changed, isNull);
      // The layout is unchanged: same 28x28 box as the enabled arrow.
      final Rect disabledBox = tester.getRect(
        find.ancestor(
          of: find.byIcon(Symbols.chevron_right),
          matching: find.byType(SizedBox),
        ).first,
      );
      expect(disabledBox.width, 28);
      expect(disabledBox.height, 28);
      // The left arrow stays enabled.
      await tester.tap(find.byIcon(Symbols.chevron_left));
      await tester.pump();
      expect(changed, today.add(const Duration(days: 6)));
    });

    testWidgets('beyond today+7 (today+30): right arrow still disabled', (
      tester,
    ) async {
      final DateTime now = DateTime.now();
      final DateTime today = DateTime(now.year, now.month, now.day);
      DateTime? changed;
      await tester.pumpWidget(
        _app(
          _selector(
            date: today.add(const Duration(days: 30)),
            onDateChanged: (DateTime d) => changed = d,
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.byIcon(Symbols.chevron_right));
      await tester.pump();
      expect(changed, isNull);
    });
  });
}
