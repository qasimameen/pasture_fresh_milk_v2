import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:pasture_fresh_milk/core/l10n/app_localizations.dart';
import 'package:pasture_fresh_milk/core/theme/app_theme.dart';
import 'package:pasture_fresh_milk/models/local_sale.dart';
import 'package:pasture_fresh_milk/models/product.dart';
import 'package:pasture_fresh_milk/models/store_profile.dart';
import 'package:pasture_fresh_milk/providers/dashboard_provider.dart';
import 'package:pasture_fresh_milk/providers/local_sale_provider.dart';
import 'package:pasture_fresh_milk/providers/product_provider.dart';
import 'package:pasture_fresh_milk/providers/store_profile_provider.dart';
import 'package:pasture_fresh_milk/repositories/local_sale_repository.dart';
import 'package:pasture_fresh_milk/screens/home/home_screen.dart';

import 'package:pasture_fresh_milk/screens/home/widgets/local_sales_section.dart';
import 'package:pasture_fresh_milk/screens/home/quick_sale_screen.dart';
import 'package:pasture_fresh_milk/screens/home/widgets/shift_banner.dart';
import 'package:pasture_fresh_milk/widgets/app_snack_bar.dart';
import 'package:pasture_fresh_milk/widgets/language_toggle.dart';
import 'package:pasture_fresh_milk/widgets/loading_state.dart';
import 'package:pasture_fresh_milk/widgets/metric_card.dart';

class MockLocalSaleRepository extends LocalSaleRepository {
  LocalSale? lastRecordedSale = LocalSale(
    id: 'last_1',
    date: DateTime.now(),
    productName: 'Fresh Cow Milk',
    quantity: 2.0,
    rate: 210.0,
    totalAmount: 420.0,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
  bool deleteCalled = false;

  @override
  Future<LocalSale> addQuickSale(
    double litres,
    String productName,
    double ratePerLitre, {
    String? productId,
  }) async {
    final now = DateTime.now();
    final sale = LocalSale(
      id: 'mock_sale_1',
      date: now,
      productName: productName,
      productId: productId,
      quantity: litres,
      rate: ratePerLitre,
      totalAmount: litres * ratePerLitre,
      createdAt: now,
      updatedAt: now,
    );
    lastRecordedSale = sale;
    return sale;
  }

  @override
  Future<void> deleteLastSale() async {
    deleteCalled = true;
    lastRecordedSale = null;
  }

  @override
  Future<LocalSale?> getLastSale() async => lastRecordedSale;

  @override
  Future<
    ({
      double totalQuantity,
      double totalAmount,
      int saleCount,
    })
  >
  getTodayTotals(DateTime date) async {
    return (
      totalQuantity: 12.0,
      totalAmount: 2400.0,
      saleCount: 4,
    );
  }
}

void main() {
  final now = DateTime.now();

  const mockData = DashboardData(
    totalCustomers: 48,
    activeCustomers: 42,
    totalDues: 18500.0,
    overdueCount: 7,
    dailySellQuantity: 124.5,
    monthlySellQuantity: 3420.0,
    monthlyGrowthPercent: 8.5,
    todayCash: 9600.0,
    advanceHeld: 14200.0,
    prepaidCount: 12,
    monthlyCollectionTotal: 185000.0,
    monthlyTarget: 220000.0,
    monthlyTargetPercent: 84.0,
    deliveryProgress: (
      total: 42,
      completed: 34,
      remaining: 6,
      skipped: 2,
      percent: 81.0,
    ),
    morningProgress: (
      total: 42,
      completed: 34,
      remaining: 6,
      skipped: 2,
      percent: 81.0,
    ),
    eveningProgress: (
      total: 30,
      completed: 0,
      remaining: 30,
      skipped: 0,
      percent: 0.0,
    ),
    activeShiftName: 'Morning',
    activeRouteName: 'Gulberg Route',
  );

  final mockStoreProfile = StoreProfile(
    id: 'store_1',
    name: 'Al-Madina Dairy Farm',
    phone: '+923001234567',
    address: 'Gulberg III, Lahore',
    createdAt: now,
    updatedAt: now,
  );

  final mockProduct = Product(
    id: 'prod_1',
    name: 'Fresh Cow Milk',
    defaultRate: 210.0,
    createdAt: now,
    updatedAt: now,
  );

  Widget buildHomeHarness({
    Locale locale = const Locale('en'),
    DashboardData? data = mockData,
    bool isLoading = false,
    ValueChanged<int>? onNavigateToTab,
    MockLocalSaleRepository? mockRepo,
  }) {
    final repo = mockRepo ?? MockLocalSaleRepository();

    return ProviderScope(
      overrides: [
        if (isLoading)
          dashboardProvider.overrideWith((ref) => Completer<DashboardData>().future)
        else if (data != null)
          dashboardProvider.overrideWith((ref) => Future.value(data)),
        storeProfileProvider.overrideWith((ref) => Future.value(mockStoreProfile)),
        productListProvider.overrideWith((ref) => Future.value([mockProduct])),
        localSaleRepositoryProvider.overrideWithValue(repo),
      ],
      child: MaterialApp(
        locale: locale,
        theme: AppTheme.lightTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: HomeScreen(
          onNavigateToTab: onNavigateToTab ?? (_) {},
        ),
      ),
    );
  }

  group('HomeScreen — Header & Store Identity', () {
    testWidgets('renders store name, active badge, settings button, and language toggle', (tester) async {
      await tester.pumpWidget(buildHomeHarness());
      await tester.pumpAndSettle();

      expect(find.text('Al-Madina Dairy Farm'), findsOneWidget);
      expect(find.text('Active'), findsWidgets);
      expect(find.byIcon(Symbols.settings), findsOneWidget);
      expect(find.byType(LanguageToggle), findsOneWidget);
    });
  });

  group('HomeScreen — ShiftBanner', () {
    testWidgets('renders active route, Morning Active pill, progress, and badges', (tester) async {
      await tester.pumpWidget(buildHomeHarness());
      await tester.pumpAndSettle();

      expect(find.byType(ShiftBanner), findsOneWidget);
      expect(find.text('Gulberg Route'), findsOneWidget);
      expect(find.text('Morning Active'), findsOneWidget);
      expect(find.text('34/42'), findsOneWidget);
    });

    testWidgets('tapping Deliveries link invokes onNavigateToTab(2)', (tester) async {
      int? navigatedTab;
      await tester.pumpWidget(
        buildHomeHarness(onNavigateToTab: (index) => navigatedTab = index),
      );
      await tester.pumpAndSettle();

      final deliveriesFinder = find.descendant(
        of: find.byType(ShiftBanner),
        matching: find.text('Deliveries'),
      ).first;
      expect(deliveriesFinder, findsOneWidget);
      await tester.tap(deliveriesFinder);
      await tester.pumpAndSettle();

      expect(navigatedTab, 2);
    });
  });

  group('HomeScreen — Bento KPI Grid & Monthly Collection', () {
    testWidgets('renders 6 MetricCards with correct values and subtitles', (tester) async {
      await tester.pumpWidget(buildHomeHarness());
      await tester.pumpAndSettle();

      expect(find.byType(MetricCard), findsNWidgets(6));

      // 1. Total Customers
      expect(find.text('Total Customers'), findsOneWidget);
      expect(find.text('48'), findsOneWidget);

      // 2. Total Dues
      expect(find.text('Total Dues'), findsOneWidget);
      expect(find.text('Rs. 18500'), findsOneWidget);
      expect(find.text('7'), findsOneWidget);

      // 3. Daily Sell
      expect(find.text('Daily Sell'), findsOneWidget);
      expect(find.text('124.5 Litre'), findsOneWidget);

      // 4. Monthly Sell
      expect(find.text('Monthly Sell'), findsOneWidget);
      expect(find.text('3420 Litre'), findsOneWidget);

      // 5. Today's Cash
      expect(find.text("Today's Cash"), findsOneWidget);
      expect(find.text('Rs. 9600'), findsOneWidget);

      // 6. Advance Held
      expect(find.text('Advance Held'), findsOneWidget);
      expect(find.text('Rs. 14200'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
    });

    testWidgets('renders Monthly Collection banner with target percent', (tester) async {
      await tester.pumpWidget(buildHomeHarness());
      await tester.pumpAndSettle();

      expect(find.text('Monthly Collection'), findsOneWidget);
      expect(find.text('Rs. 185000'), findsOneWidget);
      expect(find.text('84% of target'), findsOneWidget);
    });
  });

  group('HomeScreen — Local Counter Sales Section', () {
    tearDown(() {
      AppSnackBar.dismiss();
    });
    testWidgets('renders counter sales totals and pos product grid', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildHomeHarness());
      await tester.pumpAndSettle();

      expect(find.byType(LocalSalesSection), findsOneWidget);
      expect(find.text('Counter Sales'), findsOneWidget);
      expect(find.text('Today: 12 L • Rs. 2400'), findsOneWidget);
      
      // We should see the mock product in the grid
      expect(find.text('Fresh Cow Milk'), findsOneWidget);
      expect(find.text('Rs. 210/L'), findsOneWidget);
    });

    testWidgets('tapping a product opens QuickSaleSheet', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildHomeHarness());
      await tester.pumpAndSettle();

      // Tap the product in the grid
      await tester.tap(find.text('Fresh Cow Milk'));
      await tester.pumpAndSettle();

      expect(find.byType(QuickSaleScreen), findsOneWidget);
      expect(find.text('Quick Counter Sale'), findsOneWidget);
      // The product name is displayed read-only inside the sheet
      expect(find.text('Fresh Cow Milk'), findsWidgets);
    });

    testWidgets('QuickSaleScreen records sale and presents snackbar with Undo', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final mockRepo = MockLocalSaleRepository();
      await tester.pumpWidget(buildHomeHarness(mockRepo: mockRepo));
      await tester.pumpAndSettle();

      // Tap the product in the grid
      await tester.tap(find.text('Fresh Cow Milk'));
      await tester.pumpAndSettle();

      // Tap the '1' quick quantity chip
      await tester.tap(find.widgetWithText(ActionChip, '1'));
      await tester.pumpAndSettle();

      // Tap Record Sale
      await tester.tap(find.text('Record Sale'));
      await tester.pump(); // Start snackbar animation
      await tester.pump(const Duration(milliseconds: 250));

      expect(mockRepo.lastRecordedSale, isNotNull);
      expect(mockRepo.lastRecordedSale!.quantity, 1.0);
      expect(mockRepo.lastRecordedSale!.productName, 'Fresh Cow Milk');
      expect(find.text('Sale recorded successfully'), findsOneWidget);
      expect(find.text('Undo'), findsWidgets);

      AppSnackBar.dismiss();
      await tester.pump();
    });

    testWidgets('tapping Undo deletes the last sale and shows confirmation', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final mockRepo = MockLocalSaleRepository();
      await tester.pumpWidget(buildHomeHarness(mockRepo: mockRepo));
      await tester.pumpAndSettle();

      // Tap Undo on the last sale display
      await tester.tap(find.text('Undo').first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      expect(mockRepo.deleteCalled, isTrue);
      expect(find.text('Sale undone'), findsOneWidget);

      AppSnackBar.dismiss();
      await tester.pump();
    });
  });


  group('HomeScreen — Loading & Shimmer State', () {
    testWidgets('renders ShimmerCard and ShimmerMetricGrid when data is loading', (tester) async {
      await tester.pumpWidget(buildHomeHarness(isLoading: true));
      await tester.pump();

      expect(find.byType(ShimmerCard), findsWidgets);
      expect(find.byType(ShimmerMetricGrid), findsOneWidget);
    });
  });

  group('HomeScreen — Urdu Localization (RTL)', () {
    testWidgets('renders dashboard in Urdu under Locale(ur) with RTL', (tester) async {
      await tester.pumpWidget(buildHomeHarness(locale: const Locale('ur')));
      await tester.pumpAndSettle();

      expect(find.text('صبح فعال'), findsOneWidget);
      expect(find.text('کل گاہک'), findsOneWidget);
      expect(find.text('کل بقایا جات'), findsOneWidget);
      expect(find.text('کاؤنٹر فروخت'), findsOneWidget);
      expect(find.text('ڈیلیوری شیڈول'), findsOneWidget);
    });
  });
}
