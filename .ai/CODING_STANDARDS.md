# Coding Standards

_Aplicado por todos os agentes de implementação. Verificado pelo Review Agent._

---

## Regras Universais

- Sem números mágicos — use constantes nomeadas
- Sem código comentado em commits
- Tratamento de erros explícito — nunca engolir exceções silenciosamente
- Sem secrets no código-fonte — usar variáveis de ambiente
- Funções com responsabilidade única
- Máximo de 20 linhas por função (prefira menores)
- Funções puras preferíveis — minimize efeitos colaterais

## Dart / Flutter

### Nomenclatura
- Arquivos: `snake_case.dart`
- Classes: `PascalCase`
- Variáveis e funções: `camelCase`
- Constantes: `kConstantName` (prefixo `k`)
- Privados: `_prefixo`
- Arquivos de teste: `feature_test.dart` (sufixo `_test`)

### Tipos
- Sempre declare tipos explícitos — nunca use `var` ou `dynamic` sem justificativa
- Use `final` por padrão — `var` apenas quando reatribuição é necessária
- Use `const` em widgets e valores que não mudam em runtime

### Estrutura de Arquivos
```dart
// 1. Imports (ordenados: dart, flutter, packages, projeto)
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:driver_finance/core/errors/failures.dart';

// 2. Part directives (se necessário)
part 'my_notifier.g.dart';

// 3. Constantes do arquivo (se houver)
const kMaxRetries = 3;

// 4. Classe principal
class MyWidget extends StatelessWidget { ... }

// 5. Classes auxiliares privadas do arquivo
class _HelperWidget extends StatelessWidget { ... }
```

### Tratamento de Erros
```dart
// CORRETO — usar Result type (Either<Failure, T>)
Future<Either<Failure, Trip>> addTrip(Trip trip) async {
  try {
    final result = await _repository.save(trip);
    return Right(result);
  } on DatabaseException catch (e) {
    return Left(DatabaseFailure(e.message));
  }
}

// ERRADO — nunca fazer
Future<Trip> addTrip(Trip trip) async {
  return await _repository.save(trip); // sem tratamento
}
```

### Widgets
```dart
// CORRETO — widget simples e legível
class TripCard extends StatelessWidget {
  const TripCard({required this.trip, super.key});
  final Trip trip;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      title: Text(trip.platformName),
      subtitle: Text(trip.formattedEarnings),
    ),
  );
}
```

### Riverpod
- Use `@riverpod` annotation + code generation
- `AsyncNotifier` para estado assíncrono
- `Notifier` para estado síncrono
- Providers nomeados no padrão `featureActionProvider`
- Nunca acesse providers fora de widgets ou outros providers

## SQL / PostgreSQL

### Nomenclatura
- Tabelas: `snake_case`, plural (`trips`, `expenses`)
- Colunas: `snake_case` (`created_at`, `user_id`)
- Índices: `idx_tabela_coluna`
- Constraints: `fk_tabela_coluna`, `uq_tabela_coluna`
- Funções RPC: `snake_case` com verbo (`get_monthly_summary`, `add_trip`)

### Convenções de Schema
```sql
-- Toda tabela deve ter:
id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
user_id     UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
deleted_at  TIMESTAMPTZ  -- soft delete

-- RLS obrigatória em toda tabela com dados de usuário:
ALTER TABLE trips ENABLE ROW LEVEL SECURITY;
CREATE POLICY "users_own_trips" ON trips
  USING (auth.uid() = user_id);
```

### Formatação SQL
```sql
SELECT
    t.id,
    t.platform_id,
    t.gross_amount,
    p.name AS platform_name
FROM trips t
JOIN platforms p ON p.id = t.platform_id
WHERE
    t.user_id = auth.uid()
    AND t.deleted_at IS NULL
    AND t.trip_date >= $1
ORDER BY t.trip_date DESC;
```

## Testes

### Nomenclatura de Testes
```dart
// Padrão: test_[o_que]_[quando]_[resultado_esperado]
test('add_trip_when_offline_should_queue_for_sync', () { ... });
test('calculate_profit_when_no_expenses_should_return_gross', () { ... });
```

### Estrutura de Teste
```dart
group('TripRepository', () {
  late TripRepository sut;
  late MockLocalDataSource mockLocal;

  setUp(() {
    mockLocal = MockLocalDataSource();
    sut = TripRepositoryImpl(local: mockLocal);
  });

  test('save_when_valid_trip_should_persist_locally', () async {
    // Arrange
    final trip = TripFactory.valid();
    when(mockLocal.insert(any)).thenAnswer((_) async => trip);

    // Act
    final result = await sut.save(trip);

    // Assert
    expect(result.isRight(), true);
    verify(mockLocal.insert(trip)).called(1);
  });
});
```

### Metas de Cobertura
- Domínio (entidades + use cases): ≥ 90%
- Repositórios: ≥ 80%
- Widgets críticos (dashboard, entrada de dados): ≥ 70%
- Meta global: ≥ 80%

## Commits

- Formato: `type(scope): description` em inglês
- Types: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `perf`
- Exemplos:
  - `feat(trips): add trip registration use case`
  - `fix(sync): resolve conflict when offline queue overflows`
  - `test(expenses): add unit tests for expense calculator`
- Máximo 72 caracteres no título
- Corpo opcional em português para contexto

## Code Review Gates (verificados pelo Review Agent)

- Zero erros de lint (`flutter analyze`)
- Cobertura de testes ≥ 80% no novo código
- Sem TODOs sem issue linkada
- Sem `print()` — usar logger (`log` do dart:developer)
- Sem imports não utilizados
