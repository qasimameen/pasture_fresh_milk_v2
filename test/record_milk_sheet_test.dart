import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pasture_fresh_milk/core/l10n/app_localizations.dart';
import 'package:pasture_fresh_milk/core/theme/app_theme.dart';
import 'package:pasture_fresh_milk/models/milk_collection.dart';
import 'package:pasture_fresh_milk/models/supplier.dart';
import 'package:pasture_fresh_milk/providers/milk_collection_provider.dart';
import 'package:pasture_fresh_milk/providers/supplier_provider.dart';
import 'package:pasture_fresh_milk/repositories/milk_collection_repository.dart';
import 'package:pasture_fresh_milk/screens/suppliers/widgets/record_milk_sheet.dart';
import 'package:pasture_fresh_milk/widgets/app_dropdown.dart';
import 'package:pasture_fresh_milk/widgets/app_snack_bar.dart';

class MockMilkCollectionRepository extends MilkCollectionRepository {
  MilkCollection? lastRecordedCollection;

  @override
  Future<void> recordCollection(MilkCollection collection) async {
    lastRecordedCollection = collection;
  }
}

void main() {
  final now = DateTime(2026, 9, 14, 8, 30);

  final mockSupplier1 = Supplier(
    id: 'supp_1',
    name: 'Al-Haseeb Dairy Farm',
    location: 'Chak 45-RB',
    milkType: 'Buffalo Pure',
    pendingKhata: 15400.0,
    createdAt: now,
    updatedAt: now,
  );

  final mockSupplier2 = Supplier(
    id: 'supp_2',
    name: 'Green Pastures Farm',
    location: 'Sargodha Road',
    milkType: 'Cow Pure',
    pendingKhata: 0.0,
    createdAt: now,
    updatedAt: now,
  );

  Widget buildHarness({
    Supplier? initialSupplier,
    DateTime? initialDate,
    String initialShift = 'morning',
    VoidCallback? onSuccess,
    MockMilkCollectionRepository? mockRepo,
    List<Supplier>? suppliers,
    Locale locale = const Locale('en'),
  }) {
    final repo = mockRepo ?? MockMilkCollectionRepository();
    final supplierList = suppliers ?? [mockSupplier1, mockSupplier2];

    return ProviderScope(
      overrides: [
        milkCollectionRepositoryProvider.overrideWithValue(repo),
        supplierListProvider.overrideWith((ref) async => supplierList),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                key: const Key('open_sheet_btn'),
                onPressed: () {
                  RecordMilkSheet.show(
                    context,
                    initialSupplier: initialSupplier,
                    initialDate: initialDate,
                    initialShift: initialShift,
                    onSuccess: onSuccess,
                  );
                },
                child: const Text('Open Sheet'),
              );
            },
          ),
        ),
      ),
    );
  }

  group('RecordMilkSheet Tests (C-M14)', () {
    testWidgets('renders all fields with pre-selected supplier', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        buildHarness(initialSupplier: mockSupplier1),
      );
      await tester.pumpAndSettle();

      // Open sheet
      await tester.tap(find.byKey(const Key('open_sheet_btn')));
      await tester.pumpAndSettle();

      // Check modal title
      expect(find.text('Record Inward Milk'), findsOneWidget);

      // Check supplier name in banner
      expect(find.text('Al-Haseeb Dairy Farm'), findsOneWidget);

      // Check shifts
      expect(find.text('Morning'), findsOneWidget);
      expect(find.text('Evening'), findsOneWidget);

      // Check input labels
      expect(find.text('QUANTITY (LITRES) *'), findsOneWidget);
      expect(find.text('RATE / LITRE (RS.) *'), findsOneWidget);
      expect(find.text('FAT % *'), findsOneWidget);
      expect(find.text('LR DENSITY (CLR) *'), findsOneWidget);

      // Check batch value display
      expect(find.text('CALCULATED BATCH VALUE'), findsOneWidget);
      expect(find.text('Rs. 0'), findsOneWidget);

      // Check save button
      expect(find.byKey(const Key('record_milk_submit_button')), findsOneWidget);
    });

    testWidgets('calculates live batch value as quantity and rate change', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        buildHarness(initialSupplier: mockSupplier1),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('open_sheet_btn')));
      await tester.pumpAndSettle();

      // Enter Quantity: 150
      final qtyInput = find.descendant(
        of: find.byKey(const Key('record_milk_quantity_field')),
        matching: find.byType(TextField),
      );
      await tester.enterText(qtyInput, '150');
      await tester.pump();

      // Still 0 since rate is empty
      expect(find.text('Rs. 0'), findsOneWidget);

      // Enter Rate: 220
      final rateInput = find.descendant(
        of: find.byKey(const Key('record_milk_rate_field')),
        matching: find.byType(TextField),
      );
      await tester.enterText(rateInput, '220');
      await tester.pump();

      // 150 x 220 = 33,000
      expect(find.text('Rs. 33000'), findsOneWidget);
    });

    testWidgets('validation prevents submit on empty fields', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final mockRepo = MockMilkCollectionRepository();

      await tester.pumpWidget(
        buildHarness(initialSupplier: mockSupplier1, mockRepo: mockRepo),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('open_sheet_btn')));
      await tester.pumpAndSettle();

      // Scroll and Tap Record Batch without entering data
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('record_milk_submit_button')), warnIfMissed: false);
      await tester.pumpAndSettle();

      // Repo should NOT have been called
      expect(mockRepo.lastRecordedCollection, isNull);

      // Error snackbar shown for quantity
      expect(find.text('Please enter a valid quantity greater than 0'), findsOneWidget);

      AppSnackBar.dismiss();
      await tester.pumpAndSettle();
    });

    testWidgets('records batch and invalidates providers successfully', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final mockRepo = MockMilkCollectionRepository();
      bool successCalled = false;

      await tester.pumpWidget(
        buildHarness(
          initialSupplier: mockSupplier1,
          mockRepo: mockRepo,
          onSuccess: () => successCalled = true,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('open_sheet_btn')));
      await tester.pumpAndSettle();

      // Qty
      await tester.enterText(
        find.descendant(
          of: find.byKey(const Key('record_milk_quantity_field')),
          matching: find.byType(TextField),
        ),
        '100',
      );
      // Rate
      await tester.enterText(
        find.descendant(
          of: find.byKey(const Key('record_milk_rate_field')),
          matching: find.byType(TextField),
        ),
        '200',
      );
      // FAT
      await tester.enterText(
        find.descendant(
          of: find.byKey(const Key('record_milk_fat_field')),
          matching: find.byType(TextField),
        ),
        '6.8',
      );
      // LR
      await tester.enterText(
        find.descendant(
          of: find.byKey(const Key('record_milk_lr_field')),
          matching: find.byType(TextField),
        ),
        '29.5',
      );
      // Notes
      await tester.enterText(
        find.descendant(
          of: find.byKey(const Key('record_milk_notes_field')),
          matching: find.byType(TextField),
        ),
        'Morning clean drop',
      );
      await tester.pumpAndSettle();

      // Scroll down and Submit
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('record_milk_submit_button')), warnIfMissed: false);
      await tester.pumpAndSettle();

      // Verify repo received the collection
      expect(mockRepo.lastRecordedCollection, isNotNull);
      final recorded = mockRepo.lastRecordedCollection!;
      expect(recorded.supplierId, equals('supp_1'));
      expect(recorded.quantity, equals(100.0));
      expect(recorded.rate, equals(200.0));

      expect(recorded.batchValue, equals(20000.0));
      expect(recorded.notes, equals('Morning clean drop'));
      expect(recorded.status, equals('recorded'));

      // Verify callback fired
      expect(successCalled, isTrue);

      // Verify sheet was dismissed
      expect(find.byType(RecordMilkSheet), findsNothing);

      AppSnackBar.dismiss();
      await tester.pumpAndSettle();
    });

    testWidgets('shows dropdown when initialSupplier is null and allows selection', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        buildHarness(initialSupplier: null),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('open_sheet_btn')));
      await tester.pumpAndSettle();

      // AppDropdown should be present
      expect(find.byType(AppDropdown<Supplier>), findsOneWidget);
      expect(find.text('Choose supplier farm'), findsOneWidget);

      // Open dropdown picker
      await tester.tap(find.byType(AppDropdown<Supplier>));
      await tester.pumpAndSettle();

      // Picker rows
      expect(find.text('Al-Haseeb Dairy Farm'), findsOneWidget);
      expect(find.text('Green Pastures Farm'), findsOneWidget);

      // Select Green Pastures Farm
      await tester.tap(find.text('Green Pastures Farm'));
      await tester.pumpAndSettle();

      // Should now be selected in closed dropdown
      expect(find.text('Green Pastures Farm'), findsOneWidget);
    });

    testWidgets('renders in Urdu RTL without issues', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        buildHarness(
          initialSupplier: mockSupplier1,
          locale: const Locale('ur'),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('open_sheet_btn')));
      await tester.pumpAndSettle();

      // Urdu title
      expect(find.text('دودھ کی آمد درج کریں'), findsOneWidget);
      expect(find.text('بیچ محفوظ کریں'), findsOneWidget);
    });
  });
}
