import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Regras de negócio — cálculos financeiros', () {
    test('lucro real = receita bruta − despesas totais', () {
      const receitaBruta = 100000;
      const despesasTotais = 35000;
      final lucroReal = receitaBruta - despesasTotais;
      expect(lucroReal, 65000);
    });

    test('custo por km = total despesas / km trabalhados', () {
      const totalDespesas = 50000;
      const kmTrabalhados = 1000;
      final custoPorKm = totalDespesas / kmTrabalhados;
      expect(custoPorKm, 50.0);
    });

    test('depreciação mensal = (compra − residual) / vida útil', () {
      const precoCompra = 8000000;
      const valorResidualPct = 0.20;
      const vidaUtilMeses = 60;
      final depreciacaoMensal =
          (precoCompra * (1 - valorResidualPct)) / vidaUtilMeses;
      expect(depreciacaoMensal, closeTo(106666.67, 0.1));
    });

    test('consumo = km rodados / litros abastecidos', () {
      const kmRodados = 400;
      const litros = 40.0;
      final consumo = kmRodados / litros;
      expect(consumo, 10.0);
    });

    test('meta diária = meta mensal / dias úteis', () {
      const metaMensal = 300000;
      const diasUteis = 26;
      final metaDiaria = metaMensal ~/ diasUteis;
      expect(metaDiaria, 11538);
    });
  });
}
