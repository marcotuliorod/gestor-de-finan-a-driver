import 'package:driver_finance/features/platform/domain/entities/app_platform.dart';
import 'package:driver_finance/features/platform/presentation/providers/platform_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PlatformSelectionPage extends ConsumerWidget {
  const PlatformSelectionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final platformsAsync = ref.watch(watchPlatformsProvider);
    final notifierState = ref.watch(platformSelectionNotifierProvider);
    final notifier = ref.read(platformSelectionNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Plataformas')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref),
        tooltip: 'Adicionar plataforma',
        child: const Icon(Icons.add),
      ),
      body: notifierState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : platformsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Erro: $e')),
              data: (platforms) {
                if (platforms.isEmpty) {
                  return const Center(
                    child: Text('Configurando plataformas...'),
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
                      onToggle: (value) =>
                          notifier.toggle(p.id, isActive: value),
                    );
                  },
                );
              },
            ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final ctrl = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Nova plataforma'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(
            hintText: 'Ex: iFood, Rappi...',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final name = ctrl.text.trim();
              if (name.isEmpty) return;
              final userId =
                  Supabase.instance.client.auth.currentUser?.id ?? '';
              ref
                  .read(platformSelectionNotifierProvider.notifier)
                  .addPlatform(userId, name);
              Navigator.pop(context);
            },
            child: const Text('Salvar'),
          ),
        ],
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
      subtitle: platform.type == 'custom' ? null : Text(platform.type),
      value: platform.isActive,
      onChanged: onToggle,
    );
  }
}
