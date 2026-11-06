import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pasture_fresh_milk/core/l10n/app_localizations.dart';
import 'package:pasture_fresh_milk/core/theme/app_theme.dart';
import 'package:pasture_fresh_milk/models/customer.dart';
import 'package:pasture_fresh_milk/models/delivery.dart';
import 'package:pasture_fresh_milk/providers/customer_provider.dart';
import 'package:pasture_fresh_milk/screens/deliveries/widgets/delivery_card.dart';
import 'package:pasture_fresh_milk/widgets/quantity_stepper.dart';
import 'package:pasture_fresh_milk/widgets/status_badge.dart';

void main() {
  final testDate = DateTime(2026, 9, 13);
  const testShift = 'morning';

  Delivery makeDelivery({
    String id = 'del_1',
    String customerId = 'cust_1',
    String productName = 'Fresh Cow Milk',
    double scheduledQuantity = 2.0,
    double deliveredQuantity = 0.0,
    double rate = 180.0,
    double totalAmount = 0.0,
    double amountCollected = 0.0,
    String status = 'pending',
    String? skipReason,
    int sequenceNumber = 1,
  }) {
    return Delivery(
      id: id,
      customerId: customerId,
      productId: 'prod_1',
      productName: productName,
      date: testDate,
      shift: testShift,
      scheduledQuantity: scheduledQuantity,
      deliveredQuantity: deliveredQuantity,
      rate: rate,
      totalAmount: totalAmount,
      amountCollected: amountCollected,
      status: status,
      skipReason: skipReason,
      sequenceNumber: sequenceNumber,
      createdAt: DateTime(2026, 9, 1),
      updatedAt: DateTime(2026, 9, 1),
    );
  }

  Widget createTestWidget({
    required Delivery delivery,
    Customer? customer,
    VoidCallback? onTap,
    Locale locale = const Locale('en'),
  }) {
    return ProviderScope(
      overrides: [
        if (customer != null)
          customerByIdProvider(delivery.customerId).overrideWith((ref) async => customer),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: DeliveryCard(
              delivery: delivery,
              selectedDate: testDate,
              shiftString: testShift,
              onTap: onTap,
            ),
          ),
        ),
      ),
    );
  }

  group('DeliveryCard (Milestone C-M11) — States & Layout', () {
    testWidgets('Pending state renders stepper, Deliver and Skip buttons, and sequence number', (tester) async {
      final delivery = makeDelivery(
        sequenceNumber: 3,
        scheduledQuantity: 2.5,
        rate: 180.0,
        status: 'pending',
      );

      await tester.pumpWidget(createTestWidget(delivery: delivery));
      await tester.pumpAndSettle();


      // Product and details
      expect(find.text('Fresh Cow Milk'), findsOneWidget);
      expect(find.text('2.5 Litre • Rs. 180'), findsOneWidget);

      // Pending badge
      expect(find.byType(StatusBadge), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);

      // QuantityStepper present
      expect(find.byType(QuantityStepper), findsOneWidget);
      expect(find.text('2.5'), findsOneWidget);

      // Deliver and Skip buttons
      expect(find.byKey(Key('deliver_btn_${delivery.id}')), findsOneWidget);
      expect(find.byKey(Key('skip_btn_${delivery.id}')), findsOneWidget);
    });

    testWidgets('Delivered state renders strikethrough name, delivered summary, and Undo action', (tester) async {
      final delivery = makeDelivery(
        sequenceNumber: 1,
        scheduledQuantity: 2.0,
        deliveredQuantity: 2.0,
        totalAmount: 360.0,
        status: 'delivered',
      );

      await tester.pumpWidget(createTestWidget(delivery: delivery));
      await tester.pumpAndSettle();
      
      expect(find.text('Delivered'), findsOneWidget);
      expect(find.text('2.0 Litre delivered  •  Rs. 360'), findsOneWidget);
      expect(find.text('Undo'), findsOneWidget);

      // Stepper and deliver/skip buttons should NOT be rendered
      expect(find.byType(QuantityStepper), findsNothing);
      expect(find.byKey(Key('deliver_btn_${delivery.id}')), findsNothing);
    });

    testWidgets('Skipped state renders skip reason and Undo action', (tester) async {
      final delivery = makeDelivery(
        sequenceNumber: 2,
        scheduledQuantity: 1.5,
        status: 'skipped',
        skipReason: 'Customer out of station',
      );

      await tester.pumpWidget(createTestWidget(delivery: delivery));
      await tester.pumpAndSettle();

      expect(find.text('Skipped'), findsOneWidget); // StatusBadge
      expect(find.text('Skipped: Customer out of station'), findsOneWidget);
      expect(find.text('Undo'), findsOneWidget);

      // Stepper should not be visible
      expect(find.byType(QuantityStepper), findsNothing);
    });

    testWidgets('Tapping card invokes onTap callback', (tester) async {
      var tapped = false;
      final delivery = makeDelivery();

      await tester.pumpWidget(createTestWidget(
        delivery: delivery,
        onTap: () => tapped = true,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Fresh Cow Milk'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('Renders properly in Urdu locale with RTL', (tester) async {
      final delivery = makeDelivery(status: 'pending');

      await tester.pumpWidget(createTestWidget(
        delivery: delivery,
        locale: const Locale('ur'),
      ));
      await tester.pumpAndSettle();

      // Verify Urdu localized labels exist
      expect(find.text('Fresh Cow Milk'), findsOneWidget);
      expect(find.byType(StatusBadge), findsOneWidget);
    });

    testWidgets('Renders customer name and address when customer is loaded', (tester) async {
      final delivery = makeDelivery(customerId: 'cust_haji', status: 'pending');
      final customer = Customer(
        id: 'cust_haji',
        name: 'Haji Muhammad',
        phone: '0301-2345678',
        address: 'House 12, Street 4',
        area: 'Civil Lines',
        agreedRate: 180.0,
        createdAt: DateTime(2026, 9, 1),
        updatedAt: DateTime(2026, 9, 1),
      );

      await tester.pumpWidget(createTestWidget(
        delivery: delivery,
        customer: customer,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Haji Muhammad'), findsOneWidget);
      expect(find.text('House 12, Street 4, Civil Lines'), findsOneWidget);
      expect(find.text('Fresh Cow Milk'), findsOneWidget);
    });

    testWidgets('Renders customer name with strikethrough when delivered', (tester) async {
      final delivery = makeDelivery(
        customerId: 'cust_zubair',
        status: 'delivered',
        deliveredQuantity: 1.0,
        totalAmount: 180.0,
      );
      final customer = Customer(
        id: 'cust_zubair',
        name: 'Zubair Ansari',
        phone: '0302-3456789',
        address: 'Flat 4, Crescent Court',
        area: 'Civil Lines',
        agreedRate: 180.0,
        createdAt: DateTime(2026, 9, 1),
        updatedAt: DateTime(2026, 9, 1),
      );

      await tester.pumpWidget(createTestWidget(
        delivery: delivery,
        customer: customer,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Zubair Ansari'), findsOneWidget);
      expect(find.text('Flat 4, Crescent Court, Civil Lines'), findsOneWidget);
      final nameWidget = tester.widget<Text>(find.text('Zubair Ansari'));
      expect(nameWidget.style?.decoration, TextDecoration.lineThrough);
    });
  });
}
