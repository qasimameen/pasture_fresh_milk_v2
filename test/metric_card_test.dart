// B-M3 render verification for MetricCard (plan.md B-M3).
//
// Confirms the tile renders with and without subtitle, with and without
// value prefix/suffix, and that onTap inherits AppCard's tap behavior
// (InkWell + press animation when provided, static card when omitted).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:pasture_fresh_milk/core/l10n/app_localizations.dart';
import 'package:pasture_fresh_milk/core/theme/app_colors.dart';
import 'package:pasture_fresh_milk/core/theme/app_theme.dart';
import 'package:pasture_fresh_milk/widgets/app_card.dart';
import 'package:pasture_fresh_milk/widgets/metric_card.dart';

/// Wraps [home] the same way the real app does (B-M1 theme + l10n delegates)
/// so [AppTypography.of] resolves inside the widget tree.
MaterialApp _app(Widget home) {
  return MaterialApp(
    title: 'MetricCard Test',
    theme: AppTheme.lightTheme,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: home),
  );
}

void main() {
  testWidgets('renders label, icon, value with prefix/suffix and subtitle', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        const MetricCard(
          label: 'Total Dues',
          value: '42,650',
          valuePrefix: 'Rs. ',
          valueSuffix: '',
          subtitle: '12 overdue',
          icon: Symbols.payments,
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(MetricCard), findsOneWidget);
    expect(find.byType(AppCard), findsOneWidget);
    expect(find.text('Total Dues'), findsOneWidget);
    expect(find.text('Rs. 42,650'), findsOneWidget);
    expect(find.text('12 overdue'), findsOneWidget);
    expect(find.byIcon(Symbols.payments), findsOneWidget);
  });

  testWidgets('renders without subtitle, prefix/suffix or icon', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(const MetricCard(label: 'Today Cash', value: '1,250')),
    );
    await tester.pump();

    expect(find.byType(AppCard), findsOneWidget);
    expect(find.text('Today Cash'), findsOneWidget);
    expect(find.text('1,250'), findsOneWidget);
    expect(find.text('12 overdue'), findsNothing);
    expect(find.byIcon(Symbols.payments), findsNothing);
  });

  testWidgets('label/value/subtitle use the token-derived styles', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        const MetricCard(
          label: 'Total Dues',
          value: '42,650',
          subtitle: '12 overdue',
          subtitleColor: AppColors.errorText,
          icon: Symbols.payments,
        ),
      ),
    );
    await tester.pump();

    final Text label = tester.widget<Text>(find.text('Total Dues'));
    expect(label.style!.fontSize, 13);
    expect(label.style!.fontWeight, FontWeight.w500);
    expect(label.style!.color, AppColors.neutralMuted);

    final Text value = tester.widget<Text>(find.text('42,650'));
    expect(value.style!.fontSize, 24);
    expect(value.style!.fontWeight, FontWeight.w600);
    expect(value.style!.color, AppColors.neutralTitle);
    expect(value.style!.fontFeatures, <FontFeature>[
      const FontFeature.tabularFigures(),
    ]);

    final Text subtitle = tester.widget<Text>(find.text('12 overdue'));
    expect(subtitle.style!.fontSize, 13);
    expect(subtitle.style!.fontWeight, FontWeight.w500);
    expect(subtitle.style!.color, AppColors.errorText);
  });

  testWidgets('with onTap the AppCard surface is tappable', (tester) async {
    int taps = 0;
    await tester.pumpWidget(
      _app(MetricCard(label: 'Tappable', value: '1', onTap: () => taps++)),
    );
    await tester.pump();

    expect(find.byType(InkWell), findsOneWidget);
    await tester.tap(find.text('Tappable'));
    await tester.pump();
    expect(taps, 1);
  });

  testWidgets('without onTap renders as a static card (no InkWell)', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(const MetricCard(label: 'Static', value: '2')),
    );
    await tester.pump();

    expect(find.byType(AppCard), findsOneWidget);
    expect(find.byType(InkWell), findsNothing);
  });
}
