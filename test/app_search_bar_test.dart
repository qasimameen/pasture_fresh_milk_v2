// B-M6 render + behavior verification for AppSearchBar (plan.md B-M6).
//
// Confirms field styling (48px height, #F8F9FA bg, 16px radius, 20px search
// icon, 14px/w400 hint/input styles), the 2px brand focus ring, the optional
// 48x48 filter button (only when onFilterTap is provided), the 300ms debounced
// onChanged (NOT fired per keystroke, coalesced to the settled value), and the
// clear button (appears with text, disappears when empty, clears the field and
// fires onChanged('') immediately).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:pasture_fresh_milk/core/l10n/app_localizations.dart';
import 'package:pasture_fresh_milk/core/theme/app_colors.dart';
import 'package:pasture_fresh_milk/core/theme/app_spacing.dart';
import 'package:pasture_fresh_milk/core/theme/app_theme.dart';
import 'package:pasture_fresh_milk/widgets/app_search_bar.dart';

/// Wraps [home] the same way the real app does (B-M1 theme + l10n delegates)
/// so [AppTypography.of] resolves inside the widget tree.
MaterialApp _app(Widget home) {
  return MaterialApp(
    title: 'AppSearchBar Test',
    theme: AppTheme.lightTheme,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: home),
  );
}

/// The field surface — the [AnimatedContainer] carrying the 16px-radius
/// [BoxDecoration] and the 2px focus-ring border.
AnimatedContainer _field(WidgetTester tester) =>
    tester.widget<AnimatedContainer>(find.byType(AnimatedContainer));

void main() {
  testWidgets(
    'field styling: 48px height, scaffold bg, 16px radius, 20px search icon, '
    '14px/w400 hint + input styles; 2px brand focus ring when focused',
    (tester) async {
      final TextEditingController controller = TextEditingController();
      await tester.pumpWidget(
        _app(
          AppSearchBar(
            hintText: 'Search customers...',
            onChanged: (_) {},
            controller: controller,
          ),
        ),
      );
      await tester.pump();

      // Unfocused field: scaffold bg, 16px radius, 2px (transparent) border,
      // 48px height.
      final BoxDecoration unfocused =
          _field(tester).decoration! as BoxDecoration;
      expect(unfocused.color, AppColors.scaffold);
      expect(unfocused.borderRadius, BorderRadius.circular(16));
      expect(unfocused.border!.top.width, 1);
      expect(unfocused.border!.top.color, AppColors.neutralLine);
      expect(
        tester.getSize(find.byType(AnimatedContainer)).height,
        AppSpacing.targetMin,
      );

      // Leading search icon: 20px in neutralFaint (#94A3B8).
      final Icon searchIcon = tester.widget<Icon>(
        find.byIcon(Symbols.search),
      );
      expect(searchIcon.size, 20);
      expect(searchIcon.color, AppColors.neutralFaint);

      // Hint text: 14px/w400 in neutralFaint (#94A3B8).
      final Text hintText = tester.widget<Text>(
        find.text('Search customers...'),
      );
      expect(hintText.style!.fontSize, 14);
      expect(hintText.style!.fontWeight, FontWeight.w400);
      expect(hintText.style!.color, AppColors.neutralFaint);

      // Input text style: 14px/w400 in neutralTitle (#0F172A).
      final EditableText editable = tester.widget<EditableText>(
        find.byType(EditableText),
      );
      expect(editable.style.fontSize, 14);
      expect(editable.style.fontWeight, FontWeight.w400);
      expect(editable.style.color, AppColors.neutralTitle);

      // Focus the field -> the ring animates to brand primary (#1E40AF).
      await tester.tap(find.byType(TextField));
      await tester.pump(); // kick the AnimatedContainer transition
      await tester.pump(const Duration(milliseconds: 250)); // settle 200ms
      final BoxDecoration focused = _field(tester).decoration! as BoxDecoration;
      expect(focused.border!.top.color, AppColors.brandPrimary);
      expect(focused.border!.top.width, 2);
    },
  );

  testWidgets('filter button renders only when onFilterTap is provided', (
    tester,
  ) async {
    // Without onFilterTap: no tune icon in the tree at all.
    await tester.pumpWidget(_app(const AppSearchBar(hintText: 'Search')));
    await tester.pump();
    expect(find.byIcon(Symbols.tune), findsNothing);

    // With onFilterTap: 48x48 scaffold-bg 16px-radius button with a 20px
    // tune icon in neutralMuted (#64748B); tap fires the callback.
    int taps = 0;
    await tester.pumpWidget(
      _app(AppSearchBar(hintText: 'Search', onFilterTap: () => taps++)),
    );
    await tester.pump();

    final Icon tuneIcon = tester.widget<Icon>(find.byIcon(Symbols.tune));
    expect(tuneIcon.size, 20);
    expect(tuneIcon.color, AppColors.neutralMuted);

    final Finder buttonContainer = find.ancestor(
      of: find.byIcon(Symbols.tune),
      matching: find.byType(Container),
    );
    final Container container = tester.widget<Container>(buttonContainer);
    final BoxDecoration decoration = container.decoration! as BoxDecoration;
    expect(decoration.color, AppColors.scaffold);
    expect(decoration.borderRadius, BorderRadius.circular(16));
    expect(container.constraints, const BoxConstraints.tightFor(
      width: AppSpacing.targetMin,
      height: AppSpacing.targetMin,
    ));
    final Size buttonSize = tester.getSize(buttonContainer);
    expect(buttonSize, const Size(AppSpacing.targetMin, AppSpacing.targetMin));

    await tester.tap(find.byIcon(Symbols.tune));
    expect(taps, 1);
  });

  testWidgets('onChanged is debounced 300ms, not fired per keystroke', (
    tester,
  ) async {
    final List<String> values = <String>[];
    await tester.pumpWidget(
      _app(AppSearchBar(hintText: 'Search', onChanged: values.add)),
    );
    await tester.pump();

    // First keystroke: nothing fires immediately...
    await tester.enterText(find.byType(TextField), 'm');
    await tester.pump();
    expect(values, isEmpty);

    // ...nor 299ms later.
    await tester.pump(const Duration(milliseconds: 299));
    expect(values, isEmpty);

    // A second keystroke restarts the debounce — 'm' never fires.
    await tester.enterText(find.byType(TextField), 'mil');
    await tester.pump();
    expect(values, isEmpty);

    // Settling the full 300ms after the LAST keystroke fires once, with the
    // latest text.
    await tester.pump(const Duration(milliseconds: 299));
    expect(values, isEmpty);
    await tester.pump(const Duration(milliseconds: 1));
    expect(values, <String>['mil']);
  });

  testWidgets('clear button: appears with text, clears field, fires '
      "onChanged('') immediately, disappears when empty", (tester) async {
    String? lastValue;
    final List<int> timestamps = <int>[];
    await tester.pumpWidget(
      _app(
        AppSearchBar(
          hintText: 'Search',
          onChanged: (String v) {
            lastValue = v;
            timestamps.add(
              DateTime.now().millisecondsSinceEpoch, // fake clock ticks
            );
          },
        ),
      ),
    );
    await tester.pump();

    // Empty field: no clear button.
    expect(find.byIcon(Symbols.close), findsNothing);

    // Type -> clear button appears (with the still-pending debounce).
    await tester.enterText(find.byType(TextField), 'milk');
    await tester.pump();
    expect(find.byIcon(Symbols.close), findsOneWidget);

    // Tap clear -> field empties, onChanged('') fires IMMEDIATELY (without
    // pumping the 300ms debounce), and the button disappears.
    await tester.tap(find.byIcon(Symbols.close));
    expect(lastValue, '');

    await tester.pump();
    expect(find.byIcon(Symbols.close), findsNothing);
    expect(find.byType(EditableText), findsOneWidget);
    final EditableText editable = tester.widget<EditableText>(
      find.byType(EditableText),
    );
    expect(editable.controller.text, isEmpty);

    // The pending debounced 'milk' call was cancelled: settling time now
    // must not add any further callbacks.
    await tester.pump(const Duration(milliseconds: 500));
    expect(timestamps, hasLength(1));
  });
}

