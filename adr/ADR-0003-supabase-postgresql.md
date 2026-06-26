# ADR-0003: Supabase + PostgreSQL como Backend

## Status
Accepted

## Data
2026-06-26

## Contexto

O Driver Finance AI precisa de um backend que ofereça: autenticação (incluindo social login), banco de dados relacional robusto, armazenamento de arquivos (futura importação de comprovantes), funções serverless (Edge Functions para lógica de negócio e IA), e sincronização em tempo real para o modo offline-first.

Um time enxuto não pode manter infraestrutura de backend complexa. A solução deve ser gerenciada, escalável e ter SDK nativo para Flutter/Dart.

## Decisão

Adotamos **Supabase** como Backend-as-a-Service, que internamente usa **PostgreSQL**. Isso nos dá:
- Auth (social login: Google, Apple) via `supabase_flutter`
- PostgreSQL para todos os dados persistidos na nuvem
- Row Level Security (RLS) para isolamento de dados por usuário
- Edge Functions (Deno/TypeScript) para lógica de negócio complexa e integração com Claude API
- Realtime (para sincronização offline-first)
- Storage (para uploads futuros de PDFs/imagens)

## Justificativa

- **Supabase é PostgreSQL:** SQL padrão, sem lock-in de API proprietária
- **RLS nativa:** Isola dados por usuário sem lógica de aplicação adicional — essencial para LGPD
- **SDK Flutter oficial:** `supabase_flutter` com suporte a auth, realtime e REST
- **Edge Functions:** Permite rodar lógica no servidor (ex: chamar Claude API com segurança, sem expor API keys no cliente)
- **Open Source:** Pode ser self-hosted se necessário no futuro
- **Custo:** Free tier generoso para MVP; crescimento linear de custo com usuários

## Alternativas Consideradas

| Alternativa | Por que Rejeitada |
|-------------|------------------|
| Firebase | Banco NoSQL (Firestore) — inadequado para dados financeiros relacionais; sem RLS nativa |
| AWS Amplify | Complexidade operacional alta; curva de aprendizado maior |
| Backend próprio (Node + PostgreSQL) | Requer infraestrutura, auth própria, manutenção — inviável para time enxuto |
| PocketBase | Menos maturidade, Edge Functions não disponíveis |

## Consequências

### Positivas
- Zero infraestrutura para manter no MVP
- Auth social configurada em horas, não dias
- RLS garante isolamento de dados por design
- Edge Functions permitem lógica sensível no servidor (API keys seguras)

### Negativas
- Dependência de fornecedor (mitigada pelo self-hosting option)
- Limites do free tier podem exigir upgrade com crescimento de usuários
- Edge Functions em Deno/TypeScript: linguagem diferente do restante do projeto

### Riscos
- Supabase poderia mudar pricing ou descontinuar serviços
- Mitigação: SQL padrão PostgreSQL permite migração; self-hosting é viável
- RLS incorreta poderia vazar dados entre usuários
- Mitigação: todo PR que toca banco é revisado especificamente para RLS no checklist

## Conformidade

O Review Agent verifica:
- Toda nova tabela tem RLS habilitada com policy usando `auth.uid()`
- Nenhuma chave de API do Supabase hardcoded no cliente
- Secrets para Edge Functions gerenciados via Supabase Vault
- Chamadas ao Supabase feitas apenas na camada `data/sources/remote/`

## ADRs Relacionados
- ADR-0005: Define como sincronizar dados locais com Supabase

## Originado por
PRD — Driver Finance AI (seção Tecnologia)
