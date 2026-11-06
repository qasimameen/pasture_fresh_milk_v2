// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delivery_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$deliveryRepositoryHash() =>
    r'5bad8c0c37a3ad6b210df3cfe014b98f3defc68d';

/// Singleton [DeliveryRepository] instance.
///
/// Copied from [deliveryRepository].
@ProviderFor(deliveryRepository)
final deliveryRepositoryProvider = Provider<DeliveryRepository>.internal(
  deliveryRepository,
  name: r'deliveryRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$deliveryRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DeliveryRepositoryRef = ProviderRef<DeliveryRepository>;
String _$deliveryListHash() => r'c9f9dc7b186a61917bc3bb62684be258107f0d67';

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

/// Fetches deliveries for the day of [date] in [shift].
///
/// Copied from [deliveryList].
@ProviderFor(deliveryList)
const deliveryListProvider = DeliveryListFamily();

/// Fetches deliveries for the day of [date] in [shift].
///
/// Copied from [deliveryList].
class DeliveryListFamily extends Family<AsyncValue<List<Delivery>>> {
  /// Fetches deliveries for the day of [date] in [shift].
  ///
  /// Copied from [deliveryList].
  const DeliveryListFamily();

  /// Fetches deliveries for the day of [date] in [shift].
  ///
  /// Copied from [deliveryList].
  DeliveryListProvider call(DateTime date, String shift) {
    return DeliveryListProvider(date, shift);
  }

  @override
  DeliveryListProvider getProviderOverride(
    covariant DeliveryListProvider provider,
  ) {
    return call(provider.date, provider.shift);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'deliveryListProvider';
}

/// Fetches deliveries for the day of [date] in [shift].
///
/// Copied from [deliveryList].
class DeliveryListProvider extends FutureProvider<List<Delivery>> {
  /// Fetches deliveries for the day of [date] in [shift].
  ///
  /// Copied from [deliveryList].
  DeliveryListProvider(DateTime date, String shift)
    : this._internal(
        (ref) => deliveryList(ref as DeliveryListRef, date, shift),
        from: deliveryListProvider,
        name: r'deliveryListProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$deliveryListHash,
        dependencies: DeliveryListFamily._dependencies,
        allTransitiveDependencies:
            DeliveryListFamily._allTransitiveDependencies,
        date: date,
        shift: shift,
      );

  DeliveryListProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.date,
    required this.shift,
  }) : super.internal();

  final DateTime date;
  final String shift;

  @override
  Override overrideWith(
    FutureOr<List<Delivery>> Function(DeliveryListRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DeliveryListProvider._internal(
        (ref) => create(ref as DeliveryListRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        date: date,
        shift: shift,
      ),
    );
  }

  @override
  FutureProviderElement<List<Delivery>> createElement() {
    return _DeliveryListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DeliveryListProvider &&
        other.date == date &&
        other.shift == shift;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, date.hashCode);
    hash = _SystemHash.combine(hash, shift.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DeliveryListRef on FutureProviderRef<List<Delivery>> {
  /// The parameter `date` of this provider.
  DateTime get date;

  /// The parameter `shift` of this provider.
  String get shift;
}

class _DeliveryListProviderElement extends FutureProviderElement<List<Delivery>>
    with DeliveryListRef {
  _DeliveryListProviderElement(super.provider);

  @override
  DateTime get date => (origin as DeliveryListProvider).date;
  @override
  String get shift => (origin as DeliveryListProvider).shift;
}

String _$deliveryStatsHash() => r'5fa7140c6b0101222e06ca1ab821126d2b7deb6c';

/// Delivery counts and totals for the day of [date] in [shift]
/// (plan.md A-M9).
///
/// Copied from [deliveryStats].
@ProviderFor(deliveryStats)
const deliveryStatsProvider = DeliveryStatsFamily();

/// Delivery counts and totals for the day of [date] in [shift]
/// (plan.md A-M9).
///
/// Copied from [deliveryStats].
class DeliveryStatsFamily
    extends
        Family<
          AsyncValue<
            ({
              int total,
              int delivered,
              int pending,
              int skipped,
              double totalQuantityDelivered,
              double totalCashCollected,
            })
          >
        > {
  /// Delivery counts and totals for the day of [date] in [shift]
  /// (plan.md A-M9).
  ///
  /// Copied from [deliveryStats].
  const DeliveryStatsFamily();

  /// Delivery counts and totals for the day of [date] in [shift]
  /// (plan.md A-M9).
  ///
  /// Copied from [deliveryStats].
  DeliveryStatsProvider call(DateTime date, String shift) {
    return DeliveryStatsProvider(date, shift);
  }

  @override
  DeliveryStatsProvider getProviderOverride(
    covariant DeliveryStatsProvider provider,
  ) {
    return call(provider.date, provider.shift);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'deliveryStatsProvider';
}

/// Delivery counts and totals for the day of [date] in [shift]
/// (plan.md A-M9).
///
/// Copied from [deliveryStats].
class DeliveryStatsProvider
    extends
        FutureProvider<
          ({
            int total,
            int delivered,
            int pending,
            int skipped,
            double totalQuantityDelivered,
            double totalCashCollected,
          })
        > {
  /// Delivery counts and totals for the day of [date] in [shift]
  /// (plan.md A-M9).
  ///
  /// Copied from [deliveryStats].
  DeliveryStatsProvider(DateTime date, String shift)
    : this._internal(
        (ref) => deliveryStats(ref as DeliveryStatsRef, date, shift),
        from: deliveryStatsProvider,
        name: r'deliveryStatsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$deliveryStatsHash,
        dependencies: DeliveryStatsFamily._dependencies,
        allTransitiveDependencies:
            DeliveryStatsFamily._allTransitiveDependencies,
        date: date,
        shift: shift,
      );

  DeliveryStatsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.date,
    required this.shift,
  }) : super.internal();

  final DateTime date;
  final String shift;

  @override
  Override overrideWith(
    FutureOr<
      ({
        int total,
        int delivered,
        int pending,
        int skipped,
        double totalQuantityDelivered,
        double totalCashCollected,
      })
    >
    Function(DeliveryStatsRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DeliveryStatsProvider._internal(
        (ref) => create(ref as DeliveryStatsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        date: date,
        shift: shift,
      ),
    );
  }

  @override
  FutureProviderElement<
    ({
      int total,
      int delivered,
      int pending,
      int skipped,
      double totalQuantityDelivered,
      double totalCashCollected,
    })
  >
  createElement() {
    return _DeliveryStatsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DeliveryStatsProvider &&
        other.date == date &&
        other.shift == shift;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, date.hashCode);
    hash = _SystemHash.combine(hash, shift.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DeliveryStatsRef
    on
        FutureProviderRef<
          ({
            int total,
            int delivered,
            int pending,
            int skipped,
            double totalQuantityDelivered,
            double totalCashCollected,
          })
        > {
  /// The parameter `date` of this provider.
  DateTime get date;

  /// The parameter `shift` of this provider.
  String get shift;
}

class _DeliveryStatsProviderElement
    extends
        FutureProviderElement<
          ({
            int total,
            int delivered,
            int pending,
            int skipped,
            double totalQuantityDelivered,
            double totalCashCollected,
          })
        >
    with DeliveryStatsRef {
  _DeliveryStatsProviderElement(super.provider);

  @override
  DateTime get date => (origin as DeliveryStatsProvider).date;
  @override
  String get shift => (origin as DeliveryStatsProvider).shift;
}

String _$customerDeliveryHistoryHash() =>
    r'eb47a794dbe3d31b173a4e5fcc1c21481df04774';

/// Fetches the delivery history for the customer with [customerId].
///
/// Copied from [customerDeliveryHistory].
@ProviderFor(customerDeliveryHistory)
const customerDeliveryHistoryProvider = CustomerDeliveryHistoryFamily();

/// Fetches the delivery history for the customer with [customerId].
///
/// Copied from [customerDeliveryHistory].
class CustomerDeliveryHistoryFamily extends Family<AsyncValue<List<Delivery>>> {
  /// Fetches the delivery history for the customer with [customerId].
  ///
  /// Copied from [customerDeliveryHistory].
  const CustomerDeliveryHistoryFamily();

  /// Fetches the delivery history for the customer with [customerId].
  ///
  /// Copied from [customerDeliveryHistory].
  CustomerDeliveryHistoryProvider call(String customerId) {
    return CustomerDeliveryHistoryProvider(customerId);
  }

  @override
  CustomerDeliveryHistoryProvider getProviderOverride(
    covariant CustomerDeliveryHistoryProvider provider,
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
  String? get name => r'customerDeliveryHistoryProvider';
}

/// Fetches the delivery history for the customer with [customerId].
///
/// Copied from [customerDeliveryHistory].
class CustomerDeliveryHistoryProvider extends FutureProvider<List<Delivery>> {
  /// Fetches the delivery history for the customer with [customerId].
  ///
  /// Copied from [customerDeliveryHistory].
  CustomerDeliveryHistoryProvider(String customerId)
    : this._internal(
        (ref) => customerDeliveryHistory(
          ref as CustomerDeliveryHistoryRef,
          customerId,
        ),
        from: customerDeliveryHistoryProvider,
        name: r'customerDeliveryHistoryProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$customerDeliveryHistoryHash,
        dependencies: CustomerDeliveryHistoryFamily._dependencies,
        allTransitiveDependencies:
            CustomerDeliveryHistoryFamily._allTransitiveDependencies,
        customerId: customerId,
      );

  CustomerDeliveryHistoryProvider._internal(
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
    FutureOr<List<Delivery>> Function(CustomerDeliveryHistoryRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CustomerDeliveryHistoryProvider._internal(
        (ref) => create(ref as CustomerDeliveryHistoryRef),
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
  FutureProviderElement<List<Delivery>> createElement() {
    return _CustomerDeliveryHistoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CustomerDeliveryHistoryProvider &&
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
mixin CustomerDeliveryHistoryRef on FutureProviderRef<List<Delivery>> {
  /// The parameter `customerId` of this provider.
  String get customerId;
}

class _CustomerDeliveryHistoryProviderElement
    extends FutureProviderElement<List<Delivery>>
    with CustomerDeliveryHistoryRef {
  _CustomerDeliveryHistoryProviderElement(super.provider);

  @override
  String get customerId =>
      (origin as CustomerDeliveryHistoryProvider).customerId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
