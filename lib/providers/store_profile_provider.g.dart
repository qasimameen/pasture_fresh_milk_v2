// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_profile_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$storeProfileRepositoryHash() =>
    r'a75c55971ec179b7d0b261be776064eac40e9aed';

/// Singleton [StoreProfileRepository] instance.
///
/// Copied from [storeProfileRepository].
@ProviderFor(storeProfileRepository)
final storeProfileRepositoryProvider =
    Provider<StoreProfileRepository>.internal(
      storeProfileRepository,
      name: r'storeProfileRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$storeProfileRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef StoreProfileRepositoryRef = ProviderRef<StoreProfileRepository>;
String _$storeProfileHash() => r'812bb682241398287edd91fdde029f76d9df4f15';

/// Fetches the single store profile (or null when the table is empty).
///
/// Copied from [storeProfile].
@ProviderFor(storeProfile)
final storeProfileProvider = FutureProvider<StoreProfile?>.internal(
  storeProfile,
  name: r'storeProfileProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$storeProfileHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef StoreProfileRef = FutureProviderRef<StoreProfile?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
