import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:pasture_fresh_milk/core/l10n/app_localizations.dart';
import 'package:pasture_fresh_milk/core/routes/app_routes.dart';
import 'package:pasture_fresh_milk/core/theme/app_theme.dart';
import 'package:pasture_fresh_milk/models/customer.dart';
import 'package:pasture_fresh_milk/models/delivery.dart';
import 'package:pasture_fresh_milk/models/local_sale.dart';
import 'package:pasture_fresh_milk/models/milk_collection.dart';
import 'package:pasture_fresh_milk/models/payment.dart';
import 'package:pasture_fresh_milk/models/product.dart';
import 'package:pasture_fresh_milk/models/store_profile.dart';
import 'package:pasture_fresh_milk/models/supplier.dart';
import 'package:pasture_fresh_milk/models/supplier_payment.dart';
import 'package:pasture_fresh_milk/providers/customer_provider.dart';
import 'package:pasture_fresh_milk/providers/delivery_provider.dart';
import 'package:pasture_fresh_milk/providers/local_sale_provider.dart';
import 'package:pasture_fresh_milk/providers/locale_provider.dart';
import 'package:pasture_fresh_milk/providers/milk_collection_provider.dart';
import 'package:pasture_fresh_milk/providers/payment_provider.dart';
import 'package:pasture_fresh_milk/providers/product_provider.dart';
import 'package:pasture_fresh_milk/providers/route_provider.dart';
import 'package:pasture_fresh_milk/providers/store_profile_provider.dart';
import 'package:pasture_fresh_milk/providers/supplier_payment_provider.dart';
import 'package:pasture_fresh_milk/providers/supplier_provider.dart';
import 'package:pasture_fresh_milk/repositories/customer_repository.dart';
import 'package:pasture_fresh_milk/repositories/delivery_repository.dart';
import 'package:pasture_fresh_milk/repositories/local_sale_repository.dart';
import 'package:pasture_fresh_milk/repositories/milk_collection_repository.dart';
import 'package:pasture_fresh_milk/repositories/payment_repository.dart';
import 'package:pasture_fresh_milk/repositories/store_profile_repository.dart';
import 'package:pasture_fresh_milk/repositories/supplier_payment_repository.dart';
import 'package:pasture_fresh_milk/repositories/supplier_repository.dart';
import 'package:pasture_fresh_milk/screens/customers/customer_detail_screen.dart';
import 'package:pasture_fresh_milk/screens/customers/customers_screen.dart';
import 'package:pasture_fresh_milk/screens/customers/widgets/add_customer_sheet.dart';
import 'package:pasture_fresh_milk/screens/customers/widgets/customer_card.dart';
import 'package:pasture_fresh_milk/screens/deliveries/deliveries_screen.dart';
import 'package:pasture_fresh_milk/screens/deliveries/widgets/delivery_card.dart';
import 'package:pasture_fresh_milk/screens/home/home_screen.dart';
import 'package:pasture_fresh_milk/screens/customers/widgets/record_payment_sheet.dart'
    as cust_sheet;
import 'package:pasture_fresh_milk/screens/payments/payments_screen.dart';
import 'package:pasture_fresh_milk/screens/payments/widgets/record_payment_sheet.dart';
import 'package:pasture_fresh_milk/screens/settings/settings_screen.dart';
import 'package:pasture_fresh_milk/screens/settings/store_profile_screen.dart';
import 'package:pasture_fresh_milk/screens/suppliers/supplier_khata_screen.dart';
import 'package:pasture_fresh_milk/screens/suppliers/suppliers_screen.dart';
import 'package:pasture_fresh_milk/screens/suppliers/widgets/record_milk_sheet.dart';
import 'package:pasture_fresh_milk/widgets/app_snack_bar.dart';
import 'package:pasture_fresh_milk/widgets/app_text_field.dart';
import 'package:pasture_fresh_milk/widgets/bottom_nav_bar.dart';
import 'package:pasture_fresh_milk/widgets/language_toggle.dart';

// ── In-Memory Repositories for End-to-End Tests ──────────────────────────────

class InMemoryCustomerRepository extends CustomerRepository {
  final List<Customer> _items = [
    Customer(
      id: 'cust_101',
      name: 'Tariq Mehmood',
      phone: '03001234567',
      address: 'House 12, St 4',
      area: 'Civil Lines',
      dailyQuotaAm: 2.0,
      dailyQuotaPm: 1.0,
      agreedRate: 220.0,
      currentDue: 1200.0,
      advanceBalance: 0.0,
      status: 'active',

      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Customer(
      id: 'cust_102',
      name: 'Zubair Ansari',
      phone: '03219876543',
      address: 'Flat 5B',
      area: 'Gulberg',
      dailyQuotaAm: 0.0,
      dailyQuotaPm: 2.0,
      agreedRate: 220.0,
      currentDue: 0.0,
      advanceBalance: 500.0,
      status: 'active',

      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  @override
  Future<List<Customer>> getAll() async => List.unmodifiable(_items);

  @override
  Future<List<Customer>> getActiveCustomers() async =>
      _items.where((c) => c.status == 'active').toList();

  @override
  Future<Customer?> getById(String id) async {
    try {
      return _items.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> insert(Customer item) async {
    _items.add(item);
  }

  @override
  Future<void> update(Customer item) async {
    final idx = _items.indexWhere((c) => c.id == item.id);
    if (idx >= 0) _items[idx] = item;
  }

  @override
  Future<void> updateBalance(
      String id, double newDue, double newAdvance, {dynamic executor}) async {
    final idx = _items.indexWhere((c) => c.id == id);
    if (idx >= 0) {
      _items[idx] = _items[idx].copyWith(
        currentDue: newDue,
        advanceBalance: newAdvance,
      );
    }
  }
}

class InMemoryLocalSaleRepository extends LocalSaleRepository {
  final List<LocalSale> _sales = [];

  @override
  Future<LocalSale> addQuickSale(
    double litres,
    String productName,
    double ratePerLitre, {
    String? productId,
  }) async {
    final now = DateTime.now();
    final sale = LocalSale(
      id: 'sale_${_sales.length + 1}',
      date: now,
      productName: productName,
      productId: productId,
      quantity: litres,
      rate: ratePerLitre,
      totalAmount: litres * ratePerLitre,
      createdAt: now,
      updatedAt: now,
    );
    _sales.add(sale);
    return sale;
  }

  @override
  Future<LocalSale?> getLastSale() async =>
      _sales.isNotEmpty ? _sales.last : null;

  @override
  Future<void> deleteLastSale() async {
    if (_sales.isNotEmpty) _sales.removeLast();
  }

  @override
  Future<List<LocalSale>> getSalesByDate(DateTime date) async =>
      List.unmodifiable(_sales);

  @override
  Future<({double totalQuantity, double totalAmount, int saleCount})>
      getTodayTotals(DateTime date) async {
    final litres = _sales.fold(0.0, (sum, s) => sum + s.quantity);
    final amount = _sales.fold(0.0, (sum, s) => sum + s.totalAmount);
    return (saleCount: _sales.length, totalAmount: amount, totalQuantity: litres);
  }
}

class InMemoryDeliveryRepository extends DeliveryRepository {
  final List<Delivery> _deliveries = [
    Delivery(
      id: 'del_1',
      customerId: 'cust_101',
      date: DateTime.now(),
      shift: 'morning',
      productName: 'Buffalo Milk',
      scheduledQuantity: 2.0,
      rate: 220.0,
      totalAmount: 440.0,
      status: 'pending',
      sequenceNumber: 1,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Delivery(
      id: 'del_2',
      customerId: 'cust_102',
      date: DateTime.now(),
      shift: 'evening',
      productName: 'Buffalo Milk',
      scheduledQuantity: 2.0,
      rate: 220.0,
      totalAmount: 440.0,
      status: 'pending',
      sequenceNumber: 2,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  @override
  Future<List<Delivery>> getDeliveriesByDateAndShift(
    DateTime date,
    String shift,
  ) async =>
      _deliveries.where((d) => d.shift == shift).toList();

  @override
  Future<List<Delivery>> getDeliveriesByCustomer(String customerId) async =>
      _deliveries.where((d) => d.customerId == customerId).toList();

  @override
  Future<Delivery?> getById(String id) async {
    try {
      return _deliveries.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> markDelivered(
    String id,
    double quantity,
    String paymentMethod,
    double amountCollected, {
    String? receiverNote,
  }) async {
    final idx = _deliveries.indexWhere((d) => d.id == id);
    if (idx >= 0) {
      _deliveries[idx] = _deliveries[idx].copyWith(
        status: 'delivered',
        deliveredQuantity: quantity,
        paymentMethod: paymentMethod,
        amountCollected: amountCollected,
      );
    }
  }

  @override
  Future<
      ({
        int delivered,
        int pending,
        int skipped,
        int total,
        double totalCashCollected,
        double totalQuantityDelivered,
      })> getDeliveryStats(DateTime date, String shift) async {
    final subset = _deliveries.where((d) => d.shift == shift).toList();
    final del = subset.where((d) => d.status == 'delivered').length;
    final pen = subset.where((d) => d.status == 'pending').length;
    final skip = subset.where((d) => d.status == 'skipped').length;
    return (
      delivered: del,
      pending: pen,
      skipped: skip,
      total: subset.length,
      totalCashCollected: 0.0,
      totalQuantityDelivered: 0.0,
    );
  }
}

class InMemoryPaymentRepository extends PaymentRepository {
  final List<Payment> _payments = [];

  @override
  Future<List<Payment>> getPaymentsByDate(DateTime date) async =>
      List.unmodifiable(_payments);

  @override
  Future<List<Payment>> getPaymentsByCustomer(String customerId) async =>
      _payments.where((p) => p.customerId == customerId).toList();

  @override
  Future<double> getTodayCashTotal(DateTime date) async =>
      _payments.fold<double>(0.0, (double sum, Payment p) => sum + p.amount);

  @override
  Future<Payment> recordCashPayment(
    String customerId,
    double amount,
    String method, {
    String? receiptNumber,
    String? raastRef,
    String? notes,
    String? riderName,
  }) async {
    final p = Payment(
      id: 'pay_${_payments.length + 1}',
      customerId: customerId,
      date: DateTime.now(),
      amount: amount,
      type: 'cash_payment',
      method: method,
      receiptNumber: receiptNumber ?? 'REC-${_payments.length + 1}',
      raastRef: raastRef,
      notes: notes,
      runningBalance: 0.0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _payments.add(p);
    return p;
  }

  @override
  Future<Payment> recordAdvanceTopup(
    String customerId,
    double amount,
    String method, {
    String? receiptNumber,
    String? raastRef,
    String? notes,
    String? riderName,
  }) async {
    final p = Payment(
      id: 'topup_${_payments.length + 1}',
      customerId: customerId,
      date: DateTime.now(),
      amount: amount,
      type: 'advance_topup',
      method: method,
      receiptNumber: receiptNumber ?? 'TOP-${_payments.length + 1}',
      raastRef: raastRef,
      notes: notes,
      runningBalance: 0.0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _payments.add(p);
    return p;
  }
}

class InMemorySupplierRepository extends SupplierRepository {
  final List<Supplier> _suppliers = [
    Supplier(
      id: 'supp_1',
      name: 'Punjab Dairy Farm',
      location: 'Kasur Road',
      milkType: 'Buffalo Milk',
      phone: '03009988776',
      isActive: true,
      pendingKhata: 8500.0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  @override
  Future<List<Supplier>> getAll() async => List.unmodifiable(_suppliers);

  @override
  Future<List<Supplier>> getActiveSuppliers() async =>
      _suppliers.where((s) => s.isActive).toList();

  @override
  Future<Supplier?> getById(String id) async {
    try {
      return _suppliers.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> updateKhata(
    String id,
    double amount, {
    DatabaseExecutor? executor,
  }) async {
    final idx = _suppliers.indexWhere((s) => s.id == id);
    if (idx >= 0) {
      final current = _suppliers[idx].pendingKhata;
      final next = (current + amount).clamp(0.0, double.infinity);
      _suppliers[idx] = _suppliers[idx].copyWith(pendingKhata: next);
    }
  }
}

class InMemorySupplierPaymentRepository extends SupplierPaymentRepository {
  final List<SupplierPayment> _payments = [];

  @override
  Future<List<SupplierPayment>> getPaymentsByDate(DateTime date) async =>
      List.unmodifiable(_payments);

  @override
  Future<List<SupplierPayment>> getPaymentsBySupplier(String supplierId) async =>
      _payments.where((p) => p.supplierId == supplierId).toList();

  @override
  Future<void> recordPayment(SupplierPayment payment) async {
    _payments.add(payment);
  }

  @override
  Future<double> getTotalPaidToday(DateTime date) async =>
      _payments.fold<double>(0.0, (sum, p) => sum + p.amount);
}

class InMemoryMilkCollectionRepository extends MilkCollectionRepository {
  final List<MilkCollection> _collections = [
    MilkCollection(
      id: 'mc_1',
      supplierId: 'supp_1',
      date: DateTime.now(),
      shift: DateTime.now().hour < 12 ? 'morning' : 'evening',
      quantity: 40.0,
      rate: 180.0,
      batchValue: 7200.0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  @override
  Future<List<MilkCollection>> getCollectionsByDate(DateTime date) async =>
      List.unmodifiable(_collections);

  @override
  Future<List<MilkCollection>> getCollectionsBySupplier(String supplierId) async =>
      _collections.where((c) => c.supplierId == supplierId).toList();

  @override
  Future<
      ({
        double avgRate,
        double totalQuantity,
        double totalPayable
      })> getDailyStats(DateTime date) async {
    return (
      totalQuantity: 40.0,
      totalPayable: 7200.0,
      avgRate: 180.0,
    );
  }

  @override
  Future<void> recordCollection(MilkCollection collection) async {
    _collections.add(collection);
  }
}

class InMemoryStoreProfileRepository extends StoreProfileRepository {
  StoreProfile _profile = StoreProfile(
    id: 'store_1',
    name: 'Al-Madina Dairy',
    phone: '0300-1122334',
    address: 'Shop #4, Main Market',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  @override
  Future<StoreProfile?> getProfile() async => _profile;

  @override
  Future<void> upsertProfile(StoreProfile profile) async {
    _profile = profile;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  Future<void> settle(WidgetTester tester) async {
    for (int i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (!tester.binding.hasScheduledFrame) break;
    }
  }

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  void setTallSurface(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  Widget createTestApp({
    InMemoryCustomerRepository? custRepo,
    InMemoryLocalSaleRepository? saleRepo,
    InMemoryDeliveryRepository? delRepo,
    InMemoryPaymentRepository? payRepo,
    InMemorySupplierRepository? suppRepo,
    InMemorySupplierPaymentRepository? suppPayRepo,
    InMemoryMilkCollectionRepository? milkColRepo,
    InMemoryStoreProfileRepository? storeRepo,
  }) {
    final cRepo = custRepo ?? InMemoryCustomerRepository();
    final sRepo = saleRepo ?? InMemoryLocalSaleRepository();
    final dRepo = delRepo ?? InMemoryDeliveryRepository();
    final pRepo = payRepo ?? InMemoryPaymentRepository();
    final supRepo = suppRepo ?? InMemorySupplierRepository();
    final spRepo = suppPayRepo ?? InMemorySupplierPaymentRepository();
    final mcRepo = milkColRepo ?? InMemoryMilkCollectionRepository();
    final stRepo = storeRepo ?? InMemoryStoreProfileRepository();

    return ProviderScope(
      overrides: [
        customerRepositoryProvider.overrideWithValue(cRepo),
        localSaleRepositoryProvider.overrideWithValue(sRepo),
        deliveryRepositoryProvider.overrideWithValue(dRepo),
        paymentRepositoryProvider.overrideWithValue(pRepo),
        supplierRepositoryProvider.overrideWithValue(supRepo),
        supplierPaymentRepositoryProvider.overrideWithValue(spRepo),
        milkCollectionRepositoryProvider.overrideWithValue(mcRepo),
        storeProfileRepositoryProvider.overrideWithValue(stRepo),
        // Products override
        productListProvider.overrideWith(
          (ref) => Future.value([
            Product(
              id: 'prod_1',
              name: 'Fresh Cow Milk',
              defaultRate: 220.0,
              isActive: true,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          ]),
        ),
        routeListProvider.overrideWith((ref) => Future.value([])),
        localeProvider.overrideWith((ref) {
          final notifier = LocaleNotifier();
          // Force English state immediately for tests
          // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
          notifier.state = const Locale('en'); 
          return notifier;
        }),
      ],
      child: Consumer(
        builder: (context, ref, _) {
          final locale = ref.watch(localeProvider);
          return MaterialApp(
            locale: locale,
            theme: AppTheme.lightTheme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            initialRoute: AppRoutes.home,
            onGenerateRoute: AppRoutes.onGenerateRoute,
          );
        },
      ),
    );
  }

  group('E2E Data Flow & Cross-Screen Integration Verification', () {
    testWidgets(
      'Flow 1: Home Dashboard renders, quick sale +1L records and undoes',
      (tester) async {
        setTallSurface(tester);
        final saleRepo = InMemoryLocalSaleRepository();
        await tester.pumpWidget(createTestApp(saleRepo: saleRepo));
        await settle(tester);

        // 1. Verify Home screen renders
        expect(find.byType(HomeScreen), findsOneWidget);
        expect(find.byType(BottomNavBar), findsOneWidget);

        // 2. Find and tap "+1L" quick-tap button in Local Sales section
        final quickOneLitre = find.text('+1L');
        expect(quickOneLitre, findsOneWidget);

        await tester.tap(quickOneLitre, warnIfMissed: false);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Verify snackbar appears with Undo
        final undoBtns = find.text('Undo');
        expect(undoBtns, findsWidgets);

        // Tap Undo
        await tester.tap(undoBtns.last, warnIfMissed: false);
        await tester.pump();
        AppSnackBar.dismiss();
        await settle(tester);
      },
    );

    testWidgets(
      'Flow 2: Customers directory, adding a customer, card tap to detail, and recording payment',
      (tester) async {
        setTallSurface(tester);
        final custRepo = InMemoryCustomerRepository();
        final payRepo = InMemoryPaymentRepository();
        await tester.pumpWidget(createTestApp(
          custRepo: custRepo,
          payRepo: payRepo,
        ));
        await settle(tester);

        // 1. Switch to Customers tab
        await tester.tap(
          find.descendant(
            of: find.byType(BottomNavBar),
            matching: find.text('Customers'),
          ),
          warnIfMissed: false,
        );
        await settle(tester);
        expect(find.byType(CustomersScreen), findsOneWidget);

        // 2. Tap FAB "+ Add Customer"
        final addFab = find.byKey(const Key('add_customer_fab'));
        expect(addFab, findsOneWidget);
        await tester.tap(addFab, warnIfMissed: false);
        await settle(tester);

        expect(find.byType(AddCustomerSheet), findsOneWidget);

        // Fill out form
        await tester.enterText(
          find.byKey(const Key('customer_name_field')),
          'Zahid Qureshi',
        );
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pump();
        await tester.enterText(
          find.byKey(const Key('customer_phone_field')),
          '03219876543',
        );
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pump();
        await tester.enterText(
          find.byKey(const Key('customer_quota_am_field')),
          '2.0',
        );
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pump();
        await tester.enterText(
          find.byKey(const Key('customer_rate_field')),
          '220',
        );
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pump();

        // Scroll to save button and tap
        final saveBtn = find.byKey(const Key('save_customer_button'));
        await tester.ensureVisible(saveBtn);
        await tester.tap(saveBtn, warnIfMissed: false);
        await settle(tester);
        AppSnackBar.dismiss();
        await settle(tester);

        // 3. Verify Customer list has cards and tap customer card to navigate to detail
        final customerCards = find.byType(CustomerCard);
        expect(customerCards, findsWidgets);

        await tester.tap(customerCards.first, warnIfMissed: false);
        await settle(tester);

        expect(find.byType(CustomerDetailScreen), findsOneWidget);
        expect(find.text('Ledger'), findsOneWidget);
        expect(find.text('Deliveries'), findsOneWidget);
        expect(find.text('Payments'), findsOneWidget);

        // 4. Record payment from Customer Detail screen
        final recordPayBtn = find.byKey(const Key('record_payment_action_btn'));
        expect(recordPayBtn, findsOneWidget);
        await tester.tap(recordPayBtn, warnIfMissed: false);
        await settle(tester);

        expect(find.byType(cust_sheet.RecordPaymentSheet), findsOneWidget);

        // Enter payment amount
        await tester.enterText(
          find.byKey(const Key('payment_amount_input')),
          '500',
        );
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pump();
        await settle(tester);

        // Tap submit payment button inside sheet
        final submitBtn = find.byKey(const Key('submit_payment_btn'));
        expect(submitBtn, findsOneWidget);
        await tester.tap(submitBtn, warnIfMissed: false);
        await settle(tester);
        AppSnackBar.dismiss();
        await settle(tester);

        // 5. Pop back to CustomersScreen
        Navigator.of(tester.element(find.byType(CustomerDetailScreen))).pop();
        await settle(tester);
        expect(find.byType(CustomersScreen), findsOneWidget);
      },
    );

    testWidgets(
      'Flow 3: Deliveries Screen date/shift switching and card interactions',
      (tester) async {
        setTallSurface(tester);
        final delRepo = InMemoryDeliveryRepository();
        await tester.pumpWidget(createTestApp(delRepo: delRepo));
        await settle(tester);

        // Switch to Deliveries tab
        await tester.tap(
          find.descendant(
            of: find.byType(BottomNavBar),
            matching: find.text('Deliveries'),
          ),
          warnIfMissed: false,
        );
        await settle(tester);
        expect(find.byType(DeliveriesScreen), findsOneWidget);

        // Toggle to Evening shift
        final eveningSegment = find.text('Evening (PM)');
        expect(eveningSegment, findsOneWidget);
        await tester.tap(eveningSegment, warnIfMissed: false);
        await settle(tester);

        // Toggle back to Morning shift
        final morningSegment = find.text('Morning (AM)');
        expect(morningSegment, findsOneWidget);
        await tester.tap(morningSegment, warnIfMissed: false);
        await settle(tester);

        // Check for DeliveryCards
        final cards = find.byType(DeliveryCard);
        expect(cards, findsWidgets);

        AppSnackBar.dismiss();
        await settle(tester);
      },
    );

    testWidgets(
      'Flow 4: Payments & Accounts Screen and bottom sheet opening',
      (tester) async {
        setTallSurface(tester);
        final payRepo = InMemoryPaymentRepository();
        await tester.pumpWidget(createTestApp(payRepo: payRepo));
        await settle(tester);

        // Switch to Payments tab
        await tester.tap(
          find.descendant(
            of: find.byType(BottomNavBar),
            matching: find.text('Payments'),
          ),
          warnIfMissed: false,
        );
        await settle(tester);
        expect(find.byType(PaymentsScreen), findsOneWidget);

        // Verify CTA button exists and opens RecordPaymentSheet
        final ctaBtn = find.text('+ Record Payment In / Out');
        expect(ctaBtn, findsOneWidget);
        await tester.tap(ctaBtn, warnIfMissed: false);
        await settle(tester);

        expect(find.byType(RecordPaymentSheet), findsOneWidget);

        // Dismiss sheet
        Navigator.of(tester.element(find.byType(RecordPaymentSheet))).pop();
        await settle(tester);
        expect(find.byType(PaymentsScreen), findsOneWidget);
      },
    );

    testWidgets(
      'Flow 5: Suppliers & Procurement, Record Inward Milk, and Supplier Khata navigation',
      (tester) async {
        setTallSurface(tester);
        final suppRepo = InMemorySupplierRepository();
        await tester.pumpWidget(createTestApp(suppRepo: suppRepo));
        await settle(tester);

        // Switch to Suppliers tab
        await tester.tap(
          find.descendant(
            of: find.byType(BottomNavBar),
            matching: find.text('Suppliers'),
          ),
          warnIfMissed: false,
        );
        await settle(tester);
        expect(find.byType(SuppliersScreen), findsOneWidget);

        // Verify "+ Record Inward Milk" CTA button exists and tap it
        final recordMilkCta = find.text('+ Record Inward Milk');
        expect(recordMilkCta, findsOneWidget);
        await tester.tap(recordMilkCta, warnIfMissed: false);
        await settle(tester);

        expect(find.byType(RecordMilkSheet), findsOneWidget);

        // Close RecordMilkSheet
        Navigator.of(tester.element(find.byType(RecordMilkSheet))).pop();
        await settle(tester);

        // Tap "View Khata" on supplier card
        final viewKhataBtn = find.text('View Khata');
        expect(viewKhataBtn, findsWidgets);
        await tester.tap(viewKhataBtn.first, warnIfMissed: false);
        await settle(tester);

        expect(find.byType(SupplierKhataScreen), findsOneWidget);

        // Pop back to SuppliersScreen
        Navigator.of(tester.element(find.byType(SupplierKhataScreen))).pop();
        await settle(tester);
        expect(find.byType(SuppliersScreen), findsOneWidget);
      },
    );

    testWidgets(
      'Flow 6: Settings Screen navigation to Store Profile and editing store info',
      (tester) async {
        setTallSurface(tester);
        final storeRepo = InMemoryStoreProfileRepository();
        await tester.pumpWidget(createTestApp(storeRepo: storeRepo));
        await settle(tester);

        // Navigate to settings via route push
        final context = tester.element(find.byType(HomeScreen));
        Navigator.of(context).pushNamed(AppRoutes.settings);
        await settle(tester);

        expect(find.byType(SettingsScreen), findsOneWidget);

        // Tap Store Profile option
        final storeProfileOption = find.text('Store Profile');
        expect(storeProfileOption, findsOneWidget);
        await tester.tap(storeProfileOption, warnIfMissed: false);
        await settle(tester);

        expect(find.byType(StoreProfileScreen), findsOneWidget);

        // Edit store name
        final nameField = find.descendant(
          of: find.byType(AppTextField),
          matching: find.byType(TextField),
        );
        expect(nameField, findsWidgets);
        await tester.enterText(nameField.first, 'Al-Madina Pure Dairy');
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pump();
        await settle(tester);

        // Save
        final saveBtn = find.text('Save Changes');
        expect(saveBtn, findsOneWidget);
        await tester.tap(saveBtn, warnIfMissed: false);
        await settle(tester);
        AppSnackBar.dismiss();
        await settle(tester);

        // StoreProfileScreen auto-pops on save
        expect(find.byType(SettingsScreen), findsOneWidget);

        // Pop back to Home
        Navigator.of(tester.element(find.byType(SettingsScreen))).pop();
        await settle(tester);
        expect(find.byType(HomeScreen), findsOneWidget);
      },
    );

    testWidgets(
      'Flow 7: Language toggle switches locale to Urdu with RTL and back to English',
      (tester) async {
        setTallSurface(tester);
        await tester.pumpWidget(createTestApp());
        await settle(tester);

        // Find LanguageToggle on HomeScreen
        final langToggle = find.byType(LanguageToggle);
        expect(langToggle, findsOneWidget);

        // Tap Urdu "اردو"
        await tester.tap(find.text('اردو'), warnIfMissed: false);
        await settle(tester);

        // Verify Directionality is RTL
        final element = tester.element(find.byType(HomeScreen));
        expect(Directionality.of(element), TextDirection.rtl);

        // Switch back to English "EN"
        await tester.tap(find.text('EN'), warnIfMissed: false);
        await settle(tester);

        final elementEn = tester.element(find.byType(HomeScreen));
        expect(Directionality.of(elementEn), TextDirection.ltr);
      },
    );
  });
}
