import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../repositories/customer_repository.dart';
import '../repositories/delivery_repository.dart';
import '../repositories/local_sale_repository.dart';
import '../repositories/payment_repository.dart';

part 'dashboard_provider.g.dart';

/// Delivery-progress record for the currently active shift (plan.md A-M14).
///
/// `completed` is the number of deliveries marked delivered,
/// `remaining` the number still pending, `skipped` the number skipped and
/// `percent` the completed/total ratio as a percentage (0 when there are no
/// deliveries at all).
typedef DeliveryProgress = ({
  int total,
  int completed,
  int remaining,
  int skipped,
  double percent,
});

/// Immutable snapshot of every dashboard KPI (plan.md A-M14).
///
/// All values are derived from the current system date (`DateTime.now()`);
/// the provider holds no cache and computes everything on each request.
class DashboardData {
  const DashboardData({
    required this.totalCustomers,
    required this.activeCustomers,
    required this.totalDues,
    required this.overdueCount,
    required this.dailySellQuantity,
    required this.monthlySellQuantity,
    required this.monthlyGrowthPercent,
    required this.todayCash,
    required this.advanceHeld,
    required this.prepaidCount,
    required this.monthlyCollectionTotal,
    required this.monthlyTarget,
    required this.monthlyTargetPercent,
    required this.deliveryProgress,
    required this.morningProgress,
    required this.eveningProgress,
    required this.activeShiftName,
  });

  /// Total number of customers on record.
  final int totalCustomers;

  /// Customers whose `status` is "active".
  final int activeCustomers;

  /// Sum of all customers' `currentDue`.
  final double totalDues;

  /// Customers whose `currentDue > 0`.
  final int overdueCount;

  /// Today's total delivered quantity (morning + evening shifts).
  final double dailySellQuantity;

  /// Current calendar month's total delivered quantity.
  final double monthlySellQuantity;

  /// % change of [monthlySellQuantity] vs the previous month's delivered
  /// quantity; 0% when the previous month has no quantity.
  final double monthlyGrowthPercent;

  /// Sum of today's `cash_payment` amounts plus today's local-sale totals.
  final double todayCash;

  /// Sum of all customers' `advanceBalance`.
  final double advanceHeld;

  /// Customers whose `advanceBalance > 0`.
  final int prepaidCount;

  /// Current calendar month's total payments received (`cash_payment` type,
  /// as aggregated by [PaymentRepository]).
  final double monthlyCollectionTotal;

  /// Rolling month projection: (month-to-date delivered quantity ÷ days
  /// elapsed this month) × total days in the current month.
  final double monthlyTarget;

  /// `monthlySellQuantity / monthlyTarget x 100` (0% when the target is 0).
  final double monthlyTargetPercent;

  /// Today's delivery progress for the currently active shift.
  final DeliveryProgress deliveryProgress;
  
  /// Today's delivery progress for the Morning shift.
  final DeliveryProgress morningProgress;
  
  /// Today's delivery progress for the Evening shift.
  final DeliveryProgress eveningProgress;

  /// "Morning" before 14:00, "Evening" from 14:00 onward (time-based).
  final String activeShiftName;

  /// Returns a copy of this [DashboardData] with the given fields replaced.
  DashboardData copyWith({
    int? totalCustomers,
    int? activeCustomers,
    double? totalDues,
    int? overdueCount,
    double? dailySellQuantity,
    double? monthlySellQuantity,
    double? monthlyGrowthPercent,
    double? todayCash,
    double? advanceHeld,
    int? prepaidCount,
    double? monthlyCollectionTotal,
    double? monthlyTarget,
    double? monthlyTargetPercent,
    DeliveryProgress? deliveryProgress,
    DeliveryProgress? morningProgress,
    DeliveryProgress? eveningProgress,
    String? activeShiftName,
  }) {
    return DashboardData(
      totalCustomers: totalCustomers ?? this.totalCustomers,
      activeCustomers: activeCustomers ?? this.activeCustomers,
      totalDues: totalDues ?? this.totalDues,
      overdueCount: overdueCount ?? this.overdueCount,
      dailySellQuantity: dailySellQuantity ?? this.dailySellQuantity,
      monthlySellQuantity: monthlySellQuantity ?? this.monthlySellQuantity,
      monthlyGrowthPercent: monthlyGrowthPercent ?? this.monthlyGrowthPercent,
      todayCash: todayCash ?? this.todayCash,
      advanceHeld: advanceHeld ?? this.advanceHeld,
      prepaidCount: prepaidCount ?? this.prepaidCount,
      monthlyCollectionTotal:
          monthlyCollectionTotal ?? this.monthlyCollectionTotal,
      monthlyTarget: monthlyTarget ?? this.monthlyTarget,
      monthlyTargetPercent: monthlyTargetPercent ?? this.monthlyTargetPercent,
      deliveryProgress: deliveryProgress ?? this.deliveryProgress,
      morningProgress: morningProgress ?? this.morningProgress,
      eveningProgress: eveningProgress ?? this.eveningProgress,
      activeShiftName: activeShiftName ?? this.activeShiftName,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DashboardData &&
          runtimeType == other.runtimeType &&
          totalCustomers == other.totalCustomers &&
          activeCustomers == other.activeCustomers &&
          totalDues == other.totalDues &&
          overdueCount == other.overdueCount &&
          dailySellQuantity == other.dailySellQuantity &&
          monthlySellQuantity == other.monthlySellQuantity &&
          monthlyGrowthPercent == other.monthlyGrowthPercent &&
          todayCash == other.todayCash &&
          advanceHeld == other.advanceHeld &&
          prepaidCount == other.prepaidCount &&
          monthlyCollectionTotal == other.monthlyCollectionTotal &&
          monthlyTarget == other.monthlyTarget &&
          monthlyTargetPercent == other.monthlyTargetPercent &&
          deliveryProgress == other.deliveryProgress &&
          morningProgress == other.morningProgress &&
          eveningProgress == other.eveningProgress &&
          activeShiftName == other.activeShiftName;

  @override
  int get hashCode => Object.hashAll([
    totalCustomers,
    activeCustomers,
    totalDues,
    overdueCount,
    dailySellQuantity,
    monthlySellQuantity,
    monthlyGrowthPercent,
    todayCash,
    advanceHeld,
    prepaidCount,
    monthlyCollectionTotal,
    monthlyTarget,
    monthlyTargetPercent,
    deliveryProgress,
    morningProgress,
    eveningProgress,
    activeShiftName,
  ]);

  @override
  String toString() => 'DashboardData(totalCustomers: $totalCustomers, '
      'activeCustomers: $activeCustomers, totalDues: $totalDues, '
      'dailySellQuantity: $dailySellQuantity, todayCash: $todayCash, '
      'monthlyTarget: $monthlyTarget, activeShiftName: $activeShiftName)';
}

const _deliveryStatsZero = (
  total: 0,
  delivered: 0,
  pending: 0,
  skipped: 0,
  totalQuantityDelivered: 0.0,
  totalCashCollected: 0.0,
);

/// Determines the active shift from the wall clock (plan.md A-M14): before
/// 14:00 it is "Morning", at/after 14:00 it is "Evening".
///
/// Exposed as a pure function so callers (and tests) can verify both sides of
/// the 14:00 boundary without depending on the real system clock.
String activeShiftNameAt(DateTime time) => time.hour < 14 ? 'Morning' : 'Evening';

/// Completed/total ratio as a percentage for the delivery-progress section.
/// When [total] is 0 the result is 0% (never a division-by-zero error).
double deliveryProgressPercent(int completed, int total) =>
    total <= 0 ? 0.0 : (completed / total) * 100;

/// Month-over-month growth as a percentage (plan.md A-M14). When the
/// previous month had no quantity, growth is reported as 0% rather than
/// attempting division by zero.
double monthlyGrowthPercentOf(
  double currentMonthQuantity,
  double previousMonthQuantity,
) {
  if (previousMonthQuantity <= 0) return 0.0;
  return ((currentMonthQuantity - previousMonthQuantity) / previousMonthQuantity) *
      100;
}

/// Rolling month-target projection (resolved clarification for A-M14):
/// `(monthToDateQuantity / daysElapsedThisMonth) x daysInThisMonth` — the
/// month-to-date daily average scaled to the whole current month. Zero when
/// either input is non-positive (defensive; day-of-month is always >= 1).
double projectedMonthlyTarget({
  required double monthToDateQuantity,
  required int daysElapsedThisMonth,
  required int daysInThisMonth,
}) {
  if (daysElapsedThisMonth <= 0 || daysInThisMonth <= 0) return 0.0;
  return (monthToDateQuantity / daysElapsedThisMonth) * daysInThisMonth;
}

/// Monthly-target attainment as a percentage: `current / target x 100`.
/// When the target is 0 the result is 0% (no division-by-zero error).
double monthlyTargetPercentOf({
  required double monthToDateQuantity,
  required double monthlyTarget,
}) {
  if (monthlyTarget <= 0) return 0.0;
  return (monthToDateQuantity / monthlyTarget) * 100;
}

/// Runs [load] and returns its result, or null when that one logical
/// dashboard section fails. A-M14 requires graceful degradation: a failure in
/// one section (customer aggregates, delivery aggregates, payment/cash
/// aggregates, local-sale aggregates) must NOT prevent the whole provider
/// from resolving — the caller falls back to zero/empty values for just that
/// section and nothing is rethrown to the overall Future.
Future<T?> _safeLoad<T>(Future<T> Function() load) async {
  try {
    return await load();
  } catch (_) {
    return null;
  }
}

/// Sums the `deliveredQuantity` of every `delivered` delivery and all `local_sales`
/// dated inside [year]/[month], using only the public repositories.
Future<double> _totalSellQuantityInMonth(int year, int month) async {
  final daysInMonth = DateTime(year, month + 1, 0).day;
  final deliveryRepository = DeliveryRepository();
  final localSaleRepository = LocalSaleRepository();
  var total = 0.0;
  for (var day = 1; day <= daysInMonth; day++) {
    final date = DateTime(year, month, day);
    
    // Delivery quantity
    final deliveries = await deliveryRepository.getDeliveriesByDate(date);
    for (final delivery in deliveries) {
      if (delivery.status == 'delivered') {
        total += delivery.deliveredQuantity;
      }
    }
    
    // Local sale quantity
    final localTotals = await localSaleRepository.getTodayTotals(date);
    total += localTotals.totalQuantity;
  }
  return total;
}

/// Singleton provider that computes the dashboard KPIs by aggregating the
/// existing repositories (plan.md A-M14). Pure read-only — it never writes.
///
/// Every section is individually isolated (see [_safeLoad]): a failure in the
/// customer, delivery, payment/cash or local-sale aggregates yields zero/
/// empty values for just that section while the rest of the dashboard still
/// resolves (barring a truly unrecoverable error like an unavailable database
/// file).
///
/// Notes on the dependency list: `activeShiftName` derives from the clock
/// ([activeShiftNameAt]), not the `shifts` table; and no dashboard metric
/// consumes MilkCollection data, so that repository is deliberately not read.
@Riverpod(keepAlive: true)
Future<DashboardData> dashboard(Ref ref) async {
  final now = DateTime.now();
  final previousMonthNow = DateTime(now.year, now.month - 1);

  // ── Customer aggregates ─────────────────────────────────────────────────
  final customers = await _safeLoad(() => CustomerRepository().getAll());
  final customerList = customers ?? const [];
  final totalCustomers = customerList.length;
  final activeCustomers =
      customerList.where((c) => c.status == 'active').length;
  final totalDues = customerList.fold<double>(
    0.0,
    (sum, c) => sum + (c.currentDue < 0 ? 0 : c.currentDue),
  );
  final overdueCount = customerList.where((c) => c.currentDue > 0).length;
  final advanceHeld = customerList.fold<double>(
    0.0,
    (sum, c) => sum + (c.advanceBalance < 0 ? 0 : c.advanceBalance),
  );
  final prepaidCount = customerList.where((c) => c.advanceBalance > 0).length;

  // ── Shift detection ─────────────────────────────────────────────────────
  final shiftName = activeShiftNameAt(now);
  // Delivery rows store the shift as lowercase "morning"/"evening".
  final activeShiftKey = shiftName == 'Morning' ? 'morning' : 'evening';

  // ── Delivery aggregates ─────────────────────────────────────────────────
  final morningStats = await _safeLoad(
    () => DeliveryRepository().getDeliveryStats(now, 'morning'),
  );
  final eveningStats = await _safeLoad(
    () => DeliveryRepository().getDeliveryStats(now, 'evening'),
  );
  final extraStats = await _safeLoad(
    () => DeliveryRepository().getDeliveryStats(now, 'extra'),
  );
  final activeStats = activeShiftKey == 'morning'
      ? (morningStats ?? _deliveryStatsZero)
      : (eveningStats ?? _deliveryStatsZero);
  final deliveryProgress = (
    total: activeStats.total,
    completed: activeStats.delivered,
    remaining: activeStats.pending,
    skipped: activeStats.skipped,
    percent: deliveryProgressPercent(
      activeStats.delivered,
      activeStats.total,
    ),
  );
  
  final morningProgress = (
    total: (morningStats ?? _deliveryStatsZero).total,
    completed: (morningStats ?? _deliveryStatsZero).delivered,
    remaining: (morningStats ?? _deliveryStatsZero).pending,
    skipped: (morningStats ?? _deliveryStatsZero).skipped,
    percent: deliveryProgressPercent(
      (morningStats ?? _deliveryStatsZero).delivered,
      (morningStats ?? _deliveryStatsZero).total,
    ),
  );
  
  final eveningProgress = (
    total: (eveningStats ?? _deliveryStatsZero).total,
    completed: (eveningStats ?? _deliveryStatsZero).delivered,
    remaining: (eveningStats ?? _deliveryStatsZero).pending,
    skipped: (eveningStats ?? _deliveryStatsZero).skipped,
    percent: deliveryProgressPercent(
      (eveningStats ?? _deliveryStatsZero).delivered,
      (eveningStats ?? _deliveryStatsZero).total,
    ),
  );
  // ── Monthly quantity & growth (now combining deliveries & local sales) ─────
  final monthlySell = await _safeLoad(
    () => _totalSellQuantityInMonth(now.year, now.month),
  );
  final previousMonthQuantity = await _safeLoad(
    () => _totalSellQuantityInMonth(
      previousMonthNow.year,
      previousMonthNow.month,
    ),
  );
  final monthlySellQuantity = monthlySell ?? 0.0;
  final monthlyGrowthPercent = monthlyGrowthPercentOf(
    monthlySellQuantity,
    previousMonthQuantity ?? 0.0,
  );

  // ── Payment/collection aggregates ───────────────────────────────────────
  final cashToday =
      await _safeLoad(() => PaymentRepository().getTodayCashTotal(now));
  final monthlyCollections = await _safeLoad(
    () => PaymentRepository().getMonthlyCollectionTotal(now.year, now.month),
  );

  // ── Local-sale aggregates ───────────────────────────────────────────────
  final localSalesToday =
      await _safeLoad(() => LocalSaleRepository().getTodayTotals(now));
  final todayCash = (cashToday ?? 0.0) + (localSalesToday?.totalAmount ?? 0.0);

  final monthlyLocalSales = await _safeLoad(
    () => LocalSaleRepository().getMonthlyTotalAmount(now.year, now.month),
  );

  // Combine delivery and local sales for today's total sell quantity
  final dailySellQuantity = (morningStats?.totalQuantityDelivered ?? 0.0) +
      (eveningStats?.totalQuantityDelivered ?? 0.0) +
      (extraStats?.totalQuantityDelivered ?? 0.0) +
      (localSalesToday?.totalQuantity ?? 0.0);

  // ── Monthly-target maths ────────────────────────────────────────────────
  final projectedTarget = projectedMonthlyTarget(
    monthToDateQuantity: monthlySellQuantity,
    daysElapsedThisMonth: now.day,
    daysInThisMonth: DateTime(now.year, now.month + 1, 0).day,
  );
  final monthlyTargetPercent = monthlyTargetPercentOf(
    monthToDateQuantity: monthlySellQuantity,
    monthlyTarget: projectedTarget,
  );

  return DashboardData(
    totalCustomers: totalCustomers,
    activeCustomers: activeCustomers,
    totalDues: totalDues,
    overdueCount: overdueCount,
    dailySellQuantity: dailySellQuantity,
    monthlySellQuantity: monthlySellQuantity,
    monthlyGrowthPercent: monthlyGrowthPercent,
    todayCash: todayCash,
    advanceHeld: advanceHeld,
    prepaidCount: prepaidCount,
    monthlyCollectionTotal: (monthlyCollections ?? 0.0) + (monthlyLocalSales ?? 0.0),
    monthlyTarget: projectedTarget,
    monthlyTargetPercent: monthlyTargetPercent,
    deliveryProgress: deliveryProgress,
    morningProgress: morningProgress,
    eveningProgress: eveningProgress,
    activeShiftName: shiftName,
  );
}