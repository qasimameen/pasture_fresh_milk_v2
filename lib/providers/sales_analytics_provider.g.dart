// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sales_analytics_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$salesAnalyticsHash() => r'48a253242d00ffda1cc5d21c32ae7758b92f30bd';

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

/// See also [salesAnalytics].
@ProviderFor(salesAnalytics)
const salesAnalyticsProvider = SalesAnalyticsFamily();

/// See also [salesAnalytics].
class SalesAnalyticsFamily extends Family<AsyncValue<List<ProductSalesData>>> {
  /// See also [salesAnalytics].
  const SalesAnalyticsFamily();

  /// See also [salesAnalytics].
  SalesAnalyticsProvider call(Timeframe timeframe) {
    return SalesAnalyticsProvider(timeframe);
  }

  @override
  SalesAnalyticsProvider getProviderOverride(
    covariant SalesAnalyticsProvider provider,
  ) {
    return call(provider.timeframe);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'salesAnalyticsProvider';
}

/// See also [salesAnalytics].
class SalesAnalyticsProvider
    extends AutoDisposeFutureProvider<List<ProductSalesData>> {
  /// See also [salesAnalytics].
  SalesAnalyticsProvider(Timeframe timeframe)
    : this._internal(
        (ref) => salesAnalytics(ref as SalesAnalyticsRef, timeframe),
        from: salesAnalyticsProvider,
        name: r'salesAnalyticsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$salesAnalyticsHash,
        dependencies: SalesAnalyticsFamily._dependencies,
        allTransitiveDependencies:
            SalesAnalyticsFamily._allTransitiveDependencies,
        timeframe: timeframe,
      );

  SalesAnalyticsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.timeframe,
  }) : super.internal();

  final Timeframe timeframe;

  @override
  Override overrideWith(
    FutureOr<List<ProductSalesData>> Function(SalesAnalyticsRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SalesAnalyticsProvider._internal(
        (ref) => create(ref as SalesAnalyticsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        timeframe: timeframe,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<ProductSalesData>> createElement() {
    return _SalesAnalyticsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SalesAnalyticsProvider && other.timeframe == timeframe;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, timeframe.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SalesAnalyticsRef
    on AutoDisposeFutureProviderRef<List<ProductSalesData>> {
  /// The parameter `timeframe` of this provider.
  Timeframe get timeframe;
}

class _SalesAnalyticsProviderElement
    extends AutoDisposeFutureProviderElement<List<ProductSalesData>>
    with SalesAnalyticsRef {
  _SalesAnalyticsProviderElement(super.provider);

  @override
  Timeframe get timeframe => (origin as SalesAnalyticsProvider).timeframe;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
