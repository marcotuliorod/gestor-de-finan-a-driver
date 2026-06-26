# Backlog Completo — Driver Finance AI

_Gerado pelo Planner Agent | 2026-06-26 | Priorizado por MoSCoW_

**Legenda:** M = Must Have | S = Should Have | C = Could Have | W = Won't Have (MVP)

---

## ÉPICO 1: Autenticação e Onboarding

### E1-F1: Autenticação Social
| ID | História | Critério de Aceite | MoSCoW | Pontos |
|----|---------|-------------------|--------|--------|
| E1-US01 | Como motorista, quero entrar com minha conta Google para não criar mais uma senha | Login com Google funciona; usuário criado no Supabase; sessão persiste | M | 3 |
| E1-US02 | Como motorista iOS, quero entrar com Apple ID | Login Apple funciona no iOS; cumpre requisito App Store | S | 3 |
| E1-US03 | Como motorista, quero que minha sessão continue ativa sem precisar fazer login todo dia | Token renovado automaticamente; logout explícito disponível | M | 2 |
| E1-US04 | Como motorista, quero poder deletar minha conta e todos os dados | Delete account remove todos os dados do banco (LGPD) | M | 3 |

### E1-F2: Onboarding
| ID | História | Critério de Aceite | MoSCoW | Pontos |
|----|---------|-------------------|--------|--------|
| E1-US05 | Como novo motorista, quero um tutorial que me mostre as funcionalidades principais | 4 telas de onboarding; pode pular; aparece só na primeira vez | S | 3 |
| E1-US06 | Como motorista, quero cadastrar meu veículo no onboarding | Cadastro de veículo: marca, modelo, ano, placa, valor de compra; salvo localmente | M | 3 |
| E1-US07 | Como motorista, quero selecionar as plataformas em que trabalho | Seleção de plataformas ativas; pode editar depois | M | 2 |
| E1-US08 | Como motorista, quero definir minha meta financeira mensal no início | Campo de meta mensal; cálculo automático de meta diária | S | 2 |

---

## ÉPICO 2: Cadastros (Masters)

### E2-F1: Veículos
| ID | História | Critério de Aceite | MoSCoW | Pontos |
|----|---------|-------------------|--------|--------|
| E2-US01 | Como motorista, quero cadastrar meu veículo com dados completos | Campos: marca, modelo, ano, placa, valor compra, combustível, tanque (L) | M | 2 |
| E2-US02 | Como motorista, quero editar os dados do meu veículo | Edição de todos os campos; histórico de edições não exigido | M | 1 |
| E2-US03 | Como motorista, quero definir vida útil e valor residual para cálculo de depreciação | Campos: vida útil (meses), valor residual (%); padrão 60 meses / 20% | S | 2 |

### E2-F2: Plataformas
| ID | História | Critério de Aceite | MoSCoW | Pontos |
|----|---------|-------------------|--------|--------|
| E2-US04 | Como motorista, quero ver as plataformas disponíveis (Uber, 99, inDrive, Táxi, Delivery) | Lista com ícones; ativar/desativar por toggle | M | 2 |
| E2-US05 | Como motorista, quero adicionar uma plataforma customizada | Campo de nome livre para plataformas não listadas | C | 2 |

### E2-F3: Postos de Combustível
| ID | História | Critério de Aceite | MoSCoW | Pontos |
|----|---------|-------------------|--------|--------|
| E2-US06 | Como motorista, quero cadastrar postos favoritos para registrar abastecimentos rapidamente | Nome, bairro, tipo de combustível; selecionável no registro de abastecimento | C | 2 |

### E2-F4: Categorias de Despesa
| ID | História | Critério de Aceite | MoSCoW | Pontos |
|----|---------|-------------------|--------|--------|
| E2-US07 | Como motorista, quero ver as categorias padrão de despesa pré-cadastradas | Categorias padrão visíveis na tela de despesas; não editáveis no MVP | M | 1 |
| E2-US08 | Como motorista, quero criar categorias customizadas de despesa | Nome + ícone (lista fixa de ícones) | C | 2 |

---

## ÉPICO 3: Receitas

### E3-F1: Registro de Corridas
| ID | História | Critério de Aceite | MoSCoW | Pontos |
|----|---------|-------------------|--------|--------|
| E3-US01 | Como motorista, quero registrar uma corrida informando plataforma e valor em < 30 segundos | Formulário: plataforma, valor, data; salvo localmente imediatamente | M | 3 |
| E3-US02 | Como motorista, quero adicionar bônus e gorjeta a uma corrida | Campos opcionais: bônus, gorjeta, promoção; somados ao total | M | 2 |
| E3-US03 | Como motorista, quero registrar cancelamentos com valor de compensação | Campo de cancelamento com valor (pode ser zero) | M | 1 |
| E3-US04 | Como motorista, quero ver a lista de corridas do dia/semana/mês | Lista com filtro por período; ordenada por data desc | M | 3 |
| E3-US05 | Como motorista, quero editar ou excluir uma corrida registrada | Swipe para deletar; tap para editar; soft delete | M | 2 |
| E3-US06 | Como motorista, quero importar corridas via CSV | Upload de CSV; parser para formato Uber e 99; revisão antes de salvar | W | 5 |

---

## ÉPICO 4: Despesas

### E4-F1: Combustível
| ID | História | Critério de Aceite | MoSCoW | Pontos |
|----|---------|-------------------|--------|--------|
| E4-US01 | Como motorista, quero registrar um abastecimento com litros e valor | Campos: data, litros, valor total, tipo combustível, km atual | M | 3 |
| E4-US02 | Como motorista, quero ver meu consumo médio calculado automaticamente | Consumo = km rodados / litros abastecidos; atualizado a cada abastecimento | M | 3 |
| E4-US03 | Como motorista, quero ver o custo por km do combustível | Custo/km = valor total do combustível / km rodados | M | 2 |

### E4-F2: Outras Despesas
| ID | História | Critério de Aceite | MoSCoW | Pontos |
|----|---------|-------------------|--------|--------|
| E4-US04 | Como motorista, quero registrar qualquer despesa com categoria e valor | Campos: categoria, valor, data, descrição opcional; salvo localmente | M | 3 |
| E4-US05 | Como motorista, quero ver o total de despesas por categoria no mês | Agrupamento por categoria com total e % do total | M | 3 |
| E4-US06 | Como motorista, quero registrar despesas recorrentes (IPVA, seguro) | Despesa com flag recorrente; pode ser mensal, anual | S | 3 |
| E4-US07 | Como motorista, quero ver o histórico completo de despesas com filtros | Filtros: categoria, período, valor mín/máx | S | 3 |

---

## ÉPICO 5: Quilometragem

| ID | História | Critério de Aceite | MoSCoW | Pontos |
|----|---------|-------------------|--------|--------|
| E5-US01 | Como motorista, quero registrar km inicial e final do dia | Campos: km inicial, km final, data; km trabalho = final − inicial | M | 2 |
| E5-US02 | Como motorista, quero separar km de trabalho de km particular | Campo de km particular; km trabalho = total − particular | M | 2 |
| E5-US03 | Como motorista, quero ver o total de km rodados no trabalho no período | Soma de km trabalho por semana/mês | M | 2 |
| E5-US04 | Como motorista, quero que o odômetro atual seja sugerido automaticamente | Preencher km inicial com km final do registro anterior | S | 2 |

---

## ÉPICO 6: Manutenções

| ID | História | Critério de Aceite | MoSCoW | Pontos |
|----|---------|-------------------|--------|--------|
| E6-US01 | Como motorista, quero registrar uma manutenção com tipo, custo e km | Campos: tipo, descrição, custo, km atual, data, próxima revisão (km ou data) | M | 3 |
| E6-US02 | Como motorista, quero ver o histórico completo de manutenções do veículo | Lista ordenada por data; total gasto em manutenções | M | 2 |
| E6-US03 | Como motorista, quero ser alertado quando estiver próximo da próxima revisão | Alerta push quando: (km atual − km revisão) < 500km OU faltam 7 dias | M | 4 |
| E6-US04 | Como motorista, quero ver as manutenções programadas (próximas revisões) | Lista de revisões pendentes ordenadas por urgência | S | 2 |
| E6-US05 | Como motorista, quero ver o custo total de manutenções por período | Gráfico de barras e tabela de custos de manutenção | S | 3 |

---

## ÉPICO 7: Dashboard e Indicadores

### E7-F1: Dashboard Principal
| ID | História | Critério de Aceite | MoSCoW | Pontos |
|----|---------|-------------------|--------|--------|
| E7-US01 | Como motorista, quero ver meu lucro de hoje, desta semana e deste mês na tela inicial | Cards com valores; atualização em tempo real quando adiciono registro | M | 4 |
| E7-US02 | Como motorista, quero ver minha meta diária com progresso em % | Barra de progresso; % atingida; valor que falta | M | 3 |
| E7-US03 | Como motorista, quero ver receita total, despesas totais e lucro em um só lugar | Cards: Receita Bruta, Despesas, Lucro Líquido | M | 2 |
| E7-US04 | Como motorista, quero ver meu ganho por hora no período | Lucro / horas trabalhadas; requer registro de horas (ou estimativa) | S | 3 |
| E7-US05 | Como motorista, quero ver meu custo por km no período | (Despesas totais) / km trabalho | M | 2 |

### E7-F2: Indicadores Avançados
| ID | História | Critério de Aceite | MoSCoW | Pontos |
|----|---------|-------------------|--------|--------|
| E7-US06 | Como motorista, quero ver qual plataforma me deu mais lucro no mês | Gráfico comparativo por plataforma: receita, despesas proporcionais, lucro | S | 5 |
| E7-US07 | Como motorista, quero ver o ticket médio por corrida por plataforma | Ticket médio = receita total / número de corridas; por plataforma | S | 2 |
| E7-US08 | Como motorista, quero ver a depreciação do meu veículo como custo real | Depreciação mensal calculada e exibida no dashboard como despesa implícita | S | 4 |
| E7-US09 | Como motorista, quero ver gráfico de lucro diário do mês | Gráfico de linha com lucro por dia | S | 4 |
| E7-US10 | Como motorista, quero ver meu ROI do veículo | ROI = (Lucro acumulado − Valor Compra) / Valor Compra × 100 | C | 3 |

---

## ÉPICO 8: IA Conversacional

| ID | História | Critério de Aceite | MoSCoW | Pontos |
|----|---------|-------------------|--------|--------|
| E8-US01 | Como motorista, quero fazer perguntas em linguagem natural sobre meus ganhos | Chat funcional; responde usando dados reais do usuário; latência < 5s | S | 8 |
| E8-US02 | Como motorista, quero que a IA só use meus próprios dados | Nenhum dado de outros usuários no contexto; PII sanitizada antes do envio | S | 5 |
| E8-US03 | Como motorista, quero ver o histórico das perguntas que já fiz | Lista de conversas anteriores; pode reabrir | C | 3 |
| E8-US04 | Como motorista, quero perguntas sugeridas pré-prontas | 6 perguntas sugeridas na tela inicial do chat | S | 2 |

---

## ÉPICO 9: Metas Financeiras

| ID | História | Critério de Aceite | MoSCoW | Pontos |
|----|---------|-------------------|--------|--------|
| E9-US01 | Como motorista, quero definir uma meta mensal de lucro | Campo de meta mensal em configurações | M | 2 |
| E9-US02 | Como motorista, quero ver meu progresso em relação à meta mensal | Progresso em % + valor faltante + dias restantes no mês | M | 3 |
| E9-US03 | Como motorista, quero receber notificação quando atingir minha meta diária | Push notification ao atingir 100% da meta diária | S | 3 |
| E9-US04 | Como motorista, quero saber quanto preciso faturar por dia para bater a meta do mês | Cálculo automático: (meta − já ganho) / dias restantes | M | 2 |

---

## ÉPICO 10: Configurações e Perfil

| ID | História | Critério de Aceite | MoSCoW | Pontos |
|----|---------|-------------------|--------|--------|
| E10-US01 | Como motorista, quero editar meu perfil (nome, foto) | Campos: nome, foto de perfil (upload) | S | 2 |
| E10-US02 | Como motorista, quero alternar entre modo claro e escuro | Toggle de tema; persistido localmente | S | 2 |
| E10-US03 | Como motorista, quero fazer logout | Botão de logout; sessão encerrada | M | 1 |
| E10-US04 | Como motorista, quero exportar meus dados | Export CSV de corridas e despesas por período | C | 4 |
| E10-US05 | Como motorista, quero configurar o tipo de combustível principal do meu veículo | Gasolina / Etanol / Diesel / Flex; afeta cálculo de consumo | M | 1 |

---

## Resumo por MoSCoW

| Prioridade | Histórias | Story Points |
|-----------|-----------|-------------|
| Must Have | 38 | 82 |
| Should Have | 18 | 57 |
| Could Have | 7 | 17 |
| Won't Have (MVP) | 2 | 9 |
| **Total** | **65** | **165** |
