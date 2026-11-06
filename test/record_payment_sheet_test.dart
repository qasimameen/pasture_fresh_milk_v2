import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pasture_fresh_milk/core/l10n/app_localizations.dart';
import 'package:pasture_fresh_milk/core/theme/app_theme.dart';
import 'package:pasture_fresh_milk/models/customer.dart';
import 'package:pasture_fresh_milk/providers/payment_provider.dart';
import 'package:pasture_fresh_milk/repositories/payment_repository.dart';
import 'package:pasture_fresh_milk/screens/customers/widgets/record_payment_sheet.dart';

class MockPaymentRepository extends PaymentRepository {
  String? recordedCustomerId;
  double? recordedAmount;
  String? recordedMethod;
  String? recordedReceiptNumber;
  String? recordedRaastRef;
  String? recordedNotes;
  bool wasTopup = false;

  @override
  Future<void> recordCashPayment(
    String customerId,
    double amount,
    String method, {
    String? riderName,
    String? raastRef,
    String? receiptNumber,
    String? notes,
  }) async {
    recordedCustomerId = customerId;
    recordedAmount = amount;
    recordedMethod = method;
    recordedReceiptNumber = receiptNumber;
    recordedRaastRef = raastRef;
    recordedNotes = notes;
    wasTopup = false;
  }

  @override
  Future<void> recordAdvanceTopup(
    String customerId,
    double amount,
    String method, {
    String? raastRef,
    String? receiptNumber,
    String? notes,
  }) async {
    recordedCustomerId = customerId;
    recordedAmount = amount;
    recordedMethod = method;
    recordedReceiptNumber = receiptNumber;
    recordedRaastRef = raastRef;
    recordedNotes = notes;
    wasTopup = true;
  }
}

void main() {
  late MockPaymentRepository mockRepo;

  setUp(() {
    mockRepo = MockPaymentRepository();
  });

  final testCustomer = Customer(
    id: 'cust_pay_01',
    name: 'Muhammad Usman',
    phone: '03001234567',
    address: 'Street 5, Model Town',
    dailyQuotaAm: 2.0,
    dailyQuotaPm: 1.0,
    agreedRate: 180.0,
    currentDue: 1800.0,
    advanceBalance: 500.0,
    status: 'active',
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  Widget createTestWidget({
    Customer? customer,
    Locale locale = const Locale('en'),
    VoidCallback? onSuccess,
  }) {
    return ProviderScope(
      overrides: [
        paymentRepositoryProvider.overrideWithValue(mockRepo),
      ],
      child: MaterialApp(
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
          body: RecordPaymentSheet(
            customer: customer ?? testCustomer,
            onSuccess: onSuccess,
          ),
        ),
      ),
    );
  }

  void setTallSurface(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  group('RecordPaymentSheet (Milestone C-M10)', () {
    testWidgets('renders customer name, phone, and prefilled due amount', (tester) async {
      setTallSurface(tester);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Muhammad Usman'), findsOneWidget);
      expect(find.text('03001234567'), findsOneWidget);
      expect(find.text('Record Payment'), findsWidgets);
      expect(find.text('Rs. 1800'), findsWidgets);
    });



    testWidgets('pay full due shortcut fills exact amount', (tester) async {
      setTallSurface(tester);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Clear input first
      await tester.enterText(find.byKey(const Key('payment_amount_input')), '0');
      await tester.pumpAndSettle();

      // Tap Pay Full shortcut
      await tester.tap(find.byKey(const Key('quick_chip_full_due')));
      await tester.pumpAndSettle();

      final input = tester.widget<TextField>(
        find.descendant(
          of: find.byKey(const Key('payment_amount_input')),
          matching: find.byType(TextField),
        ),
      );
      expect(input.controller?.text, '1800');
    });

    testWidgets('quick chips increment amount', (tester) async {
      setTallSurface(tester);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('payment_amount_input')), '1000');
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('quick_chip_500')));
      await tester.pumpAndSettle();

      final input = tester.widget<TextField>(
        find.descendant(
          of: find.byKey(const Key('payment_amount_input')),
          matching: find.byType(TextField),
        ),
      );
      expect(input.controller?.text, '1500');
    });

    testWidgets('switches payment methods: Cash, Raast, Bank Transfer', (tester) async {
      setTallSurface(tester);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap Raast
      await tester.tap(find.byKey(const Key('method_raast_btn')));
      await tester.pumpAndSettle();

      // Tap Bank
      await tester.tap(find.byKey(const Key('method_bank_btn')));
      await tester.pumpAndSettle();
    });

    testWidgets('validation prevents submission when amount is empty or 0', (tester) async {
      setTallSurface(tester);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('payment_amount_input')), '');
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byKey(const Key('submit_payment_btn')));
      await tester.tap(find.byKey(const Key('submit_payment_btn')), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid amount greater than 0'), findsOneWidget);
      expect(mockRepo.recordedAmount, isNull);
    });

    testWidgets('submits cash payment successfully and calls repository', (tester) async {
      setTallSurface(tester);
      bool callbackFired = false;

      await tester.pumpWidget(createTestWidget(
        onSuccess: () => callbackFired = true,
      ));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('payment_amount_input')), '1800');
      await tester.enterText(find.byKey(const Key('payment_ref_input')), 'REC-999');
      await tester.enterText(find.byKey(const Key('payment_notes_input')), 'Monthly clearing');
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byKey(const Key('submit_payment_btn')));
      await tester.tap(find.byKey(const Key('submit_payment_btn')), warnIfMissed: false);
      await tester.pump();
      await tester.pump(const Duration(seconds: 4));

      expect(mockRepo.recordedCustomerId, 'cust_pay_01');
      expect(mockRepo.recordedAmount, 1800.0);
      expect(mockRepo.recordedMethod, 'cash');
      expect(mockRepo.recordedReceiptNumber, 'REC-999');
      expect(mockRepo.recordedNotes, 'Monthly clearing');
      expect(mockRepo.wasTopup, isFalse);
      expect(callbackFired, isTrue);
    });

    testWidgets('submits advance topup successfully and calls repository', (tester) async {
      setTallSurface(tester);
      bool callbackFired = false;

      // Use a customer with 0 dues
      final noDueCustomer = testCustomer.copyWith(currentDue: 0, advanceBalance: 1000);

      await tester.pumpWidget(createTestWidget(
        customer: noDueCustomer,
        onSuccess: () => callbackFired = true,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('method_raast_btn')));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('payment_amount_input')), '5000');
      await tester.enterText(find.byKey(const Key('payment_ref_input')), 'RAAST-1234');
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byKey(const Key('submit_payment_btn')));
      await tester.tap(find.byKey(const Key('submit_payment_btn')), warnIfMissed: false);
      await tester.pump();
      await tester.pump(const Duration(seconds: 4));

      expect(mockRepo.recordedCustomerId, 'cust_pay_01');
      expect(mockRepo.recordedAmount, 5000.0);
      expect(mockRepo.recordedMethod, 'raast');
      expect(mockRepo.recordedRaastRef, 'RAAST-1234');
      expect(mockRepo.wasTopup, isTrue);
      expect(callbackFired, isTrue);
    });

    testWidgets('renders in Urdu locale', (tester) async {
      setTallSurface(tester);
      await tester.pumpWidget(createTestWidget(locale: const Locale('ur')));
      await tester.pumpAndSettle();

      expect(find.text('رقم وصول درج کریں'), findsWidgets);
      expect(find.text('رقم وصول درج کریں'), findsWidgets);
      expect(find.text('نقد'), findsOneWidget);
      expect(find.text('راسٹ'), findsOneWidget);
      expect(find.text('بینک'), findsOneWidget);
    });
  });
}
