String formatCurrency(int cents) {
  final reais = cents / 100;
  final formatted = reais.toStringAsFixed(2).replaceAll('.', ',');
  final parts = formatted.split(',');
  final intPart = parts[0];
  final decPart = parts[1];
  final buffer = StringBuffer();
  int count = 0;
  for (int i = intPart.length - 1; i >= 0; i--) {
    if (count > 0 && count % 3 == 0) buffer.write('.');
    buffer.write(intPart[i]);
    count++;
  }
  final reversed = buffer.toString().split('').reversed.join();
  return 'R\$ $reversed,$decPart';
}

String formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.year}';
}

double? parseCurrencyInput(String input) {
  final cleaned = input.replaceAll('.', '').replaceAll(',', '.');
  return double.tryParse(cleaned);
}
