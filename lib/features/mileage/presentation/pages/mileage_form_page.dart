import 'package:driver_finance/core/ui/theme/app_colors.dart';
import 'package:driver_finance/core/utils/currency_formatter.dart';
import 'package:driver_finance/features/auth/presentation/providers/auth_provider.dart';
import 'package:driver_finance/features/mileage/presentation/providers/mileage_provider.dart';
import 'package:driver_finance/features/vehicle/presentation/providers/vehicle_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MileageFormPage extends ConsumerStatefulWidget {
  const MileageFormPage({super.key});

  @override
  ConsumerState<MileageFormPage> createState() => _MileageFormPageState();
}

class _MileageFormPageState extends ConsumerState<MileageFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _startCtrl = TextEditingController();
  final _endCtrl = TextEditingController();
  final _personalCtrl = TextEditingController(text: '0');
  DateTime _recordDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _prefillOdometer());
  }

  Future<void> _prefillOdometer() async {
    final vehicle = ref.read(watchVehicleProvider).value;
    if (vehicle == null) return;
    final repo = ref.read(mileageRepositoryProvider);
    final last = await repo.getLastOdometer(vehicle.id);
    if (last != null && _startCtrl.text.isEmpty) {
      _startCtrl.text = last.toString();
    }
  }

  @override
  void dispose() {
    _startCtrl.dispose();
    _endCtrl.dispose();
    _personalCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro de km')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _startCtrl,
                decoration: const InputDecoration(
                  labelText: 'Km inicial',
                  suffixText: 'km',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Campo obrigatório';
                  if (int.tryParse(v) == null) return 'Valor inválido';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _endCtrl,
                decoration: const InputDecoration(
                  labelText: 'Km final',
                  suffixText: 'km',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Campo obrigatório';
                  final end = int.tryParse(v);
                  final start = int.tryParse(_startCtrl.text) ?? 0;
                  if (end == null) return 'Valor inválido';
                  if (end <= start) {
                    return 'Km final deve ser maior que km inicial';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _personalCtrl,
                decoration: const InputDecoration(
                  labelText: 'Km uso pessoal',
                  suffixText: 'km',
                  border: OutlineInputBorder(),
                  helperText: 'Km não relacionado ao trabalho',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) {
                  final personal = int.tryParse(v ?? '0') ?? 0;
                  final start = int.tryParse(_startCtrl.text) ?? 0;
                  final end = int.tryParse(_endCtrl.text) ?? 0;
                  final total = end - start;
                  if (personal < 0) return 'Não pode ser negativo';
                  if (personal > total) {
                    return 'Km pessoal não pode ser maior que o total';
                  }
                  return null;
                },
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
                child: const Text('Salvar registro'),
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
    final vehicle = ref.read(watchVehicleProvider).value;
    if (vehicle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cadastre um veículo primeiro')),
      );
      return;
    }

    final start = int.parse(_startCtrl.text);
    final end = int.parse(_endCtrl.text);
    final personal = int.tryParse(_personalCtrl.text) ?? 0;
    final work = (end - start) - personal;

    final result =
        await ref.read(mileageFormNotifierProvider.notifier).save(
              userId: user.id,
              vehicleId: vehicle.id,
              startOdometer: start,
              endOdometer: end,
              workKm: work,
              personalKm: personal,
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
