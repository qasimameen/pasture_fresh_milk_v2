import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pasture_fresh_milk/core/l10n/app_localizations.dart';
import 'package:pasture_fresh_milk/core/theme/app_theme.dart';
import 'package:pasture_fresh_milk/models/local_sale.dart';
import 'package:pasture_fresh_milk/models/product.dart';
import 'package:pasture_fresh_milk/providers/local_sale_provider.dart';
import 'package:pasture_fresh_milk/providers/product_provider.dart';
import 'package:pasture_fresh_milk/repositories/local_sale_repository.dart';
import 'package:pasture_fresh_milk/screens/home/quick_sale_screen.dart';
import 'package:pasture_fresh_milk/widgets/app_button.dart';
import 'package:pasture_fresh_milk/widgets/app_dropdown.dart';
import 'package:pasture_fresh_milk/widgets/app_snack_bar.dart';
import 'package:pasture_fresh_milk/widgets/app_text_field.dart';

class MockLocalSaleRepository extends LocalSaleRepository {
  LocalSale? lastRecordedSale;
  bool deleteCalled = false;
  String? deletedSaleId;

  @override
  Future<LocalSale> addQuickSale(
    double litres,
    String productName,
    double ratePerLitre, {
    String? productId,
  }) async {
    final now = DateTime.now();
    final sale = LocalSale(
      id: 'quick_sale_mock_1',
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
  Future<void> delete(String id) async {
    deleteCalled = true;
    deletedSaleId = id;
    if (lastRecordedSale?.id == id) {
      lastRecordedSale = null;
    }
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
      totalQuantity: 10.0,
      totalAmount: 2100.0,
      saleCount: 3,
    );
  }
}

void main() {
  final now = DateTime.now();

  final mockCowMilk = Product(
    id: 'prod_cow',
    name: 'Fresh Cow Milk',
    defaultRate: 210.0,
    createdAt: now,
    updatedAt: now,
  );

  final mockBuffaloMilk = Product(
    id: 'prod_buffalo',
    name: 'Fresh Buffalo Milk',
    defaultRate: 240.0,
    createdAt: now,
    updatedAt: now,
  );

  Widget buildSheetHarness({
    Locale locale = const Locale('en'),
    Product? initialProduct,
    MockLocalSaleRepository? mockRepo,
    List<Product>? products,
  }) {
    final repo = mockRepo ?? MockLocalSaleRepository();
    final productList = products ?? [mockCowMilk, mockBuffaloMilk];

    return ProviderScope(
      overrides: [
        productListProvider.overrideWith((ref) => Future.value(productList)),
        localSaleRepositoryProvider.overrideWithValue(repo),
      ],
      child: MaterialApp(
        locale: locale,
        theme: AppTheme.lightTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return Center(
                child: ElevatedButton(
                  onPressed: () {
                    QuickSaleScreen.show(
                      context,
                      initialProduct: initialProduct ?? mockCowMilk,
                    );
                  },
                  child: const Text('Open Quick Sale'),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  group('QuickSaleSheet — Rendering & Initial Values', () {
    tearDown(() {
      AppSnackBar.dismiss();
    });

    testWidgets('renders all fields, labels, initial values, and total calculation', (tester) async {
      await tester.pumpWidget(buildSheetHarness());
      await tester.pumpAndSettle();

      // Open sheet
      await tester.tap(find.text('Open Quick Sale'));
      await tester.pumpAndSettle();

      // Title
      expect(find.text('Quick Counter Sale'), findsOneWidget);

      // Product dropdown
      expect(find.byType(AppDropdown<Product>), findsOneWidget);
      expect(find.text('Fresh Cow Milk (Rs. 210/L)'), findsOneWidget);

      // Quantity & Rate fields
      expect(find.byType(AppTextField), findsNWidgets(2));
      expect(find.text('1'), findsOneWidget);
      expect(find.text('210'), findsOneWidget);

      // Total display: 1 x 210 = Rs. 210
      expect(find.text('Total Amount'), findsOneWidget);
      expect(find.text('Rs. 210'), findsOneWidget);

      // Save CTA
      expect(find.byType(AppButton), findsOneWidget);
      expect(find.text('Record Sale'), findsOneWidget);
    });
  });

  group('QuickSaleSheet — Live Total Recalculation', () {
    tearDown(() {
      AppSnackBar.dismiss();
    });

    testWidgets('updating quantity recalculates total live', (tester) async {
      await tester.pumpWidget(buildSheetHarness());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Quick Sale'));
      await tester.pumpAndSettle();

      // Change quantity to 3
      final quantityFinder = find.byType(TextField).at(0);
      await tester.enterText(quantityFinder, '3');
      await tester.pumpAndSettle();

      // 3 x 210 = Rs. 630
      expect(find.text('Rs. 630'), findsOneWidget);
    });

    testWidgets('updating rate recalculates total live', (tester) async {
      await tester.pumpWidget(buildSheetHarness());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Quick Sale'));
      await tester.pumpAndSettle();

      // Change rate to 250 with quantity 1
      final rateFinder = find.byType(TextField).at(1);
      await tester.enterText(rateFinder, '250');
      await tester.pumpAndSettle();

      // 1 x 250 = Rs. 250
      expect(find.text('Rs. 250'), findsOneWidget);
    });

    testWidgets('selecting a different product updates rate and total', (tester) async {
      await tester.pumpWidget(buildSheetHarness());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Quick Sale'));
      await tester.pumpAndSettle();

      // Tap product dropdown to open picker
      await tester.tap(find.text('Fresh Cow Milk (Rs. 210/L)'));
      await tester.pumpAndSettle();

      // Select Buffalo Milk
      await tester.tap(find.text('Fresh Buffalo Milk (Rs. 240/L)').last);
      await tester.pumpAndSettle();

      // Rate field auto-filled with 240, total 1 x 240 = Rs. 240
      expect(find.text('240'), findsOneWidget);
      expect(find.text('Rs. 240'), findsOneWidget);
    });
  });

  group('QuickSaleSheet — Validation', () {
    tearDown(() {
      AppSnackBar.dismiss();
    });

    testWidgets('prevents submission when quantity is zero or empty', (tester) async {
      final mockRepo = MockLocalSaleRepository();
      await tester.pumpWidget(buildSheetHarness(mockRepo: mockRepo));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Quick Sale'));
      await tester.pumpAndSettle();

      // Clear quantity
      final quantityFinder = find.byType(TextField).at(0);
      await tester.enterText(quantityFinder, '0');
      await tester.pumpAndSettle();

      // Tap Record Sale
      await tester.tap(find.text('Record Sale'));
      await tester.pumpAndSettle();

      expect(find.text('Enter a valid quantity greater than 0'), findsOneWidget);
      expect(mockRepo.lastRecordedSale, isNull);
    });

    testWidgets('prevents submission when rate is zero or empty', (tester) async {
      final mockRepo = MockLocalSaleRepository();
      await tester.pumpWidget(buildSheetHarness(mockRepo: mockRepo));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Quick Sale'));
      await tester.pumpAndSettle();

      // Clear rate
      final rateFinder = find.byType(TextField).at(1);
      await tester.enterText(rateFinder, '0');
      await tester.pumpAndSettle();

      // Tap Record Sale
      await tester.tap(find.text('Record Sale'));
      await tester.pumpAndSettle();

      expect(find.text('Enter a valid rate greater than 0'), findsOneWidget);
      expect(mockRepo.lastRecordedSale, isNull);
    });
  });

  group('QuickSaleSheet — Submission & Undo', () {
    tearDown(() {
      AppSnackBar.dismiss();
    });

    testWidgets('saves valid sale, closes sheet, and presents snackbar with Undo action', (tester) async {
      final mockRepo = MockLocalSaleRepository();
      await tester.pumpWidget(buildSheetHarness(mockRepo: mockRepo));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Quick Sale'));
      await tester.pumpAndSettle();

      // Enter 2.5 litres
      final quantityFinder = find.byType(TextField).at(0);
      await tester.enterText(quantityFinder, '2.5');
      await tester.pumpAndSettle();

      // Tap Record Sale
      await tester.tap(find.text('Record Sale'));
      await tester.pumpAndSettle();

      // Repository updated
      expect(mockRepo.lastRecordedSale, isNotNull);
      expect(mockRepo.lastRecordedSale!.quantity, 2.5);
      expect(mockRepo.lastRecordedSale!.totalAmount, 525.0);

      // Sheet dismissed, snackbar shown
      expect(find.text('Sale recorded successfully'), findsOneWidget);
      expect(find.text('Undo'), findsOneWidget);

      // Tap Undo
      await tester.tap(find.text('Undo'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      expect(mockRepo.deleteCalled, isTrue);
      expect(find.text('Sale undone'), findsOneWidget);

      AppSnackBar.dismiss();
      await tester.pump();
    });
  });

  group('QuickSaleSheet — Urdu Localization (RTL)', () {
    tearDown(() {
      AppSnackBar.dismiss();
    });

    testWidgets('renders all labels in Urdu with RTL layout', (tester) async {
      await tester.pumpWidget(buildSheetHarness(locale: const Locale('ur')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Quick Sale'));
      await tester.pumpAndSettle();

      expect(find.text('فوری کاؤنٹر فروخت'), findsOneWidget);
      expect(find.textContaining('پروڈکٹ / دودھ کی قسم', findRichText: true), findsOneWidget);
      expect(find.textContaining('مقدار (لیٹر)', findRichText: true), findsOneWidget);
      expect(find.textContaining('فی لیٹر ریٹ', findRichText: true), findsOneWidget);
      expect(find.text('کل رقم'), findsOneWidget);
      expect(find.text('فروخت درج کریں'), findsOneWidget);
    });
  });
}
