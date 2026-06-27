import 'package:driver_finance/core/ui/theme/app_colors.dart';
import 'package:driver_finance/core/utils/currency_formatter.dart';
import 'package:driver_finance/features/auth/presentation/providers/auth_provider.dart';
import 'package:driver_finance/features/goals/presentation/pages/goal_form_page.dart';
import 'package:driver_finance/features/goals/presentation/providers/goal_provider.dart';
import 'package:driver_finance/features/settings/presentation/providers/theme_provider.dart';
import 'package:driver_finance/features/vehicle/presentation/pages/vehicle_form_page.dart';
import 'package:driver_finance/features/vehicle/presentation/providers/vehicle_provider.dart';
import 'package:driver_finance/features/maintenance/presentation/pages/maintenance_list_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authRepositoryProvider).currentUser;
    final vehicleAsync = ref.watch(watchVehicleProvider);
    final goalAsync = ref.watch(watchCurrentGoalProvider);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        children: [
          if (user != null) ...[
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Conta'),
              subtitle: Text(user.displayName ?? user.email),
              trailing: const Icon(Icons.edit_outlined),
              onTap: () => _editDisplayName(context, ref, user.displayName),
            ),
            const Divider(),
          ],
          vehicleAsync.when(
            loading: () => const ListTile(
              leading: Icon(Icons.directions_car),
              title: Text('Veículo'),
              trailing: CircularProgressIndicator(),
            ),
            error: (_, __) => const SizedBox(),
            data: (vehicle) => ListTile(
              leading: const Icon(Icons.directions_car),
              title: const Text('Veículo'),
              subtitle: vehicle != null
                  ? Text('${vehicle.make} ${vehicle.model}')
                  : const Text('Nenhum cadastrado'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<bool>(
                  builder: (_) => VehicleFormPage(existingVehicle: vehicle),
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.apps),
            title: const Text('Plataformas'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/platforms'),
          ),
          ListTile(
            leading: const Icon(Icons.build_outlined),
            title: const Text('Manutenções'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const MaintenanceListPage(),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.auto_awesome_rounded,
                color: AppColors.primary),
            title: const Text('Assistente IA'),
            subtitle: const Text('Converse sobre suas finanças'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/app/ai'),
          ),
          goalAsync.when(
            loading: () => const ListTile(
              leading: Icon(Icons.flag_outlined),
              title: Text('Metas'),
              trailing: CircularProgressIndicator(),
            ),
            error: (_, __) => const SizedBox(),
            data: (goal) => ListTile(
              leading: const Icon(Icons.flag_outlined),
              title: const Text('Metas'),
              subtitle: goal != null
                  ? Text('${formatCurrency(goal.monthlyTargetCents)}/mês')
                  : const Text('Nenhuma definida'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<bool>(
                  builder: (_) => GoalFormPage(existingGoal: goal),
                ),
              ),
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              'Aparência',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                    letterSpacing: 0.8,
                  ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(
                  value: ThemeMode.system,
                  icon: Icon(Icons.brightness_auto_rounded),
                  label: Text('Auto'),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  icon: Icon(Icons.light_mode_rounded),
                  label: Text('Claro'),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  icon: Icon(Icons.dark_mode_rounded),
                  label: Text('Escuro'),
                ),
              ],
              selected: {themeMode},
              onSelectionChanged: (selection) =>
                  ref.read(themeModeProvider.notifier).setMode(selection.first),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sair'),
            onTap: () => _confirmSignOut(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: AppColors.expense),
            title: const Text(
              'Excluir conta',
              style: TextStyle(color: AppColors.expense),
            ),
            onTap: () => _confirmDeleteAccount(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _editDisplayName(
      BuildContext context, WidgetRef ref, String? current) async {
    final controller = TextEditingController(text: current ?? '');
    final name = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Editar nome'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Nome'),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name == null || name.isEmpty || !context.mounted) return;
    final result =
        await ref.read(authNotifierProvider.notifier).updateDisplayName(name);
    if (!context.mounted) return;
    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      ),
      (_) => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nome atualizado')),
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Deseja encerrar sua sessão?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(authNotifierProvider.notifier).signOut();
      if (!context.mounted) return;
      context.go('/login');
    }
  }

  Future<void> _confirmDeleteAccount(
      BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir conta'),
        content: const Text(
          'Todos os seus dados serão apagados permanentemente. '
          'Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.expense),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final result =
          await ref.read(authNotifierProvider.notifier).deleteAccount();
      if (!context.mounted) return;
      result.fold(
        (failure) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        ),
        (_) => context.go('/login'),
      );
    }
  }
}
