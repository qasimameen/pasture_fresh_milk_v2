import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pasture_fresh_milk/core/theme/app_colors.dart';
import 'package:pasture_fresh_milk/core/theme/app_theme.dart';
import 'package:pasture_fresh_milk/providers/locale_provider.dart';
import 'package:pasture_fresh_milk/widgets/language_toggle.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  Widget buildSubject({
    Locale? selectedLocale,
    ValueChanged<Locale>? onLocaleChanged,
    List<Override> overrides = const <Override>[],
  }) {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Center(
            child: LanguageToggle(
              selectedLocale: selectedLocale,
              onLocaleChanged: onLocaleChanged,
            ),
          ),
        ),
      ),
    );
  }

  group('LanguageToggle — Layout and Typography', () {
    testWidgets('renders EN and اردو labels with 11px font sizes', (tester) async {
      await tester.pumpWidget(buildSubject(selectedLocale: const Locale('en')));

      final enText = tester.widget<Text>(find.text('EN'));
      final urduText = tester.widget<Text>(find.text('اردو'));

      expect(find.text('EN'), findsOneWidget);
      expect(find.text('اردو'), findsOneWidget);

      expect(enText.style?.fontSize, 11);
      expect(enText.style?.fontWeight, FontWeight.w500);

      expect(urduText.style?.fontSize, 11);
      expect(urduText.style?.fontWeight, FontWeight.w400);
    });

    testWidgets('renders active styling on EN when selectedLocale is en', (tester) async {
      await tester.pumpWidget(buildSubject(selectedLocale: const Locale('en')));

      final enText = tester.widget<Text>(find.text('EN'));
      final urduText = tester.widget<Text>(find.text('اردو'));

      // Active EN text is brandPrimary (#1E40AF)
      expect(enText.style?.color, AppColors.brandPrimary);
      // Inactive Urdu text is neutralMuted (#64748B)
      expect(urduText.style?.color, AppColors.neutralMuted);
    });

    testWidgets('renders active styling on اردو when selectedLocale is ur', (tester) async {
      await tester.pumpWidget(buildSubject(selectedLocale: const Locale('ur')));

      final enText = tester.widget<Text>(find.text('EN'));
      final urduText = tester.widget<Text>(find.text('اردو'));

      // Inactive EN text is neutralMuted
      expect(enText.style?.color, AppColors.neutralMuted);
      // Active Urdu text is brandPrimary
      expect(urduText.style?.color, AppColors.brandPrimary);
    });
  });

  group('LanguageToggle — Interactions and Callbacks', () {
    testWidgets('tapping اردو invokes onLocaleChanged with ur', (tester) async {
      Locale? selected;
      await tester.pumpWidget(
        buildSubject(
          selectedLocale: const Locale('en'),
          onLocaleChanged: (locale) => selected = locale,
        ),
      );

      await tester.tap(find.text('اردو'));
      await tester.pumpAndSettle();

      expect(selected, const Locale('ur'));
    });

    testWidgets('tapping EN invokes onLocaleChanged with en', (tester) async {
      Locale? selected;
      await tester.pumpWidget(
        buildSubject(
          selectedLocale: const Locale('ur'),
          onLocaleChanged: (locale) => selected = locale,
        ),
      );

      await tester.tap(find.text('EN'));
      await tester.pumpAndSettle();

      expect(selected, const Locale('en'));
    });

    testWidgets('taps update localeProvider when no callback is passed', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: Center(
                child: LanguageToggle(),
              ),
            ),
          ),
        ),
      );

      expect(container.read(localeProvider), const Locale('en'));

      await tester.tap(find.text('اردو'));
      await tester.pumpAndSettle();

      expect(container.read(localeProvider), const Locale('ur'));
    });
  });

  group('LanguageToggle — Persistence & SharedPreferences', () {
    testWidgets('loads initial persisted locale from SharedPreferences', (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        kLocaleStorageKey: 'ur',
      });

      final prefs = await SharedPreferences.getInstance();
      final notifier = LocaleNotifier(prefs);
      await tester.pump();

      expect(notifier.state, const Locale('ur'));
    });

    testWidgets('persists chosen locale to SharedPreferences on update', (tester) async {
      final prefs = await SharedPreferences.getInstance();
      final notifier = LocaleNotifier(prefs);

      await notifier.setLocale(const Locale('ur'));

      expect(prefs.getString(kLocaleStorageKey), 'ur');
    });
  });

  group('LanguageToggle — Animation & Semantics', () {
    testWidgets('animates active segment transition with 200ms duration', (tester) async {
      await tester.pumpWidget(buildSubject(selectedLocale: const Locale('en')));

      final Finder pillFinder = find.ancestor(
        of: find.text('EN'),
        matching: find.byType(AnimatedContainer),
      );
      final AnimatedContainer pill = tester.widget(pillFinder);
      expect(pill.duration, const Duration(milliseconds: 200));
      expect(pill.curve, Curves.easeInOut);
    });

    testWidgets('provides button and selected semantics', (tester) async {
      await tester.pumpWidget(buildSubject(selectedLocale: const Locale('en')));

      final enSemantics = tester.getSemantics(find.text('EN')).getSemanticsData();
      expect(enSemantics.hasFlag(SemanticsFlag.isButton), isTrue);
      expect(enSemantics.hasFlag(SemanticsFlag.isSelected), isTrue);

      final urduSemantics = tester.getSemantics(find.text('اردو')).getSemanticsData();
      expect(urduSemantics.hasFlag(SemanticsFlag.isButton), isTrue);
      expect(urduSemantics.hasFlag(SemanticsFlag.isSelected), isFalse);
    });
  });
}
