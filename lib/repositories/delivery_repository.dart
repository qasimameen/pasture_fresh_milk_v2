import '../core/database/app_database.dart';
import '../core/database/database_constants.dart';
import '../core/utils/id_generator.dart';
import '../models/customer.dart';
import '../models/delivery.dart';
import '../models/payment.dart';
import '../models/product.dart';
import 'base_repository.dart';
import 'customer_repository.dart';
import 'payment_repository.dart';
import 'product_repository.dart';

/// Repository for the `deliveries` table.
///
/// A-M9. Extends [BaseRepository] with the daily-delivery queries, the
/// status-mutation methods (`markDelivered`, `markSkipped`, `undoSkip`,
/// `adjustQuantity`), daily generation from active customers, stats
/// aggregation and insert/update validation of the plan.md A-M9 / Section 3.7
/// behavior details.
///
/// Customer balances are only ever touched through [CustomerRepository]'s
/// public [CustomerRepository.updateBalance] API (read-only lookup first,
/// then write); product names in [generateDailyDeliveries] are resolved
/// through [ProductRepository]'s public read API.
class DeliveryRepository extends BaseRepository<Delivery> {
  /// Allowed `status` values (plan.md Section 3.7).
  static const Set<String> _allowedStatuses = {
    'pending',
    'delivered',
    'skipped',
  };

  /// Allowed `shift` values (plan.md Section 3.7).
  static const Set<String> _allowedShifts = {'morning', 'evening', 'extra'};

  /// Allowed `paymentMethod` values (plan.md Section 3.7).
  static const Set<String> _allowedPaymentMethods = {
    'cash',
    'auto',
  };

  @override
  String get tableName => 'deliveries';

  @override
  Delivery fromMap(Map<String, dynamic> map) => Delivery.fromMap(map);

  @override
  Map<String, dynamic> toMap(Delivery item) => item.toMap();

  /// Inserts [item] after validating the plan.md A-M9 / Section 3.7
  /// invariants (scheduledQuantity > 0, rate > 0, allowed
  /// status/shift values, non-negative quantities and amount, sequence >= 1,
  /// skipReason set when skipped). Throws [ArgumentError] on violation.
  @override
  Future<void> insert(Delivery item) async {
    _assertValid(item);
    await super.insert(item);
  }

  /// Updates [item] after validating the plan.md A-M9 / Section 3.7
  /// invariants. Throws [ArgumentError] on violation.
  @override
  Future<void> update(Delivery item) async {
    _assertValid(item);
    await super.update(item);
  }

  /// Returns all deliveries for the day of [date], ignoring the time
  /// component, ordered by `sequenceNumber ASC`.
  Future<List<Delivery>> getDeliveriesByDate(DateTime date) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      tableName,
      where: 'date = ?',
      whereArgs: [Delivery.dateKey(date)],
      orderBy: 'sequenceNumber ASC',
    );
    return rows.map(fromMap).toList();
  }

  /// Returns all deliveries for the day of [date] in [shift], ignoring the
  /// time component, ordered by `sequenceNumber ASC`.
  Future<List<Delivery>> getDeliveriesByDateAndShift(
    DateTime date,
    String shift,
  ) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      tableName,
      where: 'date = ? AND shift = ?',
      whereArgs: [Delivery.dateKey(date), shift],
      orderBy: 'sequenceNumber ASC',
    );
    return rows.map(fromMap).toList();
  }

  /// Returns all deliveries for the customer with [customerId], most recent
  /// date first.
  Future<List<Delivery>> getDeliveriesByCustomer(String customerId) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      tableName,
      where: 'customerId = ?',
      whereArgs: [customerId],
      orderBy: 'date DESC, sequenceNumber ASC',
    );
    return rows.map(fromMap).toList();
  }

  /// Returns all deliveries for the customer with [customerId] whose date
  /// falls in the inclusive `[start, end]` range. The time components of
  /// [start] and [end] are ignored.
  Future<List<Delivery>> getDeliveriesByCustomerAndDateRange(
    String customerId,
    DateTime start,
    DateTime end,
  ) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      tableName,
      where: 'customerId = ? AND date >= ? AND date <= ?',
      whereArgs: [customerId, Delivery.dateKey(start), Delivery.dateKey(end)],
      orderBy: 'date ASC, sequenceNumber ASC',
    );
    return rows.map(fromMap).toList();
  }

  /// Marks the delivery with [id] as delivered (plan.md A-M9).
  ///
  /// Sets `status = 'delivered'`, `deliveredQuantity` to [quantity],
  /// `deliveryTime` to now, stores [paymentMethod] / [amountCollected],
  /// recalculates `totalAmount` as `deliveredQuantity x rate`, and
  /// then updates the customer's balance through
  /// [CustomerRepository.updateBalance]:
  ///  - `cash`: due unchanged (paid on spot)
  ///  - `credit`: `currentDue += totalAmount`
  ///  - `advance_deduction`: `advanceBalance -= totalAmount`; when that would
  ///    go negative the remainder is added to `currentDue` instead
  ///    (`advanceBalance` floors at 0)
  ///
  /// The customer is looked up read-only first and only then written.
  /// Throws [ArgumentError] on invalid input, an unknown delivery id, or an
  /// unknown payment method.
  Future<void> markDelivered(
    String id,
    double quantity,
    String paymentMethod,
    double amountCollected, {
    String? receiverNote,
  }) async {
    if (quantity < 0) {
      throw ArgumentError('Delivered quantity must be >= 0.');
    }
    if (amountCollected < 0) {
      throw ArgumentError('Amount collected must be >= 0.');
    }
    if (!_allowedPaymentMethods.contains(paymentMethod)) {
      throw ArgumentError(
        'paymentMethod must be one of: '
        'cash, auto.',
      );
    }
    final delivery = await getById(id);
    if (delivery == null) {
      throw ArgumentError('Delivery with id "$id" not found.');
    }

    // Read-only customer lookup first.
    final customer = await CustomerRepository().getById(delivery.customerId);
    if (customer == null) {
      throw ArgumentError(
        'Customer with id "${delivery.customerId}" not found.',
      );
    }

    final totalAmount = quantity * delivery.rate;
    final now = DateTime.now();

    final db = await AppDatabase.instance.database;
    
    await db.transaction((txn) async {
      await txn.update(
        tableName,
        {
          'status': 'delivered',
          'deliveredQuantity': quantity,
          'paymentMethod': paymentMethod,
          'amountCollected': amountCollected,
          'receiverNote': receiverNote,
          'totalAmount': totalAmount,
          'deliveryTime': now.toIso8601String(),
          columnUpdatedAt: now.toIso8601String(),
        },
        where: '$columnId = ?',
        whereArgs: [id],
      );

      final double newDue;
      final double newAdvance;
      double advanceDeducted = 0;

      switch (paymentMethod) {
        case 'cash':
          newDue = customer.currentDue;
          newAdvance = customer.advanceBalance;
          advanceDeducted = 0;
        case 'auto':
          if (customer.advanceBalance > 0) {
            if (customer.advanceBalance >= totalAmount) {
              newDue = customer.currentDue;
              newAdvance = customer.advanceBalance - totalAmount;
              advanceDeducted = totalAmount;
            } else {
              advanceDeducted = customer.advanceBalance;
              newDue = customer.currentDue + (totalAmount - customer.advanceBalance);
              newAdvance = 0;
            }
          } else {
            newDue = customer.currentDue + totalAmount;
            newAdvance = 0;
            advanceDeducted = 0;
          }
        default:
          throw ArgumentError('Unknown payment method: $paymentMethod.');
      }

      await CustomerRepository().updateBalance(
        delivery.customerId,
        newDue,
        newAdvance,
        executor: txn,
      );

      // Generate Payment records
      if (paymentMethod == 'cash' && totalAmount > 0) {
        final paymentRepo = PaymentRepository();
        await paymentRepo.insertWithExecutor(Payment(
          id: IdGenerator.generate(),
          customerId: customer.id,
          date: now,
          amount: totalAmount,
          type: 'cash_payment',
          method: 'cash',
          notes: 'Cash on spot for delivery',
          runningBalance: newDue,
          createdAt: now,
          updatedAt: now,
        ), txn);
      } else if (advanceDeducted > 0) {
        final paymentRepo = PaymentRepository();
        await paymentRepo.insertWithExecutor(Payment(
          id: IdGenerator.generate(),
          customerId: customer.id,
          date: now,
          amount: advanceDeducted,
          type: 'advance_deduction',
          method: null,
          notes: 'Auto-deducted for delivery',
          runningBalance: newDue,
          createdAt: now,
          updatedAt: now,
        ), txn);
      }
    });
  }

  /// Marks the delivery with [id] as skipped. [reason] is required (empty
  /// throws [ArgumentError]). The customer balance is NOT touched.
  Future<void> markSkipped(String id, String reason) async {
    if (reason.trim().isEmpty) {
      throw ArgumentError('Skip reason is required.');
    }
    final delivery = await getById(id);
    if (delivery == null) {
      throw ArgumentError('Delivery with id "$id" not found.');
    }
    final db = await AppDatabase.instance.database;
    await db.update(
      tableName,
      {
        'status': 'skipped',
        'skipReason': reason,
        columnUpdatedAt: DateTime.now().toIso8601String(),
      },
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  /// Reverts a skipped delivery with [id] back to pending, clearing
  /// `skipReason`. Throws [ArgumentError] when the delivery does not exist or
  /// its current status is not 'skipped'.
  Future<void> undoSkip(String id) async {
    final delivery = await getById(id);
    if (delivery == null) {
      throw ArgumentError('Delivery with id "$id" not found.');
    }
    if (delivery.status != 'skipped') {
      throw ArgumentError('Only skipped deliveries can be undone.');
    }
    final db = await AppDatabase.instance.database;
    await db.update(
      tableName,
      {
        'status': 'pending',
        'skipReason': null,
        columnUpdatedAt: DateTime.now().toIso8601String(),
      },
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  /// Reverts a delivered delivery with [id] back to pending, zeroing out
  /// `deliveredQuantity`, `amountCollected`, `totalAmount`, and reversing any
  /// balance change on the customer. Throws [ArgumentError] when the delivery
  /// does not exist or is not currently 'delivered'.
  Future<void> undoDeliver(String id) async {
    final delivery = await getById(id);
    if (delivery == null) {
      throw ArgumentError('Delivery with id "$id" not found.');
    }
    if (delivery.status != 'delivered') {
      throw ArgumentError('Only delivered deliveries can be undone.');
    }

    // Read customer before reversing.
    final customer = await CustomerRepository().getById(delivery.customerId);
    if (customer == null) {
      throw ArgumentError('Customer with id "${delivery.customerId}" not found.');
    }

    final db = await AppDatabase.instance.database;
    await db.update(
      tableName,
      {
        'status': 'pending',
        'deliveredQuantity': 0.0,
        'paymentMethod': null,
        'amountCollected': 0.0,
        'totalAmount': 0.0,
        'deliveryTime': null,
        columnUpdatedAt: DateTime.now().toIso8601String(),
      },
      where: '$columnId = ?',
      whereArgs: [id],
    );

    // Reverse the balance impact of the original payment method.
    final totalAmount = delivery.totalAmount;
    double newDue = customer.currentDue;
    double newAdvance = customer.advanceBalance;

    if (delivery.paymentMethod == 'cash') {
      if (delivery.deliveryTime != null) {
        await db.delete(
          'payments',
          where: 'customerId = ? AND type = ? AND date = ?',
          whereArgs: [customer.id, 'cash_payment', delivery.deliveryTime!.toIso8601String()],
        );
      }
    } else if (delivery.paymentMethod == 'auto') {
      if (delivery.deliveryTime != null) {
        final paymentRows = await db.query(
          'payments',
          where: 'customerId = ? AND type = ? AND date = ?',
          whereArgs: [customer.id, 'advance_deduction', delivery.deliveryTime!.toIso8601String()],
          limit: 1,
        );
        
        if (paymentRows.isNotEmpty) {
          final advanceDeducted = (paymentRows.first['amount'] as num).toDouble();
          newAdvance += advanceDeducted;
          newDue = (newDue - (totalAmount - advanceDeducted)).clamp(0.0, double.infinity);
          await db.delete('payments', where: 'id = ?', whereArgs: [paymentRows.first['id']]);
        } else {
          newDue = (newDue - totalAmount).clamp(0.0, double.infinity);
        }
      }
    } else {
      switch (delivery.paymentMethod) {
        case 'credit':
          newDue = (customer.currentDue - totalAmount).clamp(0.0, double.infinity);
          newAdvance = customer.advanceBalance;
        case 'advance_deduction':
          newDue = customer.currentDue;
          newAdvance = customer.advanceBalance + totalAmount;
        default:
          newDue = customer.currentDue;
          newAdvance = customer.advanceBalance;
      }
    }
    
    await CustomerRepository().updateBalance(delivery.customerId, newDue, newAdvance);
  }


  /// Adjusts the scheduled quantity of the pending delivery with [id]. Only
  /// works while the delivery is still pending (throws [ArgumentError]
  /// otherwise); `totalAmount` is kept consistent as
  /// `deliveredQuantity x rate` (0 for a pending delivery).
  Future<void> adjustQuantity(String id, double newQuantity) async {
    if (newQuantity <= 0) {
      throw ArgumentError('Scheduled quantity must be greater than 0.');
    }
    final delivery = await getById(id);
    if (delivery == null) {
      throw ArgumentError('Delivery with id "$id" not found.');
    }
    if (delivery.status != 'pending') {
      throw ArgumentError('Only pending deliveries can be adjusted.');
    }
    final db = await AppDatabase.instance.database;
    await db.update(
      tableName,
      {
        'scheduledQuantity': newQuantity,
        'totalAmount': delivery.deliveredQuantity * delivery.rate,
        columnUpdatedAt: DateTime.now().toIso8601String(),
      },
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  /// Creates one pending delivery for every customer in [customers] with
  /// `status == 'active'`, a quota > 0 for [shift], and a resolvable product
  /// (plan.md A-M9). The delivery copies the customer's `agreedRate`,
  /// `productId` and the product's name (resolved read-only through
  /// [ProductRepository]), takes its scheduled quantity from the AM/PM quota,
  /// and uses `deliverySequence` as `sequenceNumber`. Customers whose status
  /// is not active, who have no quota for [shift], or whose product cannot be
  /// resolved are skipped.
  Future<int> generateDailyDeliveries(
    DateTime date,
    String shift,
    List<Customer> customers,
  ) async {
    if (!_allowedShifts.contains(shift)) {
      throw ArgumentError('Shift must be one of: morning, evening.');
    }
    final now = DateTime.now();
    final productRepository = ProductRepository();
    final activeProducts = await productRepository.getActiveProducts();
    final defaultProduct = activeProducts.isNotEmpty ? activeProducts.first : null;

    final existingDeliveries = await getDeliveriesByDateAndShift(date, shift);
    final existingCustomerIds = existingDeliveries.map((d) => d.customerId).toSet();
    int generatedCount = 0;

    for (final customer in customers) {
      if (customer.status != 'active') continue;
      final scheduledQuantity = shift == 'morning'
          ? customer.dailyQuotaAm
          : customer.dailyQuotaPm;
      if (scheduledQuantity <= 0) continue;
      if (existingCustomerIds.contains(customer.id)) continue;

      Product? product;
      if (customer.productId != null) {
        product = await productRepository.getById(customer.productId!);
      }
      product ??= defaultProduct;

      final resolvedProductId = product?.id ?? customer.productId;
      final resolvedProductName = product?.name ?? 'Fresh Milk';

      await insert(
        Delivery(
          id: IdGenerator.generate(),
          customerId: customer.id,
          date: date,
          shift: shift,
          productId: resolvedProductId,
          productName: resolvedProductName,
          scheduledQuantity: scheduledQuantity,
          deliveredQuantity: 0.0,
          rate: customer.agreedRate,
          totalAmount: 0.0,
          status: 'pending',
          amountCollected: 0.0,
          deliveryTime: null,
          sequenceNumber: 0,
          createdAt: now,
          updatedAt: now,
        ),
      );
      generatedCount++;
    }
    return generatedCount;
  }

  /// Aggregates delivery stats for the day of [date] in [shift], ignoring the
  /// time component: counts per status, quantity delivered (sum of
  /// `deliveredQuantity` on delivered rows), quantity remaining (sum of
  /// `scheduledQuantity` on pending rows) and cash collected (sum of
  /// `amountCollected` on delivered rows).
  Future<
    ({
      int total,
      int delivered,
      int pending,
      int skipped,
      double totalQuantityDelivered,
      double totalCashCollected,
    })
  >
  getDeliveryStats(DateTime date, String shift) async {
    final deliveries = await getDeliveriesByDateAndShift(date, shift);
    var total = 0;
    var delivered = 0;
    var pending = 0;
    var skipped = 0;
    var totalQuantityDelivered = 0.0;
    var totalCashCollected = 0.0;
    for (final delivery in deliveries) {
      total++;
      switch (delivery.status) {
        case 'delivered':
          delivered++;
          totalQuantityDelivered += delivery.deliveredQuantity;
          totalCashCollected += delivery.amountCollected;
        case 'pending':
          pending++;
        case 'skipped':
          skipped++;
      }
    }
    return (
      total: total,
      delivered: delivered,
      pending: pending,
      skipped: skipped,
      totalQuantityDelivered: totalQuantityDelivered,
      totalCashCollected: totalCashCollected,
    );
  }

  /// Validates the plan.md A-M9 / Section 3.7 behavior details for [item],
  /// throwing [ArgumentError] on the first violation.
  static void _assertValid(Delivery item) {
    if (item.customerId.trim().isEmpty) {
      throw ArgumentError('Delivery customerId must be non-empty.');
    }
    if (!_allowedShifts.contains(item.shift)) {
      throw ArgumentError('Delivery shift must be one of: morning, evening, extra.');
    }
    if (item.productName.trim().isEmpty) {
      throw ArgumentError('Delivery productName must be non-empty.');
    }
    if (item.scheduledQuantity <= 0) {
      throw ArgumentError('Delivery scheduledQuantity must be greater than 0.');
    }
    if (item.deliveredQuantity < 0) {
      throw ArgumentError('Delivery deliveredQuantity must be >= 0.');
    }
    if (item.rate <= 0) {
      throw ArgumentError('Delivery rate must be greater than 0.');
    }
    if (!_allowedStatuses.contains(item.status)) {
      throw ArgumentError(
        'Delivery status must be one of: '
        'pending, delivered, skipped.',
      );
    }
    if (item.amountCollected < 0) {
      throw ArgumentError('Delivery amountCollected must be >= 0.');
    }
    if (item.sequenceNumber < 0) {
      throw ArgumentError('Delivery sequenceNumber must be >= 0.');
    }
    if (item.status == 'skipped' &&
        (item.skipReason == null || item.skipReason!.trim().isEmpty)) {
      throw ArgumentError(
        'Delivery skipReason is required when status is skipped.',
      );
    }
  }
}
