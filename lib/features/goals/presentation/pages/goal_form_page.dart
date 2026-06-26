import 'package:driver_finance/core/ui/theme/app_colors.dart';
import 'package:driver_finance/core/utils/currency_formatter.dart';
import 'package:driver_finance/features/auth/presentation/providers/auth_provider.dart';
import 'package:driver_finance/features/goals/domain/entities/financial_goal.dart';
import 'package:driver_finance/features/goals/presentation/providers/goal_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GoalFormPage extends ConsumerStatefulWidget {
  const GoalFormPage({super.key, this.existingGoal});

  final FinancialGoal? existingGoal;

  @override
  ConsumerState<GoalFormPage> createState() => _GoalFormPageState();
}

class _GoalFormPageState extends ConsumerState<GoalFormPage> {
  final _amountCtrl = TextEditingController();
  int _workingDays = 26;

  @override
  void initState() {
    super.initState();
    final goal = widget.existingGoal;
    if (goal != null) {
      _amountCtrl.text =
          (goal.monthlyTargetCents / 100).toStringAsFixed(2).replaceAll('.', ',');
      _workingDays = goal.workingDaysPerMonth;
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = ref.watch(goalNotifierProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Meta mensal')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Quanto você quer ganhar por mês?',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _amountCtrl,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Meta mensal (R\$)',
                prefixText: 'R\$ ',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d,\.]')),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Dias de trabalho por mês: $_workingDays',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Slider(
              value: _workingDays.toDouble(),
              min: 10,
              max: 31,
              divisions: 21,
              label: '$_workingDays dias',
              onChanged: (v) => setState(() => _workingDays = v.round()),
            ),
            if (_parseCents() > 0) ...[
              const SizedBox(height: 4),
              Text(
                'Meta diária: ${formatCurrency(_parseCents() ~/ _workingDays)}',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.textSecondary),
              ),
            ],
            const Spacer(),
            FilledButton(
              onPressed: isSaving ? null : _save,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              child: isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }

  int _parseCents() {
    final raw =
        _amountCtrl.text.trim().replaceAll(',', '.').replaceAll(' ', '');
    final value = double.tryParse(raw) ?? 0;
    return (value * 100).round();
  }

  Future<void> _save() async {
    final cents = _parseCents();
    if (cents <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe um valor válido')),
      );
      return;
    }

    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) return;

    final result = await ref.read(goalNotifierProvider.notifier).setGoal(
          userId: user.id,
          monthlyTargetCents: cents,
          workingDaysPerMonth: _workingDays,
        );

    if (!mounted) return;
    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      ),
      (_) => Navigator.of(context).pop(true),
    );
  }
}
