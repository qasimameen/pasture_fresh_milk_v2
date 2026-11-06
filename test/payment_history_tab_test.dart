import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pasture_fresh_milk/core/l10n/app_localizations.dart';
import 'package:pasture_fresh_milk/core/theme/app_theme.dart';
import 'package:pasture_fresh_milk/models/payment.dart';
import 'package:pasture_fresh_milk/models/customer.dart';
import 'package:pasture_fresh_milk/screens/customers/widgets/payment_history_tab.dart';
import 'package:pasture_fresh_milk/widgets/empty_state.dart';

void main() {
  final testPayments = <Payment>[
    Payment(
      id: 'pay_001',
      customerId: 'cust_001',
      date: DateTime(2026, 9, 11, 10, 0),
      amount: 1500.0,
      method: 'cash',
      type: 'cash_payment',
      receiptNumber: 'REC-1001',
      runningBalance: 500.0,
      createdAt: DateTime(2026, 9, 11),
      updatedAt: DateTime(2026, 9, 11),
    ),
    Payment(
      id: 'pay_002',
      customerId: 'cust_001',
      date: DateTime(2026, 9, 5, 15, 30),
      amount: 2000.0,
      method: 'raast',
      type: 'advance_topup',
      raastRef: 'RAAST-7890',
      runningBalance: 2500.0,
      createdAt: DateTime(2026, 9, 5),
      updatedAt: DateTime(2026, 9, 5),
    ),
    Payment(
      id: 'pay_003',
      customerId: 'cust_001',
      date: DateTime(2026, 8, 20, 11, 15),
      amount: 3000.0,
      method: 'bank_transfer',
      type: 'cash_payment',
      receiptNumber: 'BANK-3344',
      runningBalance: 5500.0,
      createdAt: DateTime(2026, 8, 20),
      updatedAt: DateTime(2026, 8, 20),
    ),
    // Deduction type - should be filtered out by PaymentHistoryTab
    Payment(
      id: 'pay_004',
      customerId: 'cust_001',
      date: DateTime(2026, 9, 1, 9, 0),
      amount: 360.0,
      method: 'auto',
      type: 'advance_deduction',
      runningBalance: 2140.0,
      createdAt: DateTime(2026, 9, 1),
      updatedAt: DateTime(2026, 9, 1),
    ),
  ];

  Widget buildTab({
    List<Payment>? payments,
    Locale locale = const Locale('en'),
    int pageSize = 20,
  }) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: PaymentHistoryTab(
          payments: payments ?? testPayments,
          customer: Customer(id: 'c1', name: 'Test Customer', phone: '123', status: 'active', agreedRate: 200.0, createdAt: DateTime.now(), updatedAt: DateTime.now()),
          pageSize: pageSize,
        ),
      ),
    );
  }

  group('PaymentHistoryTab (Milestone C-M9)', () {
    testWidgets('renders empty state when list is empty', (tester) async {
      await tester.pumpWidget(buildTab(payments: []));
      await tester.pumpAndSettle();

      expect(find.byType(EmptyState), findsOneWidget);
      expect(find.text('No payments recorded yet'), findsOneWidget);
    });

    testWidgets('filters to cash_payment and advance_topup only', (tester) async {
      await tester.pumpWidget(buildTab());
      await tester.pumpAndSettle();

      // pay_001, pay_002, pay_003 rendered, pay_004 (advance_deduction) filtered out
      // Count badge in section header displays 3
      expect(find.text('3'), findsOneWidget);
      expect(find.text('Payment History'), findsOneWidget);
    });

    testWidgets('renders month headers with sum', (tester) async {
      await tester.pumpWidget(buildTab());
      await tester.pumpAndSettle();

      // September 2026 header with total 1500 + 2000 = 3500
      expect(find.text('September 2026'), findsOneWidget);
      expect(find.text('Rs. 3500'), findsOneWidget);

      // August 2026 header with total 3000
      expect(find.text('August 2026'), findsOneWidget);
      expect(find.text('Rs. 3000'), findsOneWidget);
    });

    testWidgets('renders method badges: Cash, Raast, and Bank', (tester) async {
      await tester.pumpWidget(buildTab());
      await tester.pumpAndSettle();

      expect(find.text('Cash'), findsOneWidget);
      expect(find.text('Raast'), findsOneWidget);
      expect(find.text('Bank'), findsOneWidget);
    });

    testWidgets('renders amounts with +Rs. prefix', (tester) async {
      await tester.pumpWidget(buildTab());
      await tester.pumpAndSettle();

      expect(find.text('+Rs. 1500'), findsOneWidget);
      expect(find.text('+Rs. 2000'), findsOneWidget);
      expect(find.text('+Rs. 3000'), findsOneWidget);
    });

    testWidgets('renders receipt numbers and references', (tester) async {
      await tester.pumpWidget(buildTab());
      await tester.pumpAndSettle();

      expect(find.text('#REC-1001'), findsOneWidget);
      expect(find.text('RAAST-7890'), findsOneWidget);
      expect(find.text('#BANK-3344'), findsOneWidget);
    });

    testWidgets('renders in Urdu locale', (tester) async {
      await tester.pumpWidget(buildTab(locale: const Locale('ur')));
      await tester.pumpAndSettle();

      expect(find.text('ادائیگیوں کی تاریخ'), findsOneWidget);
      expect(find.text('نقد'), findsOneWidget);
      expect(find.text('راسٹ'), findsOneWidget);
    });
  });
}
