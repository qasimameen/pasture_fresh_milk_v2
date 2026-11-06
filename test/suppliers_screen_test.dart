import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pasture_fresh_milk/core/l10n/app_localizations.dart';
import 'package:pasture_fresh_milk/core/theme/app_theme.dart';
import 'package:pasture_fresh_milk/models/milk_collection.dart';
import 'package:pasture_fresh_milk/models/supplier.dart';
import 'package:pasture_fresh_milk/providers/milk_collection_provider.dart';
import 'package:pasture_fresh_milk/providers/supplier_provider.dart';
import 'package:pasture_fresh_milk/screens/suppliers/suppliers_screen.dart';
import 'package:pasture_fresh_milk/screens/suppliers/widgets/supplier_card.dart';
import 'package:pasture_fresh_milk/widgets/empty_state.dart';
import 'package:pasture_fresh_milk/widgets/filter_chip_bar.dart';

void main() {
  final fixedDate = DateTime(2026, 9, 14);

  final mockSuppliers = [
    Supplier(
      id: 's_01',
      name: 'Punjab Dairy Farm',
      location: 'Vehari',
      milkType: 'Buffalo',
      phone: '03001234567',
      pendingKhata: 12500.0,
      createdAt: fixedDate,
      updatedAt: fixedDate,
    ),
    Supplier(
      id: 's_02',
      name: 'Sindh Cattle Farm',
      location: 'Hyderabad',
      milkType: 'Cow',
      phone: '03007654321',
      pendingKhata: 0.0, // All cleared
      createdAt: fixedDate,
      updatedAt: fixedDate,
    ),
    Supplier(
      id: 's_03',
      name: 'Multan Dairy Co',
      location: 'Multan',
      milkType: 'Buffalo',
      phone: '03009998888',
      pendingKhata: 8000.0, // Awaiting drop
      createdAt: fixedDate,
      updatedAt: fixedDate,
    ),
  ];

  final mockCollections = [
    MilkCollection(
      id: 'mc_01',
      supplierId: 's_01',
      date: fixedDate,
      shift: 'morning',
      quantity: 120.0,
      rate: 180.0,
      batchValue: 21600.0,
      status: 'recorded',
      loggedTime: DateTime(2026, 9, 14, 6, 45),
      createdAt: fixedDate,
      updatedAt: fixedDate,
    ),
    MilkCollection(
      id: 'mc_02',
      supplierId: 's_02',
      date: fixedDate,
      shift: 'morning',
      quantity: 80.0,
      rate: 160.0,
      batchValue: 12800.0,
      status: 'recorded',
      loggedTime: DateTime(2026, 9, 14, 7, 15),
      createdAt: fixedDate,
      updatedAt: fixedDate,
    ),
  ];

  const mockStats = (
    totalQuantity: 200.0,
    totalPayable: 34400.0,
    avgRate: 172.0,
  );

  Widget buildScreen({
    List<Supplier>? suppliers,
    List<MilkCollection>? collections,
    Locale locale = const Locale('en'),
  }) {
    return ProviderScope(
      overrides: [
        supplierListProvider.overrideWith(
          (ref) => Future.value(suppliers ?? mockSuppliers),
        ),
        milkCollectionListProvider(fixedDate).overrideWith(
          (ref) => Future.value(collections ?? mockCollections),
        ),
        milkCollectionStatsProvider(fixedDate).overrideWith(
          (ref) => Future.value(mockStats),
        ),
      ],
      child: MaterialApp(
        locale: locale,
        theme: AppTheme.lightTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SuppliersScreen(initialDate: fixedDate),
      ),
    );
  }

  group('SuppliersScreen (Milestone C-M13) — Integration Tests', () {
    void setTallSurface(WidgetTester tester) {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    }

    testWidgets('renders screen header, live shift badge, and language toggle', (tester) async {
      setTallSurface(tester);
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Suppliers & Procurement'), findsOneWidget);
      expect(find.text('LIVE SHIFT'), findsOneWidget);
      expect(find.text('Pasture Fresh Milk'), findsOneWidget);
      expect(find.text('اردو'), findsOneWidget);
    });

    testWidgets('renders 2x2 KPI Bento Grid with computed milk collection metrics', (tester) async {
      setTallSurface(tester);
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      // Total Milk Inward
      expect(find.text('Total Milk Inward'), findsOneWidget);
      expect(find.text('200.0 L'), findsOneWidget);
      expect(find.text('vs yesterday'), findsOneWidget);

      // Today's Payable
      expect(find.text("Today's Payable"), findsOneWidget);
      expect(find.text('Rs. 34400'), findsOneWidget);
      expect(find.textContaining('Rs. 172/L'), findsOneWidget);
    });

    testWidgets('renders full-width CTA and FAB', (tester) async {
      setTallSurface(tester);
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('+ Record Inward Milk'), findsOneWidget);
      expect(find.byKey(const Key('log_supply_fab')), findsOneWidget);
      expect(find.text('+ Log Supply'), findsOneWidget);
    });

    testWidgets('renders farm count badge in section header', (tester) async {
      setTallSurface(tester);
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Suppliers & Milk Batches'), findsOneWidget);
      expect(find.text('3 Farms'), findsOneWidget);
    });

    testWidgets('switching filter chips filters between All, Pending Khata, Recorded, and Awaiting', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(FilterChipBar), findsOneWidget);

      // All: 3 suppliers
      expect(find.byType(SupplierCard), findsNWidgets(3));

      // Tap "Pending Khata" (s_01 and s_03 have pending khata > 0)
      await tester.tap(
        find.descendant(
          of: find.byType(FilterChipBar),
          matching: find.textContaining('Pending Khata'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(SupplierCard), findsNWidgets(2));
      expect(find.text('Punjab Dairy Farm'), findsOneWidget);
      expect(find.text('Multan Dairy Co'), findsOneWidget);

      // Tap "Recorded" (s_01 and s_02 have collections today)
      await tester.tap(
        find.descendant(
          of: find.byType(FilterChipBar),
          matching: find.textContaining('Recorded'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(SupplierCard), findsNWidgets(2));
      expect(find.text('Punjab Dairy Farm'), findsOneWidget);
      expect(find.text('Sindh Cattle Farm'), findsOneWidget);

      // Tap "Awaiting" (s_03 has no collection recorded today)
      await tester.tap(
        find.descendant(
          of: find.byType(FilterChipBar),
          matching: find.textContaining('Awaiting'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(SupplierCard), findsNWidgets(1));
      expect(find.text('Multan Dairy Co'), findsOneWidget);
      expect(find.text('Awaiting Drop'), findsOneWidget);
    });

    testWidgets('renders EmptyState when there are no suppliers', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        buildScreen(suppliers: [], collections: []),
      );
      await tester.pumpAndSettle();

      expect(find.byType(EmptyState), findsOneWidget);
      expect(find.text('No suppliers found'), findsOneWidget);
    });

    testWidgets('renders in Urdu locale with RTL layout', (tester) async {
      await tester.pumpWidget(
        buildScreen(locale: const Locale('ur')),
      );
      await tester.pumpAndSettle();

      expect(find.text('سپلائرز اور دودھ خریداری'), findsOneWidget);
      expect(find.text('لائیو شفٹ'), findsOneWidget);
      expect(find.text('+ دودھ آمد درج کریں'), findsOneWidget);

    });
  });
}
