// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$paymentRepositoryHash() => r'9312542646c6a66f3f6b5442667514199f815aed';

/// Singleton [PaymentRepository] instance.
///
/// Copied from [paymentRepository].
@ProviderFor(paymentRepository)
final paymentRepositoryProvider = Provider<PaymentRepository>.internal(
  paymentRepository,
  name: r'paymentRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$paymentRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PaymentRepositoryRef = ProviderRef<PaymentRepository>;
String _$paymentListByCustomerHash() =>
    r'83cfd4ed584d0d9dc38d2f624ce0359d93da5933';

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

/// Fetches the payment history for the customer with [customerId].
///
/// Copied from [paymentListByCustomer].
@ProviderFor(paymentListByCustomer)
const paymentListByCustomerProvider = PaymentListByCustomerFamily();

/// Fetches the payment history for the customer with [customerId].
///
/// Copied from [paymentListByCustomer].
class PaymentListByCustomerFamily extends Family<AsyncValue<List<Payment>>> {
  /// Fetches the payment history for the customer with [customerId].
  ///
  /// Copied from [paymentListByCustomer].
  const PaymentListByCustomerFamily();

  /// Fetches the payment history for the customer with [customerId].
  ///
  /// Copied from [paymentListByCustomer].
  PaymentListByCustomerProvider call(String customerId) {
    return PaymentListByCustomerProvider(customerId);
  }

  @override
  PaymentListByCustomerProvider getProviderOverride(
    covariant PaymentListByCustomerProvider provider,
  ) {
    return call(provider.customerId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'paymentListByCustomerProvider';
}

/// Fetches the payment history for the customer with [customerId].
///
/// Copied from [paymentListByCustomer].
class PaymentListByCustomerProvider extends FutureProvider<List<Payment>> {
  /// Fetches the payment history for the customer with [customerId].
  ///
  /// Copied from [paymentListByCustomer].
  PaymentListByCustomerProvider(String customerId)
    : this._internal(
        (ref) =>
            paymentListByCustomer(ref as PaymentListByCustomerRef, customerId),
        from: paymentListByCustomerProvider,
        name: r'paymentListByCustomerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$paymentListByCustomerHash,
        dependencies: PaymentListByCustomerFamily._dependencies,
        allTransitiveDependencies:
            PaymentListByCustomerFamily._allTransitiveDependencies,
        customerId: customerId,
      );

  PaymentListByCustomerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.customerId,
  }) : super.internal();

  final String customerId;

  @override
  Override overrideWith(
    FutureOr<List<Payment>> Function(PaymentListByCustomerRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PaymentListByCustomerProvider._internal(
        (ref) => create(ref as PaymentListByCustomerRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        customerId: customerId,
      ),
    );
  }

  @override
  FutureProviderElement<List<Payment>> createElement() {
    return _PaymentListByCustomerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PaymentListByCustomerProvider &&
        other.customerId == customerId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, customerId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PaymentListByCustomerRef on FutureProviderRef<List<Payment>> {
  /// The parameter `customerId` of this provider.
  String get customerId;
}

class _PaymentListByCustomerProviderElement
    extends FutureProviderElement<List<Payment>>
    with PaymentListByCustomerRef {
  _PaymentListByCustomerProviderElement(super.provider);

  @override
  String get customerId => (origin as PaymentListByCustomerProvider).customerId;
}

String _$todayPaymentsHash() => r'67c6032f25dd340387142c3d2087cc8ccf58e0c3';

/// Fetches payments recorded within the day of [date].
///
/// Copied from [todayPayments].
@ProviderFor(todayPayments)
const todayPaymentsProvider = TodayPaymentsFamily();

/// Fetches payments recorded within the day of [date].
///
/// Copied from [todayPayments].
class TodayPaymentsFamily extends Family<AsyncValue<List<Payment>>> {
  /// Fetches payments recorded within the day of [date].
  ///
  /// Copied from [todayPayments].
  const TodayPaymentsFamily();

  /// Fetches payments recorded within the day of [date].
  ///
  /// Copied from [todayPayments].
  TodayPaymentsProvider call(DateTime date) {
    return TodayPaymentsProvider(date);
  }

  @override
  TodayPaymentsProvider getProviderOverride(
    covariant TodayPaymentsProvider provider,
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
  String? get name => r'todayPaymentsProvider';
}

/// Fetches payments recorded within the day of [date].
///
/// Copied from [todayPayments].
class TodayPaymentsProvider extends FutureProvider<List<Payment>> {
  /// Fetches payments recorded within the day of [date].
  ///
  /// Copied from [todayPayments].
  TodayPaymentsProvider(DateTime date)
    : this._internal(
        (ref) => todayPayments(ref as TodayPaymentsRef, date),
        from: todayPaymentsProvider,
        name: r'todayPaymentsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$todayPaymentsHash,
        dependencies: TodayPaymentsFamily._dependencies,
        allTransitiveDependencies:
            TodayPaymentsFamily._allTransitiveDependencies,
        date: date,
      );

  TodayPaymentsProvider._internal(
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
    FutureOr<List<Payment>> Function(TodayPaymentsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TodayPaymentsProvider._internal(
        (ref) => create(ref as TodayPaymentsRef),
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
  FutureProviderElement<List<Payment>> createElement() {
    return _TodayPaymentsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TodayPaymentsProvider && other.date == date;
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
mixin TodayPaymentsRef on FutureProviderRef<List<Payment>> {
  /// The parameter `date` of this provider.
  DateTime get date;
}

class _TodayPaymentsProviderElement extends FutureProviderElement<List<Payment>>
    with TodayPaymentsRef {
  _TodayPaymentsProviderElement(super.provider);

  @override
  DateTime get date => (origin as TodayPaymentsProvider).date;
}

String _$todayCashTotalHash() => r'5e63cf4fe4abae8b193017185e6cee46f04ccdc6';

/// Total cash collected today (sum of cash_payment amounts for the current
/// day).
///
/// Copied from [todayCashTotal].
@ProviderFor(todayCashTotal)
final todayCashTotalProvider = FutureProvider<double>.internal(
  todayCashTotal,
  name: r'todayCashTotalProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$todayCashTotalHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TodayCashTotalRef = FutureProviderRef<double>;
String _$monthlyCollectionHash() => r'316150ba5a170d96923db507314ba8eefa94d4a7';

/// Total cash collected within [year]/[month].
///
/// Copied from [monthlyCollection].
@ProviderFor(monthlyCollection)
const monthlyCollectionProvider = MonthlyCollectionFamily();

/// Total cash collected within [year]/[month].
///
/// Copied from [monthlyCollection].
class MonthlyCollectionFamily extends Family<AsyncValue<double>> {
  /// Total cash collected within [year]/[month].
  ///
  /// Copied from [monthlyCollection].
  const MonthlyCollectionFamily();

  /// Total cash collected within [year]/[month].
  ///
  /// Copied from [monthlyCollection].
  MonthlyCollectionProvider call(int year, int month) {
    return MonthlyCollectionProvider(year, month);
  }

  @override
  MonthlyCollectionProvider getProviderOverride(
    covariant MonthlyCollectionProvider provider,
  ) {
    return call(provider.year, provider.month);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'monthlyCollectionProvider';
}

/// Total cash collected within [year]/[month].
///
/// Copied from [monthlyCollection].
class MonthlyCollectionProvider extends FutureProvider<double> {
  /// Total cash collected within [year]/[month].
  ///
  /// Copied from [monthlyCollection].
  MonthlyCollectionProvider(int year, int month)
    : this._internal(
        (ref) => monthlyCollection(ref as MonthlyCollectionRef, year, month),
        from: monthlyCollectionProvider,
        name: r'monthlyCollectionProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$monthlyCollectionHash,
        dependencies: MonthlyCollectionFamily._dependencies,
        allTransitiveDependencies:
            MonthlyCollectionFamily._allTransitiveDependencies,
        year: year,
        month: month,
      );

  MonthlyCollectionProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.year,
    required this.month,
  }) : super.internal();

  final int year;
  final int month;

  @override
  Override overrideWith(
    FutureOr<double> Function(MonthlyCollectionRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MonthlyCollectionProvider._internal(
        (ref) => create(ref as MonthlyCollectionRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        year: year,
        month: month,
      ),
    );
  }

  @override
  FutureProviderElement<double> createElement() {
    return _MonthlyCollectionProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MonthlyCollectionProvider &&
        other.year == year &&
        other.month == month;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, year.hashCode);
    hash = _SystemHash.combine(hash, month.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MonthlyCollectionRef on FutureProviderRef<double> {
  /// The parameter `year` of this provider.
  int get year;

  /// The parameter `month` of this provider.
  int get month;
}

class _MonthlyCollectionProviderElement extends FutureProviderElement<double>
    with MonthlyCollectionRef {
  _MonthlyCollectionProviderElement(super.provider);

  @override
  int get year => (origin as MonthlyCollectionProvider).year;
  @override
  int get month => (origin as MonthlyCollectionProvider).month;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
