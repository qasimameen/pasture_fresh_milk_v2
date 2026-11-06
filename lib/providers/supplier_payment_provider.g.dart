// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supplier_payment_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$supplierPaymentRepositoryHash() =>
    r'716c3eeebe142e1e2b533d1feaf66de169fdd368';

/// Singleton [SupplierPaymentRepository] instance.
///
/// Copied from [supplierPaymentRepository].
@ProviderFor(supplierPaymentRepository)
final supplierPaymentRepositoryProvider =
    Provider<SupplierPaymentRepository>.internal(
      supplierPaymentRepository,
      name: r'supplierPaymentRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$supplierPaymentRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SupplierPaymentRepositoryRef = ProviderRef<SupplierPaymentRepository>;
String _$supplierPaymentListHash() =>
    r'f0894e646e432808cf0f75829446e0d65c914e95';

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

/// Fetches the payment history (khata clearing) for the supplier with
/// [supplierId], sorted by date DESC.
///
/// Copied from [supplierPaymentList].
@ProviderFor(supplierPaymentList)
const supplierPaymentListProvider = SupplierPaymentListFamily();

/// Fetches the payment history (khata clearing) for the supplier with
/// [supplierId], sorted by date DESC.
///
/// Copied from [supplierPaymentList].
class SupplierPaymentListFamily
    extends Family<AsyncValue<List<SupplierPayment>>> {
  /// Fetches the payment history (khata clearing) for the supplier with
  /// [supplierId], sorted by date DESC.
  ///
  /// Copied from [supplierPaymentList].
  const SupplierPaymentListFamily();

  /// Fetches the payment history (khata clearing) for the supplier with
  /// [supplierId], sorted by date DESC.
  ///
  /// Copied from [supplierPaymentList].
  SupplierPaymentListProvider call(String supplierId) {
    return SupplierPaymentListProvider(supplierId);
  }

  @override
  SupplierPaymentListProvider getProviderOverride(
    covariant SupplierPaymentListProvider provider,
  ) {
    return call(provider.supplierId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'supplierPaymentListProvider';
}

/// Fetches the payment history (khata clearing) for the supplier with
/// [supplierId], sorted by date DESC.
///
/// Copied from [supplierPaymentList].
class SupplierPaymentListProvider
    extends FutureProvider<List<SupplierPayment>> {
  /// Fetches the payment history (khata clearing) for the supplier with
  /// [supplierId], sorted by date DESC.
  ///
  /// Copied from [supplierPaymentList].
  SupplierPaymentListProvider(String supplierId)
    : this._internal(
        (ref) => supplierPaymentList(ref as SupplierPaymentListRef, supplierId),
        from: supplierPaymentListProvider,
        name: r'supplierPaymentListProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$supplierPaymentListHash,
        dependencies: SupplierPaymentListFamily._dependencies,
        allTransitiveDependencies:
            SupplierPaymentListFamily._allTransitiveDependencies,
        supplierId: supplierId,
      );

  SupplierPaymentListProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.supplierId,
  }) : super.internal();

  final String supplierId;

  @override
  Override overrideWith(
    FutureOr<List<SupplierPayment>> Function(SupplierPaymentListRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SupplierPaymentListProvider._internal(
        (ref) => create(ref as SupplierPaymentListRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        supplierId: supplierId,
      ),
    );
  }

  @override
  FutureProviderElement<List<SupplierPayment>> createElement() {
    return _SupplierPaymentListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SupplierPaymentListProvider &&
        other.supplierId == supplierId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, supplierId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SupplierPaymentListRef on FutureProviderRef<List<SupplierPayment>> {
  /// The parameter `supplierId` of this provider.
  String get supplierId;
}

class _SupplierPaymentListProviderElement
    extends FutureProviderElement<List<SupplierPayment>>
    with SupplierPaymentListRef {
  _SupplierPaymentListProviderElement(super.provider);

  @override
  String get supplierId => (origin as SupplierPaymentListProvider).supplierId;
}

String _$todaySupplierPaymentsHash() =>
    r'5b55a3a0c887418c027cfc22c34e0a3182d86899';

/// Fetches the payments recorded within the day of [date].
///
/// Copied from [todaySupplierPayments].
@ProviderFor(todaySupplierPayments)
const todaySupplierPaymentsProvider = TodaySupplierPaymentsFamily();

/// Fetches the payments recorded within the day of [date].
///
/// Copied from [todaySupplierPayments].
class TodaySupplierPaymentsFamily
    extends Family<AsyncValue<List<SupplierPayment>>> {
  /// Fetches the payments recorded within the day of [date].
  ///
  /// Copied from [todaySupplierPayments].
  const TodaySupplierPaymentsFamily();

  /// Fetches the payments recorded within the day of [date].
  ///
  /// Copied from [todaySupplierPayments].
  TodaySupplierPaymentsProvider call(DateTime date) {
    return TodaySupplierPaymentsProvider(date);
  }

  @override
  TodaySupplierPaymentsProvider getProviderOverride(
    covariant TodaySupplierPaymentsProvider provider,
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
  String? get name => r'todaySupplierPaymentsProvider';
}

/// Fetches the payments recorded within the day of [date].
///
/// Copied from [todaySupplierPayments].
class TodaySupplierPaymentsProvider
    extends FutureProvider<List<SupplierPayment>> {
  /// Fetches the payments recorded within the day of [date].
  ///
  /// Copied from [todaySupplierPayments].
  TodaySupplierPaymentsProvider(DateTime date)
    : this._internal(
        (ref) => todaySupplierPayments(ref as TodaySupplierPaymentsRef, date),
        from: todaySupplierPaymentsProvider,
        name: r'todaySupplierPaymentsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$todaySupplierPaymentsHash,
        dependencies: TodaySupplierPaymentsFamily._dependencies,
        allTransitiveDependencies:
            TodaySupplierPaymentsFamily._allTransitiveDependencies,
        date: date,
      );

  TodaySupplierPaymentsProvider._internal(
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
    FutureOr<List<SupplierPayment>> Function(TodaySupplierPaymentsRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TodaySupplierPaymentsProvider._internal(
        (ref) => create(ref as TodaySupplierPaymentsRef),
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
  FutureProviderElement<List<SupplierPayment>> createElement() {
    return _TodaySupplierPaymentsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TodaySupplierPaymentsProvider && other.date == date;
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
mixin TodaySupplierPaymentsRef on FutureProviderRef<List<SupplierPayment>> {
  /// The parameter `date` of this provider.
  DateTime get date;
}

class _TodaySupplierPaymentsProviderElement
    extends FutureProviderElement<List<SupplierPayment>>
    with TodaySupplierPaymentsRef {
  _TodaySupplierPaymentsProviderElement(super.provider);

  @override
  DateTime get date => (origin as TodaySupplierPaymentsProvider).date;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
