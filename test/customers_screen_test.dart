import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pasture_fresh_milk/core/l10n/app_localizations.dart';
import 'package:pasture_fresh_milk/core/theme/app_theme.dart';
import 'package:pasture_fresh_milk/models/customer.dart';
import 'package:pasture_fresh_milk/providers/customer_provider.dart';
import 'package:pasture_fresh_milk/repositories/customer_repository.dart';
import 'package:pasture_fresh_milk/screens/customers/customers_screen.dart';
import 'package:pasture_fresh_milk/screens/customers/widgets/customer_card.dart';
import 'package:pasture_fresh_milk/widgets/app_button.dart';
import 'package:pasture_fresh_milk/widgets/app_snack_bar.dart';
import 'package:pasture_fresh_milk/widgets/empty_state.dart';
import 'package:pasture_fresh_milk/widgets/loading_state.dart';
import 'package:pasture_fresh_milk/widgets/status_badge.dart';

class MockCustomerRepository extends CustomerRepository {
  List<Customer> customers = <Customer>[
    Customer(
      id: 'cust_1',
      name: 'Tariq Mehmood',
      phone: '03001234567',
      address: 'House 12, St 4',
      area: 'Civil Lines',
      dailyQuotaAm: 2.0,
      dailyQuotaPm: 1.0,
      agreedRate: 180.0,
      currentDue: 1200.0,
      advanceBalance: 0.0,
      status: 'active',

      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    ),
    Customer(
      id: 'cust_2',
      name: 'Zubair Ansari',
      phone: '03219876543',
      address: 'Flat 5B',
      area: 'Gulberg III',
      dailyQuotaAm: 0.0,
      dailyQuotaPm: 2.0,
      agreedRate: 190.0,
      currentDue: 0.0,
      advanceBalance: 500.0,
      status: 'active',

      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    ),
    Customer(
      id: 'cust_3',
      name: 'Malik Kamran',
      phone: '03335554433',
      address: 'Plot 88',
      area: 'Model Town',
      dailyQuotaAm: 1.5,
      dailyQuotaPm: 0.0,
      agreedRate: 180.0,
      currentDue: 0.0,
      advanceBalance: 0.0,
      status: 'paused',
      pausedSince: DateTime(2026, 9, 1),

      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    ),
    Customer(
      id: 'cust_4',
      name: 'Bilal Ahmed',
      phone: '03451112233',
      address: 'Sector B',
      area: 'DHA Phase 5',
      dailyQuotaAm: 1.0,
      dailyQuotaPm: 1.0,
      agreedRate: 200.0,
      currentDue: 0.0,
      advanceBalance: 0.0,
      status: 'active',

      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    ),
  ];

  Customer? lastUpdated;

  @override
  Future<List<Customer>> getAll() async => customers;

  @override
  Future<List<Customer>> getActiveCustomers() async =>
      customers.where((c) => c.status == 'active').toList();

  @override
  Future<void> update(Customer item) async {
    lastUpdated = item;
    final index = customers.indexWhere((c) => c.id == item.id);
    if (index != -1) {
      customers[index] = item;
    }
  }
}

Widget createTestApp({
  required MockCustomerRepository repository,
  Locale locale = const Locale('en'),
  VoidCallback? onAddCustomer,
  ValueChanged<Customer>? onCustomerTap,
  Future<List<Customer>> Function(Ref)? allCustomersOverride,
}) {
  return ProviderScope(
    overrides: [
      customerRepositoryProvider.overrideWithValue(repository),
      allCustomersProvider.overrideWith(
        allCustomersOverride ?? (ref) async => repository.getAll(),
      ),
      customerStatsProvider.overrideWith((ref) async {
        final all = await repository.getAll();
        var totalDues = 0.0;
        for (final c in all) {
          totalDues += c.currentDue;
        }
        return (
          total: all.length,
          active: all.where((c) => c.status == 'active').length,
          withDues: all.where((c) => c.currentDue > 0).length,
          totalDues: totalDues,
          onAdvance: all.where((c) => c.advanceBalance > 0).length,
        );
      }),
    ],
    child: MaterialApp(
      theme: AppTheme.lightTheme,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: CustomersScreen(
          onAddCustomer: onAddCustomer,
          onCustomerTap: onCustomerTap,
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CustomersScreen — Rendering & Directory Overview', () {
    testWidgets('renders header, stats summary bar, search bar, and FAB', (tester) async {
      setTallSurface(tester);
      final mockRepo = MockCustomerRepository();
      await tester.pumpWidget(createTestApp(repository: mockRepo));
      await tester.pumpAndSettle();

      // Screen title
      expect(find.text('Customers'), findsOneWidget);

      // Customer count badge
      expect(find.text('4'), findsWidgets);

      // Summary Bar stats
      expect(find.text('TOTAL'), findsOneWidget);
      expect(find.text('WITH DUES'), findsOneWidget);
      expect(find.text('ON ADVANCE'), findsOneWidget);
      expect(find.text('1 (Rs. 1200)'), findsOneWidget);

      // Search Bar hint
      expect(find.text('Search by name, phone, area...'), findsOneWidget);

      // FAB "+ Add Customer"
      expect(find.byKey(const Key('add_customer_fab')), findsOneWidget);
      expect(find.text('Add Customer'), findsOneWidget);

      // 4 Customer Cards rendered
      expect(find.byType(CustomerCard), findsNWidgets(4));
    });

    testWidgets('CustomerCard displays correct details, initials, badges, and balances', (tester) async {
      setTallSurface(tester);
      final mockRepo = MockCustomerRepository();
      await tester.pumpWidget(createTestApp(repository: mockRepo));
      await tester.pumpAndSettle();

      // Customer Names
      expect(find.text('Tariq Mehmood'), findsOneWidget);
      expect(find.text('Zubair Ansari'), findsOneWidget);
      expect(find.text('Malik Kamran'), findsOneWidget);
      expect(find.text('Bilal Ahmed'), findsOneWidget);

      // Status Badges
      expect(find.byType(StatusBadge), findsNWidgets(4));
      expect(find.text('Active'), findsNWidgets(3));
      expect(find.text('Paused'), findsOneWidget);

      // Balance badges
      expect(find.text('Due: Rs. 1200'), findsOneWidget);
      expect(find.text('Advance: Rs. 500'), findsOneWidget);
      expect(find.text('Cleared: Rs. 0'), findsNWidgets(2));

      // Contextual Action Buttons
      expect(find.text('Record Payment'), findsOneWidget);
      expect(find.text('Add Recharge'), findsOneWidget);
      expect(find.text('Resume Supply'), findsOneWidget);
      expect(find.text('Ledger'), findsNWidgets(4));
    });
  });

  group('CustomersScreen — Search & Filter Chips', () {
    testWidgets('debounced search filters customers by name, phone, or area', (tester) async {
      setTallSurface(tester);
      final mockRepo = MockCustomerRepository();
      await tester.pumpWidget(createTestApp(repository: mockRepo));
      await tester.pumpAndSettle();

      expect(find.byType(CustomerCard), findsNWidgets(4));

      // Search by name
      await tester.enterText(find.byType(TextField), 'Zubair');
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      expect(find.byType(CustomerCard), findsOneWidget);
      expect(find.text('Zubair Ansari'), findsOneWidget);

      // Search by phone
      await tester.enterText(find.byType(TextField), '0300123');
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      expect(find.byType(CustomerCard), findsOneWidget);
      expect(find.text('Tariq Mehmood'), findsOneWidget);

      // Search by area
      await tester.enterText(find.byType(TextField), 'Model Town');
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      expect(find.byType(CustomerCard), findsOneWidget);
      expect(find.text('Malik Kamran'), findsOneWidget);
    });

    testWidgets('empty state displays when search has no matches, and Clear Filters resets', (tester) async {
      setTallSurface(tester);
      final mockRepo = MockCustomerRepository();
      await tester.pumpWidget(createTestApp(repository: mockRepo));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'nonexistentquery123');
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      expect(find.byType(CustomerCard), findsNothing);
      expect(find.byType(EmptyState), findsOneWidget);
      expect(find.text('No customers found'), findsOneWidget);

      // Tap "Clear Filters"
      await tester.tap(find.text('Clear Filters'));
      await tester.pumpAndSettle();

      expect(find.byType(CustomerCard), findsNWidgets(4));
    });

    testWidgets('filter chips filter customers: Has Dues, On Advance, Morning, Evening', (tester) async {
      setTallSurface(tester);
      final mockRepo = MockCustomerRepository();
      await tester.pumpWidget(createTestApp(repository: mockRepo));
      await tester.pumpAndSettle();

      // Chip 1: Has Dues
      await tester.tap(find.textContaining('Has Dues'));
      await tester.pumpAndSettle();
      expect(find.byType(CustomerCard), findsOneWidget);
      expect(find.text('Tariq Mehmood'), findsOneWidget);

      // Chip 2: On Advance
      await tester.tap(find.textContaining('On Advance'));
      await tester.pumpAndSettle();
      expect(find.byType(CustomerCard), findsOneWidget);
      expect(find.text('Zubair Ansari'), findsOneWidget);

      // Chip 3: Morning
      await tester.tap(find.textContaining('Morning'));
      await tester.pumpAndSettle();
      expect(find.byType(CustomerCard), findsNWidgets(3)); // Tariq, Malik, Bilal

      // Chip 4: Evening
      await tester.tap(find.textContaining('Evening'));
      await tester.pumpAndSettle();
      expect(find.byType(CustomerCard), findsNWidgets(2)); // Zubair, Bilal

      // Chip 0: All
      await tester.ensureVisible(find.textContaining('All'));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('All'));
      await tester.pumpAndSettle();
      expect(find.byType(CustomerCard), findsNWidgets(4));
    });
  });

  group('CustomersScreen — Contextual Actions & Call Handler', () {
    testWidgets('tapping Resume Supply resumes deliveries and displays snackbar', (tester) async {
      setTallSurface(tester);
      final mockRepo = MockCustomerRepository();
      await tester.pumpWidget(createTestApp(repository: mockRepo));
      await tester.pumpAndSettle();

      expect(mockRepo.customers.firstWhere((c) => c.name == 'Malik Kamran').status, 'paused');

      final resumeBtn = find.widgetWithText(AppButton, 'Resume Supply');
      await tester.ensureVisible(resumeBtn);
      await tester.pumpAndSettle();

      // Tap "Resume Supply"
      await tester.tap(resumeBtn, warnIfMissed: false);
      await tester.pump();

      expect(mockRepo.lastUpdated?.status, 'active');
      expect(find.text('Supply resumed for Malik Kamran'), findsOneWidget);

      AppSnackBar.dismiss();
      await tester.pumpAndSettle();
    });

    testWidgets('tapping customer card triggers onCustomerTap callback', (tester) async {
      setTallSurface(tester);
      final mockRepo = MockCustomerRepository();
      Customer? tappedCustomer;
      await tester.pumpWidget(
        createTestApp(
          repository: mockRepo,
          onCustomerTap: (c) => tappedCustomer = c,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Tariq Mehmood'));
      await tester.pumpAndSettle();

      expect(tappedCustomer?.name, 'Tariq Mehmood');
    });

    testWidgets('tapping FAB calls onAddCustomer callback', (tester) async {
      setTallSurface(tester);
      final mockRepo = MockCustomerRepository();
      var fabTapped = false;
      await tester.pumpWidget(
        createTestApp(
          repository: mockRepo,
          onAddCustomer: () => fabTapped = true,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('add_customer_fab')));
      await tester.pumpAndSettle();

      expect(fabTapped, isTrue);
    });
  });

  group('CustomersScreen — Loading State & Urdu RTL', () {
    testWidgets('renders shimmer cards while data is loading', (tester) async {
      setTallSurface(tester);
      final completer = Completer<List<Customer>>();
      final mockRepo = MockCustomerRepository();

      await tester.pumpWidget(
        createTestApp(
          repository: mockRepo,
          allCustomersOverride: (ref) => completer.future,
        ),
      );

      await tester.pump();
      expect(find.byType(ShimmerCard), findsWidgets);

      completer.complete(mockRepo.customers);
      await tester.pumpAndSettle();
      expect(find.byType(CustomerCard), findsNWidgets(4));
    });

    testWidgets('renders in Urdu RTL under Locale("ur") without errors', (tester) async {
      setTallSurface(tester);
      final mockRepo = MockCustomerRepository();
      await tester.pumpWidget(
        createTestApp(
          repository: mockRepo,
          locale: const Locale('ur'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('گاہک'), findsWidgets);
      expect(find.text('نیا گاہک'), findsOneWidget);
      expect(find.text('کل'), findsOneWidget);
      expect(find.textContaining('واجبات'), findsWidgets);
      expect(find.text('کھاتہ'), findsWidgets);
    });
  });
}
