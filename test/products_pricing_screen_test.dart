import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pasture_fresh_milk/core/l10n/app_localizations.dart';
import 'package:pasture_fresh_milk/core/theme/app_theme.dart';
import 'package:pasture_fresh_milk/models/customer.dart';
import 'package:pasture_fresh_milk/models/product.dart';
import 'package:pasture_fresh_milk/providers/customer_provider.dart';
import 'package:pasture_fresh_milk/providers/product_provider.dart';
import 'package:pasture_fresh_milk/repositories/customer_repository.dart';
import 'package:pasture_fresh_milk/repositories/product_repository.dart';
import 'package:pasture_fresh_milk/screens/settings/products_pricing_screen.dart';
import 'package:pasture_fresh_milk/widgets/app_snack_bar.dart';
import 'package:material_symbols_icons/symbols.dart';

class _FakeProductRepository implements ProductRepository {
  _FakeProductRepository(this.products);

  final List<Product> products;
  bool insertCalled = false;
  bool updateCalled = false;
  Product? lastInserted;
  Product? lastUpdated;

  @override
  String get tableName => 'products';

  @override
  Product fromMap(Map<String, dynamic> map) => Product.fromMap(map);

  @override
  Map<String, dynamic> toMap(Product item) => item.toMap();

  @override
  Future<List<Product>> getAll() async => List.from(products);

  @override
  Future<List<Product>> getActiveProducts() async =>
      products.where((p) => p.isActive).toList();

  @override
  Future<void> insert(Product item) async {
    insertCalled = true;
    lastInserted = item;
    products.add(item);
  }

  @override
  Future<void> update(Product item) async {
    updateCalled = true;
    lastUpdated = item;
    final index = products.indexWhere((p) => p.id == item.id);
    if (index != -1) {
      products[index] = item;
    }
  }

  @override
  Future<Product?> getById(String id) async {
    final matches = products.where((p) => p.id == id);
    return matches.isNotEmpty ? matches.first : null;
  }

  @override
  Future<int> delete(String id) async {
    products.removeWhere((p) => p.id == id);
    return 1;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeCustomerRepository implements CustomerRepository {
  _FakeCustomerRepository(this.customers);

  final List<Customer> customers;

  @override
  String get tableName => 'customers';

  @override
  Customer fromMap(Map<String, dynamic> map) => Customer.fromMap(map);

  @override
  Map<String, dynamic> toMap(Customer item) => item.toMap();

  @override
  Future<List<Customer>> getCustomersByProduct(String productId) async {
    return customers.where((c) => c.productId == productId).toList();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  final now = DateTime(2026, 9, 14);

  final mockProducts = [
    Product(
      id: 'p_1',
      name: 'Buffalo Milk',
      description: 'High fat rich creamy milk',
      defaultRate: 210.0,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    ),
    Product(
      id: 'p_2',
      name: 'Cow Milk (Pure)',
      description: 'Fresh farm cow milk',
      defaultRate: 190.0,
      isActive: false,
      createdAt: now,
      updatedAt: now,
    ),
  ];

  Widget buildHarness({
    required _FakeProductRepository productRepo,
    required _FakeCustomerRepository customerRepo,
    Locale locale = const Locale('en'),
  }) {
    return ProviderScope(
      overrides: [
        productRepositoryProvider.overrideWithValue(productRepo),
        allProductListProvider.overrideWith((ref) async => productRepo.getAll()),
        productListProvider.overrideWith((ref) async => productRepo.getActiveProducts()),
        customerRepositoryProvider.overrideWithValue(customerRepo),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const ProductsPricingScreen(),
      ),
    );
  }

  group('ProductsPricingScreen (C-M17)', () {
    testWidgets('renders product list with names, descriptions, rates, and badges',
        (tester) async {
      final productRepo = _FakeProductRepository(List.from(mockProducts));
      final customerRepo = _FakeCustomerRepository([]);

      await tester.pumpWidget(
        buildHarness(productRepo: productRepo, customerRepo: customerRepo),
      );
      await tester.pumpAndSettle();

      expect(find.text('Products & Pricing'), findsOneWidget);
      expect(find.text('Buffalo Milk'), findsOneWidget);
      expect(find.text('High fat rich creamy milk'), findsOneWidget);
      expect(find.text('Rs. 210 / Litre'), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);

      expect(find.text('Cow Milk (Pure)'), findsOneWidget);
      expect(find.text('Fresh farm cow milk'), findsOneWidget);
      expect(find.text('Rs. 190 / Litre'), findsOneWidget);
      expect(find.text('Inactive'), findsOneWidget);
    });

    testWidgets('tapping Add Product FAB opens sheet, saving inserts new product',
        (tester) async {
      final productRepo = _FakeProductRepository(List.from(mockProducts));
      final customerRepo = _FakeCustomerRepository([]);

      await tester.pumpWidget(
        buildHarness(productRepo: productRepo, customerRepo: customerRepo),
      );
      await tester.pumpAndSettle();

      // Tap FAB
      await tester.tap(find.text('Add Product'));
      await tester.pumpAndSettle();

      expect(find.text('Add Product'), findsAtLeastNWidgets(1));

      // Enter product details
      await tester.enterText(
        find.widgetWithText(TextField, 'e.g. Buffalo Milk'),
        'Goat Milk',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'e.g. 210'),
        '300',
      );
      await tester.pumpAndSettle();

      // Tap Save
      await tester.tap(find.text('Save Changes'));
      await tester.pump();

      expect(productRepo.insertCalled, isTrue);
      expect(productRepo.lastInserted?.name, equals('Goat Milk'));
      expect(productRepo.lastInserted?.defaultRate, equals(300.0));

      AppSnackBar.dismiss();
      await tester.pumpAndSettle();
    });

    testWidgets('tapping Edit on a product opens sheet and updates rate',
        (tester) async {
      final productRepo = _FakeProductRepository(List.from(mockProducts));
      final customerRepo = _FakeCustomerRepository([]);

      await tester.pumpWidget(
        buildHarness(productRepo: productRepo, customerRepo: customerRepo),
      );
      await tester.pumpAndSettle();

      // Tap Edit on Buffalo Milk
      final editButtons = find.byIcon(Symbols.edit);
      await tester.tap(editButtons.first);
      await tester.pumpAndSettle();

      expect(find.text('Edit Product'), findsOneWidget);
      expect(find.text('Buffalo Milk'), findsAtLeastNWidgets(1));

      // Update rate
      await tester.enterText(find.widgetWithText(TextField, '210'), '220');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save Changes'));
      await tester.pump();

      expect(productRepo.updateCalled, isTrue);
      expect(productRepo.lastUpdated?.defaultRate, equals(220.0));

      AppSnackBar.dismiss();
      await tester.pumpAndSettle();
    });

    testWidgets('cannot deactivate product when active customers are assigned',
        (tester) async {
      final productRepo = _FakeProductRepository(List.from(mockProducts));
      final activeCustomer = Customer(
        id: 'cust_1',
        name: 'Tariq Mehmood',
        phone: '03001234567',
        productId: 'p_1',
        agreedRate: 210.0,
        status: 'active',


        createdAt: now,
        updatedAt: now,
      );
      final customerRepo = _FakeCustomerRepository([activeCustomer]);

      await tester.pumpWidget(
        buildHarness(productRepo: productRepo, customerRepo: customerRepo),
      );
      await tester.pumpAndSettle();

      // Tap Deactivate on Buffalo Milk (p_1)
      await tester.tap(find.text('Deactivate'));
      await tester.pump();

      // Warning snackbar shown, no dialog
      expect(find.textContaining('Cannot deactivate: Active customers are assigned'), findsOneWidget);
      expect(productRepo.updateCalled, isFalse);

      AppSnackBar.dismiss();
      await tester.pumpAndSettle();
    });

    testWidgets('deactivating product with no customers asks confirmation and deactivates',
        (tester) async {
      final productRepo = _FakeProductRepository(List.from(mockProducts));
      final customerRepo = _FakeCustomerRepository([]); // No customers

      await tester.pumpWidget(
        buildHarness(productRepo: productRepo, customerRepo: customerRepo),
      );
      await tester.pumpAndSettle();

      // Tap Deactivate on Buffalo Milk
      await tester.tap(find.text('Deactivate'));
      await tester.pumpAndSettle();

      // Confirmation dialog shown
      expect(find.text('Deactivate Product'), findsOneWidget);
      expect(
        find.textContaining('Are you sure you want to deactivate "Buffalo Milk"?'),
        findsOneWidget,
      );

      // Confirm
      await tester.tap(find.text('Confirm'));
      await tester.pump();

      expect(productRepo.updateCalled, isTrue);
      expect(productRepo.lastUpdated?.isActive, isFalse);

      AppSnackBar.dismiss();
      await tester.pumpAndSettle();
    });

    testWidgets('tapping Activate reactivates an inactive product',
        (tester) async {
      final productRepo = _FakeProductRepository(List.from(mockProducts));
      final customerRepo = _FakeCustomerRepository([]);

      await tester.pumpWidget(
        buildHarness(productRepo: productRepo, customerRepo: customerRepo),
      );
      await tester.pumpAndSettle();

      // Tap Activate on Cow Milk (Pure)
      await tester.tap(find.text('Activate'));
      await tester.pump();

      expect(productRepo.updateCalled, isTrue);
      expect(productRepo.lastUpdated?.isActive, isTrue);

      AppSnackBar.dismiss();
      await tester.pumpAndSettle();
    });

    testWidgets('renders EmptyState when product list is empty', (tester) async {
      final productRepo = _FakeProductRepository([]);
      final customerRepo = _FakeCustomerRepository([]);

      await tester.pumpWidget(
        buildHarness(productRepo: productRepo, customerRepo: customerRepo),
      );
      await tester.pumpAndSettle();

      expect(find.text('No products found'), findsOneWidget);
      expect(find.text('Add milk products and default pricing.'), findsOneWidget);
    });

    testWidgets('renders cleanly in Urdu locale with RTL', (tester) async {
      final productRepo = _FakeProductRepository(List.from(mockProducts));
      final customerRepo = _FakeCustomerRepository([]);

      await tester.pumpWidget(
        buildHarness(
          productRepo: productRepo,
          customerRepo: customerRepo,
          locale: const Locale('ur'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('مصنوعات اور قیمتیں'), findsOneWidget);
      expect(find.text('نئی پروڈکٹ شامل کریں'), findsAtLeastNWidgets(1));
      expect(find.text('فعال'), findsOneWidget);
      expect(find.text('غیر فعال'), findsOneWidget);
    });
  });
}
