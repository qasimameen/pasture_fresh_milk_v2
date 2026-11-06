import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pasture_fresh_milk/core/l10n/app_localizations.dart';
import 'package:pasture_fresh_milk/core/theme/app_theme.dart';
import 'package:pasture_fresh_milk/models/local_sale.dart';
import 'package:pasture_fresh_milk/models/payment.dart';
import 'package:pasture_fresh_milk/models/supplier_payment.dart';
import 'package:pasture_fresh_milk/screens/payments/widgets/transaction_card.dart';

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
      home: Scaffold(body: Center(child: child)),
    );
  }

  group('TransactionCard (Milestone C-M12)', () {
    testWidgets('Customer Collection renders green amount, title, and Cleared badge', (tester) async {
      final now = DateTime(2026, 9, 13, 10, 30);
      final payment = Payment(
        id: 'p_1',
        customerId: 'c_1',
        date: now,
        amount: 1500.0,
        type: 'cash_payment',
        method: 'cash',
        receiptNumber: 'REC-101',
        runningBalance: 0.0,
        createdAt: now,
        updatedAt: now,
      );

      await tester.pumpWidget(
        buildWrapper(
          child: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context);
              final item = TransactionFeedItem.fromPayment(
                payment,
                customerName: 'Muhammad Ali',
                l10n: l10n,
              );
              return TransactionCard(item: item);
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Muhammad Ali'), findsOneWidget);
      expect(find.text('+Rs. 1500'), findsOneWidget);
      expect(find.text('Cleared'), findsOneWidget);
      expect(find.textContaining('10:30'), findsOneWidget);
      expect(find.textContaining('#REC-101'), findsOneWidget);
    });

    testWidgets('Advance Deposit renders blue icon, title, and Advance badge', (tester) async {
      final now = DateTime(2026, 9, 13, 11, 00);
      final payment = Payment(
        id: 'p_2',
        customerId: 'c_2',
        date: now,
        amount: 3000.0,
        type: 'advance_topup',
        method: 'raast',
        raastRef: '#PK-RAAST-123',
        runningBalance: 0.0,
        createdAt: now,
        updatedAt: now,
      );

      await tester.pumpWidget(
        buildWrapper(
          child: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context);
              final item = TransactionFeedItem.fromPayment(
                payment,
                customerName: 'Tariq Mehmood',
                l10n: l10n,
              );
              return TransactionCard(item: item);
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tariq Mehmood'), findsOneWidget);
      expect(find.text('+Rs. 3000'), findsOneWidget);
      expect(find.text('Advance'), findsOneWidget);
      expect(find.textContaining('#PK-RAAST-123'), findsOneWidget);
    });

    testWidgets('Supplier Outflow renders red amount, supplier name, and Supplier Outflow badge', (tester) async {
      final now = DateTime(2026, 9, 13, 12, 15);
      final sp = SupplierPayment(
        id: 'sp_1',
        supplierId: 's_1',
        date: now,
        amount: 5000.0,
        type: 'cash_payment',
        voucherNumber: 'VCH-202',
        createdAt: now,
        updatedAt: now,
      );

      await tester.pumpWidget(
        buildWrapper(
          child: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context);
              final item = TransactionFeedItem.fromSupplierPayment(
                sp,
                supplierName: 'Green Pastures Farm',
                l10n: l10n,
              );
              return TransactionCard(item: item);
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Green Pastures Farm'), findsOneWidget);
      expect(find.text('-Rs. 5000'), findsOneWidget);
      expect(find.text('Supplier Outflow'), findsOneWidget);
      expect(find.textContaining('#VCH-202'), findsOneWidget);
    });

    testWidgets('Counter Retail renders Daily Retail badge and litres title', (tester) async {
      final now = DateTime(2026, 9, 13, 14, 00);
      final sale = LocalSale(
        id: 'ls_1',
        date: now,
        quantity: 4.0,
        productName: 'Fresh Buffalo Milk',
        rate: 200.0,
        totalAmount: 800.0,
        createdAt: now,
        updatedAt: now,
      );

      await tester.pumpWidget(
        buildWrapper(
          child: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context);
              final item = TransactionFeedItem.fromLocalSale(sale, l10n: l10n);
              return TransactionCard(item: item);
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Fresh Buffalo Milk (4)'), findsOneWidget);
      expect(find.text('+Rs. 800'), findsOneWidget);
      expect(find.text('Daily Retail'), findsOneWidget);
    });

    testWidgets('tapping TransactionCard fires onTap callback', (tester) async {
      bool tapped = false;
      final item = TransactionFeedItem(
        id: 'tx_1',
        type: TransactionType.customerCollection,
        title: 'Test Customer',
        subtitle: '10:00 AM',
        amount: 500.0,
        date: DateTime(2026, 9, 13, 10, 0),
        badgeLabel: 'Cleared',
        isInflow: true,
      );


      await tester.pumpWidget(
        buildWrapper(
          child: TransactionCard(
            item: item,
            onTap: () => tapped = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(TransactionCard), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('renders in Urdu locale without layout errors', (tester) async {
      final now = DateTime(2026, 9, 13, 10, 30);
      final payment = Payment(
        id: 'p_1',
        customerId: 'c_1',
        date: now,
        amount: 1500.0,
        type: 'cash_payment',
        method: 'cash',
        receiptNumber: 'REC-101',
        runningBalance: 0.0,
        createdAt: now,
        updatedAt: now,
      );

      await tester.pumpWidget(
        buildWrapper(
          locale: const Locale('ur'),
          child: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context);
              final item = TransactionFeedItem.fromPayment(
                payment,
                customerName: 'محمد علی',
                l10n: l10n,
              );
              return TransactionCard(item: item);
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('محمد علی'), findsOneWidget);
      expect(find.text('+Rs. 1500'), findsOneWidget);
    });
  });
}
