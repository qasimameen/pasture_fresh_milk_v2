// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_sale_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$localSaleRepositoryHash() =>
    r'17dd74a61cc964ea4fbab4b48bcdac0b1e085baf';

/// Singleton [LocalSaleRepository] instance.
///
/// Copied from [localSaleRepository].
@ProviderFor(localSaleRepository)
final localSaleRepositoryProvider = Provider<LocalSaleRepository>.internal(
  localSaleRepository,
  name: r'localSaleRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$localSaleRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LocalSaleRepositoryRef = ProviderRef<LocalSaleRepository>;
String _$todayLocalSalesHash() => r'0eec98c38cc4ab8d44d37c8e1ac2d5e7fea6b144';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Fetches the local sales recorded for the day of [date].
///
/// Copied from [todayLocalSales].
@ProviderFor(todayLocalSales)
const todayLocalSalesProvider = TodayLocalSalesFamily();

/// Fetches the local sales recorded for the day of [date].
///
/// Copied from [todayLocalSales].
class TodayLocalSalesFamily extends Family<AsyncValue<List<LocalSale>>> {
  /// Fetches the local sales recorded for the day of [date].
  ///
  /// Copied from [todayLocalSales].
  const TodayLocalSalesFamily();

  /// Fetches the local sales recorded for the day of [date].
  ///
  /// Copied from [todayLocalSales].
  TodayLocalSalesProvider call(DateTime date) {
    return TodayLocalSalesProvider(date);
  }

  @override
  TodayLocalSalesProvider getProviderOverride(
    covariant TodayLocalSalesProvider provider,
  ) {
    return call(provider.date);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'todayLocalSalesProvider';
}

/// Fetches the local sales recorded for the day of [date].
///
/// Copied from [todayLocalSales].
class TodayLocalSalesProvider extends FutureProvider<List<LocalSale>> {
  /// Fetches the local sales recorded for the day of [date].
  ///
  /// Copied from [todayLocalSales].
  TodayLocalSalesProvider(DateTime date)
    : this._internal(
        (ref) => todayLocalSales(ref as TodayLocalSalesRef, date),
        from: todayLocalSalesProvider,
        name: r'todayLocalSalesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$todayLocalSalesHash,
        dependencies: TodayLocalSalesFamily._dependencies,
        allTransitiveDependencies:
            TodayLocalSalesFamily._allTransitiveDependencies,
        date: date,
      );

  TodayLocalSalesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.date,
  }) : super.internal();

  final DateTime date;

  @override
  Override overrideWith(
    FutureOr<List<LocalSale>> Function(TodayLocalSalesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TodayLocalSalesProvider._internal(
        (ref) => create(ref as TodayLocalSalesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        date: date,
      ),
    );
  }

  @override
  FutureProviderElement<List<LocalSale>> createElement() {
    return _TodayLocalSalesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TodayLocalSalesProvider && other.date == date;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, date.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TodayLocalSalesRef on FutureProviderRef<List<LocalSale>> {
  /// The parameter `date` of this provider.
  DateTime get date;
}

class _TodayLocalSalesProviderElement
    extends FutureProviderElement<List<LocalSale>>
    with TodayLocalSalesRef {
  _TodayLocalSalesProviderElement(super.provider);

  @override
  DateTime get date => (origin as TodayLocalSalesProvider).date;
}

String _$todayLocalSaleTotalsHash() =>
    r'027234a5328a102df51e206f53a70027f553812c';

/// Daily local-sale totals for the day of [date]: total litres, total amount
/// and sale count (plan.md A-M13).
///
/// Copied from [todayLocalSaleTotals].
@ProviderFor(todayLocalSaleTotals)
const todayLocalSaleTotalsProvider = TodayLocalSaleTotalsFamily();

/// Daily local-sale totals for the day of [date]: total litres, total amount
/// and sale count (plan.md A-M13).
///
/// Copied from [todayLocalSaleTotals].
class TodayLocalSaleTotalsFamily
    extends
        Family<
          AsyncValue<
            ({double totalQuantity, double totalAmount, int saleCount})
          >
        > {
  /// Daily local-sale totals for the day of [date]: total litres, total amount
  /// and sale count (plan.md A-M13).
  ///
  /// Copied from [todayLocalSaleTotals].
  const TodayLocalSaleTotalsFamily();

  /// Daily local-sale totals for the day of [date]: total litres, total amount
  /// and sale count (plan.md A-M13).
  ///
  /// Copied from [todayLocalSaleTotals].
  TodayLocalSaleTotalsProvider call(DateTime date) {
    return TodayLocalSaleTotalsProvider(date);
  }

  @override
  TodayLocalSaleTotalsProvider getProviderOverride(
    covariant TodayLocalSaleTotalsProvider provider,
  ) {
    return call(provider.date);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'todayLocalSaleTotalsProvider';
}

/// Daily local-sale totals for the day of [date]: total litres, total amount
/// and sale count (plan.md A-M13).
///
/// Copied from [todayLocalSaleTotals].
class TodayLocalSaleTotalsProvider
    extends
        FutureProvider<
          ({double totalQuantity, double totalAmount, int saleCount})
        > {
  /// Daily local-sale totals for the day of [date]: total litres, total amount
  /// and sale count (plan.md A-M13).
  ///
  /// Copied from [todayLocalSaleTotals].
  TodayLocalSaleTotalsProvider(DateTime date)
    : this._internal(
        (ref) => todayLocalSaleTotals(ref as TodayLocalSaleTotalsRef, date),
        from: todayLocalSaleTotalsProvider,
        name: r'todayLocalSaleTotalsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$todayLocalSaleTotalsHash,
        dependencies: TodayLocalSaleTotalsFamily._dependencies,
        allTransitiveDependencies:
            TodayLocalSaleTotalsFamily._allTransitiveDependencies,
        date: date,
      );

  TodayLocalSaleTotalsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.date,
  }) : super.internal();

  final DateTime date;

  @override
  Override overrideWith(
    FutureOr<({double totalQuantity, double totalAmount, int saleCount})>
    Function(TodayLocalSaleTotalsRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TodayLocalSaleTotalsProvider._internal(
        (ref) => create(ref as TodayLocalSaleTotalsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        date: date,
      ),
    );
  }

  @override
  FutureProviderElement<
    ({double totalQuantity, double totalAmount, int saleCount})
  >
  createElement() {
    return _TodayLocalSaleTotalsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TodayLocalSaleTotalsProvider && other.date == date;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, date.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TodayLocalSaleTotalsRef
    on
        FutureProviderRef<
          ({double totalQuantity, double totalAmount, int saleCount})
        > {
  /// The parameter `date` of this provider.
  DateTime get date;
}

class _TodayLocalSaleTotalsProviderElement
    extends
        FutureProviderElement<
          ({double totalQuantity, double totalAmount, int saleCount})
        >
    with TodayLocalSaleTotalsRef {
  _TodayLocalSaleTotalsProviderElement(super.provider);

  @override
  DateTime get date => (origin as TodayLocalSaleTotalsProvider).date;
}

String _$lastLocalSaleHash() => r'c42c35b0d13e623fdfdf30b4e2c12877627a8718';

/// Fetches the most recently created local sale, or null when none exist.
///
/// Copied from [lastLocalSale].
@ProviderFor(lastLocalSale)
final lastLocalSaleProvider = FutureProvider<LocalSale?>.internal(
  lastLocalSale,
  name: r'lastLocalSaleProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$lastLocalSaleHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LastLocalSaleRef = FutureProviderRef<LocalSale?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
