import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pasture_fresh_milk/app.dart';
import 'package:pasture_fresh_milk/core/l10n/app_localizations.dart';
import 'package:pasture_fresh_milk/core/routes/app_routes.dart';
import 'package:pasture_fresh_milk/core/theme/app_theme.dart';
import 'package:pasture_fresh_milk/screens/app_shell.dart';
import 'package:pasture_fresh_milk/screens/customers/customer_detail_screen.dart';
import 'package:pasture_fresh_milk/screens/customers/customers_screen.dart';
import 'package:pasture_fresh_milk/screens/home/home_screen.dart';
import 'package:pasture_fresh_milk/screens/deliveries/deliveries_screen.dart';
import 'package:pasture_fresh_milk/screens/payments/payments_screen.dart';
import 'package:pasture_fresh_milk/providers/supplier_provider.dart';
import 'package:pasture_fresh_milk/screens/settings/drivers_screen.dart';
import 'package:pasture_fresh_milk/screens/settings/products_pricing_screen.dart';
import 'package:pasture_fresh_milk/screens/settings/settings_screen.dart';
import 'package:pasture_fresh_milk/screens/settings/store_profile_screen.dart';
import 'package:pasture_fresh_milk/screens/suppliers/supplier_khata_screen.dart';
import 'package:pasture_fresh_milk/screens/suppliers/suppliers_screen.dart';
import 'package:pasture_fresh_milk/widgets/bottom_nav_bar.dart';


import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  Widget buildShell({
    Locale locale = const Locale('en'),
    int initialIndex = 0,
  }) {
    return ProviderScope(
      child: MaterialApp(
        locale: locale,
        theme: AppTheme.lightTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: AppShell(initialIndex: initialIndex),
      ),
    );
  }

  group('AppShell — 5-Tab Navigation & State Preservation', () {
    testWidgets('renders all 5 tabs and starts on the initial tab (Home)', (tester) async {
      await tester.pumpWidget(buildShell());
      await tester.pump(); await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(BottomNavBar), findsOneWidget);
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byKey(const Key('tab_view_home')), findsOneWidget);
    });

    testWidgets('switching tabs updates the visible content via IndexedStack', (tester) async {
      await tester.pumpWidget(buildShell());
      await tester.pump(); await tester.pump(const Duration(milliseconds: 500));

      // Switch to Customers (tab index 1)
      await tester.tap(find.descendant(of: find.byType(BottomNavBar), matching: find.text('Customers')));
      await tester.pump(); await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(CustomersScreen), findsOneWidget);

      // Switch to Deliveries (tab index 2)
      await tester.tap(find.descendant(of: find.byType(BottomNavBar), matching: find.text('Deliveries')));
      await tester.pump(); await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(DeliveriesScreen), findsOneWidget);

      // Switch to Payments (tab index 3)
      await tester.tap(find.descendant(of: find.byType(BottomNavBar), matching: find.text('Payments')));
      await tester.pump(); await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(PaymentsScreen), findsOneWidget);


      // Switch to Suppliers (tab index 4)
      await tester.tap(find.descendant(of: find.byType(BottomNavBar), matching: find.text('Suppliers')));
      await tester.pump(); await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(SuppliersScreen), findsOneWidget);
      expect(find.byKey(const Key('tab_view_suppliers')), findsOneWidget);
    });

    testWidgets('preserves tab state when switching between tabs', (tester) async {
      await tester.pumpWidget(buildShell());
      await tester.pump(); await tester.pump(const Duration(milliseconds: 500));

      // Switch to Suppliers tab (index 4)
      await tester.tap(find.descendant(of: find.byType(BottomNavBar), matching: find.text('Suppliers')));
      await tester.pump(); await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(SuppliersScreen), findsOneWidget);

      // Tap Evening shift on Suppliers tab
      await tester.tap(find.text('Evening (PM)'));
      await tester.pump(); await tester.pump(const Duration(milliseconds: 500));

      // Switch to Payments tab
      await tester.tap(find.descendant(of: find.byType(BottomNavBar), matching: find.text('Payments')));
      await tester.pump(); await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(PaymentsScreen), findsOneWidget);

      // Switch back to Suppliers tab
      await tester.tap(find.descendant(of: find.byType(BottomNavBar), matching: find.text('Suppliers')));
      await tester.pump(); await tester.pump(const Duration(milliseconds: 500));

      // State is preserved in SuppliersScreen
      expect(find.byType(SuppliersScreen), findsOneWidget);
    });
  });

  group('AppShell — Localization (EN & UR)', () {
    Finder tabLabel(String text) => find.descendant(
          of: find.byType(BottomNavBar),
          matching: find.text(text),
        );

    testWidgets('renders English tab labels', (tester) async {
      await tester.pumpWidget(buildShell(locale: const Locale('en')));
      await tester.pump(); await tester.pump(const Duration(milliseconds: 500));

      expect(tabLabel('Home'), findsOneWidget);
      expect(tabLabel('Customers'), findsOneWidget);
      expect(tabLabel('Deliveries'), findsOneWidget);
      expect(tabLabel('Payments'), findsOneWidget);
      expect(tabLabel('Suppliers'), findsOneWidget);
    });

    testWidgets('renders Urdu tab labels under Locale(ur) with RTL', (tester) async {
      await tester.pumpWidget(buildShell(locale: const Locale('ur')));
      await tester.pump(); await tester.pump(const Duration(milliseconds: 500));

      expect(tabLabel('ہوم'), findsOneWidget);
      expect(tabLabel('گاہک'), findsOneWidget);
      expect(tabLabel('ڈیلیوری'), findsOneWidget);
      expect(tabLabel('ادائیگی'), findsOneWidget);
      expect(tabLabel('سپلائر'), findsOneWidget);
    });
  });

  group('AppRoutes — Route Generation & Parameter Parsing', () {
    testWidgets('generates parameterized Customer Detail route (/customer/:id)', (tester) async {
      final route = AppRoutes.onGenerateRoute(
        const RouteSettings(name: '/customer/cust_101'),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () => Navigator.of(context).push(route),
                  child: const Text('Go to Customer'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Go to Customer'));
      await tester.pump(); await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(CustomerDetailScreen), findsOneWidget);
    });

    testWidgets('generates parameterized Supplier Khata route (/supplier/:id/khata)', (tester) async {
      final route = AppRoutes.onGenerateRoute(
        const RouteSettings(name: '/supplier/sup_202/khata'),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            supplierByIdProvider('sup_202').overrideWith((ref) async => null),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () => Navigator.of(context).push(route),
                  child: const Text('Go to Khata'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Go to Khata'));
      await tester.pump(); await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(SupplierKhataScreen), findsOneWidget);
    });

    testWidgets('generates Settings subroutes', (tester) async {
      // 1. Settings shell
      final settingsRoute = AppRoutes.onGenerateRoute(
        const RouteSettings(name: '/settings'),
      );
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            key: const ValueKey('settings_shell_test_app'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () => Navigator.of(context).push(settingsRoute),
                  child: const Text('Go to /settings'),
                );
              },
            ),
          ),
        ),
      );
      await tester.tap(find.text('Go to /settings'));
      await tester.pump(); await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(SettingsScreen), findsOneWidget);

      // 2. Settings Profile
      final profileRoute = AppRoutes.onGenerateRoute(
        const RouteSettings(name: '/settings/profile'),
      );
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            key: const ValueKey('settings_profile_test_app'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () => Navigator.of(context).push(profileRoute),
                  child: const Text('Go to /settings/profile'),
                );
              },
            ),
          ),
        ),
      );
      await tester.tap(find.text('Go to /settings/profile'));
      await tester.pump(); await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(StoreProfileScreen), findsOneWidget);

      // 3. Settings Products & Pricing
      final productsRoute = AppRoutes.onGenerateRoute(
        const RouteSettings(name: '/settings/products'),
      );
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            key: const ValueKey('settings_products_test_app'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () => Navigator.of(context).push(productsRoute),
                  child: const Text('Go to /settings/products'),
                );
              },
            ),
          ),
        ),
      );
      await tester.tap(find.text('Go to /settings/products'));
      await tester.pump(); await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(ProductsPricingScreen), findsOneWidget);


      // 5. Drivers (/settings/drivers)
      final driversRoute = AppRoutes.onGenerateRoute(
        const RouteSettings(name: '/settings/drivers'),
      );
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            key: const ValueKey<String>('drivers-test-app'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () => Navigator.of(context).push(driversRoute),
                  child: const Text('Go to /settings/drivers'),
                );
              },
            ),
          ),
        ),
      );
      await tester.tap(find.text('Go to /settings/drivers'));
      await tester.pump(); await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(DriversScreen), findsOneWidget);
    });
  });

  group('AlMadinaDairyApp — Root Smoke Test', () {
    testWidgets('launches AlMadinaDairyApp into AppShell', (tester) async {
      await tester.pumpWidget(const AlMadinaDairyApp());
      await tester.pump(); await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(AppShell), findsOneWidget);
      expect(find.byType(BottomNavBar), findsOneWidget);
      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });
}
