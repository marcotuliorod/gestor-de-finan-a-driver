import 'package:driver_finance/core/providers/shared_preferences_provider.dart';
import 'package:driver_finance/core/ui/theme/app_colors.dart';
import 'package:driver_finance/features/auth/presentation/providers/auth_provider.dart';
import 'package:driver_finance/features/goals/presentation/providers/goal_provider.dart';
import 'package:driver_finance/features/platform/presentation/providers/platform_provider.dart';
import 'package:driver_finance/features/vehicle/presentation/pages/vehicle_form_page.dart';
import 'package:driver_finance/features/vehicle/presentation/providers/vehicle_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _pageCtrl = PageController();
  int _currentPage = 0;

  static const _totalPages = 4;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _seedPlatforms();
    });
  }

  void _seedPlatforms() {
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user != null) {
      ref
          .read(platformSelectionNotifierProvider.notifier)
          .seed(user.id);
    }
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _OnboardingHeader(
              currentPage: _currentPage,
              totalPages: _totalPages,
              onSkip: _finish,
            ),
            Expanded(
              child: PageView(
                controller: _pageCtrl,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _WelcomePage(onNext: _nextPage),
                  _VehicleStep(onNext: _nextPage),
                  _PlatformStep(onNext: _nextPage),
                  _GoalStep(onFinish: _finish),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _nextPage() {
    setState(() => _currentPage++);
    _pageCtrl.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _finish() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool('onboarding_done', true);
    if (!mounted) return;
    context.go('/app/dashboard');
  }
}

class _OnboardingHeader extends StatelessWidget {
  const _OnboardingHeader({
    required this.currentPage,
    required this.totalPages,
    required this.onSkip,
  });

  final int currentPage;
  final int totalPages;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Row(
            children: List.generate(totalPages, (i) {
              final active = i == currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 6),
                width: active ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : AppColors.textSecondary,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
          const Spacer(),
          if (currentPage < totalPages - 1)
            TextButton(
              onPressed: onSkip,
              child: const Text('Pular'),
            ),
        ],
      ),
    );
  }
}

class _WelcomePage extends StatelessWidget {
  const _WelcomePage({required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final features = [
      (Icons.attach_money_rounded, 'Registre corridas e ganhos'),
      (Icons.local_gas_station_rounded, 'Controle combustível e despesas'),
      (Icons.bar_chart_rounded, 'Dashboard com lucro real'),
      (Icons.smart_toy_rounded, 'IA para análises financeiras'),
    ];

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.directions_car_rounded, size: 80, color: AppColors.primary),
          const SizedBox(height: 24),
          Text(
            'Bem-vindo ao Driver Finance!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Gerencie seus ganhos e despesas como motorista de app.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ...features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Icon(f.$1, color: AppColors.primary, size: 22),
                    const SizedBox(width: 12),
                    Text(f.$2,
                        style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              )),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: onNext,
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            child: const Text('Começar'),
          ),
        ],
      ),
    );
  }
}

class _VehicleStep extends ConsumerWidget {
  const _VehicleStep({required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicleAsync = ref.watch(watchVehicleProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Seu veículo',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Cadastre seu veículo para cálculos de depreciação e consumo.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          vehicleAsync.when(
            loading: () => const CircularProgressIndicator(),
            error: (_, __) => const SizedBox(),
            data: (vehicle) {
              if (vehicle != null) {
                return _VehicleSummaryCard(
                  make: vehicle.make,
                  model: vehicle.model,
                );
              }
              return OutlinedButton.icon(
                onPressed: () => _openVehicleForm(context),
                icon: const Icon(Icons.add),
                label: const Text('Adicionar veículo'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
              );
            },
          ),
          const Spacer(),
          FilledButton(
            onPressed: onNext,
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            child: const Text('Próximo'),
          ),
        ],
      ),
    );
  }

  Future<void> _openVehicleForm(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute<bool>(
        builder: (_) => const VehicleFormPage(),
      ),
    );
  }
}

class _VehicleSummaryCard extends StatelessWidget {
  const _VehicleSummaryCard({required this.make, required this.model});

  final String make;
  final String model;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.directions_car_rounded, color: AppColors.primary),
        title: Text('$make $model'),
        subtitle: const Text('Cadastrado ✓'),
        trailing: const Icon(Icons.check_circle, color: AppColors.income),
      ),
    );
  }
}

class _PlatformStep extends ConsumerWidget {
  const _PlatformStep({required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final platformsAsync = ref.watch(watchPlatformsProvider);
    final notifier = ref.read(platformSelectionNotifierProvider.notifier);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Plataformas de trabalho',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Selecione em quais apps você trabalha.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: platformsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox(),
              data: (platforms) => ListView.builder(
                itemCount: platforms.length,
                itemBuilder: (_, i) {
                  final p = platforms[i];
                  return CheckboxListTile(
                    title: Text(p.displayName),
                    value: p.isActive,
                    onChanged: (v) =>
                        notifier.toggle(p.id, isActive: v ?? true),
                  );
                },
              ),
            ),
          ),
          FilledButton(
            onPressed: onNext,
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            child: const Text('Próximo'),
          ),
        ],
      ),
    );
  }
}

class _GoalStep extends ConsumerStatefulWidget {
  const _GoalStep({required this.onFinish});

  final VoidCallback onFinish;

  @override
  ConsumerState<_GoalStep> createState() => _GoalStepState();
}

class _GoalStepState extends ConsumerState<_GoalStep> {
  final _goalCtrl = TextEditingController();
  int _workingDays = 26;

  @override
  void dispose() {
    _goalCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Sua meta mensal',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Defina quanto quer ganhar por mês (pode mudar depois).',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _goalCtrl,
            decoration: const InputDecoration(
              labelText: 'Meta mensal (R\$)',
              hintText: '3000,00',
              prefixText: 'R\$ ',
              border: OutlineInputBorder(),
            ),
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d,.]')),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Dias úteis/mês',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: _workingDays > 1
                    ? () => setState(() => _workingDays--)
                    : null,
              ),
              Text('$_workingDays',
                  style: Theme.of(context).textTheme.titleMedium),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: _workingDays < 31
                    ? () => setState(() => _workingDays++)
                    : null,
              ),
            ],
          ),
          const Spacer(),
          FilledButton(
            onPressed: _saveAndFinish,
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            child: const Text('Começar a usar'),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: widget.onFinish,
            child: const Text('Definir depois'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveAndFinish() async {
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) {
      widget.onFinish();
      return;
    }

    final raw = _goalCtrl.text.replaceAll('.', '').replaceAll(',', '.');
    final amount = double.tryParse(raw) ?? 0;
    if (amount > 0) {
      await ref.read(goalNotifierProvider.notifier).setGoal(
            userId: user.id,
            monthlyTargetCents: (amount * 100).round(),
            workingDaysPerMonth: _workingDays,
          );
    }
    widget.onFinish();
  }
}
