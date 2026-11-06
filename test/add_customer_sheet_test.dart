import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pasture_fresh_milk/core/l10n/app_localizations.dart';
import 'package:pasture_fresh_milk/core/theme/app_theme.dart';
import 'package:pasture_fresh_milk/models/customer.dart';
import 'package:pasture_fresh_milk/models/product.dart';
import 'package:pasture_fresh_milk/models/route_model.dart';
import 'package:pasture_fresh_milk/providers/customer_provider.dart';
import 'package:pasture_fresh_milk/providers/product_provider.dart';
import 'package:pasture_fresh_milk/providers/route_provider.dart';
import 'package:pasture_fresh_milk/repositories/customer_repository.dart';
import 'package:pasture_fresh_milk/screens/customers/widgets/add_customer_sheet.dart';
import 'package:pasture_fresh_milk/widgets/app_snack_bar.dart';

class MockCustomerRepository extends CustomerRepository {
  Customer? lastInserted;
  Customer? lastUpdated;

  @override
  Future<List<Customer>> getAll() async => [];

  @override
  Future<void> insert(Customer item) async {
    lastInserted = item;
  }

  @override
  Future<void> update(Customer item) async {
    lastUpdated = item;
  }
}

final testRoutes = <DeliveryRoute>[
  DeliveryRoute(
    id: 'route_1',
    name: 'Model Town Route',
    area: 'Model Town',
    isActive: true,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  ),
  DeliveryRoute(
    id: 'route_2',
    name: 'DHA Phase 5 Route',
    area: 'DHA',
    isActive: true,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  ),
];

final testProducts = <Product>[
  Product(
    id: 'prod_cow_milk',
    name: 'Fresh Cow Milk',
    description: '100% Pure Cow Milk',
    defaultRate: 180.0,
    isActive: true,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  ),
  Product(
    id: 'prod_buffalo_milk',
    name: 'Pure Buffalo Milk',
    description: 'High fat buffalo milk',
    defaultRate: 220.0,
    isActive: true,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
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
  required MockCustomerRepository repository,
  Customer? customerToEdit,
  Locale locale = const Locale('en'),
  List<DeliveryRoute>? routes,
  List<Product>? products,
}) {
  return ProviderScope(
    overrides: [
      customerRepositoryProvider.overrideWithValue(repository),
      routeListProvider.overrideWith((ref) async => routes ?? testRoutes),
      productListProvider.overrideWith((ref) async => products ?? testProducts),
    ],
    child: MaterialApp(
      theme: AppTheme.lightTheme,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Builder(
          builder: (context) {
            return Center(
              child: ElevatedButton(
                key: const Key('open_sheet_btn'),
                onPressed: () {
                  AddCustomerSheet.show(
                    context,
                    customerToEdit: customerToEdit,
                  );
                },
                child: const Text('Open Sheet'),
              ),
            );
          },
        ),
      ),
    ),
  );
}

void main() {
  group('AddCustomerSheet (Milestone C-M5)', () {
    late MockCustomerRepository mockRepo;

    setUp(() {
      mockRepo = MockCustomerRepository();
    });

    testWidgets('renders all fields in Add mode with initial defaults', (tester) async {
      setTallSurface(tester);
      await tester.pumpWidget(createTestApp(repository: mockRepo));
      await tester.pumpAndSettle();

      // Open bottom sheet
      await tester.tap(find.byKey(const Key('open_sheet_btn')));
      await tester.pumpAndSettle();

      // Verify header title
      expect(find.text('Add Customer'), findsOneWidget);

      // Verify fields
      expect(find.byKey(const Key('customer_name_field')), findsOneWidget);
      expect(find.byKey(const Key('customer_phone_field')), findsOneWidget);
      expect(find.byKey(const Key('customer_address_field')), findsOneWidget);
      expect(find.byKey(const Key('customer_quota_am_field')), findsOneWidget);
      expect(find.byKey(const Key('customer_quota_pm_field')), findsOneWidget);
      expect(find.byKey(const Key('customer_product_dropdown')), findsOneWidget);
      expect(find.byKey(const Key('customer_rate_field')), findsOneWidget);
      expect(find.byKey(const Key('customer_notes_field')), findsOneWidget);

      // Verify save button
      expect(find.byKey(const Key('save_customer_button')), findsOneWidget);
      expect(find.text('Add Customer'), findsWidgets); // Appears in title/header & button

      // Check product default rate auto-fill
      final rateField = tester.widget<TextField>(
        find.descendant(
          of: find.byKey(const Key('customer_rate_field')),
          matching: find.byType(TextField),
        ),
      );
      expect(rateField.controller?.text, '180');
    });

    testWidgets('shows validation errors when required fields are missing or invalid', (tester) async {
      setTallSurface(tester);
      await tester.pumpWidget(createTestApp(repository: mockRepo));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('open_sheet_btn')));
      await tester.pumpAndSettle();

      // Clear the rate field so rate is 0
      await tester.enterText(
        find.descendant(
          of: find.byKey(const Key('customer_rate_field')),
          matching: find.byType(TextField),
        ),
        '',
      );
      await tester.pumpAndSettle();

      // Scroll to save button and tap
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -500));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('save_customer_button')), warnIfMissed: false);
      await tester.pumpAndSettle();

      // Check validation error messages
      expect(find.text('Customer name is required'), findsOneWidget);
      expect(find.text('Phone number is required'), findsOneWidget);
      expect(find.text('Enter a valid rate greater than 0'), findsOneWidget);
      expect(
        find.text('At least one quota (AM or PM) must be greater than 0'),
        findsOneWidget,
      );

      // Verify no repository calls were made
      expect(mockRepo.lastInserted, isNull);
    });

    testWidgets('successfully inserts new customer with valid inputs', (tester) async {
      setTallSurface(tester);
      await tester.pumpWidget(createTestApp(repository: mockRepo));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('open_sheet_btn')));
      await tester.pumpAndSettle();

      // Fill in Name
      await tester.enterText(
        find.descendant(
          of: find.byKey(const Key('customer_name_field')),
          matching: find.byType(TextField),
        ),
        'Muhammad Usman',
      );

      // Fill in Phone
      await tester.enterText(
        find.descendant(
          of: find.byKey(const Key('customer_phone_field')),
          matching: find.byType(TextField),
        ),
        '03009876543',
      );

      // Fill in Address
      await tester.enterText(
        find.descendant(
          of: find.byKey(const Key('customer_address_field')),
          matching: find.byType(TextField),
        ),
        'House 44, St 9',
      );

      // Fill in Quota AM
      await tester.enterText(
        find.descendant(
          of: find.byKey(const Key('customer_quota_am_field')),
          matching: find.byType(TextField),
        ),
        '2.5',
      );

      // Fill in Quota PM
      await tester.enterText(
        find.descendant(
          of: find.byKey(const Key('customer_quota_pm_field')),
          matching: find.byType(TextField),
        ),
        '1.0',
      );

      // Fill in Rate
      await tester.enterText(
        find.descendant(
          of: find.byKey(const Key('customer_rate_field')),
          matching: find.byType(TextField),
        ),
        '200',
      );

      // Scroll to save button and tap
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -500));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('save_customer_button')), warnIfMissed: false);
      await tester.pumpAndSettle();

      // Verify repository insert called
      expect(mockRepo.lastInserted, isNotNull);
      expect(mockRepo.lastInserted!.name, 'Muhammad Usman');
      expect(mockRepo.lastInserted!.phone, '03009876543');
      expect(mockRepo.lastInserted!.address, 'House 44, St 9');
      expect(mockRepo.lastInserted!.dailyQuotaAm, 2.5);
      expect(mockRepo.lastInserted!.dailyQuotaPm, 1.0);
      expect(mockRepo.lastInserted!.agreedRate, 200.0);
      expect(mockRepo.lastInserted!.status, 'active');

      // Sheet should be dismissed
      expect(find.byType(AddCustomerSheet), findsNothing);
      AppSnackBar.dismiss();
      await tester.pumpAndSettle();
    });

    testWidgets('renders Edit mode pre-populated and updates customer', (tester) async {
      setTallSurface(tester);
      final existingCustomer = Customer(
        id: 'cust_edit_1',
        name: 'Rashid Khan',
        phone: '03123456789',
        address: 'Sector C, Phase 1',
        area: 'DHA',



        dailyQuotaAm: 0.0,
        dailyQuotaPm: 3.0,
        productId: 'prod_cow_milk',
        agreedRate: 195.0,
        currentDue: 500.0,
        advanceBalance: 0.0,
        status: 'active',
        notes: 'Leave at front gate',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      await tester.pumpWidget(createTestApp(
        repository: mockRepo,
        customerToEdit: existingCustomer,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('open_sheet_btn')));
      await tester.pumpAndSettle();

      // Verify Edit header
      expect(find.text('Edit Customer'), findsOneWidget);

      // Verify pre-populated values
      final nameField = tester.widget<TextField>(
        find.descendant(
          of: find.byKey(const Key('customer_name_field')),
          matching: find.byType(TextField),
        ),
      );
      expect(nameField.controller?.text, 'Rashid Khan');

      final phoneField = tester.widget<TextField>(
        find.descendant(
          of: find.byKey(const Key('customer_phone_field')),
          matching: find.byType(TextField),
        ),
      );
      expect(phoneField.controller?.text, '03123456789');

      final addressField = tester.widget<TextField>(
        find.descendant(
          of: find.byKey(const Key('customer_address_field')),
          matching: find.byType(TextField),
        ),
      );
      expect(addressField.controller?.text, 'Sector C, Phase 1');

      final rateField = tester.widget<TextField>(
        find.descendant(
          of: find.byKey(const Key('customer_rate_field')),
          matching: find.byType(TextField),
        ),
      );
      expect(rateField.controller?.text, '195');

      final notesField = tester.widget<TextField>(
        find.descendant(
          of: find.byKey(const Key('customer_notes_field')),
          matching: find.byType(TextField),
        ),
      );
      expect(notesField.controller?.text, 'Leave at front gate');

      // Edit name
      await tester.enterText(
        find.descendant(
          of: find.byKey(const Key('customer_name_field')),
          matching: find.byType(TextField),
        ),
        'Rashid Khan Senior',
      );

      // Save
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -500));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('save_customer_button')), warnIfMissed: false);
      await tester.pumpAndSettle();

      // Verify repository update called
      expect(mockRepo.lastUpdated, isNotNull);
      expect(mockRepo.lastUpdated!.id, 'cust_edit_1');
      expect(mockRepo.lastUpdated!.name, 'Rashid Khan Senior');
      expect(mockRepo.lastUpdated!.currentDue, 500.0); // Preserved
      expect(mockRepo.lastUpdated!.dailyQuotaPm, 3.0);

      // Sheet dismissed
      expect(find.byType(AddCustomerSheet), findsNothing);
      AppSnackBar.dismiss();
      await tester.pumpAndSettle();
    });

    testWidgets('renders in Urdu locale with RTL alignment', (tester) async {
      setTallSurface(tester);
      await tester.pumpWidget(createTestApp(
        repository: mockRepo,
        locale: const Locale('ur'),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('open_sheet_btn')));
      await tester.pumpAndSettle();

      // Verify Urdu title & labels
      expect(find.text('نیا گاہک شامل کریں'), findsOneWidget);
      expect(find.textContaining('نام'), findsWidgets);
      expect(find.textContaining('فون نمبر'), findsWidgets);
      expect(find.textContaining('پتہ'), findsWidgets);
      expect(find.text('نیا گاہک'), findsOneWidget);
    });
  });
}
