// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shift_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$shiftRepositoryHash() => r'd91f7c1dbcd63b635a086835259ad89c8b29edda';

/// Singleton [ShiftRepository] instance.
///
/// Copied from [shiftRepository].
@ProviderFor(shiftRepository)
final shiftRepositoryProvider = Provider<ShiftRepository>.internal(
  shiftRepository,
  name: r'shiftRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$shiftRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ShiftRepositoryRef = ProviderRef<ShiftRepository>;
String _$shiftListHash() => r'481504804eb98850ab060258cbf57088f5175ca2';

/// Fetches all active shifts.
///
/// Copied from [shiftList].
@ProviderFor(shiftList)
final shiftListProvider = FutureProvider<List<Shift>>.internal(
  shiftList,
  name: r'shiftListProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$shiftListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ShiftListRef = FutureProviderRef<List<Shift>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
