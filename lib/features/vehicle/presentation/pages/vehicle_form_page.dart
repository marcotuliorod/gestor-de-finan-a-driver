import 'package:driver_finance/core/ui/theme/app_colors.dart';
import 'package:driver_finance/core/utils/currency_formatter.dart';
import 'package:driver_finance/features/auth/presentation/providers/auth_provider.dart';
import 'package:driver_finance/features/vehicle/domain/entities/vehicle.dart';
import 'package:driver_finance/features/vehicle/presentation/providers/vehicle_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VehicleFormPage extends ConsumerStatefulWidget {
  const VehicleFormPage({super.key, this.existingVehicle});

  final Vehicle? existingVehicle;

  @override
  ConsumerState<VehicleFormPage> createState() => _VehicleFormPageState();
}

class _VehicleFormPageState extends ConsumerState<VehicleFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _makeCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _plateCtrl = TextEditingController();
  final _tankCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  String _fuelType = 'gasoline';

  @override
  void initState() {
    super.initState();
    final v = widget.existingVehicle;
    if (v != null) {
      _makeCtrl.text = v.make;
      _modelCtrl.text = v.model;
      _yearCtrl.text = v.year.toString();
      _plateCtrl.text = v.licensePlate;
      _tankCtrl.text = v.tankCapacityL.toString();
      _priceCtrl.text = (v.purchasePriceCents / 100).toStringAsFixed(2);
      _fuelType = v.fuelType;
    } else {
      _yearCtrl.text = DateTime.now().year.toString();
      _tankCtrl.text = '50.0';
    }
  }

  @override
  void dispose() {
    _makeCtrl.dispose();
    _modelCtrl.dispose();
    _yearCtrl.dispose();
    _plateCtrl.dispose();
    _tankCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(vehicleFormNotifierProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingVehicle != null ? 'Editar Veículo' : 'Meu Veículo',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _Field(
              label: 'Marca',
              ctrl: _makeCtrl,
              hint: 'Ex: Toyota',
              validator: (v) =>
                  (v?.trim().isEmpty ?? true) ? 'Informe a marca' : null,
            ),
            const SizedBox(height: 16),
            _Field(
              label: 'Modelo',
              ctrl: _modelCtrl,
              hint: 'Ex: Corolla',
              validator: (v) =>
                  (v?.trim().isEmpty ?? true) ? 'Informe o modelo' : null,
            ),
            const SizedBox(height: 16),
            _Field(
              label: 'Ano',
              ctrl: _yearCtrl,
              hint: '2022',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) {
                final year = int.tryParse(v ?? '');
                if (year == null) return 'Ano inválido';
                if (year < 1950 || year > DateTime.now().year + 1) {
                  return 'Ano fora do intervalo válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _Field(
              label: 'Placa',
              ctrl: _plateCtrl,
              hint: 'ABC1D23',
              textCapitalization: TextCapitalization.characters,
              validator: (v) =>
                  (v?.trim().isEmpty ?? true) ? 'Informe a placa' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _fuelType,
              decoration: const InputDecoration(
                labelText: 'Combustível',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'gasoline', child: Text('Gasolina')),
                DropdownMenuItem(value: 'ethanol', child: Text('Etanol')),
                DropdownMenuItem(value: 'diesel', child: Text('Diesel')),
                DropdownMenuItem(value: 'flex', child: Text('Flex')),
              ],
              onChanged: (v) => setState(() => _fuelType = v!),
            ),
            const SizedBox(height: 16),
            _Field(
              label: 'Tanque (litros)',
              ctrl: _tankCtrl,
              hint: '50.0',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                final n = double.tryParse(v?.replaceAll(',', '.') ?? '');
                if (n == null || n <= 0) return 'Capacidade inválida';
                return null;
              },
            ),
            const SizedBox(height: 16),
            _Field(
              label: 'Valor de compra (R\$)',
              ctrl: _priceCtrl,
              hint: '80000,00',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                final n = double.tryParse(
                    v?.replaceAll('.', '').replaceAll(',', '.') ?? '');
                if (n == null || n <= 0) return 'Valor inválido';
                return null;
              },
            ),
            if (widget.existingVehicle != null) ...[
              const SizedBox(height: 24),
              _RoiCard(vehicle: widget.existingVehicle!),
            ],
            const SizedBox(height: 32),
            FilledButton(
              onPressed: isLoading ? null : _submit,
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) return;

    final priceRaw =
        _priceCtrl.text.replaceAll('.', '').replaceAll(',', '.');
    final priceCents = ((double.parse(priceRaw)) * 100).round();

    final result = await ref.read(vehicleFormNotifierProvider.notifier).save(
          existingId: widget.existingVehicle?.id,
          userId: user.id,
          make: _makeCtrl.text.trim(),
          model: _modelCtrl.text.trim(),
          year: int.parse(_yearCtrl.text),
          licensePlate: _plateCtrl.text.trim().toUpperCase(),
          fuelType: _fuelType,
          tankCapacityL: double.parse(
              _tankCtrl.text.replaceAll(',', '.')),
          purchasePriceCents: priceCents,
        );

    result.fold(
      (failure) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: AppColors.expense,
          ),
        );
      },
      (_) {
        if (!mounted) return;
        Navigator.of(context).pop(true);
      },
    );
  }
}

class _RoiCard extends StatelessWidget {
  const _RoiCard({required this.vehicle});

  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monthsOwned =
        ((now.year - vehicle.year) * 12 + now.month).clamp(1, vehicle.usefulLifeMonths);
    final depreciationAccumulated =
        vehicle.monthlyDepreciationCents * monthsOwned;
    final estimatedValue =
        (vehicle.purchasePriceCents - depreciationAccumulated).clamp(0, vehicle.purchasePriceCents);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ROI do Veículo',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            _RoiRow(
              label: 'Valor de compra',
              value: formatCurrency(vehicle.purchasePriceCents),
              color: AppColors.income,
            ),
            _RoiRow(
              label: 'Depreciação acumulada (~${monthsOwned}m)',
              value: '- ${formatCurrency(depreciationAccumulated)}',
              color: AppColors.expense,
            ),
            const Divider(height: 16),
            _RoiRow(
              label: 'Valor atual estimado',
              value: formatCurrency(estimatedValue),
              color: estimatedValue > 0 ? AppColors.income : AppColors.textSecondary,
              bold: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _RoiRow extends StatelessWidget {
  const _RoiRow({
    required this.label,
    required this.value,
    required this.color,
    this.bold = false,
  });

  final String label;
  final String value;
  final Color color;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.ctrl,
    this.hint,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.textCapitalization = TextCapitalization.none,
  });

  final String label;
  final TextEditingController ctrl;
  final String? hint;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      textCapitalization: textCapitalization,
    );
  }
}
