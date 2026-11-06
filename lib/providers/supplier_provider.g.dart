// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supplier_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$supplierRepositoryHash() =>
    r'c8f67641e65c9dc19eb426939551a99420f8da28';

/// Singleton [SupplierRepository] instance.
///
/// Copied from [supplierRepository].
@ProviderFor(supplierRepository)
final supplierRepositoryProvider = Provider<SupplierRepository>.internal(
  supplierRepository,
  name: r'supplierRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$supplierRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SupplierRepositoryRef = ProviderRef<SupplierRepository>;
String _$supplierListHash() => r'6cf3ee7ed7b9616e35186b8d2474560850222cdf';

/// Fetches all active suppliers, seeded on first use.
///
/// Copied from [supplierList].
@ProviderFor(supplierList)
final supplierListProvider = FutureProvider<List<Supplier>>.internal(
  supplierList,
  name: r'supplierListProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$supplierListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SupplierListRef = FutureProviderRef<List<Supplier>>;
String _$supplierByIdHash() => r'7b9c36f5d9ef4005321f0a8c775a07c251843582';

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

/// Fetches the supplier with [id], or null when absent.
///
/// Copied from [supplierById].
@ProviderFor(supplierById)
const supplierByIdProvider = SupplierByIdFamily();

/// Fetches the supplier with [id], or null when absent.
///
/// Copied from [supplierById].
class SupplierByIdFamily extends Family<AsyncValue<Supplier?>> {
  /// Fetches the supplier with [id], or null when absent.
  ///
  /// Copied from [supplierById].
  const SupplierByIdFamily();

  /// Fetches the supplier with [id], or null when absent.
  ///
  /// Copied from [supplierById].
  SupplierByIdProvider call(String id) {
    return SupplierByIdProvider(id);
  }

  @override
  SupplierByIdProvider getProviderOverride(
    covariant SupplierByIdProvider provider,
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
  String? get name => r'supplierByIdProvider';
}

/// Fetches the supplier with [id], or null when absent.
///
/// Copied from [supplierById].
class SupplierByIdProvider extends FutureProvider<Supplier?> {
  /// Fetches the supplier with [id], or null when absent.
  ///
  /// Copied from [supplierById].
  SupplierByIdProvider(String id)
    : this._internal(
        (ref) => supplierById(ref as SupplierByIdRef, id),
        from: supplierByIdProvider,
        name: r'supplierByIdProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$supplierByIdHash,
        dependencies: SupplierByIdFamily._dependencies,
        allTransitiveDependencies:
            SupplierByIdFamily._allTransitiveDependencies,
        id: id,
      );

  SupplierByIdProvider._internal(
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
    FutureOr<Supplier?> Function(SupplierByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SupplierByIdProvider._internal(
        (ref) => create(ref as SupplierByIdRef),
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
  FutureProviderElement<Supplier?> createElement() {
    return _SupplierByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SupplierByIdProvider && other.id == id;
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
mixin SupplierByIdRef on FutureProviderRef<Supplier?> {
  /// The parameter `id` of this provider.
  String get id;
}

class _SupplierByIdProviderElement extends FutureProviderElement<Supplier?>
    with SupplierByIdRef {
  _SupplierByIdProviderElement(super.provider);

  @override
  String get id => (origin as SupplierByIdProvider).id;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
