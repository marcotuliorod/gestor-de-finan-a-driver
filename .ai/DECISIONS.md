# Decision Log

_Índice rápido de todas as decisões arquiteturais. Detalhes completos em `adr/`._
_Consulte antes de qualquer decisão técnica para evitar conflitos e retrabalho._

---

## Como Usar

1. Antes de tomar uma decisão técnica, busque aqui se já foi decidido
2. Se encontrar uma decisão relevante, siga-a — não reabra sem justificativa forte
3. Para propor mudança: crie novo ADR como "Supersedes ADR-X"
4. Decisões Accepted têm força de lei no projeto

---

## Status Possíveis

| Status | Significado |
|--------|-------------|
| **Proposed** | Em discussão, ainda não obrigatório |
| **Accepted** | Em vigor — deve ser seguido |
| **Deprecated** | Substituído — não use mais |
| **Superseded** | Formalmente substituído por outro ADR |

---

## Índice de Decisões

| ID | Data | Título | Status | Trigger |
|----|------|--------|--------|---------|
| ADR-0001 | 2026-06-26 | Adotar Framework Multi-Agente Baseado em Prompts | Accepted | Framework Init |
| ADR-0002 | 2026-06-26 | Flutter como Plataforma UI Cross-Platform | Accepted | PRD — Tech Stack |
| ADR-0003 | 2026-06-26 | Supabase + PostgreSQL como Backend | **Superseded por ADR-0006** | PRD — Tech Stack |
| ADR-0004 | 2026-06-26 | Clean Architecture + DDD + Feature First | Accepted | PRD — Tech Stack |
| ADR-0005 | 2026-06-26 | Offline First com SQLite (Drift) + Sync backend próprio | Accepted (atualizado) | PRD — Req. Não Funcionais |
| ADR-0006 | 2026-08-25 | Backend próprio (Python/FastAPI) + Postgres self-hosted, substituindo Supabase | Accepted | Decisão do usuário |

---

## Como Adicionar uma Decisão

1. Crie `adr/ADR-[próximo-número]-[slug].md` usando o template em `adr/README.md`
2. Adicione linha neste índice
3. Se a decisão altera ARCHITECTURE.md: atualize o arquivo
4. Referencie o número do ADR em comentários de código relacionados (ex: `// see ADR-0003`)
