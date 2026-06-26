import 'package:driver_finance/core/ui/theme/app_colors.dart';
import 'package:driver_finance/core/utils/currency_formatter.dart';
import 'package:driver_finance/features/platform/presentation/providers/platform_provider.dart';
import 'package:driver_finance/features/trips/domain/entities/trip.dart';
import 'package:driver_finance/features/trips/presentation/pages/trip_form_page.dart';
import 'package:driver_finance/features/trips/presentation/providers/trip_provider.dart';
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

class TripListPage extends ConsumerStatefulWidget {
  const TripListPage({super.key});

  @override
  ConsumerState<TripListPage> createState() => _TripListPageState();
}

class _TripListPageState extends ConsumerState<TripListPage> {
  _Period _period = _Period.thisMonth;

  @override
  Widget build(BuildContext context) {
    final (start, end) = _period.range;
    final tripsAsync = ref.watch(watchTripsProvider((start, end)));
    final platformsAsync = ref.watch(watchPlatformsProvider);

    final platformMap = {
      for (final p in platformsAsync.value ?? []) p.id: p.displayName,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Corridas'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: _PeriodSelector(
            selected: _period,
            onChanged: (p) => setState(() => _period = p),
          ),
        ),
      ),
      body: tripsAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (trips) {
          if (trips.isEmpty) {
            return const _EmptyState();
          }
          final total = trips.fold(0, (s, t) => s + t.totalIncomeCents);
          return Column(
            children: [
              _TotalBanner(totalCents: total, count: trips.length),
              Expanded(
                child: ListView.builder(
                  itemCount: trips.length,
                  itemBuilder: (_, i) => _TripTile(
                    trip: trips[i],
                    platformName:
                        platformMap[trips[i].platformId] ?? '—',
                    onDelete: () => _delete(trips[i].id),
                    onEdit: () => _openForm(trips[i]),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(null),
        icon: const Icon(Icons.add),
        label: const Text('Corrida'),
      ),
    );
  }

  Future<void> _openForm(Trip? existing) async {
    await Navigator.of(context).push(
      MaterialPageRoute<bool>(
        builder: (_) => TripFormPage(existingTrip: existing),
      ),
    );
  }

  Future<void> _delete(String tripId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir corrida?'),
        content: const Text('Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.expense,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(tripFormNotifierProvider.notifier).delete(tripId);
    }
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
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
      ),
    );
  }
}

class _TotalBanner extends StatelessWidget {
  const _TotalBanner({
    required this.totalCents,
    required this.count,
  });

  final int totalCents;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.income.withValues(alpha: 0.1),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$count corrida${count != 1 ? 's' : ''}'),
          Text(
            formatCurrency(totalCents),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.income,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _TripTile extends StatelessWidget {
  const _TripTile({
    required this.trip,
    required this.platformName,
    required this.onDelete,
    required this.onEdit,
  });

  final Trip trip;
  final String platformName;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(trip.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: AppColors.expense,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async => false,
      onDismissed: (_) {},
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.income.withValues(alpha: 0.15),
          child: const Icon(
            Icons.directions_car_rounded,
            color: AppColors.income,
            size: 20,
          ),
        ),
        title: Text(platformName),
        subtitle: Text(formatDate(trip.tripDate)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              formatCurrency(trip.totalIncomeCents),
              style: const TextStyle(
                color: AppColors.income,
                fontWeight: FontWeight.w600,
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (v) {
                if (v == 'edit') onEdit();
                if (v == 'delete') onDelete();
              },
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: 'edit',
                  child: Text('Editar'),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Text('Excluir'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions_car_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Nenhuma corrida no período',
            style: TextStyle(color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'Toque no botão + para registrar',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
