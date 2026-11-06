// B-M5 render verification for FilterChipBar (plan.md B-M5).
//
// Confirms active vs inactive chip styling, count/dot rendering, 8px chip
// gaps, the 48px tap-target height, the onSelected callback, horizontal
// scrolling on overflow, and auto-scroll to the active chip on selection
// change.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pasture_fresh_milk/core/l10n/app_localizations.dart';
import 'package:pasture_fresh_milk/core/theme/app_colors.dart';
import 'package:pasture_fresh_milk/core/theme/app_shadows.dart';
import 'package:pasture_fresh_milk/core/theme/app_spacing.dart';
import 'package:pasture_fresh_milk/core/theme/app_theme.dart';
import 'package:pasture_fresh_milk/widgets/filter_chip_bar.dart';

/// Wraps [home] the same way the real app does (B-M1 theme + l10n delegates)
/// so [AppTypography.of] resolves inside the widget tree.
MaterialApp _app(Widget home) {
  return MaterialApp(
    title: 'FilterChipBar Test',
    theme: AppTheme.lightTheme,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: home),
  );
}

const List<FilterChipData> _chips = <FilterChipData>[
  FilterChipData(label: 'All'),
  FilterChipData(label: 'Has Dues', count: 12),
  FilterChipData(
    label: 'Collections',
    count: 24,
    dotColor: AppColors.successMain,
  ),
];

const List<FilterChipData> _longChips = <FilterChipData>[
  FilterChipData(label: 'Very Long Filter One'),
  FilterChipData(label: 'Very Long Filter Two'),
  FilterChipData(label: 'Very Long Filter Three'),
  FilterChipData(label: 'Very Long Filter Four'),
  FilterChipData(label: 'Very Long Filter Five'),
  FilterChipData(label: 'Very Long Filter Six'),
];

/// Returns the pill [Container] ancestor of [labelText] — the Container with
/// the 9999px-radius [BoxDecoration].
Container _pill(WidgetTester tester, String labelText) {
  return tester
      .widgetList<Container>(
        find.ancestor(
          of: find.text(labelText),
          matching: find.byType(Container),
        ),
      )
      .firstWhere(
        (Container container) =>
            container.decoration is BoxDecoration &&
            (container.decoration! as BoxDecoration).borderRadius ==
                BorderRadius.circular(9999),
      );
}

void main() {
  testWidgets(
    'active chip is brand-filled with shadow; inactive is white; counts and '
    'dots render; gaps, padding and tap target match the spec',
    (tester) async {
      await tester.pumpWidget(
        _app(
          FilterChipBar(chips: _chips, selectedIndex: 1, onSelected: (_) {}),
        ),
      );
      await tester.pump();

      // Active pill (Has Dues, index 1).
      final BoxDecoration active =
          _pill(tester, 'Has Dues (12)').decoration! as BoxDecoration;
      expect(active.color, AppColors.brandPrimary);
      expect(active.borderRadius, BorderRadius.circular(9999));
      expect(active.boxShadow, AppShadows.shadowSoft);

      // Inactive pills are white with no shadow.
      final BoxDecoration inactive =
          _pill(tester, 'All').decoration! as BoxDecoration;
      expect(inactive.color, AppColors.card);
      expect(inactive.boxShadow, AppShadows.shadowNone);
      expect(
        _pill(tester, 'Collections (24)').decoration! as BoxDecoration,
        isNot(same(active)),
      );
      expect(
        (_pill(tester, 'Collections (24)').decoration! as BoxDecoration).color,
        AppColors.card,
      );

      // Typography: 12px/w600 white active, 12px/w500 body-color inactive.
      final Text activeText = tester.widget<Text>(find.text('Has Dues (12)'));
      expect(activeText.style!.fontSize, 12);
      expect(activeText.style!.fontWeight, FontWeight.w600);
      expect(activeText.style!.color, AppColors.card);

      final Text inactiveText = tester.widget<Text>(find.text('All'));
      expect(inactiveText.style!.fontSize, 12);
      expect(inactiveText.style!.fontWeight, FontWeight.w500);
      expect(inactiveText.style!.color, AppColors.neutralBody);

      // Count is appended as "(N)" and the dot renders in its color.
      expect(find.text('Has Dues (12)'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (Widget w) =>
              w is Container &&
              w.decoration is BoxDecoration &&
              (w.decoration! as BoxDecoration).shape == BoxShape.circle &&
              (w.decoration! as BoxDecoration).color == AppColors.successMain,
        ),
        findsOneWidget,
      );

      // 8px gaps between chips (row spacing token).
      final Row row = tester.widget<Row>(find.byType(Row).first);
      expect(row.spacing, AppSpacing.spaceXs);

      // Pill padding: 16px horizontal (spaceMd) / 6px vertical.
      expect(
        _pill(tester, 'All').padding,
        const EdgeInsets.symmetric(horizontal: AppSpacing.spaceMd, vertical: 6),
      );

      // 48px minimum tap-target height; the pill itself stays compact.
      final Size wrapperSize = tester.getSize(
        find.ancestor(
          of: find.text('All'),
          matching: find.byWidgetPredicate(
            (Widget w) =>
                w is ConstrainedBox &&
                w.constraints ==
                    const BoxConstraints(minHeight: AppSpacing.targetMin),
          ),
        ),
      );
      expect(wrapperSize.height, AppSpacing.targetMin);
      final Size pillSize = tester.getSize(
        find.ancestor(
          of: find.text('All'),
          matching: find.byWidgetPredicate(
            (Widget w) => w is Container && w.decoration is BoxDecoration,
          ),
        ),
      );
      expect(pillSize.height, lessThan(AppSpacing.targetMin));
    },
  );

  testWidgets('tapping a chip fires onSelected with its index', (tester) async {
    int? selected;
    await tester.pumpWidget(
      _app(
        FilterChipBar(
          chips: _chips,
          selectedIndex: 0,
          onSelected: (int index) => selected = index,
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Collections (24)'));
    expect(selected, 2);

    await tester.tap(find.text('All'));
    expect(selected, 0);

    await tester.tap(find.text('Has Dues (12)'));
    expect(selected, 1);
  });

  testWidgets('bar scrolls horizontally when chips overflow', (tester) async {
    await tester.pumpWidget(
      _app(
        SizedBox(
          width: 300,
          child: FilterChipBar(
            chips: _longChips,
            selectedIndex: 0,
            onSelected: (_) {},
          ),
        ),
      ),
    );
    await tester.pump();

    // The last chip is outside the 300px viewport.
    expect(find.text('Very Long Filter Six').hitTestable(), findsNothing);

    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(-2000, 0),
    );
    await tester.pumpAndSettle();

    expect(find.text('Very Long Filter Six').hitTestable(), findsOneWidget);
  });

  testWidgets('auto-scrolls to the active chip on selection change', (
    tester,
  ) async {
    Future<void> pumpBar(int selectedIndex) async {
      await tester.pumpWidget(
        _app(
          SizedBox(
            width: 300,
            child: FilterChipBar(
              chips: _longChips,
              selectedIndex: selectedIndex,
              onSelected: (_) {},
            ),
          ),
        ),
      );
      await tester.pump();
    }

    await pumpBar(0);
    final ScrollableState scrollable = tester.state<ScrollableState>(
      find.byType(Scrollable),
    );
    expect(scrollable.position.pixels, 0);

    // Select the last chip -> the bar auto-scrolls to keep it visible.
    await pumpBar(5);
    await tester.pumpAndSettle(); // post-frame ensureVisible + 200ms animation

    expect(scrollable.position.pixels, greaterThan(0));
    expect(find.text('Very Long Filter Six').hitTestable(), findsOneWidget);
  });
}
