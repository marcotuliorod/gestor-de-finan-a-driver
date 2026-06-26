# ADR-0002: Flutter como Plataforma UI Cross-Platform

## Status
Accepted

## Data
2026-06-26

## Contexto

O Driver Finance AI precisa atingir motoristas em iOS e Android a partir de uma única base de código. O público-alvo (motoristas de aplicativo) usa predominantemente Android, mas uma parcela relevante usa iOS. Manter dois apps nativos separados dobraria o custo de desenvolvimento e manutenção para um time enxuto.

A escolha da tecnologia de UI define o ecossistema de toda a camada de apresentação: linguagem, ferramentas, componentes, testes e processo de deploy.

## Decisão

Usamos **Flutter** com **Dart** como framework UI cross-platform. O app será compilado para Android e iOS a partir de uma única base de código. State management via **Riverpod** (com code generation). Persistência local via **Drift** (SQLite ORM para Dart).

## Justificativa

- **Performance:** Flutter compila para código nativo — sem bridge JavaScript como React Native. Essencial para operações locais < 300ms exigidas pelo PRD.
- **Single codebase:** Um único time mantém iOS e Android simultaneamente.
- **Ecossistema maduro:** Dart/Flutter tem suporte de banco (Drift), state management (Riverpod), e testes (flutter_test) de alta qualidade.
- **Offline First nativo:** Drift + SQLite em Dart é a combinação mais robusta para apps offline-first em mobile.
- **Familiaridade:** Stack definida pelo proprietário do produto no PRD.

## Alternativas Consideradas

| Alternativa | Por que Rejeitada |
|-------------|------------------|
| React Native | Bridge JS impacta performance; overhead de < 300ms seria difícil de garantir |
| Kotlin Multiplatform (KMP) | Maturidade menor do ecossistema de UI compartilhada em 2026 |
| Apps nativos separados (Kotlin + Swift) | Custo 2x de desenvolvimento e manutenção |
| PWA / Web App | Experiência degradada para uso intenso mobile; sem acesso offline completo |

## Consequências

### Positivas
- Um único codebase para iOS + Android
- Performance nativa (compilação AOT)
- Hot reload acelera o desenvolvimento
- Dart type-safe reduz bugs em runtime

### Negativas
- Dart é menos comum que JavaScript/TypeScript — pool menor de desenvolvedores
- Algumas APIs nativas podem exigir plugins específicos ou implementação manual

### Riscos
- Plugins de terceiros podem não ter suporte equivalente em iOS e Android
- Mitigação: avaliar suporte cross-platform antes de adotar qualquer plugin

## Conformidade

O Review Agent verifica:
- Nenhum código platform-specific sem abstração de plugin
- Nenhum uso de `dart:io` ou `dart:html` diretamente (usar abstrações)
- `flutter analyze` sem warnings em todo PR

## ADRs Relacionados
- ADR-0004: Clean Architecture define como organizar o código Flutter

## Originado por
PRD — Driver Finance AI (seção Tecnologia)
