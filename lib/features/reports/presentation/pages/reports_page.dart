import 'package:driver_finance/core/ui/theme/app_colors.dart';
import 'package:driver_finance/core/utils/currency_formatter.dart';
import 'package:driver_finance/features/reports/domain/entities/platform_stats.dart';
import 'package:driver_finance/features/reports/domain/entities/reports_summary.dart';
import 'package:driver_finance/features/reports/presentation/providers/reports_provider.dart';
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

class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage> {
  _Period _period = _Period.thisMonth;

  @override
  Widget build(BuildContext context) {
    final range = _period.range;
    final summary = ref.watch(reportsSummaryProvider(range));

    return Scaffold(
      appBar: AppBar(title: const Text('Relatórios')),
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
                _SummaryRow(summary: summary),
                const SizedBox(height: 24),
                _IncomeBarChart(summary: summary),
                const SizedBox(height: 24),
                _ExpensePieChart(summary: summary),
                const SizedBox(height: 24),
                _PlatformBreakdown(period: range),
                const SizedBox(height: 16),
              ],
            ),
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({required this.selected, required this.onChanged});

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

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.summary});

  final ReportsSummary summary;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCard(
          label: 'Receita',
          value: formatCurrency(summary.totalIncomeCents),
          color: AppColors.income,
        ),
        const SizedBox(width: 8),
        _StatCard(
          label: 'Despesas',
          value: formatCurrency(summary.totalExpensesCents),
          color: AppColors.expense,
        ),
        const SizedBox(width: 8),
        _StatCard(
          label: 'Lucro',
          value: formatCurrency(summary.netProfitCents),
          color: summary.netProfitCents >= 0
              ? AppColors.income
              : AppColors.expense,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IncomeBarChart extends StatelessWidget {
  const _IncomeBarChart({required this.summary});

  final ReportsSummary summary;

  @override
  Widget build(BuildContext context) {
    final dailies = summary.dailyIncomes;

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
            const SizedBox(height: 16),
            if (dailies.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Text(
                    'Sem corridas no período',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              )
            else
              SizedBox(
                height: 180,
                child: BarChart(
                  BarChartData(
                    barGroups: dailies.asMap().entries.map((entry) {
                      final i = entry.key;
                      final d = entry.value;
                      return BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: d.amountCents / 100,
                            color: AppColors.income,
                            width: dailies.length > 15 ? 8 : 14,
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
                            if (i < 0 || i >= dailies.length) {
                              return const SizedBox();
                            }
                            final date = dailies[i].date;
                            if (dailies.length > 15 && date.day % 5 != 0) {
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

class _ExpensePieChart extends StatelessWidget {
  const _ExpensePieChart({required this.summary});

  final ReportsSummary summary;

  @override
  Widget build(BuildContext context) {
    final fuel = summary.fuelExpenseCents;
    final other = summary.otherExpenseCents;
    final total = fuel + other;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Distribuição de despesas',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            if (total == 0)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Text(
                    'Sem despesas no período',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              )
            else
              Row(
                children: [
                  SizedBox(
                    height: 140,
                    width: 140,
                    child: PieChart(
                      PieChartData(
                        sections: [
                          if (fuel > 0)
                            PieChartSectionData(
                              value: fuel.toDouble(),
                              title:
                                  '${(fuel / total * 100).toStringAsFixed(0)}%',
                              color: const Color(0xFFFF9800),
                              radius: 55,
                              titleStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          if (other > 0)
                            PieChartSectionData(
                              value: other.toDouble(),
                              title:
                                  '${(other / total * 100).toStringAsFixed(0)}%',
                              color: AppColors.expense,
                              radius: 55,
                              titleStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                        ],
                        centerSpaceRadius: 30,
                        sectionsSpace: 2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _LegendRow(
                          color: const Color(0xFFFF9800),
                          label: 'Combustível',
                          amount: formatCurrency(fuel),
                        ),
                        const SizedBox(height: 8),
                        _LegendRow(
                          color: AppColors.expense,
                          label: 'Outros',
                          amount: formatCurrency(other),
                        ),
                        const Divider(height: 16),
                        _LegendRow(
                          color: AppColors.textSecondary,
                          label: 'Total',
                          amount: formatCurrency(total),
                          bold: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _PlatformBreakdown extends ConsumerWidget {
  const _PlatformBreakdown({required this.period});

  final (DateTime, DateTime) period;

  static const _platformColors = {
    'Uber': Color(0xFF1A1A1A),
    '99': Color(0xFFF6AE00),
    'inDrive': Color(0xFF5BB543),
    'Táxi': Color(0xFF1565C0),
    'Delivery': Color(0xFFE65100),
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(platformStatsProvider(period));
    if (stats.isEmpty) return const SizedBox.shrink();

    final totalIncome = stats.fold<int>(0, (s, p) => s + p.incomeCents);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Receita por plataforma',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            ...stats.map((s) {
              final color =
                  _platformColors[s.platformName] ?? AppColors.primary;
              final pct = totalIncome > 0
                  ? s.incomeCents / totalIncome
                  : 0.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            s.platformName,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w500),
                          ),
                        ),
                        Text(
                          formatCurrency(s.incomeCents),
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 6,
                        backgroundColor: color.withOpacity(0.15),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '${s.tripCount} corridas',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                        const Spacer(),
                        Text(
                          'Ticket médio: ${formatCurrency(s.averageCents)}',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.color,
    required this.label,
    required this.amount,
    this.bold = false,
  });

  final Color color;
  final String label;
  final String amount;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: bold ? FontWeight.w600 : null,
                ),
          ),
        ),
        Text(
          amount,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                color: bold ? null : AppColors.textSecondary,
              ),
        ),
      ],
    );
  }
}
