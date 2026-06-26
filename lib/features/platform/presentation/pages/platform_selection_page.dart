import 'package:driver_finance/features/platform/domain/entities/app_platform.dart';
import 'package:driver_finance/features/platform/presentation/providers/platform_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlatformSelectionPage extends ConsumerWidget {
  const PlatformSelectionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final platformsAsync = ref.watch(watchPlatformsProvider);
    final notifier = ref.read(platformSelectionNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Plataformas')),
      body: platformsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (platforms) {
          if (platforms.isEmpty) {
            return const Center(
              child: Text('Nenhuma plataforma configurada'),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: platforms.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final p = platforms[i];
              return _PlatformTile(
                platform: p,
                onToggle: (value) => notifier.toggle(p.id, isActive: value),
              );
            },
          );
        },
      ),
    );
  }
}

class _PlatformTile extends StatelessWidget {
  const _PlatformTile({required this.platform, required this.onToggle});

  final AppPlatform platform;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(platform.displayName),
      subtitle: Text(platform.type),
      value: platform.isActive,
      onChanged: onToggle,
    );
  }
}
