import 'package:driver_finance/core/ui/theme/app_colors.dart';
import 'package:driver_finance/core/utils/currency_formatter.dart';
import 'package:driver_finance/features/expenses/domain/entities/expense.dart';
import 'package:driver_finance/features/expenses/presentation/pages/expense_form_page.dart';
import 'package:driver_finance/features/expenses/presentation/providers/expense_provider.dart';
import 'package:driver_finance/features/fuel/domain/entities/fuel_record.dart';
import 'package:driver_finance/features/fuel/presentation/pages/fuel_form_page.dart';
import 'package:driver_finance/features/fuel/presentation/providers/fuel_provider.dart';
import 'package:driver_finance/features/mileage/domain/entities/mileage_record.dart';
import 'package:driver_finance/features/mileage/presentation/pages/mileage_form_page.dart';
import 'package:driver_finance/features/mileage/presentation/providers/mileage_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum _ExpensePeriod { thisMonth, threeMonths, thisYear }

extension on _ExpensePeriod {
  String get label => switch (this) {
        _ExpensePeriod.thisMonth => 'Este mês',
        _ExpensePeriod.threeMonths => 'Últimos 3 meses',
        _ExpensePeriod.thisYear => 'Este ano',
      };

  (DateTime, DateTime) get range {
    final now = DateTime.now();
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final start = switch (this) {
      _ExpensePeriod.thisMonth => DateTime(now.year, now.month),
      _ExpensePeriod.threeMonths => DateTime(now.year, now.month - 2),
      _ExpensePeriod.thisYear => DateTime(now.year),
    };
    return (start, end);
  }
}

class ExpenseListPage extends ConsumerStatefulWidget {
  const ExpenseListPage({super.key});

  @override
  ConsumerState<ExpenseListPage> createState() => _ExpenseListPageState();
}

class _ExpenseListPageState extends ConsumerState<ExpenseListPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _tabs.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Despesas'),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: 'Combustível'),
            Tab(text: 'Outras'),
            Tab(text: 'Quilometragem'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: const [
          _FuelTab(),
          _ExpensesTab(),
          _MileageTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAdd,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _openAdd() async {
    final tab = _tabs.index;
    if (tab == 0) {
      await Navigator.of(context).push(
        MaterialPageRoute<bool>(builder: (_) => const FuelFormPage()),
      );
    } else if (tab == 1) {
      await Navigator.of(context).push(
        MaterialPageRoute<bool>(builder: (_) => const ExpenseFormPage()),
      );
    } else {
      await Navigator.of(context).push(
        MaterialPageRoute<bool>(builder: (_) => const MileageFormPage()),
      );
    }
  }
}

class _FuelTab extends ConsumerWidget {
  const _FuelTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fuelAsync = ref.watch(watchFuelRecordsProvider);
    return fuelAsync.when(
      loading: () =>
          const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erro: $e')),
      data: (records) {
        if (records.isEmpty) {
          return const _EmptyState(
            icon: Icons.local_gas_station_rounded,
            message: 'Nenhum abastecimento registrado',
          );
        }
        return ListView.builder(
          itemCount: records.length,
          itemBuilder: (_, i) => _FuelTile(record: records[i]),
        );
      },
    );
  }
}

class _FuelTile extends StatelessWidget {
  const _FuelTile({required this.record});

  final FuelRecord record;

  @override
  Widget build(BuildContext context) {
    final pricePerLiter =
        record.pricePerLiter.toStringAsFixed(3).replaceAll('.', ',');
    return ListTile(
      leading: const CircleAvatar(
        backgroundColor: Color(0xFFFFF3E0),
        child: Icon(
          Icons.local_gas_station_rounded,
          color: Colors.orange,
          size: 20,
        ),
      ),
      title: Text(
        '${record.liters.toStringAsFixed(2).replaceAll('.', ',')} L'
        ' • R\$ $pricePerLiter/L',
      ),
      subtitle: Text(formatDate(record.recordDate)),
      trailing: Text(
        formatCurrency(record.amountCents),
        style: const TextStyle(
          color: AppColors.expense,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ExpensesTab extends ConsumerStatefulWidget {
  const _ExpensesTab();

  @override
  ConsumerState<_ExpensesTab> createState() => _ExpensesTabState();
}

class _ExpensesTabState extends ConsumerState<_ExpensesTab> {
  _ExpensePeriod _period = _ExpensePeriod.thisMonth;

  @override
  Widget build(BuildContext context) {
    final range = _period.range;
    final expensesAsync = ref.watch(watchExpensesProvider(range));

    return Column(
      children: [
        _PeriodChips(
          selected: _period,
          onChanged: (p) => setState(() => _period = p),
        ),
        Expanded(
          child: expensesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Erro: $e')),
            data: (expenses) {
              if (expenses.isEmpty) {
                return _EmptyState(
                  icon: Icons.receipt_long_outlined,
                  message: 'Nenhuma despesa em ${_period.label.toLowerCase()}',
                );
              }
              final total =
                  expenses.fold<int>(0, (s, e) => s + e.amountCents);
              return Column(
                children: [
                  _TotalBanner(totalCents: total),
                  Expanded(
                    child: ListView.builder(
                      itemCount: expenses.length,
                      itemBuilder: (_, i) =>
                          _ExpenseTile(expense: expenses[i]),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PeriodChips extends StatelessWidget {
  const _PeriodChips({required this.selected, required this.onChanged});

  final _ExpensePeriod selected;
  final ValueChanged<_ExpensePeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: _ExpensePeriod.values
            .map(
              (p) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(p.label),
                  selected: p == selected,
                  onSelected: (_) => onChanged(p),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  const _ExpenseTile({required this.expense});

  final Expense expense;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.expense.withOpacity(0.1),
        child: const Icon(
          Icons.receipt_outlined,
          color: AppColors.expense,
          size: 20,
        ),
      ),
      title: Text(expense.category.label),
      subtitle: Text(
        '${formatDate(expense.expenseDate)}'
        '${expense.description != null ? ' • ${expense.description}' : ''}',
      ),
      trailing: Text(
        formatCurrency(expense.amountCents),
        style: const TextStyle(
          color: AppColors.expense,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _MileageTab extends ConsumerWidget {
  const _MileageTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final range = _ExpensePeriod.thisMonth.range;
    final mileageAsync = ref.watch(watchMileageProvider(range));
    return mileageAsync.when(
      loading: () =>
          const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erro: $e')),
      data: (records) {
        if (records.isEmpty) {
          return const _EmptyState(
            icon: Icons.speed_rounded,
            message: 'Nenhum km registrado este mês',
          );
        }
        final totalWork = records.fold(0, (s, r) => s + r.workKm);
        return Column(
          children: [
            Container(
              color: AppColors.primary.withOpacity(0.08),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total trabalho'),
                  Text(
                    '$totalWork km',
                    style:
                        Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: records.length,
                itemBuilder: (_, i) =>
                    _MileageTile(record: records[i]),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MileageTile extends StatelessWidget {
  const _MileageTile({required this.record});

  final MileageRecord record;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(
        backgroundColor: Color(0xFFE3F2FD),
        child: Icon(Icons.speed_rounded, color: Colors.blue, size: 20),
      ),
      title: Text('${record.workKm} km trabalho'),
      subtitle: Text(
        '${formatDate(record.recordDate)}'
        ' • ${record.startOdometer}→${record.endOdometer} km',
      ),
      trailing: record.personalKm > 0
          ? Text(
              '${record.personalKm} km pessoal',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            )
          : null,
    );
  }
}

class _TotalBanner extends StatelessWidget {
  const _TotalBanner({required this.totalCents});

  final int totalCents;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.expense.withOpacity(0.08),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Total este mês'),
          Text(
            formatCurrency(totalCents),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.expense,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.message,
  });

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          const Text(
            'Toque no botão + para adicionar',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
