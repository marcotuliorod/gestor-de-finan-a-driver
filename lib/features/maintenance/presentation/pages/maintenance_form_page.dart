import 'package:driver_finance/core/utils/currency_formatter.dart';
import 'package:driver_finance/features/auth/presentation/providers/auth_provider.dart';
import 'package:driver_finance/features/maintenance/presentation/providers/maintenance_provider.dart';
import 'package:driver_finance/features/vehicle/presentation/providers/vehicle_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MaintenanceFormPage extends ConsumerStatefulWidget {
  const MaintenanceFormPage({super.key});

  @override
  ConsumerState<MaintenanceFormPage> createState() =>
      _MaintenanceFormPageState();
}

class _MaintenanceFormPageState extends ConsumerState<MaintenanceFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _costCtrl = TextEditingController();
  final _odometerCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _nextKmCtrl = TextEditingController();

  String _type = 'Troca de óleo';
  DateTime _maintenanceDate = DateTime.now();
  DateTime? _nextMaintenanceDate;
  bool _isSaving = false;

  static const _maintenanceTypes = [
    'Troca de óleo',
    'Freios',
    'Pneus',
    'Revisão geral',
    'Filtros',
    'Correia dentada',
    'Suspensão',
    'Elétrica',
    'Outros',
  ];

  @override
  void dispose() {
    _costCtrl.dispose();
    _odometerCtrl.dispose();
    _descriptionCtrl.dispose();
    _nextKmCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final user = ref.read(authRepositoryProvider).currentUser;
    final vehicle = ref.read(watchVehicleProvider).valueOrNull;

    if (user == null || vehicle == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veículo não encontrado')),
        );
      }
      setState(() => _isSaving = false);
      return;
    }

    final costCents = ((parseCurrencyInput(_costCtrl.text) ?? 0) * 100).round();
    final odometer = int.tryParse(_odometerCtrl.text.replaceAll('.', '')) ?? 0;
    final nextKm = _nextKmCtrl.text.isNotEmpty
        ? int.tryParse(_nextKmCtrl.text.replaceAll('.', ''))
        : null;

    final result =
        await ref.read(maintenanceNotifierProvider.notifier).addRecord(
              userId: user.id,
              vehicleId: vehicle.id,
              type: _type,
              description: _descriptionCtrl.text.trim().isEmpty
                  ? null
                  : _descriptionCtrl.text.trim(),
              costCents: costCents,
              odometer: odometer,
              maintenanceDate: _maintenanceDate,
              nextMaintenanceKm: nextKm,
              nextMaintenanceDate: _nextMaintenanceDate,
            );

    if (!mounted) return;
    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
        setState(() => _isSaving = false);
      },
      (_) => Navigator.of(context).pop(true),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova Manutenção')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                initialValue: _type,
                decoration: const InputDecoration(
                  labelText: 'Tipo de manutenção',
                  border: OutlineInputBorder(),
                ),
                items: _maintenanceTypes
                    .map(
                      (t) => DropdownMenuItem(value: t, child: Text(t)),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _type = v ?? _type),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionCtrl,
                decoration: const InputDecoration(
                  labelText: 'Descrição (opcional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _costCtrl,
                decoration: const InputDecoration(
                  labelText: 'Custo (R\$)',
                  prefixText: 'R\$ ',
                  border: OutlineInputBorder(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d,.]')),
                ],
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Campo obrigatório';
                  final val = parseCurrencyInput(v) ?? 0;
                  if (val < 0) return 'Valor inválido';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _odometerCtrl,
                decoration: const InputDecoration(
                  labelText: 'Odômetro atual (km)',
                  suffixText: 'km',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Campo obrigatório';
                  return null;
                },
              ),
              const SizedBox(height: 4),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Data da manutenção'),
                subtitle: Text(formatDate(_maintenanceDate)),
                trailing: const Icon(Icons.calendar_today_outlined),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _maintenanceDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null && mounted) {
                    setState(() => _maintenanceDate = picked);
                  }
                },
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  'Próxima revisão (opcional)',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              TextFormField(
                controller: _nextKmCtrl,
                decoration: const InputDecoration(
                  labelText: 'Km para próxima revisão',
                  suffixText: 'km',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Data da próxima revisão'),
                subtitle: Text(
                  _nextMaintenanceDate == null
                      ? 'Não definida'
                      : formatDate(_nextMaintenanceDate!),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_nextMaintenanceDate != null)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () =>
                            setState(() => _nextMaintenanceDate = null),
                      ),
                    const Icon(Icons.calendar_today_outlined),
                  ],
                ),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _nextMaintenanceDate ??
                        _maintenanceDate.add(const Duration(days: 90)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2035),
                  );
                  if (picked != null && mounted) {
                    setState(() => _nextMaintenanceDate = picked);
                  }
                },
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
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
      ),
    );
  }
}
