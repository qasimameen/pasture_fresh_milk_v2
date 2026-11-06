import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pasture_fresh_milk/core/l10n/app_localizations.dart';
import 'package:pasture_fresh_milk/core/theme/app_theme.dart';
import 'package:pasture_fresh_milk/models/customer.dart';
import 'package:pasture_fresh_milk/models/local_sale.dart';
import 'package:pasture_fresh_milk/models/payment.dart';
import 'package:pasture_fresh_milk/models/supplier.dart';
import 'package:pasture_fresh_milk/models/supplier_payment.dart';
import 'package:pasture_fresh_milk/providers/customer_provider.dart';
import 'package:pasture_fresh_milk/providers/local_sale_provider.dart';
import 'package:pasture_fresh_milk/providers/payment_provider.dart';
import 'package:pasture_fresh_milk/providers/supplier_payment_provider.dart';
import 'package:pasture_fresh_milk/providers/supplier_provider.dart';
import 'package:pasture_fresh_milk/screens/payments/payments_screen.dart';
import 'package:pasture_fresh_milk/screens/payments/widgets/record_payment_sheet.dart';
import 'package:pasture_fresh_milk/screens/payments/widgets/transaction_card.dart';
import 'package:pasture_fresh_milk/screens/payments/widgets/whatsapp_reminder_card.dart';
import 'package:pasture_fresh_milk/widgets/empty_state.dart';
import 'package:pasture_fresh_milk/widgets/filter_chip_bar.dart';

void main() {
  final fixedDate = DateTime(2026, 9, 13);

  final mockCustomers = [
    Customer(
      id: 'c_1',
      name: 'Usman Ghani',
      phone: '03001112233',
      status: 'active',

      agreedRate: 220.0,
      currentDue: 3500.0,
      advanceBalance: 0.0,
      createdAt: fixedDate,
      updatedAt: fixedDate,
    ),
    Customer(
      id: 'c_2',
      name: 'Hamza Khan',
      phone: '03004445566',
      status: 'active',

      agreedRate: 220.0,
      currentDue: 1200.0,
      advanceBalance: 500.0,
      createdAt: fixedDate,
      updatedAt: fixedDate,
    ),
    Customer(
      id: 'c_3',
      name: 'Bilal Ahmad',
      phone: '03007778899',
      status: 'active',

      agreedRate: 220.0,
      currentDue: 0.0,
      advanceBalance: 2000.0,
      createdAt: fixedDate,
      updatedAt: fixedDate,
    ),
  ];

  final mockSuppliers = [
    Supplier(
      id: 's_1',
      name: 'Punjab Dairy Farm',
      pendingKhata: 12500.0,
      createdAt: fixedDate,
      updatedAt: fixedDate,
    ),
  ];

  final mockPayments = [
    Payment(
      id: 'p_1',
      customerId: 'c_1',
      date: DateTime(2026, 9, 13, 10, 30),
      amount: 1500.0,
      type: 'cash_payment',
      method: 'cash',
      receiptNumber: 'REC-101',
      runningBalance: 2000.0,
      createdAt: fixedDate,
      updatedAt: fixedDate,
    ),
    Payment(
      id: 'p_2',
      customerId: 'c_3',
      date: DateTime(2026, 9, 13, 11, 15),
      amount: 2000.0,
      type: 'advance_topup',
      method: 'raast',
      raastRef: '#PK-RAAST-01',
      runningBalance: 0.0,
      createdAt: fixedDate,
      updatedAt: fixedDate,
    ),
  ];

  final mockSupplierPayments = [
    SupplierPayment(
      id: 'sp_1',
      supplierId: 's_1',
      date: DateTime(2026, 9, 13, 12, 0),
      amount: 4000.0,
      type: 'cash_payment',
      voucherNumber: 'VCH-100',
      createdAt: fixedDate,
      updatedAt: fixedDate,
    ),
  ];

  final mockLocalSales = [
    LocalSale(
      id: 'ls_1',
      date: DateTime(2026, 9, 13, 13, 0),
      quantity: 5.0,
      productName: 'Cow Milk',
      rate: 180.0,
      totalAmount: 900.0,
      createdAt: fixedDate,
      updatedAt: fixedDate,
    ),
  ];

  Widget buildScreen({
    Locale locale = const Locale('en'),
    List<Customer>? customers,
    List<Supplier>? suppliers,
    List<Payment>? payments,
    List<SupplierPayment>? supplierPayments,
    List<LocalSale>? localSales,
  }) {
    return ProviderScope(
      overrides: [
        customerListProvider.overrideWith(
          (ref) => Future.value(customers ?? mockCustomers),
        ),
        supplierListProvider.overrideWith(
          (ref) => Future.value(suppliers ?? mockSuppliers),
        ),
        todayPaymentsProvider(fixedDate).overrideWith(
          (ref) => Future.value(payments ?? mockPayments),
        ),
        todaySupplierPaymentsProvider(fixedDate).overrideWith(
          (ref) => Future.value(supplierPayments ?? mockSupplierPayments),
        ),
        todayLocalSalesProvider(fixedDate).overrideWith(
          (ref) => Future.value(localSales ?? mockLocalSales),
        ),
      ],
      child: MaterialApp(
        locale: locale,
        theme: AppTheme.lightTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: PaymentsScreen(initialDate: fixedDate),
      ),
    );
  }

  group('PaymentsScreen (Milestone C-M12) — Full Integration Tests', () {
    testWidgets('renders screen header, live sync badge, and language toggle', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Payments & Accounts'), findsOneWidget);
      expect(find.text('LIVE SYNC'), findsOneWidget);
      expect(find.text('اردو'), findsOneWidget); // Toggle to Urdu
    });

    testWidgets('renders 2x2 KPI Bento Grid with computed metrics', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      // Today's Inflow: 1500 (payment) + 2000 (topup) + 900 (sale) = 4400
      expect(find.text("Today's Inflow"), findsOneWidget);
      expect(find.text('Rs. 4400'), findsOneWidget);

      // Customer Dues: 3500 + 1200 + 0 = 4700
      expect(find.text('Customer Dues'), findsOneWidget);
      expect(find.text('Rs. 4700'), findsOneWidget);

      // Dairy Payables: 12500
      expect(find.text('Dairy Payables'), findsOneWidget);
      expect(find.text('Rs. 12500'), findsOneWidget);

      // Cash in Hand: cashInflow (1500 + 900) - cashOutflow (4000) = clamped to 0
      expect(find.text('Cash in Hand'), findsOneWidget);
      expect(find.text('Counter verified'), findsOneWidget);
    });

    testWidgets('renders full-width CTA and opens RecordPaymentSheet on tap', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      final ctaFinder = find.text('+ Record Payment In / Out');
      expect(ctaFinder, findsOneWidget);

      await tester.tap(ctaFinder);
      await tester.pumpAndSettle();

      // Bottom sheet is displayed
      expect(find.byType(RecordPaymentSheet), findsOneWidget);
    });

    testWidgets('renders WhatsApp Reminders carousel for overdue customers', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('WhatsApp Reminders'), findsOneWidget);
      // Overdue customers count badge: 2 (Usman Ghani & Hamza Khan)
      expect(find.text('2'), findsWidgets);
      expect(find.byType(WhatsAppReminderCard), findsNWidgets(2));
      expect(
        find.descendant(
          of: find.byType(WhatsAppReminderCard),
          matching: find.text('Usman Ghani'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(WhatsAppReminderCard),
          matching: find.text('Hamza Khan'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('switching filter chips updates the visible transaction items', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(FilterChipBar), findsOneWidget);

      // All: 4 items (1 collection, 1 topup, 1 supplier payment, 1 local sale)
      expect(find.byType(TransactionCard), findsNWidgets(4));

      // Tap "Collections"
      await tester.tap(
        find.descendant(
          of: find.byType(FilterChipBar),
          matching: find.textContaining('Collections'),
        ),
      );
      await tester.pumpAndSettle();

      // Collections: 3 inflow items (1 collection + 1 advance + 1 retail)
      expect(find.byType(TransactionCard), findsNWidgets(3));

      // Tap "Payables"
      await tester.tap(
        find.descendant(
          of: find.byType(FilterChipBar),
          matching: find.textContaining('Payables'),
        ),
      );
      await tester.pumpAndSettle();

      // Payables: 1 outflow item (Supplier Outflow)
      expect(find.byType(TransactionCard), findsNWidgets(1));
      expect(find.text('Punjab Dairy Farm'), findsOneWidget);
      expect(find.text('-Rs. 4000'), findsOneWidget);
    });

    testWidgets('renders EmptyState when there are no transactions today', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        buildScreen(
          payments: [],
          supplierPayments: [],
          localSales: [],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(EmptyState), findsOneWidget);
      expect(find.text('No transactions today'), findsOneWidget);
    });

    testWidgets('renders in Urdu locale with RTL layout', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        buildScreen(locale: const Locale('ur')),
      );
      await tester.pumpAndSettle();

      expect(find.text('ادائیگیاں اور کھاتے'), findsOneWidget);
      expect(find.text('+ ادائیگی درج کریں / دیں'), findsOneWidget);
    });

  });
}
