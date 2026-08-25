# ADR-0004: Clean Architecture + DDD + Feature First

## Status
Accepted

## Data
2026-06-26

## Contexto

O Driver Finance AI terá múltiplos domínios (corridas, despesas, quilometragem, manutenções, metas, IA) que evoluem independentemente. Precisamos de uma estrutura que: permita testar a lógica de negócio sem UI ou banco de dados, facilite adicionar novas features sem afetar as existentes, e organize o código de forma intuitiva para encontrar qualquer arquivo rapidamente.

## Decisão

Adotamos **Clean Architecture** (separação em camadas: Presentation, Domain, Data) combinada com **Domain-Driven Design** (entidades, value objects, use cases, repositories como abstrações) e organização **Feature First** (código agrupado por feature, não por tipo técnico).

### Estrutura de Pastas

```
src/
  core/           — código compartilhado (UI, auth, network, database, sync, errors, utils)
  features/
    auth/
      domain/     — entities/, repositories/ (interfaces), use_cases/
      data/       — models/, repositories/ (impl), sources/local/, sources/remote/
      presentation/ — pages/, widgets/, providers/
    trips/
    expenses/
    mileage/
    maintenance/
    goals/
    ai_chat/
    reports/
    vehicles/
    platforms/
    settings/
```

### Regras de Dependência

```
Presentation → Domain ← Data
     ↓              ↑
  (usa Use Cases)   (implementa Repository interfaces)
```

- Domain **não importa** Flutter, clientes de rede (Dio/ApiClient), Drift, ou qualquer framework
- Presentation usa Domain via Use Cases e Providers (Riverpod)
- Data implementa as interfaces de Domain

## Justificativa

- **Testabilidade:** Domain layer sem dependências externas → testes unitários puros e rápidos
- **Feature First:** Encontrar código de "corridas" é óbvio — `src/features/trips/` — sem navegar entre pastas `models/`, `controllers/`, etc. separadas
- **Independência de framework:** Se o backend mudar, apenas a camada `data/` muda; Domain permanece intacto (validado na prática pela migração Supabase → backend próprio, ADR-0006)
- **DDD:** Use Cases nomeados por ação de negócio (`AddTrip`, `GetMonthlySummary`) tornam o código auto-documentado
- **Escalabilidade:** Features novas são adicionadas sem tocar código existente

## Alternativas Consideradas

| Alternativa | Por que Rejeitada |
|-------------|------------------|
| MVC / MVVM simples | Sem separação Domain/Data → difícil testar, acoplamento alto com frameworks |
| Type First (models/, controllers/, pages/) | Difícil encontrar tudo de uma feature; não escala bem |
| BLoC como única solução | State management, não arquitetura completa; pode ser usado dentro desta estrutura |
| GetX | Combina state, DI e routing em um framework; dificulta testes e impõe padrões próprios |

## Consequências

### Positivas
- Testes unitários de Domain sem setup de flutter/rede/drift
- Nova feature: criar pasta em `features/` sem modificar existentes (Open/Closed principle)
- Onboarding: qualquer dev entende onde encontrar qualquer código

### Negativas
- Mais arquivos e pastas que MVC simples — overhead inicial perceptível
- Use Cases de 1-2 linhas podem parecer "over-engineering" para operações triviais

### Riscos
- Tentação de colocar lógica de negócio no Provider (Presentation) para "economizar arquivos"
- Mitigação: Review Agent checa explicitamente que widgets não contêm lógica de negócio

## Conformidade

O Review Agent verifica:
- Domain layer não tem imports de `flutter/`, clientes de rede, `drift/`
- Toda operação de negócio tem Use Case dedicado
- Providers (Riverpod) apenas delegam para Use Cases — não contêm lógica
- Feature nova criada dentro de `src/features/[feature]/` seguindo a estrutura padrão

## ADRs Relacionados
- ADR-0002: Flutter como UI (Presentation layer)
- ADR-0006: backend próprio como Data Source remoto
- ADR-0005: Offline First define como a camada Data é estruturada

## Originado por
PRD — Driver Finance AI (seções Tecnologia e Arquitetura)
