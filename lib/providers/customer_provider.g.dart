// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$customerRepositoryHash() =>
    r'ff32144c9cb18885206e50c527837d2071bc1737';

/// Singleton [CustomerRepository] instance.
///
/// Copied from [customerRepository].
@ProviderFor(customerRepository)
final customerRepositoryProvider = Provider<CustomerRepository>.internal(
  customerRepository,
  name: r'customerRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$customerRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CustomerRepositoryRef = ProviderRef<CustomerRepository>;
String _$customerListHash() => r'aedbeb4b35cd90c32785d421debc1b69d66fa3e5';

/// Fetches all active customers (status = 'active'), seeded on first use.
///
/// Copied from [customerList].
@ProviderFor(customerList)
final customerListProvider = FutureProvider<List<Customer>>.internal(
  customerList,
  name: r'customerListProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$customerListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CustomerListRef = FutureProviderRef<List<Customer>>;
String _$customerByIdHash() => r'320d2a748c8289d7ea09df63ea8031c0a0e0d5a8';

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

/// Fetches the customer with [id], or null when absent.
///
/// Copied from [customerById].
@ProviderFor(customerById)
const customerByIdProvider = CustomerByIdFamily();

/// Fetches the customer with [id], or null when absent.
///
/// Copied from [customerById].
class CustomerByIdFamily extends Family<AsyncValue<Customer?>> {
  /// Fetches the customer with [id], or null when absent.
  ///
  /// Copied from [customerById].
  const CustomerByIdFamily();

  /// Fetches the customer with [id], or null when absent.
  ///
  /// Copied from [customerById].
  CustomerByIdProvider call(String id) {
    return CustomerByIdProvider(id);
  }

  @override
  CustomerByIdProvider getProviderOverride(
    covariant CustomerByIdProvider provider,
  ) {
    return call(provider.id);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'customerByIdProvider';
}

/// Fetches the customer with [id], or null when absent.
///
/// Copied from [customerById].
class CustomerByIdProvider extends FutureProvider<Customer?> {
  /// Fetches the customer with [id], or null when absent.
  ///
  /// Copied from [customerById].
  CustomerByIdProvider(String id)
    : this._internal(
        (ref) => customerById(ref as CustomerByIdRef, id),
        from: customerByIdProvider,
        name: r'customerByIdProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$customerByIdHash,
        dependencies: CustomerByIdFamily._dependencies,
        allTransitiveDependencies:
            CustomerByIdFamily._allTransitiveDependencies,
        id: id,
      );

  CustomerByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  Override overrideWith(
    FutureOr<Customer?> Function(CustomerByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CustomerByIdProvider._internal(
        (ref) => create(ref as CustomerByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  FutureProviderElement<Customer?> createElement() {
    return _CustomerByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CustomerByIdProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CustomerByIdRef on FutureProviderRef<Customer?> {
  /// The parameter `id` of this provider.
  String get id;
}

class _CustomerByIdProviderElement extends FutureProviderElement<Customer?>
    with CustomerByIdRef {
  _CustomerByIdProviderElement(super.provider);

  @override
  String get id => (origin as CustomerByIdProvider).id;
}

String _$customerSearchHash() => r'c69ea7332a6b5bacc41f2ac6647fc5545de428d9';

/// Fetches customers matching [query] across name/phone/address/area.
///
/// Copied from [customerSearch].
@ProviderFor(customerSearch)
const customerSearchProvider = CustomerSearchFamily();

/// Fetches customers matching [query] across name/phone/address/area.
///
/// Copied from [customerSearch].
class CustomerSearchFamily extends Family<AsyncValue<List<Customer>>> {
  /// Fetches customers matching [query] across name/phone/address/area.
  ///
  /// Copied from [customerSearch].
  const CustomerSearchFamily();

  /// Fetches customers matching [query] across name/phone/address/area.
  ///
  /// Copied from [customerSearch].
  CustomerSearchProvider call(String query) {
    return CustomerSearchProvider(query);
  }

  @override
  CustomerSearchProvider getProviderOverride(
    covariant CustomerSearchProvider provider,
  ) {
    return call(provider.query);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'customerSearchProvider';
}

/// Fetches customers matching [query] across name/phone/address/area.
///
/// Copied from [customerSearch].
class CustomerSearchProvider extends FutureProvider<List<Customer>> {
  /// Fetches customers matching [query] across name/phone/address/area.
  ///
  /// Copied from [customerSearch].
  CustomerSearchProvider(String query)
    : this._internal(
        (ref) => customerSearch(ref as CustomerSearchRef, query),
        from: customerSearchProvider,
        name: r'customerSearchProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$customerSearchHash,
        dependencies: CustomerSearchFamily._dependencies,
        allTransitiveDependencies:
            CustomerSearchFamily._allTransitiveDependencies,
        query: query,
      );

  CustomerSearchProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.query,
  }) : super.internal();

  final String query;

  @override
  Override overrideWith(
    FutureOr<List<Customer>> Function(CustomerSearchRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CustomerSearchProvider._internal(
        (ref) => create(ref as CustomerSearchRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        query: query,
      ),
    );
  }

  @override
  FutureProviderElement<List<Customer>> createElement() {
    return _CustomerSearchProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CustomerSearchProvider && other.query == query;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, query.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CustomerSearchRef on FutureProviderRef<List<Customer>> {
  /// The parameter `query` of this provider.
  String get query;
}

class _CustomerSearchProviderElement
    extends FutureProviderElement<List<Customer>>
    with CustomerSearchRef {
  _CustomerSearchProviderElement(super.provider);

  @override
  String get query => (origin as CustomerSearchProvider).query;
}

String _$customerStatsHash() => r'3050fabbe38e970a1d463f9dfd33a6d76509502a';

/// Customer counts and financial aggregates (plan.md A-M7): total,
/// active (status = 'active'), withDues (currentDue > 0), totalDues
/// (sum of currentDue), onAdvance (advanceBalance > 0).
///
/// Copied from [customerStats].
@ProviderFor(customerStats)
final customerStatsProvider =
    FutureProvider<
      ({int total, int active, int withDues, double totalDues, int onAdvance})
    >.internal(
      customerStats,
      name: r'customerStatsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$customerStatsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CustomerStatsRef =
    FutureProviderRef<
      ({int total, int active, int withDues, double totalDues, int onAdvance})
    >;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
