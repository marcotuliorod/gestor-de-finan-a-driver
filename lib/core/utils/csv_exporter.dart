import 'package:csv/csv.dart';
import 'package:driver_finance/features/expenses/domain/entities/expense.dart';
import 'package:driver_finance/features/trips/domain/entities/trip.dart';

String tripsToCSV(List<Trip> trips) {
  final rows = <List<dynamic>>[
    [
      'Data',
      'Valor Bruto (R\$)',
      'Bônus (R\$)',
      'Gorjeta (R\$)',
      'Total (R\$)',
      'Notas'
    ],
    ...trips.map(
      (t) => [
        '${t.tripDate.day.toString().padLeft(2, '0')}/${t.tripDate.month.toString().padLeft(2, '0')}/${t.tripDate.year}',
        (t.grossAmountCents / 100).toStringAsFixed(2),
        (t.bonusAmountCents / 100).toStringAsFixed(2),
        (t.tipAmountCents / 100).toStringAsFixed(2),
        (t.totalIncomeCents / 100).toStringAsFixed(2),
        t.notes ?? '',
      ],
    ),
  ];
  return const ListToCsvConverter().convert(rows);
}

String expensesToCSV(List<Expense> expenses) {
  final rows = <List<dynamic>>[
    ['Data', 'Categoria', 'Valor (R\$)', 'Descrição', 'Recorrente'],
    ...expenses.map(
      (e) => [
        '${e.expenseDate.day.toString().padLeft(2, '0')}/${e.expenseDate.month.toString().padLeft(2, '0')}/${e.expenseDate.year}',
        e.category.label,
        (e.amountCents / 100).toStringAsFixed(2),
        e.description ?? '',
        e.isRecurring ? 'Sim' : 'Não',
      ],
    ),
  ];
  return const ListToCsvConverter().convert(rows);
}
