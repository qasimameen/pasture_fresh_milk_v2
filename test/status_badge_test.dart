// B-M4 render verification for StatusBadge (plan.md B-M4).
//
// Confirms every factory renders its Section 1.1 bg/text color pair, the
// pill shape/padding/typography match the B-M4 spec, the "done" icon renders
// at 14px for delivered/cleared and is omitted cleanly otherwise, and the
// custom constructor + label overrides work.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:pasture_fresh_milk/core/l10n/app_localizations.dart';
import 'package:pasture_fresh_milk/core/theme/app_colors.dart';
import 'package:pasture_fresh_milk/core/theme/app_theme.dart';
import 'package:pasture_fresh_milk/widgets/status_badge.dart';

/// Wraps [home] the same way the real app does (B-M1 theme + l10n delegates)
/// so [AppTypography.of] resolves inside the widget tree.
MaterialApp _app(Widget home) {
  return MaterialApp(
    title: 'StatusBadge Test',
    theme: AppTheme.lightTheme,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: home),
  );
}

/// Returns the badge's pill [Container] (the ancestor of the label that
/// carries a [BoxDecoration]).
Container _pill(WidgetTester tester, String label) {
  return tester
      .widgetList<Container>(
        find.ancestor(of: find.text(label), matching: find.byType(Container)),
      )
      .firstWhere(
        (Container container) => container.decoration is BoxDecoration,
      );
}

void main() {
  testWidgets('every factory renders its Section 1.1 bg/text color pair', (
    tester,
  ) async {
    final List<(StatusBadge, Color, Color, String)> cases =
        <(StatusBadge, Color, Color, String)>[
          (
            const StatusBadge.active(),
            AppColors.successLight,
            AppColors.successText,
            'Active',
          ),
          (
            const StatusBadge.pending(),
            AppColors.warningLight,
            AppColors.warningText,
            'Pending',
          ),
          (
            const StatusBadge.delivered(),
            AppColors.successLight,
            AppColors.successText,
            'Delivered',
          ),
          (
            const StatusBadge.skipped(),
            AppColors.errorLight,
            AppColors.errorMain,
            'Skipped',
          ),
          (
            const StatusBadge.paused(),
            AppColors.brandSubtle,
            AppColors.neutralMuted,
            'Paused',
          ),
          (
            const StatusBadge.overdue(days: 3),
            AppColors.errorLight,
            AppColors.errorMain,
            '3 days overdue',
          ),
          (
            const StatusBadge.cleared(),
            AppColors.successLight,
            AppColors.successText,
            'Cleared',
          ),
          (
            const StatusBadge.advance(),
            AppColors.brandSoft,
            AppColors.brandPrimary,
            'Advance',
          ),
          (
            const StatusBadge.supplierOutflow(),
            AppColors.errorLight,
            AppColors.errorMain,
            'Supplier Outflow',
          ),
          (
            const StatusBadge.dailyRetail(),
            AppColors.warningLight,
            AppColors.warningDark,
            'Daily Retail',
          ),
        ];

    for (final (StatusBadge badge, Color bg, Color text, String label)
        in cases) {
      await tester.pumpWidget(_app(badge));
      await tester.pump();

      final Text textWidget = tester.widget<Text>(find.text(label));
      expect(textWidget.style!.color, text, reason: '$label text color');
      expect(textWidget.style!.fontSize, 11, reason: '$label font size');
      expect(
        textWidget.style!.fontWeight,
        FontWeight.w700,
        reason: '$label font weight',
      );
      expect(
        textWidget.style!.letterSpacing,
        0.06 * 11,
        reason: '$label letter spacing',
      );

      final Container pill = _pill(tester, label);
      final BoxDecoration decoration = pill.decoration! as BoxDecoration;
      expect(decoration.color, bg, reason: '$label bg color');
      expect(
        decoration.borderRadius,
        BorderRadius.circular(9999),
        reason: '$label pill radius',
      );
      expect(
        pill.padding,
        const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        reason: '$label pill padding',
      );
    }
  });

  testWidgets('delivered and cleared render the done icon at 14px', (
    tester,
  ) async {
    await tester.pumpWidget(_app(const StatusBadge.delivered()));
    await tester.pump();

    final Icon deliveredIcon = tester.widget<Icon>(find.byIcon(Symbols.done));
    expect(deliveredIcon.size, 14);
    expect(deliveredIcon.color, AppColors.successText);

    await tester.pumpWidget(_app(const StatusBadge.cleared()));
    await tester.pump();

    final Icon clearedIcon = tester.widget<Icon>(find.byIcon(Symbols.done));
    expect(clearedIcon.size, 14);
    expect(clearedIcon.color, AppColors.successText);
  });

  testWidgets('badges without an icon omit it cleanly', (tester) async {
    await tester.pumpWidget(_app(const StatusBadge.active()));
    await tester.pump();

    expect(find.text('Active'), findsOneWidget);
    expect(find.byType(Icon), findsNothing);
  });

  testWidgets('default constructor renders custom label, colors and iconSize', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        const StatusBadge(
          label: 'Raast',
          backgroundColor: AppColors.brandTint,
          textColor: AppColors.brandPrimaryDark,
          icon: Symbols.done,
          iconSize: 18.0,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Raast'), findsOneWidget);

    final Container pill = _pill(tester, 'Raast');
    final BoxDecoration decoration = pill.decoration! as BoxDecoration;
    expect(decoration.color, AppColors.brandTint);

    final Icon icon = tester.widget<Icon>(find.byIcon(Symbols.done));
    expect(icon.size, 18.0);
    expect(icon.color, AppColors.brandPrimaryDark);
  });

  testWidgets('label overrides and overdue pluralization work', (tester) async {
    await tester.pumpWidget(_app(const StatusBadge.delivered(label: 'Paid')));
    await tester.pump();
    expect(find.text('Paid'), findsOneWidget);
    expect(find.text('Delivered'), findsNothing);

    await tester.pumpWidget(_app(const StatusBadge.overdue(days: 1)));
    await tester.pump();
    expect(find.text('1 day overdue'), findsOneWidget);

    await tester.pumpWidget(_app(const StatusBadge.overdue(days: 3)));
    await tester.pump();
    expect(find.text('3 days overdue'), findsOneWidget);

    await tester.pumpWidget(
      _app(const StatusBadge.overdue(days: 7, label: 'Late')),
    );
    await tester.pump();
    expect(find.text('Late'), findsOneWidget);
    expect(find.text('7 days overdue'), findsNothing);
  });
}
