import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pasture_fresh_milk/core/l10n/app_localizations.dart';
import 'package:pasture_fresh_milk/core/routes/app_routes.dart';
import 'package:pasture_fresh_milk/core/theme/app_theme.dart';
import 'package:pasture_fresh_milk/screens/settings/settings_screen.dart';
import 'package:pasture_fresh_milk/screens/settings/store_profile_screen.dart';

void main() {
  Widget buildHarness({
    Locale locale = const Locale('en'),
    NavigatorObserver? observer,
  }) {
    return ProviderScope(
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        navigatorObservers: observer != null ? [observer] : [],
        onGenerateRoute: AppRoutes.onGenerateRoute,
        home: const SettingsScreen(),
      ),
    );
  }

  group('SettingsScreen (C-M16)', () {
    testWidgets('renders screen title and all 4 configuration options',
        (tester) async {
      await tester.pumpWidget(buildHarness());
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
      expect(
        find.text('Store configuration and delivery operations'),
        findsOneWidget,
      );

      expect(find.text('Store Profile'), findsOneWidget);
      expect(
        find.text('Shop name, contact phone, and address'),
        findsOneWidget,
      );

      expect(find.text('Products & Pricing'), findsOneWidget);
      expect(find.text('Manage milk products and rates'), findsOneWidget);

      expect(find.text('Shifts & Routes'), findsOneWidget);
      expect(
        find.text('Configure delivery shifts and routes'),
        findsOneWidget,
      );

      expect(find.text('Drivers'), findsOneWidget);
      expect(find.text('Delivery personnel and riders'), findsOneWidget);
    });

    testWidgets('tapping Store Profile navigates to profile screen',
        (tester) async {
      await tester.pumpWidget(buildHarness());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Store Profile'));
      await tester.pumpAndSettle();

      // StoreProfileScreen renders
      expect(find.byType(StoreProfileScreen), findsOneWidget);
    });

    testWidgets('renders cleanly in Urdu locale with RTL', (tester) async {
      await tester.pumpWidget(buildHarness(locale: const Locale('ur')));
      await tester.pumpAndSettle();

      expect(find.text('ترتیبات'), findsOneWidget);
      expect(find.text('دکان کا پروفائل'), findsOneWidget);
      expect(find.text('مصنوعات اور قیمتیں'), findsOneWidget);
      expect(find.text('شفٹس اور روٹس'), findsOneWidget);
      expect(find.text('ڈرائیورز'), findsOneWidget);
    });
  });
}
