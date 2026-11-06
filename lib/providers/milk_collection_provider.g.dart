// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'milk_collection_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$milkCollectionRepositoryHash() =>
    r'1e5c733d1d2acd855890e18bd936219609aa7268';

/// Singleton [MilkCollectionRepository] instance.
///
/// Copied from [milkCollectionRepository].
@ProviderFor(milkCollectionRepository)
final milkCollectionRepositoryProvider =
    Provider<MilkCollectionRepository>.internal(
      milkCollectionRepository,
      name: r'milkCollectionRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$milkCollectionRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MilkCollectionRepositoryRef = ProviderRef<MilkCollectionRepository>;
String _$milkCollectionListHash() =>
    r'334277dfd2e6da9f4d2a1e68da62a5a5dca4c913';

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

/// Fetches the milk collections recorded for the day of [date].
///
/// Copied from [milkCollectionList].
@ProviderFor(milkCollectionList)
const milkCollectionListProvider = MilkCollectionListFamily();

/// Fetches the milk collections recorded for the day of [date].
///
/// Copied from [milkCollectionList].
class MilkCollectionListFamily
    extends Family<AsyncValue<List<MilkCollection>>> {
  /// Fetches the milk collections recorded for the day of [date].
  ///
  /// Copied from [milkCollectionList].
  const MilkCollectionListFamily();

  /// Fetches the milk collections recorded for the day of [date].
  ///
  /// Copied from [milkCollectionList].
  MilkCollectionListProvider call(DateTime date) {
    return MilkCollectionListProvider(date);
  }

  @override
  MilkCollectionListProvider getProviderOverride(
    covariant MilkCollectionListProvider provider,
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
  String? get name => r'milkCollectionListProvider';
}

/// Fetches the milk collections recorded for the day of [date].
///
/// Copied from [milkCollectionList].
class MilkCollectionListProvider extends FutureProvider<List<MilkCollection>> {
  /// Fetches the milk collections recorded for the day of [date].
  ///
  /// Copied from [milkCollectionList].
  MilkCollectionListProvider(DateTime date)
    : this._internal(
        (ref) => milkCollectionList(ref as MilkCollectionListRef, date),
        from: milkCollectionListProvider,
        name: r'milkCollectionListProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$milkCollectionListHash,
        dependencies: MilkCollectionListFamily._dependencies,
        allTransitiveDependencies:
            MilkCollectionListFamily._allTransitiveDependencies,
        date: date,
      );

  MilkCollectionListProvider._internal(
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
    FutureOr<List<MilkCollection>> Function(MilkCollectionListRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MilkCollectionListProvider._internal(
        (ref) => create(ref as MilkCollectionListRef),
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
  FutureProviderElement<List<MilkCollection>> createElement() {
    return _MilkCollectionListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MilkCollectionListProvider && other.date == date;
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
mixin MilkCollectionListRef on FutureProviderRef<List<MilkCollection>> {
  /// The parameter `date` of this provider.
  DateTime get date;
}

class _MilkCollectionListProviderElement
    extends FutureProviderElement<List<MilkCollection>>
    with MilkCollectionListRef {
  _MilkCollectionListProviderElement(super.provider);

  @override
  DateTime get date => (origin as MilkCollectionListProvider).date;
}

String _$milkCollectionStatsHash() =>
    r'b5d998420924d19c2dd8e11bbfb63ae588082b60';

/// Daily collection statistics for the day of [date]: total litres,
/// total payable and weighted-average rate (plan.md A-M11).
///
/// Copied from [milkCollectionStats].
@ProviderFor(milkCollectionStats)
const milkCollectionStatsProvider = MilkCollectionStatsFamily();

/// Daily collection statistics for the day of [date]: total litres,
/// total payable and weighted-average rate (plan.md A-M11).
///
/// Copied from [milkCollectionStats].
class MilkCollectionStatsFamily
    extends
        Family<
          AsyncValue<
            ({double totalQuantity, double totalPayable, double avgRate})
          >
        > {
  /// Daily collection statistics for the day of [date]: total litres,
  /// total payable and weighted-average rate (plan.md A-M11).
  ///
  /// Copied from [milkCollectionStats].
  const MilkCollectionStatsFamily();

  /// Daily collection statistics for the day of [date]: total litres,
  /// total payable and weighted-average rate (plan.md A-M11).
  ///
  /// Copied from [milkCollectionStats].
  MilkCollectionStatsProvider call(DateTime date) {
    return MilkCollectionStatsProvider(date);
  }

  @override
  MilkCollectionStatsProvider getProviderOverride(
    covariant MilkCollectionStatsProvider provider,
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
  String? get name => r'milkCollectionStatsProvider';
}

/// Daily collection statistics for the day of [date]: total litres,
/// total payable and weighted-average rate (plan.md A-M11).
///
/// Copied from [milkCollectionStats].
class MilkCollectionStatsProvider
    extends
        FutureProvider<
          ({double totalQuantity, double totalPayable, double avgRate})
        > {
  /// Daily collection statistics for the day of [date]: total litres,
  /// total payable and weighted-average rate (plan.md A-M11).
  ///
  /// Copied from [milkCollectionStats].
  MilkCollectionStatsProvider(DateTime date)
    : this._internal(
        (ref) => milkCollectionStats(ref as MilkCollectionStatsRef, date),
        from: milkCollectionStatsProvider,
        name: r'milkCollectionStatsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$milkCollectionStatsHash,
        dependencies: MilkCollectionStatsFamily._dependencies,
        allTransitiveDependencies:
            MilkCollectionStatsFamily._allTransitiveDependencies,
        date: date,
      );

  MilkCollectionStatsProvider._internal(
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
    FutureOr<({double totalQuantity, double totalPayable, double avgRate})>
    Function(MilkCollectionStatsRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MilkCollectionStatsProvider._internal(
        (ref) => create(ref as MilkCollectionStatsRef),
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
    ({double totalQuantity, double totalPayable, double avgRate})
  >
  createElement() {
    return _MilkCollectionStatsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MilkCollectionStatsProvider && other.date == date;
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
mixin MilkCollectionStatsRef
    on
        FutureProviderRef<
          ({double totalQuantity, double totalPayable, double avgRate})
        > {
  /// The parameter `date` of this provider.
  DateTime get date;
}

class _MilkCollectionStatsProviderElement
    extends
        FutureProviderElement<
          ({double totalQuantity, double totalPayable, double avgRate})
        >
    with MilkCollectionStatsRef {
  _MilkCollectionStatsProviderElement(super.provider);

  @override
  DateTime get date => (origin as MilkCollectionStatsProvider).date;
}

String _$supplierCollectionsHash() =>
    r'93a53b03961a0b7b2c8949fca5c3a5b003093e19';

/// Fetches the collection history for the supplier with [supplierId].
///
/// Copied from [supplierCollections].
@ProviderFor(supplierCollections)
const supplierCollectionsProvider = SupplierCollectionsFamily();

/// Fetches the collection history for the supplier with [supplierId].
///
/// Copied from [supplierCollections].
class SupplierCollectionsFamily
    extends Family<AsyncValue<List<MilkCollection>>> {
  /// Fetches the collection history for the supplier with [supplierId].
  ///
  /// Copied from [supplierCollections].
  const SupplierCollectionsFamily();

  /// Fetches the collection history for the supplier with [supplierId].
  ///
  /// Copied from [supplierCollections].
  SupplierCollectionsProvider call(String supplierId) {
    return SupplierCollectionsProvider(supplierId);
  }

  @override
  SupplierCollectionsProvider getProviderOverride(
    covariant SupplierCollectionsProvider provider,
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
  String? get name => r'supplierCollectionsProvider';
}

/// Fetches the collection history for the supplier with [supplierId].
///
/// Copied from [supplierCollections].
class SupplierCollectionsProvider extends FutureProvider<List<MilkCollection>> {
  /// Fetches the collection history for the supplier with [supplierId].
  ///
  /// Copied from [supplierCollections].
  SupplierCollectionsProvider(String supplierId)
    : this._internal(
        (ref) => supplierCollections(ref as SupplierCollectionsRef, supplierId),
        from: supplierCollectionsProvider,
        name: r'supplierCollectionsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$supplierCollectionsHash,
        dependencies: SupplierCollectionsFamily._dependencies,
        allTransitiveDependencies:
            SupplierCollectionsFamily._allTransitiveDependencies,
        supplierId: supplierId,
      );

  SupplierCollectionsProvider._internal(
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
    FutureOr<List<MilkCollection>> Function(SupplierCollectionsRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SupplierCollectionsProvider._internal(
        (ref) => create(ref as SupplierCollectionsRef),
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
  FutureProviderElement<List<MilkCollection>> createElement() {
    return _SupplierCollectionsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SupplierCollectionsProvider &&
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
mixin SupplierCollectionsRef on FutureProviderRef<List<MilkCollection>> {
  /// The parameter `supplierId` of this provider.
  String get supplierId;
}

class _SupplierCollectionsProviderElement
    extends FutureProviderElement<List<MilkCollection>>
    with SupplierCollectionsRef {
  _SupplierCollectionsProviderElement(super.provider);

  @override
  String get supplierId => (origin as SupplierCollectionsProvider).supplierId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
