import 'dart:async';

import 'package:driver_finance/core/notifications/goal_notification_service.dart';
import 'package:driver_finance/core/notifications/maintenance_alert_scheduler.dart';
import 'package:driver_finance/core/ui/theme/app_colors.dart';
import 'package:driver_finance/core/utils/currency_formatter.dart';
import 'package:driver_finance/features/dashboard/domain/entities/daily_revenue.dart';
import 'package:driver_finance/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:driver_finance/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:driver_finance/features/expenses/presentation/pages/expense_form_page.dart';
import 'package:driver_finance/features/fuel/presentation/pages/fuel_form_page.dart';
import 'package:driver_finance/features/maintenance/domain/entities/maintenance_record.dart';
import 'package:driver_finance/features/maintenance/presentation/pages/maintenance_form_page.dart';
import 'package:driver_finance/features/maintenance/presentation/pages/maintenance_list_page.dart';
import 'package:driver_finance/features/maintenance/presentation/providers/maintenance_provider.dart';
import 'package:driver_finance/features/trips/presentation/pages/trip_form_page.dart';
import 'package:fl_chart/fl_chart.dart';
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

    ref.listen<AsyncValue<List<MaintenanceRecord>>>(
      watchMaintenanceProvider,
      (prev, next) {
        if (prev == null) return;
        final records = next.valueOrNull;
        if (records != null) {
          unawaited(MaintenanceAlertScheduler.rescheduleAll(records));
        }
      },
    );

    ref.listen<DashboardSummary?>(
      dashboardSummaryProvider(range),
      (prev, next) {
        if (prev == null) return;
        final wasNotMet = (prev.goalProgress ?? 0) < 1.0;
        final isNowMet = (next?.goalProgress ?? 0) >= 1.0;
        if (wasNotMet && isNowMet) {
          unawaited(GoalNotificationService.notifyGoalReached());
        }
      },
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: summary == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const _MaintenanceAlertCard(),
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
                _DailyRevenueChart(dailyRevenues: summary.dailyRevenues),
                if (summary.dailyRevenues.isNotEmpty)
                  const SizedBox(height: 16),
                const _QuickActions(),
              ],
            ),
    );
  }
}

class _MaintenanceAlertCard extends ConsumerWidget {
  const _MaintenanceAlertCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(watchMaintenanceProvider).valueOrNull ?? [];
    final now = DateTime.now();
    final threshold = now.add(const Duration(days: 7));
    final alerts = records.where((r) {
      if (r.nextMaintenanceDate != null &&
          !r.nextMaintenanceDate!.isAfter(threshold)) {
        return true;
      }
      return false;
    }).toList();

    if (alerts.isEmpty) return const SizedBox.shrink();

    final overdue = alerts
        .where((r) =>
            r.nextMaintenanceDate != null &&
            r.nextMaintenanceDate!.isBefore(now))
        .length;
    final label = overdue > 0
        ? '$overdue manutenção(ões) em atraso'
        : '${alerts.length} manutenção(ões) próxima(s)';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        color: AppColors.warning.withValues(alpha: 0.12),
        child: ListTile(
          leading: Icon(
            Icons.warning_amber_rounded,
            color: overdue > 0 ? AppColors.expense : AppColors.warning,
          ),
          title: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: overdue > 0 ? AppColors.expense : AppColors.warning,
            ),
          ),
          subtitle: const Text('Toque para ver detalhes'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const MaintenanceListPage(),
            ),
          ),
        ),
      ),
    );
  }
}

class _DailyRevenueChart extends StatelessWidget {
  const _DailyRevenueChart({required this.dailyRevenues});

  final List<DailyRevenue> dailyRevenues;

  @override
  Widget build(BuildContext context) {
    if (dailyRevenues.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                'Receita por dia',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 140,
              child: BarChart(
                BarChartData(
                  barGroups: dailyRevenues.asMap().entries.map((entry) {
                    final i = entry.key;
                    final d = entry.value;
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: d.amountCents / 100,
                          color: AppColors.income,
                          width: dailyRevenues.length > 15 ? 8 : 14,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(3),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (value, meta) {
                          final i = value.toInt();
                          if (i < 0 || i >= dailyRevenues.length) {
                            return const SizedBox();
                          }
                          final date = dailyRevenues[i].date;
                          if (dailyRevenues.length > 15 && date.day % 5 != 0) {
                            return const SizedBox();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              '${date.day}',
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          formatCurrency((rod.toY * 100).round()),
                          const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
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
              backgroundColor: barColor.withValues(alpha: 0.15),
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
          if (summary.depreciationCents > 0)
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFF3E5F5),
                child: Icon(
                  Icons.trending_down_rounded,
                  color: Color(0xFF7B1FA2),
                  size: 20,
                ),
              ),
              title: const Text('Depreciação'),
              trailing: Text(
                formatCurrency(summary.depreciationCents),
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
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<bool>(
                    builder: (_) => const MaintenanceFormPage(),
                  ),
                ),
                icon: const Icon(Icons.build_outlined, size: 18),
                label: const Text('Manutenção'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
