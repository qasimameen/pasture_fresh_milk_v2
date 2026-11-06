import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pasture_fresh_milk/core/services/receipt_service.dart';
import 'package:pasture_fresh_milk/screens/customers/widgets/unified_bill_receipt.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('Test receipt capture', (tester) async {
    final service = ReceiptService();
    
    // We provide a basic MediaQuery size for the test environment
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: Scaffold(body: Text('Test')))));
    final context = tester.element(find.byType(Scaffold));

    // We must use runAsync because captureFromWidget uses real Timer/Future internally
    await tester.runAsync(() async {
      await service.generateAndShareReceipt(
        context,
        UnifiedBillReceipt(
          customerId: 'test_cust_1',
          startDate: DateTime.now().subtract(const Duration(days: 7)),
          endDate: DateTime.now().add(const Duration(days: 1)),
        ),
        fileName: 'unified_bill_receipt.png',
      );
    });
    
    expect(true, isTrue); // Just ensuring it didn't throw uncaught exceptions

    // Clean up
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  });
}
