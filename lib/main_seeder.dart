import 'package:flutter/material.dart';
import 'package:pasture_fresh_milk/core/database/app_database.dart';
import 'package:uuid/uuid.dart';
import 'package:pasture_fresh_milk/models/customer.dart';
import 'package:pasture_fresh_milk/models/delivery.dart';
import 'package:pasture_fresh_milk/models/payment.dart';

void main() {
  runApp(const MaterialApp(home: SeederApp()));
}

class SeederApp extends StatefulWidget {
  const SeederApp({super.key});

  @override
  State<SeederApp> createState() => _SeederAppState();
}

class _SeederAppState extends State<SeederApp> {
  String status = 'Tap to seed test data...';
  bool isSeeding = false;
  String queryResult = '';

  Future<void> seedData() async {
    if (isSeeding) return;
    setState(() {
      isSeeding = true;
      status = 'Initializing Database...';
      queryResult = '';
    });
    
    final db = await AppDatabase.instance.database;

    setState(() => status = 'Wiping tables...');
    await db.execute('PRAGMA foreign_keys = OFF');
    await db.execute('DELETE FROM deliveries');
    await db.execute('DELETE FROM payments');
    await db.execute('DELETE FROM customers');
    await db.execute('PRAGMA foreign_keys = ON');

    const uuid = Uuid();
    const pName = 'Fresh Buffalo Milk (4L)';
    const pRate = 150.0;
    
    void generateHistory(String cId, double targetPrevDues, double targetPrevAdv, List<Delivery> deliveries, List<Payment> payments) {
      final startDate = DateTime(2026, 5, 1);
      double accumulatedCharges = 0;
      double accumulatedPayments = 0;
      
      for (int i = 0; i < 120; i++) {
        final dDate = startDate.add(Duration(days: i));
        deliveries.add(Delivery(
          id: uuid.v4(), customerId: cId, date: dDate, productName: pName, scheduledQuantity: 4.0, deliveredQuantity: 4.0,
          rate: pRate, shift: 'morning', sequenceNumber: 1, totalAmount: 600.0, status: 'delivered', createdAt: DateTime.now(), updatedAt: DateTime.now(), syncStatus: 1,
        ));
        accumulatedCharges += 600.0;
        
        if (i % 7 == 6) {
          payments.add(Payment(
            id: uuid.v4(), customerId: cId, date: dDate, amount: 4200.0,
            type: 'cash_payment', runningBalance: 0.0,
            createdAt: DateTime.now(), updatedAt: DateTime.now(), syncStatus: 1,
          ));
          accumulatedPayments += 4200.0;
        }
      }
      
      double netBalance = accumulatedCharges - accumulatedPayments;
      double desiredNet = targetPrevDues - targetPrevAdv;
      double diff = netBalance - desiredNet;
      
      if (diff > 0) {
        payments.add(Payment(
          id: uuid.v4(), customerId: cId, date: DateTime(2026, 8, 30), amount: diff,
          type: 'cash_payment', runningBalance: 0.0,
          createdAt: DateTime.now(), updatedAt: DateTime.now(), syncStatus: 1,
        ));
      } else if (diff < 0) {
        deliveries.add(Delivery(
          id: uuid.v4(), customerId: cId, date: DateTime(2026, 8, 30), productName: pName, scheduledQuantity: (-diff)/pRate, deliveredQuantity: (-diff)/pRate,
          rate: pRate, shift: 'morning', sequenceNumber: 1, totalAmount: -diff, status: 'delivered', createdAt: DateTime.now(), updatedAt: DateTime.now(), syncStatus: 1,
        ));
      }
    }

    Future<void> seedScenario(
      String name, double prevDues, double prevAdv, double periodCharges, double periodPaid,
      {bool isNew = false, bool refund = false, bool activityAfter = false,
      bool boundaryDate = false, bool multiProduct = false, bool midPeriodRateChange = false, bool zeroQuantity = false}
    ) async {
      setState(() => status = 'Seeding $name...');
      final cId = uuid.v4();
      
      double initialBalance = prevDues - prevAdv;
      double actualPeriodPaid = refund ? -periodPaid : periodPaid;
      double netAmount = initialBalance + periodCharges - actualPeriodPaid;
      double finalDue = netAmount > 0 ? netAmount : 0;
      double finalAdv = netAmount < 0 ? -netAmount : 0;
      
      final c = Customer(
        id: cId, name: name, phone: '03000000000',
        address: name.contains('LONG') ? 'House No 45, Street 12, Phase 6, Defence Housing Authority, Near Main Boulevard, Lahore, Pakistan' : 'Test Address',
        dailyQuotaAm: 4.0, agreedRate: pRate,
        advanceBalance: finalAdv, 
        currentDue: finalDue,
        createdAt: DateTime.now(), updatedAt: DateTime.now(), syncStatus: 1,
      );
      
      final List<Delivery> deliveries = [];
      final List<Payment> payments = [];
      
      if (!isNew) {
        if (['1. NORMAL DUES', '2. NORMAL ADVANCE', '5. OVERPAYMENT', '9. BOUNDARY-DATE', '13. ACTIVITY AFTER'].contains(name)) {
          generateHistory(cId, prevDues, prevAdv, deliveries, payments);
        } else {
          if (prevDues > 0) {
            deliveries.add(Delivery(id: uuid.v4(), customerId: cId, date: DateTime(2026, 8, 15), productName: pName, scheduledQuantity: prevDues / pRate, deliveredQuantity: prevDues / pRate, rate: pRate, shift: 'morning', sequenceNumber: 1, totalAmount: prevDues, status: 'delivered', createdAt: DateTime.now(), updatedAt: DateTime.now(), syncStatus: 1));
          }
          if (prevAdv > 0) {
            payments.add(Payment(id: uuid.v4(), customerId: cId, date: DateTime(2026, 8, 20), amount: prevAdv, type: 'cash_payment', runningBalance: 0.0, createdAt: DateTime.now(), updatedAt: DateTime.now(), syncStatus: 1));
          }
        }
      }

      if (multiProduct) {
        deliveries.add(Delivery(id: uuid.v4(), customerId: cId, date: DateTime(2026, 9, 5), productName: 'Fresh Buffalo Milk (4L)', scheduledQuantity: 2.0, deliveredQuantity: 2.0, rate: 150.0, shift: 'morning', sequenceNumber: 1, totalAmount: 300.0, status: 'delivered', createdAt: DateTime.now(), updatedAt: DateTime.now(), syncStatus: 1));
        deliveries.add(Delivery(id: uuid.v4(), customerId: cId, date: DateTime(2026, 9, 5), productName: 'Yogurt', scheduledQuantity: 1.0, deliveredQuantity: 1.0, rate: 200.0, shift: 'morning', sequenceNumber: 2, totalAmount: 200.0, status: 'delivered', createdAt: DateTime.now(), updatedAt: DateTime.now(), syncStatus: 1));
      } else if (midPeriodRateChange) {
        deliveries.add(Delivery(id: uuid.v4(), customerId: cId, date: DateTime(2026, 9, 5), productName: pName, scheduledQuantity: 2.0, deliveredQuantity: 2.0, rate: 150.0, shift: 'morning', sequenceNumber: 1, totalAmount: 300.0, status: 'delivered', createdAt: DateTime.now(), updatedAt: DateTime.now(), syncStatus: 1));
        deliveries.add(Delivery(id: uuid.v4(), customerId: cId, date: DateTime(2026, 9, 15), productName: pName, scheduledQuantity: 2.0, deliveredQuantity: 2.0, rate: 160.0, shift: 'morning', sequenceNumber: 1, totalAmount: 320.0, status: 'delivered', createdAt: DateTime.now(), updatedAt: DateTime.now(), syncStatus: 1));
      } else if (zeroQuantity) {
        deliveries.add(Delivery(id: uuid.v4(), customerId: cId, date: DateTime(2026, 9, 5), productName: pName, scheduledQuantity: 4.0, deliveredQuantity: 0.0, rate: pRate, shift: 'morning', sequenceNumber: 1, totalAmount: 0.0, status: 'delivered', createdAt: DateTime.now(), updatedAt: DateTime.now(), syncStatus: 1));
      } else if (boundaryDate) {
        deliveries.add(Delivery(id: uuid.v4(), customerId: cId, date: DateTime(2026, 8, 31), productName: pName, scheduledQuantity: 1.0, deliveredQuantity: 1.0, rate: pRate, shift: 'morning', sequenceNumber: 1, totalAmount: 150.0, status: 'delivered', createdAt: DateTime.now(), updatedAt: DateTime.now(), syncStatus: 1));
        deliveries.add(Delivery(id: uuid.v4(), customerId: cId, date: DateTime(2026, 9, 1), productName: pName, scheduledQuantity: 1.0, deliveredQuantity: 1.0, rate: pRate, shift: 'morning', sequenceNumber: 1, totalAmount: 150.0, status: 'delivered', createdAt: DateTime.now(), updatedAt: DateTime.now(), syncStatus: 1));
        deliveries.add(Delivery(id: uuid.v4(), customerId: cId, date: DateTime(2026, 9, 30), productName: pName, scheduledQuantity: 1.0, deliveredQuantity: 1.0, rate: pRate, shift: 'morning', sequenceNumber: 1, totalAmount: 150.0, status: 'delivered', createdAt: DateTime.now(), updatedAt: DateTime.now(), syncStatus: 1));
      } else if (name == '12. HIGH VOLUME') {
        for (int i=1; i<=15; i++) {
          String prodName = pName;
          double rate = 150.0;
          if (i >= 6 && i <= 10) {
            rate = 160.0;
          } else if (i >= 11 && i <= 13) {
            prodName = 'Yogurt';
            rate = 200.0;
          } else if (i >= 14) {
            prodName = 'Butter';
            rate = 425.0;
          }
          deliveries.add(Delivery(id: uuid.v4(), customerId: cId, date: DateTime(2026, 9, i), productName: prodName, scheduledQuantity: 1.0, deliveredQuantity: 1.0, rate: rate, shift: 'morning', sequenceNumber: i, totalAmount: rate, status: 'delivered', createdAt: DateTime.now(), updatedAt: DateTime.now(), syncStatus: 1));
        }
      } else {
        if (periodCharges > 0) {
          deliveries.add(Delivery(id: uuid.v4(), customerId: cId, date: DateTime(2026, 9, 5), productName: pName, scheduledQuantity: periodCharges / pRate, deliveredQuantity: periodCharges / pRate, rate: pRate, shift: 'morning', sequenceNumber: 1, totalAmount: periodCharges, status: 'delivered', createdAt: DateTime.now(), updatedAt: DateTime.now(), syncStatus: 1));
        }
      }

      if (periodPaid > 0) {
        payments.add(Payment(id: uuid.v4(), customerId: cId, date: DateTime(2026, 9, 10), amount: periodPaid, type: refund ? 'advance_deduction' : 'cash_payment', runningBalance: 0.0, createdAt: DateTime.now(), updatedAt: DateTime.now(), syncStatus: 1));
      }
      
      if (activityAfter) {
        deliveries.add(Delivery(id: uuid.v4(), customerId: cId, date: DateTime(2026, 10, 5), productName: pName, scheduledQuantity: 4.0, deliveredQuantity: 4.0, rate: pRate, shift: 'morning', sequenceNumber: 1, totalAmount: 600.0, status: 'delivered', createdAt: DateTime.now(), updatedAt: DateTime.now(), syncStatus: 1));
      }

      await db.insert('customers', c.toMap());
      for (var d in deliveries) { await db.insert('deliveries', d.toMap()); }
      for (var p in payments) { await db.insert('payments', p.toMap()); }
    }

    await seedScenario('1. NORMAL DUES', 100, 0, 600, 500);
    await seedScenario('2. NORMAL ADVANCE', 0, 200, 500, 800);
    await seedScenario('3. EXACTLY SETTLED', 100, 0, 500, 600);
    await seedScenario('4. BRAND NEW CUSTOMER', 0, 0, 300, 0, isNew: true);
    await seedScenario('5. OVERPAYMENT', 200, 0, 400, 1000);
    await seedScenario('6. NET REFUND', 0, 0, 200, 100, refund: true);
    await seedScenario('7. MULTI-PRODUCT', 0, 0, 500, 0, multiProduct: true);
    await seedScenario('8. MID-PERIOD RATE CHANGE', 0, 0, 620, 0, midPeriodRateChange: true);
    await seedScenario('9. BOUNDARY-DATE', 100, 0, 300, 0, boundaryDate: true);
    await seedScenario('10. ZERO-QUANTITY DELIVERED', 0, 0, 0, 0, zeroQuantity: true);
    await seedScenario('11. LONG NAME/ADDRESS Muhammad Zubair Ansari Al-Hussaini Qureshi', 100, 0, 600, 500);
    await seedScenario('12. HIGH VOLUME', 0, 0, 3000, 0);
    await seedScenario('13. ACTIVITY AFTER endDate', 100, 0, 600, 500, activityAfter: true);
    
    // Verify Scenario 1 Math
    final results = await db.query('customers', where: 'name = ?', whereArgs: ['1. NORMAL DUES']);
    if (results.isNotEmpty) {
      final zubairId = results.first['id'] as String;
      
      final rawDCount = await db.rawQuery('SELECT COUNT(*) as count FROM deliveries WHERE customerId = ?', [zubairId]);
      final rawPCount = await db.rawQuery('SELECT COUNT(*) as count FROM payments WHERE customerId = ?', [zubairId]);
      
      final exactDCount = rawDCount.first['count'] as int;
      final exactPCount = rawPCount.first['count'] as int;

      final delivs = await db.query('deliveries', where: 'customerId = ?', whereArgs: [zubairId]);
      final payms = await db.query('payments', where: 'customerId = ?', whereArgs: [zubairId]);
      
      double totalD = 0;
      for (var d in delivs) {
        totalD += (d['totalAmount'] as num).toDouble();
      }
      double totalP = 0;
      for (var p in payms) {
        final amount = (p['amount'] as num).toDouble();
        final type = p['type'] as String;
        totalP += type == 'cash_payment' ? amount : -amount;
      }
      
      setState(() {
        queryResult = 'Scenario 1 Verification:\\n'
                      'DB Raw COUNT(*) Deliveries: $exactDCount (Expected: 121)\\n'
                      'DB Raw COUNT(*) Payments: $exactPCount (Expected: 18)\\n'
                      'Sum of all deliveries: $totalD\\n'
                      'Sum of all payments: $totalP\\n'
                      'Final balance should be ${totalD - totalP}';
        status = 'Success! Wiped & seeded 13 scenarios.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Database Seeder')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(status, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isSeeding || status.contains('Success') ? null : seedData,
              child: const Text('Seed Database'),
            ),
            const SizedBox(height: 40),
            if (queryResult.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.grey.shade200,
                  child: Text(queryResult, style: const TextStyle(fontFamily: 'monospace')),
                ),
              )
          ],
        ),
      ),
    );
  }
}




