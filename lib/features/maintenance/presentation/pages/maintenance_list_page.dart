import 'package:driver_finance/core/ui/theme/app_colors.dart';
import 'package:driver_finance/core/utils/currency_formatter.dart';
import 'package:driver_finance/features/maintenance/domain/entities/maintenance_record.dart';
import 'package:driver_finance/features/maintenance/presentation/pages/maintenance_form_page.dart';
import 'package:driver_finance/features/maintenance/presentation/providers/maintenance_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MaintenanceListPage extends ConsumerWidget {
  const MaintenanceListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maintenanceAsync = ref.watch(watchMaintenanceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Manutenções')),
      body: maintenanceAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) =>
            const Center(child: Text('Erro ao carregar manutenções')),
        data: (records) => records.isEmpty
            ? _EmptyState(onAdd: () => _openForm(context))
            : _MaintenanceContent(
                records: records,
                onDelete: (id) => ref
                    .read(maintenanceNotifierProvider.notifier)
                    .deleteRecord(id),
                onAdd: () => _openForm(context),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _openForm(BuildContext context) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const MaintenanceFormPage()),
    );
  }
}

class _MaintenanceContent extends StatelessWidget {
  const _MaintenanceContent({
    required this.records,
    required this.onDelete,
    required this.onAdd,
  });

  final List<MaintenanceRecord> records;
  final void Function(String id) onDelete;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final totalCents = records.fold<int>(0, (s, r) => s + r.costCents);

    final upcoming = records
        .where(
            (r) => r.nextMaintenanceKm != null || r.nextMaintenanceDate != null)
        .toList()
      ..sort((a, b) {
        final aDate = a.nextMaintenanceDate;
        final bDate = b.nextMaintenanceDate;
        if (aDate != null && bDate != null) return aDate.compareTo(bDate);
        if (aDate != null) return -1;
        if (bDate != null) return 1;
        return (a.nextMaintenanceKm ?? 0).compareTo(b.nextMaintenanceKm ?? 0);
      });

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        _CostSummaryCard(totalCents: totalCents, count: records.length),
        if (upcoming.isNotEmpty) ...[
          const SizedBox(height: 4),
          _SectionHeader(title: 'Próximas Revisões (${upcoming.length})'),
          ...upcoming.map((r) => _UpcomingTile(record: r)),
          const Divider(height: 1),
        ],
        const _SectionHeader(title: 'Histórico'),
        ...records.asMap().entries.map((entry) {
          final i = entry.key;
          final r = entry.value;
          return Column(
            children: [
              _MaintenanceTile(
                record: r,
                onDelete: () => onDelete(r.id),
              ),
              if (i < records.length - 1) const Divider(height: 1),
            ],
          );
        }),
      ],
    );
  }
}

class _CostSummaryCard extends StatelessWidget {
  const _CostSummaryCard({required this.totalCents, required this.count});

  final int totalCents;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Color(0xFFE3F2FD),
              child: Icon(Icons.build_rounded, color: Colors.blue, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total em manutenções',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatCurrency(totalCents),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.expense,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),
            Text(
              '$count serviços',
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 0.6,
            ),
      ),
    );
  }
}

class _UpcomingTile extends StatelessWidget {
  const _UpcomingTile({required this.record});

  final MaintenanceRecord record;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isUrgent = record.nextMaintenanceDate != null &&
        record.nextMaintenanceDate!.difference(now).inDays <= 7;
    final urgentColor = isUrgent ? AppColors.warning : AppColors.income;

    String subtitle = '';
    if (record.nextMaintenanceDate != null) {
      final days = record.nextMaintenanceDate!.difference(now).inDays;
      if (days < 0) {
        subtitle = 'Atrasada há ${-days} dias';
      } else if (days == 0) {
        subtitle = 'Hoje';
      } else {
        subtitle = 'Em $days dias (${formatDate(record.nextMaintenanceDate!)})';
      }
    } else if (record.nextMaintenanceKm != null) {
      subtitle = 'Próxima em ${record.nextMaintenanceKm} km';
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: urgentColor.withValues(alpha: 0.12),
        child: Icon(
          Icons.schedule_rounded,
          color: urgentColor,
          size: 20,
        ),
      ),
      title: Text(record.type),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: urgentColor, fontSize: 12),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.build_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhuma manutenção registrada',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Registre revisões, trocas de óleo e outros serviços.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Registrar manutenção'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MaintenanceTile extends StatelessWidget {
  const _MaintenanceTile({required this.record, required this.onDelete});

  final MaintenanceRecord record;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(record.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: AppColors.expense,
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (_) => showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Excluir manutenção'),
          content: const Text('Esta manutenção será removida.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Excluir'),
            ),
          ],
        ),
      ),
      onDismissed: (_) => onDelete(),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFE3F2FD),
          child: Icon(Icons.build_rounded, color: Colors.blue, size: 20),
        ),
        title: Text(record.type),
        subtitle: _buildSubtitle(),
        isThreeLine: record.nextMaintenanceKm != null,
        trailing: Text(
          formatCurrency(record.costCents),
          style: const TextStyle(
            color: AppColors.expense,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSubtitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(formatDate(record.maintenanceDate)),
        if (record.nextMaintenanceKm != null)
          Text(
            'Próxima: ${record.nextMaintenanceKm} km',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
      ],
    );
  }
}
