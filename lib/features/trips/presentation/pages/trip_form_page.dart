import 'package:driver_finance/core/ui/theme/app_colors.dart';
import 'package:driver_finance/core/utils/currency_formatter.dart';
import 'package:driver_finance/features/auth/presentation/providers/auth_provider.dart';
import 'package:driver_finance/features/platform/presentation/providers/platform_provider.dart';
import 'package:driver_finance/features/trips/domain/entities/trip.dart';
import 'package:driver_finance/features/trips/presentation/providers/trip_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TripFormPage extends ConsumerStatefulWidget {
  const TripFormPage({super.key, this.existingTrip});

  final Trip? existingTrip;

  @override
  ConsumerState<TripFormPage> createState() => _TripFormPageState();
}

class _TripFormPageState extends ConsumerState<TripFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _grossCtrl = TextEditingController();
  final _bonusCtrl = TextEditingController();
  final _tipCtrl = TextEditingController();
  final _promotionCtrl = TextEditingController();
  final _cancellationCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  String? _selectedPlatformId;
  DateTime _tripDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    final t = widget.existingTrip;
    if (t != null) {
      _grossCtrl.text =
          (t.grossAmountCents / 100).toStringAsFixed(2).replaceAll('.', ',');
      _bonusCtrl.text =
          (t.bonusAmountCents / 100).toStringAsFixed(2).replaceAll('.', ',');
      _tipCtrl.text =
          (t.tipAmountCents / 100).toStringAsFixed(2).replaceAll('.', ',');
      _promotionCtrl.text =
          (t.promotionCents / 100).toStringAsFixed(2).replaceAll('.', ',');
      _cancellationCtrl.text = (t.cancellationCents / 100)
          .toStringAsFixed(2)
          .replaceAll('.', ',');
      _notesCtrl.text = t.notes ?? '';
      if (t.durationMinutes != null) {
        _durationCtrl.text = t.durationMinutes.toString();
      }
      _selectedPlatformId = t.platformId;
      _tripDate = t.tripDate;
    }
  }

  @override
  void dispose() {
    _grossCtrl.dispose();
    _bonusCtrl.dispose();
    _tipCtrl.dispose();
    _promotionCtrl.dispose();
    _cancellationCtrl.dispose();
    _durationCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final platformsAsync = ref.watch(watchPlatformsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingTrip == null ? 'Nova corrida' : 'Editar corrida',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              platformsAsync.when(
                loading: () =>
                    const CircularProgressIndicator(),
                error: (_, __) => const SizedBox(),
                data: (platforms) {
                  final active =
                      platforms.where((p) => p.isActive).toList();
                  return DropdownButtonFormField<String>(
                    value: _selectedPlatformId,
                    decoration: const InputDecoration(
                      labelText: 'Plataforma',
                      border: OutlineInputBorder(),
                    ),
                    items: active
                        .map(
                          (p) => DropdownMenuItem(
                            value: p.id,
                            child: Text(p.displayName),
                          ),
                        )
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _selectedPlatformId = v),
                    validator: (v) =>
                        v == null ? 'Selecione uma plataforma' : null,
                  );
                },
              ),
              const SizedBox(height: 12),
              _CurrencyField(
                controller: _grossCtrl,
                label: 'Valor bruto (R\$)',
                required: true,
              ),
              const SizedBox(height: 12),
              _CurrencyField(
                controller: _bonusCtrl,
                label: 'Bônus (R\$)',
              ),
              const SizedBox(height: 12),
              _CurrencyField(
                controller: _tipCtrl,
                label: 'Gorjeta (R\$)',
              ),
              const SizedBox(height: 12),
              _CurrencyField(
                controller: _promotionCtrl,
                label: 'Promoção (R\$)',
              ),
              const SizedBox(height: 12),
              _CurrencyField(
                controller: _cancellationCtrl,
                label: 'Cancelamento (R\$)',
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today),
                title: Text('Data: ${formatDate(_tripDate)}'),
                onTap: _pickDate,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _durationCtrl,
                decoration: const InputDecoration(
                  labelText: 'Duração (min) — opcional',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (v) {
                  if (v == null || v.isEmpty) return null;
                  final val = int.tryParse(v);
                  if (val == null || val <= 0) return 'Informe um número válido';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesCtrl,
                decoration: const InputDecoration(
                  labelText: 'Observações (opcional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _save,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text('Salvar corrida'),
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
      initialDate: _tripDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _tripDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) return;

    int parseCents(String text) =>
        ((parseCurrencyInput(text) ?? 0) * 100).round();

    final durationText = _durationCtrl.text.trim();
    final durationMinutes =
        durationText.isEmpty ? null : int.tryParse(durationText);

    final result = await ref
        .read(tripFormNotifierProvider.notifier)
        .save(
          existingId: widget.existingTrip?.id,
          userId: user.id,
          platformId: _selectedPlatformId!,
          grossAmountCents: parseCents(_grossCtrl.text),
          bonusAmountCents: parseCents(_bonusCtrl.text),
          tipAmountCents: parseCents(_tipCtrl.text),
          promotionCents: parseCents(_promotionCtrl.text),
          cancellationCents: parseCents(_cancellationCtrl.text),
          durationMinutes: durationMinutes,
          tripDate: _tripDate,
          notes: _notesCtrl.text,
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

class _CurrencyField extends StatelessWidget {
  const _CurrencyField({
    required this.controller,
    required this.label,
    this.required = false,
  });

  final TextEditingController controller;
  final String label;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixText: 'R\$ ',
        border: const OutlineInputBorder(),
      ),
      keyboardType:
          const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[\d,.]')),
      ],
      validator: required
          ? (v) {
              if (v == null || v.isEmpty) return 'Campo obrigatório';
              final val = parseCurrencyInput(v) ?? 0;
              if (val <= 0) return 'Valor deve ser maior que zero';
              return null;
            }
          : null,
    );
  }
}
