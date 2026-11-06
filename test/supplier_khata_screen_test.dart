import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pasture_fresh_milk/core/l10n/app_localizations.dart';
import 'package:pasture_fresh_milk/core/theme/app_theme.dart';
import 'package:pasture_fresh_milk/models/milk_collection.dart';
import 'package:pasture_fresh_milk/models/supplier.dart';
import 'package:pasture_fresh_milk/models/supplier_payment.dart';
import 'package:pasture_fresh_milk/providers/milk_collection_provider.dart';
import 'package:pasture_fresh_milk/providers/supplier_payment_provider.dart';
import 'package:pasture_fresh_milk/providers/supplier_provider.dart';
import 'package:pasture_fresh_milk/screens/suppliers/supplier_khata_screen.dart';
import 'package:pasture_fresh_milk/screens/suppliers/widgets/pay_supplier_sheet.dart';

void main() {
  final now = DateTime(2026, 9, 14, 8, 30);

  final mockSupplier = Supplier(
    id: 'supp_101',
    name: 'Al-Haseeb Dairy Farm',
    location: 'Chak 45-RB',
    milkType: 'Buffalo Pure',
    phone: '03001234567',
    pendingKhata: 24500.0,
    createdAt: now,
    updatedAt: now,
  );

  final mockCollections = [
    MilkCollection(
      id: 'col_1',
      supplierId: 'supp_101',
      date: DateTime(2026, 9, 14),
      shift: 'morning',
      quantity: 120.0,

      rate: 210.0,
      batchValue: 25200.0,
      status: 'recorded',
      loggedTime: DateTime(2026, 9, 14, 7, 15),
      notes: 'Clean morning drop',
      createdAt: now,
      updatedAt: now,
    ),
    MilkCollection(
      id: 'col_2',
      supplierId: 'supp_101',
      date: DateTime(2026, 9, 13),
      shift: 'evening',
      quantity: 100.0,

      rate: 210.0,
      batchValue: 21000.0,
      status: 'recorded',
      loggedTime: DateTime(2026, 9, 13, 18, 45),
      createdAt: now,
      updatedAt: now,
    ),
  ];

  final mockPayments = [
    SupplierPayment(
      id: 'pay_1',
      supplierId: 'supp_101',
      date: DateTime(2026, 9, 13, 19, 0),
      amount: 20000.0,
      type: 'cash_payment',
      voucherNumber: 'VCH-981',
      notes: 'Evening cash payout',
      createdAt: now,
      updatedAt: now,
    ),
  ];

  Widget buildHarness({
    Supplier? supplier,
    List<MilkCollection>? collections,
    List<SupplierPayment>? payments,
    VoidCallback? onCall,
    Locale locale = const Locale('en'),
  }) {
    return ProviderScope(
      overrides: [
        supplierByIdProvider('supp_101').overrideWith(
          (ref) async => supplier ?? mockSupplier,
        ),
        supplierCollectionsProvider('supp_101').overrideWith(
          (ref) async => collections ?? mockCollections,
        ),
        supplierPaymentListProvider('supp_101').overrideWith(
          (ref) async => payments ?? mockPayments,
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SupplierKhataScreen(
          supplierId: 'supp_101',
          onCall: onCall,
        ),
      ),
    );
  }

  group('SupplierKhataScreen Tests (C-M15)', () {
    testWidgets('renders supplier summary card with pending khata and metrics', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildHarness());
      await tester.pumpAndSettle();

      // Check AppBar title
      expect(find.text('Al-Haseeb Dairy Farm'), findsAtLeastNWidgets(1));

      // Check Location & Milk Type
      expect(find.text('Chak 45-RB'), findsOneWidget);
      expect(find.text('Buffalo Pure'), findsOneWidget);

      // Check Pending Khata
      expect(find.text('PENDING KHATA'), findsOneWidget);
      expect(find.text('Rs. 24500'), findsOneWidget);

      // Check Pay Cash CTA
      expect(find.byKey(const Key('pay_cash_cta')), findsOneWidget);

      // Check Summary Metrics: 120 + 100 = 220 L, payments = 20,000
      expect(find.text('Total Milk Supplied'), findsOneWidget);
      expect(find.text('220.0'), findsOneWidget);
      expect(find.text('Total Payments'), findsOneWidget);
      expect(find.text('Rs. 20000'), findsOneWidget);
    });

    testWidgets('renders collections list in first tab', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildHarness());
      await tester.pumpAndSettle();

      // Collections tab active by default
      expect(find.text('120.0'), findsOneWidget);

      expect(find.text('Rs. 210'), findsNWidgets(2));
      expect(find.text('Rs. 25200'), findsOneWidget);
      expect(find.text('Clean morning drop'), findsOneWidget);

      expect(find.text('100.0'), findsOneWidget);
      expect(find.text('Rs. 21000'), findsOneWidget);
    });

    testWidgets('switching to Payments tab displays payment history', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildHarness());
      await tester.pumpAndSettle();

      // Tap Payments tab
      await tester.tap(find.text('Payments'));
      await tester.pumpAndSettle();

      // Should display payment entry
      expect(find.text('Rs. 20000'), findsAtLeastNWidgets(1));
      expect(find.text('Voucher: VCH-981'), findsOneWidget);
      expect(find.text('Evening cash payout'), findsOneWidget);
      expect(find.text('Cash'), findsOneWidget);
    });

    testWidgets('tapping Pay Cash opens PaySupplierSheet', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildHarness());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('pay_cash_cta')), warnIfMissed: false);
      await tester.pumpAndSettle();

      // Sheet should appear
      expect(find.byType(PaySupplierSheet), findsOneWidget);
      expect(find.text('Pay Supplier Cash'), findsOneWidget);
    });

    testWidgets('call button triggers phone dialer callback', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      bool callTriggered = false;
      await tester.pumpWidget(
        buildHarness(onCall: () => callTriggered = true),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('call_supplier_button')));
      await tester.pumpAndSettle();

      expect(callTriggered, isTrue);
    });

    testWidgets('displays empty states when collections and payments are empty', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        buildHarness(
          collections: <MilkCollection>[],
          payments: <SupplierPayment>[],
        ),
      );
      await tester.pumpAndSettle();

      // Empty collections tab
      expect(find.text('No milk collections recorded'), findsOneWidget);

      // Switch to payments tab
      await tester.tap(find.text('Payments'));
      await tester.pumpAndSettle();

      // Empty payments tab
      expect(find.text('No payments recorded yet'), findsOneWidget);
    });

    testWidgets('renders correctly in Urdu RTL layout', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        buildHarness(locale: const Locale('ur')),
      );
      await tester.pumpAndSettle();

      // Check Urdu tab labels
      expect(find.text('آمد دودھ'), findsOneWidget);
      expect(find.text('ادائیگیوں کی تفصیل'), findsOneWidget);
      expect(find.text('نقد ادائیگی'), findsOneWidget);
    });
  });
}
