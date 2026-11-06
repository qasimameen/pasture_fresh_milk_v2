import 'package:sqflite/sqflite.dart';

import '../core/database/app_database.dart';
import '../core/database/database_constants.dart';
import '../core/utils/id_generator.dart';
import '../models/customer.dart';
import '../models/payment.dart';
import 'base_repository.dart';
import 'customer_repository.dart';

/// Repository for the `payments` table.
///
/// A-M10. Extends [BaseRepository] with the payment queries, the
/// balance-modifying recording methods and insert/update validation of the
/// plan.md A-M10 / Section 3.8 behavior details.
///
/// Every balance-modifying method runs inside a single `db.transaction()`:
/// the Payment row(s) and the customer balance update are written through the
/// transaction handle (via [BaseRepository.insertWithExecutor] and
/// `CustomerRepository.updateBalance(executor:)`) so either both commit or
/// neither does.
class PaymentRepository extends BaseRepository<Payment> {
  /// Allowed `type` values (plan.md Section 3.8).
  static const Set<String> _allowedTypes = {
    'cash_payment',
    'advance_topup',
    'advance_deduction',
    'auto_settlement',
  };

  /// Allowed `method` values (plan.md Section 3.8). `auto_settlement` rows
  /// store a null method instead.
  static const Set<String> _allowedMethods = {'cash', 'raast', 'bank_transfer'};

  @override
  String get tableName => 'payments';

  @override
  Payment fromMap(Map<String, dynamic> map) => Payment.fromMap(map);

  @override
  Map<String, dynamic> toMap(Payment item) => item.toMap();

  /// Inserts [item] after validating the plan.md A-M10 / Section 3.8
  /// invariants.
  @override
  Future<void> insert(Payment item) async {
    _assertValid(item);
    await super.insert(item);
  }

  /// Updates [item] after validating the plan.md A-M10 / Section 3.8
  /// invariants.
  @override
  Future<void> update(Payment item) async {
    _assertValid(item);
    await super.update(item);
  }

  /// Returns every payment for the customer with [customerId], most recent
  /// first (plan.md A-M10: sorted by date DESC).
  Future<List<Payment>> getPaymentsByCustomer(String customerId) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      tableName,
      where: 'customerId = ?',
      whereArgs: [customerId],
      orderBy: 'date DESC',
    );
    return rows.map(fromMap).toList();
  }

  /// Returns every payment whose date falls within the day of [date],
  /// ignoring the time component of [date], in chronological order.
  Future<List<Payment>> getPaymentsByDate(DateTime date) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      tableName,
      where: 'date >= ? AND date < ?',
      whereArgs: [
        Payment.dateKey(date),
        Payment.dateKey(DateTime(date.year, date.month, date.day + 1)),
      ],
      orderBy: 'date ASC',
    );
    return rows.map(fromMap).toList();
  }

  /// Returns every payment whose date falls within the inclusive `[start, end]`
  /// day range. The time components of [start] and [end] are ignored (either
  /// day fully counts).
  Future<List<Payment>> getPaymentsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      tableName,
      where: 'date >= ? AND date < ?',
      whereArgs: [
        Payment.dateKey(start),
        Payment.dateKey(DateTime(end.year, end.month, end.day + 1)),
      ],
      orderBy: 'date ASC',
    );
    return rows.map(fromMap).toList();
  }

  /// Sums the `cash_payment` amounts recorded within the day of [date]
  /// (plan.md A-M10 "Today's Inflow"). The time component of [date] is
  /// ignored.
  Future<double> getTodayCashTotal(DateTime date) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) AS total '
      'FROM $tableName '
      'WHERE type IN (?, ?) AND date >= ? AND date < ?',
      [
        'cash_payment',
        'advance_topup',
        Payment.dateKey(date),
        Payment.dateKey(DateTime(date.year, date.month, date.day + 1)),
      ],
    );
    return (rows.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  /// Sums the `cash_payment` amounts recorded within [year]/[month].
  Future<double> getMonthlyCollectionTotal(int year, int month) async {
    final db = await AppDatabase.instance.database;
    final monthStart = DateTime(year, month);
    final nextMonthStart = DateTime(year, month + 1);
    final rows = await db.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) AS total '
      'FROM $tableName '
      'WHERE type IN (?, ?) AND date >= ? AND date < ?',
      [
        'cash_payment',
        'advance_topup',
        Payment.dateKey(monthStart),
        Payment.dateKey(nextMonthStart),
      ],
    );
    return (rows.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  /// Records a `cash_payment` for the customer with [customerId]
  /// (plan.md A-M10) atomically:
  ///
  ///  - inside a single `db.transaction()`, reads the customer's current
  ///    `currentDue` / `advanceBalance`,
  ///  - computes the reduction: `currentDue -= amount`; when that would go
  ///    below 0 the excess is added to `advanceBalance` and `currentDue` is
  ///    set to 0,
  ///  - inserts the Payment row (`runningBalance` = the resulting
  ///    `currentDue`), then
  ///  - writes the new balance through [CustomerRepository.updateBalance]
  ///    with the transaction handle.
  ///
  /// If either write throws, the whole transaction rolls back and the Payment
  /// row is not persisted. Throws [ArgumentError] on invalid input or when no
  /// customer with [customerId] exists.
  Future<void> recordCashPayment(
    String customerId,
    double amount,
    String method, {
    String? riderName,
    String? raastRef,
    String? receiptNumber,
    String? notes,
  }) async {
    if (amount <= 0) {
      throw ArgumentError('Payment amount must be greater than 0.');
    }
    if (!_allowedMethods.contains(method)) {
      throw ArgumentError(
        'Payment method must be one of: cash, raast, bank_transfer.',
      );
    }
    final db = await AppDatabase.instance.database;
    await db.transaction((txn) async {
      final customer = await _getCustomer(txn, customerId); // throws if absent
      var currentDue = customer.currentDue - amount;
      var advanceBalance = customer.advanceBalance;
      if (currentDue < 0) {
        advanceBalance += -currentDue;
        currentDue = 0;
      }
      final payment = _buildPayment(
        customerId: customerId,
        amount: amount,
        type: 'cash_payment',
        method: method,
        runningBalance: currentDue,
        riderName: riderName,
        raastRef: raastRef,
        receiptNumber: receiptNumber,
        notes: notes,
      );
      _assertValid(payment);
      await insertWithExecutor(payment, txn);
      await CustomerRepository().updateBalance(
        customerId,
        currentDue,
        advanceBalance,
        executor: txn,
      );
    });
  }

  /// Records an `advance_topup` for the customer with [customerId]
  /// (plan.md A-M10) atomically:
  ///
  ///  - inside a single `db.transaction()`, reads the customer's current
  ///    balances, adds [amount] to `advanceBalance` and inserts the
  ///    advance_topup Payment row,
  ///  - when the customer has `currentDue > 0`, reduces `currentDue` from the
  ///    (already increased) `advanceBalance` by as much as the advance covers
  ///    and inserts a second Payment row of type `auto_settlement`,
  ///  - writes the final balances through [CustomerRepository.updateBalance]
  ///    with the transaction handle.
  ///
  /// All of the above is one atomic unit. Throws [ArgumentError] on invalid
  /// input or when no customer with [customerId] exists.
  Future<void> recordAdvanceTopup(
    String customerId,
    double amount,
    String method, {
    String? raastRef,
    String? receiptNumber,
    String? notes,
  }) async {
    if (amount <= 0) {
      throw ArgumentError('Payment amount must be greater than 0.');
    }
    if (!_allowedMethods.contains(method)) {
      throw ArgumentError(
        'Payment method must be one of: cash, raast, bank_transfer.',
      );
    }
    final db = await AppDatabase.instance.database;
    await db.transaction((txn) async {
      final customer = await _getCustomer(txn, customerId); // throws if absent
      var advanceBalance = customer.advanceBalance + amount;
      var currentDue = customer.currentDue;

      final topup = _buildPayment(
        customerId: customerId,
        amount: amount,
        type: 'advance_topup',
        method: method,
        runningBalance: currentDue,
        raastRef: raastRef,
        receiptNumber: receiptNumber,
        notes: notes,
      );
      _assertValid(topup);
      await insertWithExecutor(topup, txn);

      if (currentDue > 0) {
        final settleAmount = currentDue < advanceBalance
            ? currentDue
            : advanceBalance;
        if (settleAmount > 0) {
          currentDue -= settleAmount;
          advanceBalance -= settleAmount;
          final settlement = _buildPayment(
            customerId: customerId,
            amount: settleAmount,
            type: 'auto_settlement',
            method: null,
            runningBalance: currentDue,
          );
          _assertValid(settlement);
          await insertWithExecutor(settlement, txn);
        }
      }

      await CustomerRepository().updateBalance(
        customerId,
        currentDue,
        advanceBalance,
        executor: txn,
      );
    });
  }

  /// Settles [dueAmount] of the customer with [customerId]'s dues from their
  /// advance (an `auto_settlement`, plan.md A-M10) atomically: reduces both
  /// `advanceBalance` and `currentDue` by [dueAmount] and inserts the
  /// auto_settlement Payment row inside one `db.transaction()`.
  ///
  /// Throws [ArgumentError] when [dueAmount] <= 0, when the customer's
  /// `advanceBalance` is less than [dueAmount], when [dueAmount] exceeds the
  /// customer's `currentDue` (would drive it negative), or when no customer
  /// with [customerId] exists.
  Future<void> autoSettleFromAdvance(
    String customerId,
    double dueAmount,
  ) async {
    if (dueAmount <= 0) {
      throw ArgumentError('Settle amount must be greater than 0.');
    }
    final db = await AppDatabase.instance.database;
    await db.transaction((txn) async {
      final customer = await _getCustomer(txn, customerId); // throws if absent
      if (customer.advanceBalance < dueAmount) {
        throw ArgumentError(
          'Customer advanceBalance must be >= settle amount to auto-settle.',
        );
      }
      if (customer.currentDue < dueAmount) {
        throw ArgumentError(
          'Customer currentDue must be >= settle amount to auto-settle.',
        );
      }
      final newDue = customer.currentDue - dueAmount;
      final newAdvance = customer.advanceBalance - dueAmount;
      final settlement = _buildPayment(
        customerId: customerId,
        amount: dueAmount,
        type: 'auto_settlement',
        method: null,
        runningBalance: newDue,
      );
      _assertValid(settlement);
      await insertWithExecutor(settlement, txn);
      await CustomerRepository().updateBalance(
        customerId,
        newDue,
        newAdvance,
        executor: txn,
      );
    });
  }

  /// Reads the customer with [id] through [txn] (inside a running
  /// transaction), throwing [ArgumentError] when no such customer exists.
  static Future<Customer> _getCustomer(DatabaseExecutor txn, String id) async {
    final rows = await txn.query(
      'customers',
      where: '$columnId = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) {
      throw ArgumentError('Customer with id "$id" not found.');
    }
    return Customer.fromMap(rows.first);
  }

  /// Builds a [Payment] row for [customerId] with an auto-generated
  /// `receiptNumber` ("REC-{timestamp_millis}", plan.md A-M10) when none is
  /// supplied.
  static Payment _buildPayment({
    required String customerId,
    required double amount,
    required String type,
    required String? method,
    required double runningBalance,
    String? receiptNumber,
    String? raastRef,
    String? notes,
    String? riderName,
  }) {
    final now = DateTime.now();
    return Payment(
      id: IdGenerator.generate(),
      customerId: customerId,
      date: now,
      amount: amount,
      type: type,
      method: method,
      receiptNumber: receiptNumber ?? 'REC-${now.millisecondsSinceEpoch}',
      raastRef: raastRef,
      notes: notes,
      runningBalance: runningBalance,
      riderName: riderName,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Validates the plan.md A-M10 / Section 3.8 behavior details for [item],
  /// throwing [ArgumentError] on the first violation.
  static void _assertValid(Payment item) {
    if (item.customerId.trim().isEmpty) {
      throw ArgumentError('Payment customerId must be non-empty.');
    }
    if (item.amount <= 0) {
      throw ArgumentError('Payment amount must be greater than 0.');
    }
    if (!_allowedTypes.contains(item.type)) {
      throw ArgumentError(
        'Payment type must be one of: '
        'cash_payment, advance_topup, advance_deduction, auto_settlement.',
      );
    }
    if (item.type == 'auto_settlement' || item.type == 'advance_deduction') {
      if (item.method != null) {
        throw ArgumentError(
          'Payment method must be null for ${item.type} records.',
        );
      }
    } else if (!_allowedMethods.contains(item.method)) {
      throw ArgumentError(
        'Payment method must be one of: cash, raast, bank_transfer.',
      );
    }
    if (item.runningBalance < 0) {
      throw ArgumentError('Payment runningBalance must be >= 0.');
    }
  }
}
