# 📊 Project State - Sistema de Gestão

> **Estado completo do projeto gerenciado pelo AI Project Manager**
> 
> Este diretório contém a **fonte única da verdade** sobre o projeto.

## 🎯 Quick Start

### Para o Gerente de Projetos (AI)

```bash
# 1. Sempre começar lendo o estado
cat project-state/current-sprint.json

# 2. Executar ação necessária

# 3. Atualizar estado (exemplos no README.md)

# 4. Logar mudança no task-log.jsonl
```

**Regra de Ouro:** Nunca responda sem ler o estado. Nunca aja sem atualizar o estado.

### Para Consultas Rápidas

```bash
# Ver status do sprint
bash project-state/scripts/pm-helpers.sh status

# Listar tasks
bash project-state/scripts/pm-helpers.sh list

# Ver tasks em progresso
bash project-state/scripts/pm-helpers.sh list IN_PROGRESS

# Ver tasks de um agente
bash project-state/scripts/pm-helpers.sh agent "FastAPI Agent"
```

## 📁 Estrutura

```
project-state/
├── 📄 INDEX.md                 ← VOCÊ ESTÁ AQUI (ponto de entrada)
├── 📘 README.md                ← Documentação completa (comandos, exemplos, schemas)
│
├── 🗂️  Arquivos de Estado (modificados frequentemente)
│   ├── project.json            ← Info geral, roadmap, épicos, OKRs
│   ├── current-sprint.json     ← Sprint atual com todas as tasks
│   └── task-log.jsonl          ← Log append-only de mudanças
│
├── 📋 templates/               ← Templates de referência
│   ├── task-template.json      ← Estrutura de uma task
│   └── sprint-template.json    ← Estrutura de um sprint
│
└── 🛠️  scripts/                ← Utilitários
    └── pm-helpers.sh           ← Script com comandos prontos
```

## 📊 Estado Atual do Projeto

**Projeto:** DOT Marketing - HandBI  
**Sprint Atual:** 12 (18/11 - 01/12/2025)  
**Objetivo:** Implementar autenticação Microsoft Entra no HandBI

### Métricas Rápidas

```bash
# Execute para ver métricas atualizadas
cat current-sprint.json | jq '{
  sprint: .sprint,
  total_tasks: .metrics.tasks.total,
  concluidas: .metrics.tasks.done,
  em_progresso: .metrics.tasks.in_progress,
  velocity: "\(.metrics.completed_points)/\(.metrics.total_points) pontos"
}'
```

## 🔄 Workflows Principais

### 1. Receber Diretiva (Nova Funcionalidade)

```bash
# Usuário: "Implementar validação de CPF no backend"

# 1. LER
cat current-sprint.json | jq '.metrics'

# 2. CRIAR TASK
bash scripts/pm-helpers.sh create "Implementar validação de CPF" "FastAPI Agent" P1 3

# 3. RESPONDER ao usuário confirmando criação e delegação
```

### 2. Atualizar Progresso

```bash
# Agente reporta: "TASK-004 concluída"

# 1. LER
cat current-sprint.json | jq '.tasks[] | select(.id=="TASK-004")'

# 2. ATUALIZAR
bash scripts/pm-helpers.sh update TASK-004 DONE "Implementação finalizada e testada"

# 3. RESPONDER confirmando atualização
```

### 3. Consultar Status

```bash
# Usuário: "Qual o status do sprint?"

# 1. LER e FORMATAR
bash scripts/pm-helpers.sh status

# 2. RESPONDER com análise e insights
```

## 📚 Documentação

### Arquivos Principais

| Arquivo | Propósito | Quando Usar |
|---------|-----------|-------------|
| **INDEX.md** | Overview e quick start | Primeira vez ou referência rápida |
| **README.md** | Documentação completa | Exemplos detalhados, comandos avançados |
| **project.json** | Estado geral do projeto | Consultar roadmap, épicos, OKRs |
| **current-sprint.json** | Sprint ativo | SEMPRE antes de qualquer ação |
| **task-log.jsonl** | Histórico de mudanças | Auditar mudanças, analisar timeline |

### Schemas

Ver `templates/` para estrutura completa de:
- Task (`task-template.json`)
- Sprint (`sprint-template.json`)

### Scripts Úteis

Ver `scripts/pm-helpers.sh` para comandos prontos:
- Criar tasks
- Atualizar status
- Consultar métricas
- Validar consistência

## ⚠️ Checklist do Gerente

Antes de **cada resposta**, verificar:

- [ ] Li `current-sprint.json`?
- [ ] Se for diretiva, atualizei o estado?
- [ ] Loguei no `task-log.jsonl`?
- [ ] Confirmei na resposta ao usuário?

## 🎓 Exemplos Práticos

### Exemplo 1: Nova Task

**Input:** "Adicionar gráfico de pizza no dashboard"

```bash
# 1. LER estado
cat current-sprint.json | jq '.metrics'

# 2. ANALISAR
# - Camadas: UX/UI (design) + Vue (implementação)
# - Estimativa: 5 SP
# - Prioridade: P1

# 3. CRIAR
bash scripts/pm-helpers.sh create "Adicionar gráfico de pizza no dashboard" "Vue Agent" P1 5

# 4. RESPONDER
# "✅ Task criada: TASK-XXXX - Adicionar gráfico de pizza no dashboard
#  Delegando ao Vue Agent para implementação.
#  Estimativa: 5 Story Points"
```

### Exemplo 2: Reportar Progresso

**Input:** "FastAPI Agent reporta conclusão de TASK-004"

```bash
# 1. LER task
cat current-sprint.json | jq '.tasks[] | select(.id=="TASK-004")'

# 2. ATUALIZAR
bash scripts/pm-helpers.sh update TASK-004 DONE "OAuth2 flow implementado e testado"

# 3. RESPONDER
# "✅ Task TASK-004 concluída!
#  Sprint progress: X/Y tasks done (Z points)"
```

### Exemplo 3: Sprint Status

**Input:** "Como está o sprint?"

```bash
# 1. CONSULTAR
bash scripts/pm-helpers.sh status

# 2. ANALISAR impedimentos, riscos, próximos passos

# 3. RESPONDER com insights e recomendações
```

## 🚀 Primeiros Passos

1. **Leia este INDEX.md** (você está aqui) ✅
2. **Explore README.md** para comandos detalhados
3. **Verifique current-sprint.json** para entender estado atual
4. **Teste pm-helpers.sh** para se familiarizar com comandos
5. **Comece a gerenciar!** Lembre-se: LER → AGIR → ATUALIZAR → LOGAR

## 🆘 Problemas Comuns

### JSON Inválido
```bash
# Validar
jq empty current-sprint.json

# Se inválido, restaurar backup ou corrigir manualmente
```

### Métricas Inconsistentes
```bash
# Recalcular automaticamente
bash scripts/pm-helpers.sh validate
```

### Dúvidas sobre Comandos
```bash
# Ver todos os comandos disponíveis
bash scripts/pm-helpers.sh help
```

## 📖 Referências Externas

- [jq Manual](https://stedolan.github.io/jq/manual/) - Manipulação de JSON
- [JSON Lines](https://jsonlines.org/) - Formato do task-log.jsonl
- [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) - Formato de timestamps

---

**Lembre-se:** O estado nestes arquivos **É** a realidade do projeto.  
Não existe "projeto" fora desses arquivos.  
Sua memória é volátil - o JSON é permanente.

Para documentação completa, ver **README.md** →
