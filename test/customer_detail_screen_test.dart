import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pasture_fresh_milk/core/l10n/app_localizations.dart';
import 'package:pasture_fresh_milk/core/theme/app_theme.dart';
import 'package:pasture_fresh_milk/models/customer.dart';
import 'package:pasture_fresh_milk/models/delivery.dart';
import 'package:pasture_fresh_milk/models/payment.dart';
import 'package:pasture_fresh_milk/models/product.dart';
import 'package:pasture_fresh_milk/models/route_model.dart';
import 'package:pasture_fresh_milk/providers/customer_provider.dart';
import 'package:pasture_fresh_milk/providers/delivery_provider.dart';
import 'package:pasture_fresh_milk/providers/payment_provider.dart';
import 'package:pasture_fresh_milk/providers/product_provider.dart';
import 'package:pasture_fresh_milk/providers/route_provider.dart';
import 'package:pasture_fresh_milk/screens/customers/customer_detail_screen.dart';

final testCustomer = Customer(
  id: 'cust_detail_1',
  name: 'Tariq Mehmood',
  phone: '03001234567',
  address: 'House 12, Street 4',
  area: 'Model Town',

  productId: 'prod_cow_milk',

  dailyQuotaAm: 2.0,
  dailyQuotaPm: 1.0,
  agreedRate: 180.0,
  currentDue: 1200.0,
  advanceBalance: 0.0,
  status: 'active',

  createdAt: DateTime(2026, 1, 1),
  updatedAt: DateTime(2026, 1, 1),
);

final testRoutes = <DeliveryRoute>[
  DeliveryRoute(
    id: 'route_1',
    name: 'Model Town Route',
    area: 'Model Town',
    isActive: true,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  ),
];

final testProducts = <Product>[
  Product(
    id: 'prod_cow_milk',
    name: 'Fresh Cow Milk',
    description: 'Pure Cow Milk',
    defaultRate: 180.0,
    isActive: true,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  ),
];

final testDeliveries = <Delivery>[
  Delivery(
    id: 'del_1',
    customerId: 'cust_detail_1',
    date: DateTime(2026, 9, 12),
    shift: 'morning',
    productName: 'Fresh Cow Milk',
    scheduledQuantity: 2.0,
    deliveredQuantity: 2.0,
    rate: 180.0,
    totalAmount: 360.0,
    status: 'delivered',
    paymentMethod: 'credit',
    sequenceNumber: 2,
    createdAt: DateTime(2026, 9, 12),
    updatedAt: DateTime(2026, 9, 12),
  ),
  Delivery(
    id: 'del_2',
    customerId: 'cust_detail_1',
    date: DateTime(2026, 9, 11),
    shift: 'evening',
    productName: 'Fresh Cow Milk',
    scheduledQuantity: 1.0,
    deliveredQuantity: 1.0,
    rate: 180.0,
    totalAmount: 180.0,
    status: 'delivered',
    paymentMethod: 'credit',
    sequenceNumber: 2,
    createdAt: DateTime(2026, 9, 11),
    updatedAt: DateTime(2026, 9, 11),
  ),
];

final testPayments = <Payment>[
  Payment(
    id: 'pay_1',
    customerId: 'cust_detail_1',
    date: DateTime(2026, 9, 10, 14, 30),
    amount: 1000.0,
    method: 'cash',
    type: 'cash_payment',
    runningBalance: 1200.0,
    createdAt: DateTime(2026, 9, 10),
    updatedAt: DateTime(2026, 9, 10),
  ),
];

void setTallSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

Widget createTestApp({
  Customer? customer,
  List<DeliveryRoute>? routes,
  List<Product>? products,
  List<Delivery>? deliveries,
  List<Payment>? payments,
  Locale locale = const Locale('en'),
  VoidCallback? onCall,
  VoidCallback? onEditProfile,
}) {
  final targetCustomer = customer ?? testCustomer;

  return ProviderScope(
    overrides: [
      customerByIdProvider(targetCustomer.id)
          .overrideWith((ref) async => targetCustomer),
      routeListProvider.overrideWith((ref) async => routes ?? testRoutes),
      productListProvider.overrideWith((ref) async => products ?? testProducts),
      customerDeliveryHistoryProvider(targetCustomer.id)
          .overrideWith((ref) async => deliveries ?? testDeliveries),
      paymentListByCustomerProvider(targetCustomer.id)
          .overrideWith((ref) async => payments ?? testPayments),
    ],
    child: MaterialApp(
      theme: AppTheme.lightTheme,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: CustomerDetailScreen(
        customerId: targetCustomer.id,
        onCall: onCall,
        onEditProfile: onEditProfile,
      ),
    ),
  );
}

void main() {
  group('CustomerDetailScreen (Milestone C-M6)', () {
    testWidgets('renders profile header, financial summary, and preferences', (tester) async {
      setTallSurface(tester);
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Verify Screen Header
      expect(find.text('Tariq Mehmood'), findsWidgets);
      expect(find.byKey(const Key('detail_back_button')), findsOneWidget);
      expect(find.byKey(const Key('detail_call_button')), findsOneWidget);
      expect(find.byKey(const Key('detail_edit_button')), findsOneWidget);

      // Verify Contact & Route info
      expect(find.text('03001234567'), findsOneWidget);
      expect(find.text('House 12, Street 4'), findsOneWidget);
      expect(find.text('Model Town Route'), findsOneWidget);

      // Verify Financial Balance cards
      expect(find.byKey(const Key('detail_due_amount')), findsOneWidget);
      expect(find.text('Rs. 1200'), findsWidgets);
      expect(find.byKey(const Key('detail_advance_amount')), findsOneWidget);
      expect(find.text('Rs. 0'), findsOneWidget);

      // Verify Action buttons
      expect(find.byKey(const Key('record_payment_action_btn')), findsOneWidget);
      expect(find.byKey(const Key('add_topup_action_btn')), findsOneWidget);
      expect(find.byKey(const Key('share_bill_action_btn')), findsOneWidget);

      // Verify Delivery Preferences
      expect(find.text('AM: 2.0 L'), findsOneWidget);
      expect(find.text('PM: 1.0 L'), findsOneWidget);
      expect(find.text('Rs. 180/L'), findsOneWidget);
      expect(find.text('Fresh Cow Milk'), findsOneWidget);
    });

    testWidgets('displays sticky bottom dues bar when customer has current dues', (tester) async {
      setTallSurface(tester);
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Verify Sticky bar
      expect(find.byKey(const Key('collect_payment_bottom_btn')), findsOneWidget);
      expect(find.text('Collect Payment'), findsOneWidget);
    });

    testWidgets('hides sticky bottom dues bar when customer has no dues', (tester) async {
      setTallSurface(tester);
      final customerNoDues = testCustomer.copyWith(currentDue: 0.0);
      await tester.pumpWidget(createTestApp(customer: customerNoDues));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('collect_payment_bottom_btn')), findsNothing);
    });

    testWidgets('tab switching displays Deliveries and Payments lists', (tester) async {
      setTallSurface(tester);
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Tab 1: Advance Ledger initially active
      expect(find.byKey(const Key('tab_summary')), findsOneWidget);
      expect(find.textContaining('Delivery'), findsWidgets);
      expect(find.textContaining('Payment'), findsWidgets);

      // Switch to Tab 2: Deliveries
      await tester.tap(find.byKey(const Key('tab_delivery_history')));
      await tester.pumpAndSettle();

      expect(find.text('Delivered'), findsWidgets);
      expect(find.textContaining('Fresh Cow Milk'), findsWidgets);

      // Switch to Tab 3: Payments
      await tester.tap(find.byKey(const Key('tab_payment_history')));
      await tester.pumpAndSettle();

      expect(find.text('Cash'), findsWidgets);
      expect(find.text('+Rs. 1000'), findsOneWidget);
    });

    testWidgets('triggers call and edit profile callbacks', (tester) async {
      setTallSurface(tester);
      bool callTapped = false;
      bool editTapped = false;

      await tester.pumpWidget(createTestApp(
        onCall: () => callTapped = true,
        onEditProfile: () => editTapped = true,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('detail_call_button')));
      await tester.pumpAndSettle();
      expect(callTapped, isTrue);

      await tester.tap(find.byKey(const Key('detail_edit_button')));
      await tester.pumpAndSettle();
      expect(editTapped, isTrue);
    });

    testWidgets('renders in Urdu locale with RTL alignment', (tester) async {
      setTallSurface(tester);
      await tester.pumpWidget(createTestApp(locale: const Locale('ur')));
      await tester.pumpAndSettle();

      expect(find.text('کھاتہ'), findsOneWidget);
      expect(find.text('ڈیلیوریز'), findsOneWidget);
      expect(find.text('ادائیگیاں'), findsOneWidget);
      expect(find.text('قابل ادا واجبات'), findsOneWidget);
      expect(find.text('ایڈوانس رقم'), findsOneWidget);
    });
  });
}
