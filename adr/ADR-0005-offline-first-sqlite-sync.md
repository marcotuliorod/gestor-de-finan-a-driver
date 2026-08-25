# ADR-0005: Offline First com SQLite (Drift) + Sincronização com o backend próprio

## Status
Accepted (atualizado em 2026-08-25 — ver nota abaixo)

## Data
2026-06-26

> **Atualização 2026-08-25 (ADR-0006):** o destino remoto da sincronização deixou de ser o Supabase e passou a ser o backend próprio (Python/FastAPI + Postgres self-hosted). O restante deste documento (modelo dual, fluxo de escrita/leitura, schema de sync) permanece válido conceitualmente, mas o comportamento **real implementado é mais simples** do que o descrito abaixo: não existe `SyncQueue`/retry com backoff em produção — cada escrita local dispara um push fire-and-forget único ao backend via `ApiClient`; falhas são reportadas ao Sentry (não silenciosamente descartadas) mas não são reenfileiradas automaticamente. Essa lacuna já existia com o Supabase e não foi resolvida na migração — ver ADR-0006, seção de riscos.

## Contexto

O PRD exige tempo de resposta < 300ms para operações locais e funcionamento sem conexão. Motoristas frequentemente dirigem em áreas com conectividade instável ou usam o app enquanto dirigem (sem atenção para esperar loading). Os dados financeiros devem estar sempre disponíveis e nunca perdidos, mesmo sem internet.

Ao mesmo tempo, os dados precisam ser sincronizados com um backend remoto para backup na nuvem, acesso multi-dispositivo futuro, e o módulo de IA (que roda server-side).

## Decisão

Adotamos uma estratégia **Offline First** com **SQLite local via Drift** como fonte de verdade primária, sincronização assíncrona em background com o backend próprio.

### Modelo de Dados Dual

- **Local (Drift/SQLite):** Espelho completo dos dados do usuário. Leitura e escrita sempre local.
- **Remote (backend próprio/PostgreSQL):** Destino de sincronização. Fonte de verdade para multi-dispositivo e backup.

### Fluxo de Escrita

```
1. User action → Use Case → Repository
2. Repository.save() → LocalDataSource.insert() [síncrono, < 50ms]
3. UI atualiza imediatamente (optimistic update)
4. SyncQueue.add(recordId, operation) [async]
5. Background: SyncService → RemoteDataSource.upsert() [quando online]
6. Em sucesso: remove da SyncQueue, atualiza sync_status do registro
7. Em falha: retry com backoff exponencial (3 tentativas)
```

### Fluxo de Leitura

```
1. Use Case → Repository.get()
2. Repository → LocalDataSource.query() [sempre local, < 10ms]
3. Return dados
```

### Schema de Sincronização

Toda tabela local tem:
```sql
sync_status   TEXT NOT NULL DEFAULT 'pending',  -- pending | synced | error
synced_at     TEXT,                              -- ISO8601 timestamp
local_id      TEXT NOT NULL DEFAULT (gen_random_uuid())  -- id local antes do sync
```

### Resolução de Conflitos (MVP)

**Last-write-wins** baseado em `updated_at`:
- Se registro remoto tem `updated_at` mais recente → remote vence
- Se registro local tem `updated_at` mais recente → local vence
- Em empate → local vence (experiência do usuário prioritária)

_Nota: Estratégia de merge mais sofisticada é candidata para v2.0 — ver questão aberta em PROJECT_CONTEXT.md_

## Justificativa

- **< 300ms garantido:** Leitura e escrita local com SQLite é sub-10ms
- **Zero perda de dados:** SyncQueue persiste localmente — mesmo sem internet, os dados não são perdidos
- **Optimistic UI:** Experiência fluida — usuário não espera confirmação de rede
- **Drift:** O ORM de SQLite mais robusto para Dart; type-safe, migrations versionadas, streams reativos
- **Last-write-wins (MVP):** Conflitos são raros para dados pessoais de um único motorista; simplicidade primeiro

## Alternativas Consideradas

| Alternativa | Por que Rejeitada |
|-------------|------------------|
| Sem cache local (só Supabase) | Latência > 300ms; sem funcionamento offline |
| Cache simples (sem sync queue) | Risco de perda de dados em crash pós-write local pré-sync |
| CRDTs para resolução de conflitos | Complexidade alta desnecessária para MVP single-user |
| Realm / Isar | Menos maturidade que Drift para Flutter; Drift tem migrations melhores |

## Consequências

### Positivas
- Performance local garantida (< 300ms)
- Funciona completamente offline
- Dados nunca perdidos (sync queue persistida)
- Experiência de usuário fluida (optimistic updates)

### Negativas
- Complexidade: dois modelos de dados (local + remote) com mappers
- Conflitos de sync possíveis (mitigados por last-write-wins no MVP)
- Tamanho do app maior (SQLite embutido)

### Riscos
- Sync queue pode crescer indefinidamente se usuário nunca reconectar
- Mitigação: alertar usuário após X dias sem sincronização; limite de 1000 items na queue
- Conflitos com multi-dispositivo (futuro): last-write-wins pode ser inadequado
- Mitigação: documentado como limitação, a ser revisado em v2.0

## Conformidade

O Review Agent verifica:
- Toda escrita passa por LocalDataSource antes de qualquer chamada remota
- SyncQueue é atualizada em toda operação de escrita
- Nenhuma leitura vai diretamente para RemoteDataSource sem fallback local
- Migrations Drift versionadas e reversíveis

## ADRs Relacionados
- ADR-0006: backend próprio (Python/FastAPI + Postgres) como destino do sync remoto, substituindo o Supabase de ADR-0003
- ADR-0004: Repository pattern abstrai local vs remote

## Originado por
PRD — Driver Finance AI (Requisitos Não Funcionais: Offline, < 300ms, Sincronização)
