import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/customer_provider.dart';
import 'providers/delivery_provider.dart';
import 'providers/payment_provider.dart';
import 'models/customer.dart';
import 'models/delivery.dart';
import 'models/payment.dart';

import 'screens/customers/widgets/unified_bill_receipt.dart';
import 'core/theme/app_colors.dart';

void main() {
  runApp(
    ProviderScope(
      overrides: [
        customerByIdProvider('preview_cust_1').overrideWith((ref) => Customer(
          id: 'preview_cust_1',
          name: 'Preview Customer',
          phone: '03001234567',
          address: '123 Test Block, Town',
          area: 'Area A',
          agreedRate: 220,
          currentDue: 500,
          advanceBalance: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        )),
        customerDeliveryHistoryProvider('preview_cust_1').overrideWith((ref) => [
          Delivery(
            id: 'preview_del_1',
            customerId: 'preview_cust_1',
            date: DateTime.now().subtract(const Duration(days: 2)),
            shift: 'morning',
            productName: 'Fresh Buffalo Milk',
            rate: 220,
            scheduledQuantity: 4.0,
            deliveredQuantity: 4.0,
            sequenceNumber: 1,
            totalAmount: 880,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          )
        ]),
        paymentListByCustomerProvider('preview_cust_1').overrideWith((ref) => [
          Payment(
            id: 'preview_pay_1',
            customerId: 'preview_cust_1',
            amount: 880,
            date: DateTime.now().subtract(const Duration(days: 1)),
            method: 'cash',
            type: 'cash_payment',
            runningBalance: 0.0,
            receiptNumber: 'REC-5555',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          )
        ]),
      ],
      child: const ReceiptPreviewApp(),
    ),
  );
}

class ReceiptPreviewApp extends StatefulWidget {
  const ReceiptPreviewApp({super.key});

  @override
  State<ReceiptPreviewApp> createState() => _ReceiptPreviewAppState();
}

class _ReceiptPreviewAppState extends State<ReceiptPreviewApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: AppColors.scaffold,
        appBar: AppBar(
          title: const Text('Receipt Previews'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 32.0),
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: UnifiedBillReceipt(
                      customerId: 'preview_cust_1',
                      startDate: DateTime.now().subtract(const Duration(days: 7)),
                      endDate: DateTime.now().add(const Duration(days: 1)),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
