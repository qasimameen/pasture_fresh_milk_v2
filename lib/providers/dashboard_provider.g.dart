// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dashboardHash() => r'422a97776557722fe8f641483d0f23cbe77c9802';

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
/// ([activeShiftNameAt]), not the `shifts` table; `activeRouteName` is
/// intentionally always `''` (see its field docs); and no dashboard metric
/// consumes MilkCollection data, so that repository is deliberately not read.
///
/// Copied from [dashboard].
@ProviderFor(dashboard)
final dashboardProvider = FutureProvider<DashboardData>.internal(
  dashboard,
  name: r'dashboardProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$dashboardHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DashboardRef = FutureProviderRef<DashboardData>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
