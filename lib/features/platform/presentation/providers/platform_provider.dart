import 'package:driver_finance/core/database/app_database.dart';
import 'package:driver_finance/core/errors/failures.dart';
import 'package:driver_finance/features/auth/presentation/providers/auth_provider.dart';
import 'package:driver_finance/features/platform/data/repositories/platform_repository_impl.dart';
import 'package:driver_finance/features/platform/domain/entities/app_platform.dart';
import 'package:driver_finance/features/platform/domain/repositories/platform_repository.dart';
import 'package:driver_finance/features/platform/domain/usecases/seed_default_platforms.dart';
import 'package:driver_finance/features/platform/domain/usecases/toggle_platform.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final platformRepositoryProvider = Provider<PlatformRepository>((ref) {
  return PlatformRepositoryImpl(
    database: ref.watch(appDatabaseProvider),
    supabase: Supabase.instance.client,
  );
});

final watchPlatformsProvider = StreamProvider<List<AppPlatform>>((ref) {
  return ref.watch(platformRepositoryProvider).watchPlatforms();
});

class PlatformSelectionNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;
    final result = await ref.read(platformRepositoryProvider).getPlatforms();
    result.fold(
      (_) {},
      (list) async {
        if (list.isEmpty) {
          await SeedDefaultPlatformsUseCase(
            ref.read(platformRepositoryProvider),
          )(userId);
        }
      },
    );
  }

  Future<Either<Failure, Unit>> seed(String userId) async {
    return SeedDefaultPlatformsUseCase(ref.read(platformRepositoryProvider))(
      userId,
    );
  }

  Future<Either<Failure, Unit>> toggle(String id, {required bool isActive}) {
    return TogglePlatformUseCase(
      ref.read(platformRepositoryProvider),
    )(id, isActive: isActive);
  }

  Future<Either<Failure, Unit>> addPlatform(String userId, String name) {
    return ref.read(platformRepositoryProvider).addPlatform(userId, name);
  }
}

final platformSelectionNotifierProvider =
    AsyncNotifierProvider<PlatformSelectionNotifier, void>(
  PlatformSelectionNotifier.new,
);
