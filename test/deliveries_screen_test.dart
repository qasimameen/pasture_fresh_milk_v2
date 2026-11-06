import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pasture_fresh_milk/core/l10n/app_localizations.dart';
import 'package:pasture_fresh_milk/core/theme/app_theme.dart';
import 'package:pasture_fresh_milk/models/customer.dart';
import 'package:pasture_fresh_milk/models/delivery.dart';
import 'package:pasture_fresh_milk/providers/customer_provider.dart';
import 'package:pasture_fresh_milk/providers/delivery_provider.dart';
import 'package:pasture_fresh_milk/repositories/customer_repository.dart';
import 'package:pasture_fresh_milk/repositories/delivery_repository.dart';
import 'package:pasture_fresh_milk/screens/deliveries/deliveries_screen.dart';
import 'package:pasture_fresh_milk/screens/deliveries/widgets/delivery_card.dart';
import 'package:pasture_fresh_milk/widgets/empty_state.dart';
import 'package:pasture_fresh_milk/widgets/filter_chip_bar.dart';
import 'package:pasture_fresh_milk/widgets/shift_selector.dart';

class MockDeliveryRepository extends DeliveryRepository {
  List<Delivery> mockDeliveries = [];

  @override
  Future<List<Delivery>> getDeliveriesByDateAndShift(
    DateTime date,
    String shift,
  ) async {
    final result = mockDeliveries
        .where((d) =>
            Delivery.dateKey(d.date) == Delivery.dateKey(date) &&
            d.shift == shift)
        .toList();
    return result;
  }

  @override
  Future<
    ({
      int total,
      int delivered,
      int pending,
      int skipped,
      double totalQuantityDelivered,
      double totalCashCollected,
    })
  >
  getDeliveryStats(DateTime date, String shift) async {
    final list = await getDeliveriesByDateAndShift(date, shift);
    var pending = 0;
    var delivered = 0;
    var skipped = 0;
    var totalDeliveredLitres = 0.0;
    var totalCash = 0.0;

    for (final d in list) {
      if (d.status == 'delivered') {
        delivered++;
        totalDeliveredLitres += d.deliveredQuantity;
        totalCash += d.amountCollected;
      } else if (d.status == 'skipped') {
        skipped++;
      } else {
        pending++;
      }
    }

    return (
      total: list.length,
      delivered: delivered,
      pending: pending,
      skipped: skipped,
      totalQuantityDelivered: totalDeliveredLitres,
      totalCashCollected: totalCash,
    );
  }
}

class MockCustomerRepository extends CustomerRepository {
  List<Customer> mockCustomers = [];
  @override
  Future<List<Customer>> getAll() async => mockCustomers;
  @override
  Future<List<Customer>> getActiveCustomers() async => mockCustomers;
}

void main() {
  final testDate = DateTime.now();

  List<Delivery> createSampleDeliveries() {
    return [
      Delivery(
        id: 'del_1',
        customerId: 'cust_1',
        productId: 'prod_1',
        productName: 'Fresh Cow Milk',
        date: testDate,
        shift: 'morning',
        scheduledQuantity: 2.0,
        deliveredQuantity: 0.0,
        rate: 180.0,
        totalAmount: 0.0,
        amountCollected: 0.0,
        status: 'pending',
        sequenceNumber: 1,
        createdAt: testDate,
        updatedAt: testDate,
      ),
      Delivery(
        id: 'del_2',
        customerId: 'cust_2',
        productId: 'prod_2',
        productName: 'Buffalo Milk',
        date: testDate,
        shift: 'morning',
        scheduledQuantity: 1.5,
        deliveredQuantity: 1.5,
        rate: 220.0,
        totalAmount: 330.0,
        amountCollected: 330.0,
        status: 'delivered',
        sequenceNumber: 2,
        createdAt: testDate,
        updatedAt: testDate,
      ),
      Delivery(
        id: 'del_3',
        customerId: 'cust_3',
        productId: 'prod_1',
        productName: 'Fresh Cow Milk',
        date: testDate,
        shift: 'morning',
        scheduledQuantity: 3.0,
        deliveredQuantity: 0.0,
        rate: 180.0,
        totalAmount: 0.0,
        amountCollected: 0.0,
        status: 'skipped',
        skipReason: 'Shop closed',
        sequenceNumber: 3,
        createdAt: testDate,
        updatedAt: testDate,
      ),
    ];
  }

  Widget createDeliveriesScreenApp({
    required MockDeliveryRepository deliveryRepo,
    MockCustomerRepository? customerRepo,
    DateTime? date,
    Locale locale = const Locale('en'),
    ValueChanged<Delivery>? onDeliveryTap,
    VoidCallback? onMarkAllTap,
  }) {
    return ProviderScope(
      overrides: [
        deliveryRepositoryProvider.overrideWithValue(deliveryRepo),
        customerRepositoryProvider.overrideWithValue(customerRepo ?? MockCustomerRepository()),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: DeliveriesScreen(
          initialDate: date ?? testDate,
          initialShift: ShiftType.morning,
          onDeliveryTap: onDeliveryTap,
          onMarkAllTap: onMarkAllTap,
        ),
      ),
    );
  }

  group('DeliveriesScreen (Milestone C-M11) — Full Integration Tests', () {
    testWidgets('Renders header, selectors, filters, list of DeliveryCards and sticky summary banner', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final repo = MockDeliveryRepository();
      repo.mockDeliveries = createSampleDeliveries();

      await tester.pumpWidget(createDeliveriesScreenApp(deliveryRepo: repo));
      await tester.pumpAndSettle();

      // Screen title and count pill
      expect(find.text("Today's Deliveries"), findsOneWidget);
      expect(find.byKey(const Key('deliveries_total_badge')), findsOneWidget);
      expect(find.text('3'), findsWidgets); // total badge and filter chip

      // Selectors & Search
      expect(find.byKey(const Key('deliveries_date_selector')), findsOneWidget);
      expect(find.byKey(const Key('deliveries_shift_selector')), findsOneWidget);
      expect(find.byKey(const Key('deliveries_search_bar')), findsOneWidget);
      expect(find.byKey(const Key('deliveries_filter_chips')), findsOneWidget);

      // DeliveryCards
      expect(find.byType(DeliveryCard), findsNWidgets(3));
      expect(find.text('Fresh Cow Milk'), findsWidgets);
      expect(find.text('Buffalo Milk'), findsOneWidget);
    });

    testWidgets('Status filter chip filters deliveries by pending, delivered, skipped', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final repo = MockDeliveryRepository();
      repo.mockDeliveries = createSampleDeliveries();

      await tester.pumpWidget(createDeliveriesScreenApp(deliveryRepo: repo));
      await tester.pumpAndSettle();

      expect(find.byType(DeliveryCard), findsNWidgets(3));

      // Tap Pending filter chip (index 1)
      final filterBar = tester.widget<FilterChipBar>(find.byKey(const Key('deliveries_filter_chips')));
      filterBar.onSelected(1);
      await tester.pumpAndSettle();
      expect(find.byType(DeliveryCard), findsNWidgets(1));
      expect(find.text('Fresh Cow Milk'), findsOneWidget);

      // Tap Delivered filter chip (index 2)
      filterBar.onSelected(2);
      await tester.pumpAndSettle();
      expect(find.byType(DeliveryCard), findsNWidgets(1));
      expect(find.text('Buffalo Milk'), findsOneWidget);

      // Tap Skipped filter chip (index 3)
      filterBar.onSelected(3);
      await tester.pumpAndSettle();
      expect(find.byType(DeliveryCard), findsNWidgets(1));
      expect(find.text('Skipped: Shop closed'), findsOneWidget);
    });

    testWidgets('Search query filters deliveries in real-time', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final repo = MockDeliveryRepository();
      repo.mockDeliveries = createSampleDeliveries();

      await tester.pumpWidget(createDeliveriesScreenApp(deliveryRepo: repo));
      await tester.pumpAndSettle();

      expect(find.byType(DeliveryCard), findsNWidgets(3));

      // Enter search text 'Buffalo'
      await tester.enterText(find.byKey(const Key('deliveries_search_bar')), 'Buffalo');
      // Wait for debounce 300ms
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      expect(find.byType(DeliveryCard), findsNWidgets(1));
      expect(find.text('Buffalo Milk'), findsOneWidget);
      expect(find.text('Fresh Cow Milk'), findsNothing);
    });

    testWidgets('Empty state displays when no deliveries match filter', (tester) async {
      final repo = MockDeliveryRepository();
      repo.mockDeliveries = createSampleDeliveries();

      await tester.pumpWidget(createDeliveriesScreenApp(deliveryRepo: repo));
      await tester.pumpAndSettle();

      // Enter query with no match
      await tester.enterText(find.byKey(const Key('deliveries_search_bar')), 'NonExistentProduct');
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      expect(find.byType(EmptyState), findsOneWidget);
      expect(find.text('No deliveries found'), findsOneWidget);
    });

    testWidgets('Mark All triggers its corresponding callback', (tester) async {
      final repo = MockDeliveryRepository();
      repo.mockDeliveries = createSampleDeliveries();

      var markAllTriggered = false;

      await tester.pumpWidget(createDeliveriesScreenApp(
        deliveryRepo: repo,
        onMarkAllTap: () => markAllTriggered = true,
      ));
      await tester.pumpAndSettle();

      // Tap Mark All
      await tester.tap(find.byKey(const Key('deliveries_mark_all_btn')));
      await tester.pumpAndSettle();
      expect(markAllTriggered, isTrue);
    });

    testWidgets('Renders properly in Urdu locale with RTL', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final repo = MockDeliveryRepository();
      repo.mockDeliveries = createSampleDeliveries();

      await tester.pumpWidget(createDeliveriesScreenApp(
        deliveryRepo: repo,
        locale: const Locale('ur'),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(DeliveryCard), findsNWidgets(3));
    });

    testWidgets('Deliveries are sorted: pending first, then by customer name ascending', (tester) async {
      final repo = MockDeliveryRepository();
      // del_1: pending, cust_1
      // del_2: delivered, cust_2
      // del_3: pending, cust_3 (will be updated to cust_0 to test name sorting)
      final deliveries = createSampleDeliveries();
      // change del_3 customer to 'cust_0' and status to 'pending'
      deliveries[2] = Delivery(
        id: deliveries[2].id,
        customerId: 'cust_0',
        productId: deliveries[2].productId,
        productName: deliveries[2].productName,
        date: deliveries[2].date,
        shift: deliveries[2].shift,
        scheduledQuantity: deliveries[2].scheduledQuantity,
        deliveredQuantity: deliveries[2].deliveredQuantity,
        rate: deliveries[2].rate,
        totalAmount: deliveries[2].totalAmount,
        amountCollected: deliveries[2].amountCollected,
        status: 'pending',
        skipReason: deliveries[2].skipReason,
        sequenceNumber: deliveries[2].sequenceNumber,
        createdAt: deliveries[2].createdAt,
        updatedAt: deliveries[2].updatedAt,
      );
      
      repo.mockDeliveries = deliveries;

      final customerRepo = MockCustomerRepository();
      customerRepo.mockCustomers = [
        Customer(
          id: 'cust_1', name: 'Zebra', phone: '123', agreedRate: 200, createdAt: DateTime.now(), updatedAt: DateTime.now(),
        ),
        Customer(
          id: 'cust_2', name: 'Apple', phone: '123', agreedRate: 200, createdAt: DateTime.now(), updatedAt: DateTime.now(),
        ),
        Customer(
          id: 'cust_0', name: 'Banana', phone: '123', agreedRate: 200, createdAt: DateTime.now(), updatedAt: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(createDeliveriesScreenApp(
        deliveryRepo: repo,
        customerRepo: customerRepo,
      ));
      await tester.pumpAndSettle();

      // Expected order:
      // 1. Pending - Banana (cust_0, del_3)
      // 2. Pending - Zebra (cust_1, del_1)
      // 3. Delivered - Apple (cust_2, del_2)

      final cards = tester.widgetList<DeliveryCard>(find.byType(DeliveryCard)).toList();
      expect(cards.length, 3);
      expect(cards[0].delivery.customerId, 'cust_0');
      expect(cards[1].delivery.customerId, 'cust_1');
      expect(cards[2].delivery.customerId, 'cust_2');
    });
  });
}
