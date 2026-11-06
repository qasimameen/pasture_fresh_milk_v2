import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/store_profile.dart';
import '../repositories/store_profile_repository.dart';

part 'store_profile_provider.g.dart';

/// Singleton [StoreProfileRepository] instance.
@Riverpod(keepAlive: true)
StoreProfileRepository storeProfileRepository(Ref ref) =>
    StoreProfileRepository();

/// Fetches the single store profile (or null when the table is empty).
@Riverpod(keepAlive: true)
Future<StoreProfile?> storeProfile(Ref ref) async {
  final repository = ref.watch(storeProfileRepositoryProvider);
  return repository.getProfile();
}