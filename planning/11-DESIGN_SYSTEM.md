# Design System — Driver Finance AI

_Gerado pelo Frontend Agent | 2026-06-26_

---

## Paleta de Cores

### Cores Primárias

```dart
// Tokens de cores — src/core/ui/theme/app_colors.dart

class AppColors {
  // Primary — Verde profit (positivo, crescimento)
  static const primary         = Color(0xFF00C853); // Verde vibrante
  static const primaryDark     = Color(0xFF00962E);
  static const primaryLight    = Color(0xFF69FF7D);
  static const primaryContainer= Color(0xFFD7FFE0);

  // Secondary — Azul confiança
  static const secondary       = Color(0xFF1565C0);
  static const secondaryLight  = Color(0xFF5E92F3);

  // Semantic — Estados financeiros
  static const profit          = Color(0xFF00C853); // lucro positivo
  static const loss            = Color(0xFFE53935); // prejuízo
  static const neutral         = Color(0xFF546E7A); // neutro
  static const warning         = Color(0xFFFF8F00); // alerta (manutenção)

  // Surface (Light Mode)
  static const background      = Color(0xFFF5F7FA);
  static const surface         = Color(0xFFFFFFFF);
  static const surfaceVariant  = Color(0xFFEEF1F5);

  // Surface (Dark Mode)
  static const backgroundDark  = Color(0xFF0D1117);
  static const surfaceDark     = Color(0xFF161B22);
  static const surfaceVariantDark = Color(0xFF21262D);

  // Text
  static const textPrimary     = Color(0xFF1A1A2E);
  static const textSecondary   = Color(0xFF6B7280);
  static const textDisabled    = Color(0xFFBDBDBD);
  static const textOnPrimary   = Color(0xFFFFFFFF);

  // Chart Colors (plataformas)
  static const uber            = Color(0xFF000000);
  static const app99           = Color(0xFFFFCC00);
  static const indrive         = Color(0xFF00A651);
  static const taxi            = Color(0xFF1565C0);
  static const delivery        = Color(0xFFFF5722);
  static const custom          = Color(0xFF9C27B0);
}
```

---

## Tipografia

```dart
// src/core/ui/theme/app_typography.dart

class AppTypography {
  static const fontFamily = 'Inter';  // Google Fonts

  // Display — valores monetários grandes no dashboard
  static const displayLarge = TextStyle(
    fontSize: 36, fontWeight: FontWeight.w700, letterSpacing: -1.0,
  );
  static const displayMedium = TextStyle(
    fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.5,
  );

  // Headline — títulos de seção
  static const headlineMedium = TextStyle(
    fontSize: 22, fontWeight: FontWeight.w600,
  );
  static const headlineSmall = TextStyle(
    fontSize: 18, fontWeight: FontWeight.w600,
  );

  // Body — texto corrido
  static const bodyLarge = TextStyle(
    fontSize: 16, fontWeight: FontWeight.w400, height: 1.5,
  );
  static const bodyMedium = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w400, height: 1.5,
  );
  static const bodySmall = TextStyle(
    fontSize: 12, fontWeight: FontWeight.w400,
  );

  // Label — botões, chips
  static const labelLarge = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1,
  );
  static const labelMedium = TextStyle(
    fontSize: 12, fontWeight: FontWeight.w500,
  );

  // Número monetário — destaque
  static const moneyDisplay = TextStyle(
    fontSize: 32, fontWeight: FontWeight.w800,
    fontFeatures: [FontFeature.tabularFigures()],
  );
  static const moneyMedium = TextStyle(
    fontSize: 20, fontWeight: FontWeight.w700,
    fontFeatures: [FontFeature.tabularFigures()],
  );
}
```

---

## Espaçamento e Dimensões

```dart
// src/core/ui/theme/app_spacing.dart

class AppSpacing {
  // Base unit: 4px
  static const double xs  = 4.0;
  static const double sm  = 8.0;
  static const double md  = 16.0;
  static const double lg  = 24.0;
  static const double xl  = 32.0;
  static const double xxl = 48.0;

  // Border Radius
  static const double radiusSm  = 8.0;
  static const double radiusMd  = 12.0;
  static const double radiusLg  = 16.0;
  static const double radiusXl  = 24.0;
  static const double radiusFull= 999.0;

  // Card padding padrão
  static const EdgeInsets cardPadding = EdgeInsets.all(md);

  // Page padding
  static const EdgeInsets pagePadding = EdgeInsets.symmetric(
    horizontal: md, vertical: sm,
  );

  // Mínimo de toque (acessibilidade)
  static const double minTapTarget = 44.0;
}
```

---

## Componentes do Design System

### MetricCard

Exibe um indicador financeiro com título, valor e variação opcional.

```
┌────────────────────────────┐
│  Receita Bruta             │
│  R$ 2.712,00               │ ← displayMedium / moneyMedium
│  ↑ 12% vs semana passada  │ ← caption verde/vermelho
└────────────────────────────┘
```

```dart
// src/core/ui/components/metric_card.dart
class MetricCard extends StatelessWidget {
  const MetricCard({
    required this.title,
    required this.value,    // Money
    this.change,            // MetricChange? (valor + direção)
    this.onTap,
    super.key,
  });
}
```

---

### CurrencyField

Campo de entrada de valor monetário com formatação automática.

```
R$ 1.234,50
```

- Input: apenas dígitos, formata como BRL
- Valida: valor > 0
- Teclado numérico automático

---

### PlatformBadge

Badge colorido para identificar plataforma.

```
[■ Uber]  [■ 99]  [■ inDrive]
```

```dart
class PlatformBadge extends StatelessWidget {
  const PlatformBadge({required this.platform, this.compact = false, super.key});
}
```

---

### GoalProgressBar

Barra de progresso da meta com % e valor faltante.

```
Meta: R$ 4.000
R$2.712 ████████████░░░░  68%  Faltam: R$1.288
```

---

### EmptyState

Tela vazia com ilustração e call-to-action.

```
        [🚗 Ícone]

  "Nenhuma corrida registrada"

  "Registre sua primeira corrida
   para ver seus ganhos aqui."

  [ + Adicionar corrida ]
```

---

### AlertCard

Card de alerta de manutenção com nível de urgência.

```
[!] ← ícone de cor conforme urgência
Troca de óleo próxima
420 km além do prazo recomendado
[Registrar agora]
```

Urgência:
- 🟡 Amarelo: faltam > 500km ou > 15 dias
- 🟠 Laranja: faltam 100–500km ou 7–15 dias
- 🔴 Vermelho: < 100km ou < 7 dias / atrasado

---

## Temas (Light / Dark)

```dart
// src/core/ui/theme/app_theme.dart

ThemeData get lightTheme => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.light,
  ),
  textTheme: _buildTextTheme(Colors.black),
  cardTheme: CardTheme(
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
    ),
    color: AppColors.surface,
  ),
  appBarTheme: AppBarTheme(
    elevation: 0,
    backgroundColor: AppColors.background,
    titleTextStyle: AppTypography.headlineSmall,
  ),
  // ...
);

ThemeData get darkTheme => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.dark,
  ),
  // Override surfaces para dark mode
  scaffoldBackgroundColor: AppColors.backgroundDark,
  // ...
);
```

---

## Iconografia

Usar **Material Symbols** (outlined) como conjunto padrão.

| Contexto | Ícone |
|---------|-------|
| Corrida / Trip | `directions_car` |
| Combustível | `local_gas_station` |
| Despesa | `receipt_long` |
| Lucro / Profit | `trending_up` |
| Manutenção | `build` |
| Meta | `flag` |
| IA / Chat | `smart_toy` |
| Relatório | `bar_chart` |
| Configurações | `settings` |
| Alerta | `warning` |
| Adicionar | `add_circle` |
| Sucesso | `check_circle` |
| Erro | `error` |

---

## Acessibilidade

- Contraste mínimo: AA (4.5:1 para texto normal, 3:1 para texto grande)
- Tamanho mínimo de toque: 44×44px
- `semanticLabel` em toda imagem não decorativa
- Suporte a `textScaleFactor` (até 1.5× sem overflow)
- Cores de estado (lucro/prejuízo) nunca dependem só de cor — usar ícone + cor

---

## Formatação Monetária

```dart
// src/core/utils/currency_formatter.dart
class CurrencyFormatter {
  static String format(Money money) =>
    NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(money.reais);

  static String formatCompact(Money money) =>
    money.reais >= 1000
      ? 'R\$ ${(money.reais / 1000).toStringAsFixed(1)}k'
      : format(money);
}
```
