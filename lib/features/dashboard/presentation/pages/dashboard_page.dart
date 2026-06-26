import 'package:driver_finance/core/ui/theme/app_colors.dart';
import 'package:driver_finance/core/utils/currency_formatter.dart';
import 'package:driver_finance/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:driver_finance/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:driver_finance/features/expenses/presentation/pages/expense_form_page.dart';
import 'package:driver_finance/features/fuel/presentation/pages/fuel_form_page.dart';
import 'package:driver_finance/features/trips/presentation/pages/trip_form_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum _Period { today, thisWeek, thisMonth }

extension on _Period {
  String get label => switch (this) {
        _Period.today => 'Hoje',
        _Period.thisWeek => 'Semana',
        _Period.thisMonth => 'Mês',
      };

  (DateTime, DateTime) get range {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return switch (this) {
      _Period.today => (today, endOfDay),
      _Period.thisWeek => (
          today.subtract(Duration(days: today.weekday - 1)),
          endOfDay,
        ),
      _Period.thisMonth => (
          DateTime(now.year, now.month),
          endOfDay,
        ),
    };
  }
}

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  _Period _period = _Period.thisMonth;

  @override
  Widget build(BuildContext context) {
    final range = _period.range;
    final summary = ref.watch(dashboardSummaryProvider(range));

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: summary == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _PeriodSelector(
                  selected: _period,
                  onChanged: (p) => setState(() => _period = p),
                ),
                const SizedBox(height: 16),
                _KpiRow(summary: summary),
                const SizedBox(height: 16),
                if (summary.monthlyGoalCents != null) ...[
                  _GoalCard(summary: summary),
                  const SizedBox(height: 16),
                ],
                _ExpenseBreakdown(summary: summary),
                const SizedBox(height: 16),
                const _QuickActions(),
              ],
            ),
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({
    required this.selected,
    required this.onChanged,
  });

  final _Period selected;
  final ValueChanged<_Period> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _Period.values
          .map(
            (p) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(p.label),
                  selected: p == selected,
                  onSelected: (_) => onChanged(p),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _KpiRow extends StatelessWidget {
  const _KpiRow({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _KpiCard(
            icon: Icons.arrow_upward_rounded,
            label: 'Receita',
            amountCents: summary.totalIncomeCents,
            color: AppColors.income,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _KpiCard(
            icon: Icons.arrow_downward_rounded,
            label: 'Despesas',
            amountCents: summary.totalExpensesCents,
            color: AppColors.expense,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _KpiCard(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Lucro',
            amountCents: summary.netProfitCents,
            color: summary.netProfitCents >= 0
                ? AppColors.income
                : AppColors.expense,
          ),
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.icon,
    required this.label,
    required this.amountCents,
    required this.color,
  });

  final IconData icon;
  final String label;
  final int amountCents;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                formatCurrency(amountCents),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final progress = summary.goalProgress!;
    final clampedProgress = progress.clamp(0.0, 1.0);
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final expectedProgress = now.day / daysInMonth;
    final isAhead = summary.isGoalMet || progress >= expectedProgress;
    final barColor = isAhead ? AppColors.income : AppColors.warning;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Meta do mês',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  '${(progress * 100).toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: barColor,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: clampedProgress,
              color: barColor,
              backgroundColor: barColor.withOpacity(0.15),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            if (summary.isGoalMet)
              Text(
                'Meta atingida!',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.income,
                      fontWeight: FontWeight.w600,
                    ),
              )
            else
              Text(
                '${formatCurrency(summary.totalIncomeCents)} de '
                '${formatCurrency(summary.monthlyGoalCents!)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ExpenseBreakdown extends StatelessWidget {
  const _ExpenseBreakdown({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Text(
              'Despesas',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFFFFF3E0),
              child: Icon(
                Icons.local_gas_station_rounded,
                color: Colors.orange,
                size: 20,
              ),
            ),
            title: const Text('Combustível'),
            trailing: Text(
              formatCurrency(summary.fuelExpenseCents),
              style: const TextStyle(
                color: AppColors.expense,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFFFFEBEE),
              child: Icon(
                Icons.receipt_outlined,
                color: AppColors.expense,
                size: 20,
              ),
            ),
            title: const Text('Outros'),
            trailing: Text(
              formatCurrency(summary.otherExpenseCents),
              style: const TextStyle(
                color: AppColors.expense,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  formatCurrency(summary.totalExpensesCents),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.expense,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Registrar',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<bool>(
                    builder: (_) => const TripFormPage(),
                  ),
                ),
                icon: const Icon(Icons.directions_car_rounded, size: 18),
                label: const Text('Corrida'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<bool>(
                    builder: (_) => const ExpenseFormPage(),
                  ),
                ),
                icon: const Icon(Icons.receipt_outlined, size: 18),
                label: const Text('Despesa'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<bool>(
                    builder: (_) => const FuelFormPage(),
                  ),
                ),
                icon: const Icon(Icons.local_gas_station_rounded, size: 18),
                label: const Text('Abastec.'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
