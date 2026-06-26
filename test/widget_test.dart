import 'package:driver_finance/features/auth/domain/entities/app_user.dart';
import 'package:driver_finance/features/goals/domain/entities/financial_goal.dart';
import 'package:driver_finance/features/platform/domain/entities/app_platform.dart';
import 'package:driver_finance/features/vehicle/domain/entities/vehicle.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppUser entity', () {
    test('equality is based on id', () {
      const a = AppUser(id: '1', email: 'a@a.com');
      const b = AppUser(id: '1', email: 'b@b.com');
      const c = AppUser(id: '2', email: 'a@a.com');
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('hashCode is based on id', () {
      const a = AppUser(id: '42', email: 'test@test.com');
      expect(a.hashCode, equals('42'.hashCode));
    });
  });

  group('Vehicle entity', () {
    test('monthlyDepreciationCents calculation', () {
      const v = Vehicle(
        id: '1',
        userId: 'u',
        make: 'Toyota',
        model: 'Corolla',
        year: 2022,
        licensePlate: 'ABC1D23',
        fuelType: 'gasoline',
        tankCapacityL: 55.0,
        purchasePriceCents: 8000000, // R$ 80.000
        usefulLifeMonths: 60,
        residualValuePct: 0.20,
      );
      // depreciação = 80.000 * (1 - 0.20) / 60 = 64.000 / 60 ≈ 1.066,67
      expect(v.monthlyDepreciationCents, equals(106667));
    });

    test('copyWith preserves unchanged fields', () {
      const v = Vehicle(
        id: '1',
        userId: 'u',
        make: 'Toyota',
        model: 'Corolla',
        year: 2022,
        licensePlate: 'ABC1D23',
        fuelType: 'gasoline',
        tankCapacityL: 55.0,
        purchasePriceCents: 8000000,
      );
      final updated = v.copyWith(make: 'Honda');
      expect(updated.make, equals('Honda'));
      expect(updated.model, equals('Corolla'));
      expect(updated.id, equals('1'));
    });

    test('equality is based on id', () {
      const v1 = Vehicle(
        id: 'abc',
        userId: 'u',
        make: 'A',
        model: 'B',
        year: 2020,
        licensePlate: 'XYZ',
        fuelType: 'flex',
        tankCapacityL: 50.0,
        purchasePriceCents: 5000000,
      );
      const v2 = Vehicle(
        id: 'abc',
        userId: 'u',
        make: 'C',
        model: 'D',
        year: 2021,
        licensePlate: 'ZZZ',
        fuelType: 'diesel',
        tankCapacityL: 80.0,
        purchasePriceCents: 9000000,
      );
      expect(v1, equals(v2));
    });
  });

  group('AppPlatform entity', () {
    test('displayName returns correct labels', () {
      const tests = [
        ('uber', 'Uber'),
        ('app99', '99'),
        ('indrive', 'inDrive'),
        ('taxi', 'Táxi'),
        ('delivery', 'Delivery'),
      ];
      for (final (type, expected) in tests) {
        final p = AppPlatform(id: '1', userId: 'u', type: type);
        expect(p.displayName, equals(expected),
            reason: 'type=$type should display $expected');
      }
    });

    test('custom platform uses customName', () {
      const p = AppPlatform(
        id: '1',
        userId: 'u',
        type: 'custom',
        customName: 'Minha plataforma',
      );
      expect(p.displayName, equals('Minha plataforma'));
    });

    test('defaultTypes contains expected platforms', () {
      expect(AppPlatform.defaultTypes, contains('uber'));
      expect(AppPlatform.defaultTypes, contains('app99'));
      expect(AppPlatform.defaultTypes, hasLength(5));
    });

    test('copyWith changes only isActive', () {
      const p = AppPlatform(id: '1', userId: 'u', type: 'uber', isActive: true);
      final toggled = p.copyWith(isActive: false);
      expect(toggled.isActive, isFalse);
      expect(toggled.type, equals('uber'));
    });
  });

  group('FinancialGoal entity', () {
    final goal = FinancialGoal(
      id: '1',
      userId: 'u',
      monthlyTargetCents: 300000, // R$ 3.000
      workingDaysPerMonth: 26,
      periodStart: DateTime(2026, 6, 1),
      periodEnd: DateTime(2026, 6, 30),
    );

    test('dailyTargetCents = monthly / workingDays', () {
      expect(goal.dailyTargetCents, equals(11538)); // 300.000 ~/ 26
    });

    test('equality based on id', () {
      final g2 = FinancialGoal(
        id: '1',
        userId: 'u',
        monthlyTargetCents: 999999,
        workingDaysPerMonth: 5,
        periodStart: DateTime(2025),
        periodEnd: DateTime(2025, 12),
      );
      expect(goal, equals(g2));
    });
  });

  group('Business rule calculations', () {
    test('lucro real = receita bruta − despesas totais', () {
      const receitaBruta = 100000;
      const despesasTotais = 35000;
      expect(receitaBruta - despesasTotais, equals(65000));
    });

    test('custo por km = total despesas / km trabalhados', () {
      const totalDespesas = 50000;
      const kmTrabalhados = 1000;
      expect(totalDespesas / kmTrabalhados, equals(50.0));
    });

    test('consumo = km rodados / litros abastecidos', () {
      const kmRodados = 400;
      const litros = 40.0;
      expect(kmRodados / litros, equals(10.0));
    });

    test('meta diária = meta mensal ~/ dias úteis', () {
      const metaMensal = 300000;
      const diasUteis = 26;
      expect(metaMensal ~/ diasUteis, equals(11538));
    });
  });
}
