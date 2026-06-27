import 'package:driver_finance/core/ui/theme/app_colors.dart';
import 'package:driver_finance/core/utils/currency_formatter.dart';
import 'package:driver_finance/features/auth/presentation/providers/auth_provider.dart';
import 'package:driver_finance/features/fuel/presentation/providers/fuel_provider.dart';
import 'package:driver_finance/features/vehicle/presentation/providers/vehicle_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FuelFormPage extends ConsumerStatefulWidget {
  const FuelFormPage({super.key});

  @override
  ConsumerState<FuelFormPage> createState() => _FuelFormPageState();
}

class _FuelFormPageState extends ConsumerState<FuelFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _litersCtrl = TextEditingController();
  final _odometerCtrl = TextEditingController();

  String _fuelType = 'gasoline';
  DateTime _recordDate = DateTime.now();

  static const _fuelTypes = [
    ('gasoline', 'Gasolina'),
    ('ethanol', 'Etanol'),
    ('diesel', 'Diesel'),
    ('flex', 'Flex'),
  ];

  @override
  void dispose() {
    _amountCtrl.dispose();
    _litersCtrl.dispose();
    _odometerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Abastecimento')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _amountCtrl,
                decoration: const InputDecoration(
                  labelText: 'Valor total (R\$)',
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
                  if (val <= 0) return 'Valor deve ser maior que zero';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _litersCtrl,
                decoration: const InputDecoration(
                  labelText: 'Litros abastecidos',
                  suffixText: 'L',
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
                  if (val <= 0) return 'Litros deve ser maior que zero';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _odometerCtrl,
                decoration: const InputDecoration(
                  labelText: 'Km atual (odômetro)',
                  suffixText: 'km',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Campo obrigatório';
                  if (int.tryParse(v) == null) return 'Valor inválido';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _fuelType,
                decoration: const InputDecoration(
                  labelText: 'Tipo de combustível',
                  border: OutlineInputBorder(),
                ),
                items: _fuelTypes
                    .map(
                      (ft) => DropdownMenuItem(
                        value: ft.$1,
                        child: Text(ft.$2),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _fuelType = v!),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today),
                title: Text('Data: ${formatDate(_recordDate)}'),
                onTap: _pickDate,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _save,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text('Salvar abastecimento'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _recordDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _recordDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) return;

    final vehicleAsync = ref.read(watchVehicleProvider);
    final vehicle = vehicleAsync.value;
    if (vehicle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cadastre um veículo primeiro')),
      );
      return;
    }

    final amountCents =
        ((parseCurrencyInput(_amountCtrl.text) ?? 0) * 100).round();
    final liters = parseCurrencyInput(_litersCtrl.text) ?? 0;
    final odometer = int.tryParse(_odometerCtrl.text) ?? 0;

    final result = await ref.read(fuelFormNotifierProvider.notifier).save(
          userId: user.id,
          vehicleId: vehicle.id,
          amountCents: amountCents,
          liters: liters,
          odometer: odometer,
          fuelType: _fuelType,
          recordDate: _recordDate,
        );

    if (!mounted) return;
    result.fold(
      (f) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(f.message),
          backgroundColor: AppColors.expense,
        ),
      ),
      (_) => Navigator.of(context).pop(true),
    );
  }
}
