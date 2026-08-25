/// Formata como `YYYY-MM-DD`, sem o componente de hora — o backend valida
/// campos `date` (Pydantic) e um datetime completo pode ser rejeitado.
String dateOnly(DateTime date) => date.toIso8601String().split('T').first;
