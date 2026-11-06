import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pasture_fresh_milk/core/l10n/app_localizations.dart';
import 'package:pasture_fresh_milk/core/theme/app_theme.dart';
import 'package:pasture_fresh_milk/models/milk_collection.dart';
import 'package:pasture_fresh_milk/models/supplier.dart';
import 'package:pasture_fresh_milk/screens/suppliers/widgets/supplier_card.dart';

void main() {
  Widget buildWrapper({
    required Widget child,
    Locale locale = const Locale('en'),
  }) {
    return MaterialApp(
      locale: locale,
      theme: AppTheme.lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Center(child: child),
      ),
    );
  }

  final testSupplier = Supplier(
    id: 's_01',
    name: 'Punjab Dairy Farm',
    location: 'Vehari',
    milkType: 'Buffalo',
    phone: '03001234567',
    pendingKhata: 12500.0,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  final testCollection = MilkCollection(
    id: 'mc_01',
    supplierId: 's_01',
    date: DateTime(2026, 9, 14),
    shift: 'morning',
    quantity: 120.0,
    rate: 180.0,
    batchValue: 21600.0,
    status: 'recorded',
    loggedTime: DateTime(2026, 9, 14, 6, 45),
    createdAt: DateTime(2026, 9, 14),
    updatedAt: DateTime(2026, 9, 14),
  );

  group('SupplierCard (Milestone C-M13)', () {
    testWidgets('State 1: Tested & Recorded renders quality metrics, batch value, and pending khata', (tester) async {
      await tester.pumpWidget(
        buildWrapper(
          child: SupplierCard(
            supplier: testSupplier,
            collection: testCollection,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Punjab Dairy Farm'), findsOneWidget);
      expect(find.text('Vehari • Buffalo'), findsOneWidget);
      expect(find.text('Tested & Recorded'), findsOneWidget);
      expect(find.text('120.0'), findsOneWidget);
      expect(find.text('Rs. 180'), findsOneWidget);
      expect(find.text('Rs. 21600'), findsOneWidget);
      expect(find.textContaining('Pending Khata: Rs. 12500'), findsOneWidget);
      expect(find.text('Pay Cash'), findsOneWidget);
      expect(find.text('View Khata'), findsOneWidget);
    });

    testWidgets('State 2: All Cleared renders cleared badge and Daily Slips action', (tester) async {
      final clearedSupplier = testSupplier.copyWith(pendingKhata: 0.0);

      await tester.pumpWidget(
        buildWrapper(
          child: SupplierCard(
            supplier: clearedSupplier,
            collection: testCollection,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('All Cleared'), findsOneWidget);
      expect(find.text('All Khata Cleared'), findsOneWidget);
      expect(find.text('Daily Slips'), findsOneWidget);
      expect(find.text('View Khata'), findsOneWidget);
      expect(find.text('Pay Cash'), findsNothing);
    });

    testWidgets('State 3: Awaiting Drop renders amber card with transit notice and Log Drop action', (tester) async {
      await tester.pumpWidget(
        buildWrapper(
          child: SupplierCard(
            supplier: testSupplier,
            collection: null, // Not yet dropped
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Punjab Dairy Farm'), findsOneWidget);
      expect(find.text('Awaiting Drop'), findsOneWidget);
      expect(find.text('Batch In Transit'), findsOneWidget);
      expect(find.text('Quick Call'), findsOneWidget);
      expect(find.text('Log Drop'), findsOneWidget);
      expect(find.text('Pay Cash'), findsNothing);
    });

    testWidgets('action buttons trigger onPayCash, onViewKhata, and onLogDrop callbacks', (tester) async {
      bool payCashTapped = false;
      bool viewKhataTapped = false;

      await tester.pumpWidget(
        buildWrapper(
          child: SupplierCard(
            supplier: testSupplier,
            collection: testCollection,
            onPayCash: () => payCashTapped = true,
            onViewKhata: () => viewKhataTapped = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pay Cash'));
      await tester.pumpAndSettle();
      expect(payCashTapped, isTrue);

      await tester.tap(find.text('View Khata'));
      await tester.pumpAndSettle();
      expect(viewKhataTapped, isTrue);

      // Test Log Drop callback on awaiting card
      bool logDropTapped = false;
      await tester.pumpWidget(
        buildWrapper(
          child: SupplierCard(
            supplier: testSupplier,
            collection: null,
            onLogDrop: () => logDropTapped = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Log Drop'));
      await tester.pumpAndSettle();
      expect(logDropTapped, isTrue);
    });

    testWidgets('renders in Urdu locale with RTL without errors', (tester) async {
      await tester.pumpWidget(
        buildWrapper(
          locale: const Locale('ur'),
          child: SupplierCard(
            supplier: testSupplier,
            collection: testCollection,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Punjab Dairy Farm'), findsOneWidget);
      expect(find.text('ٹیسٹ اور ریکارڈ شدہ'), findsOneWidget);
      expect(find.text('نقد ادائیگی'), findsOneWidget);
      expect(find.text('کھاتہ دیکھیں'), findsOneWidget);
    });
  });
}
