# Sistema de Gestão de Projeto - Documentação

## 📋 Visão Geral

Este diretório contém o **estado completo do projeto** gerenciado pelo AI Project Manager.
Todos os arquivos aqui são a **fonte única da verdade** sobre o projeto.

## 📁 Estrutura de Arquivos

```
/project-state/
  ├── project.json          # Informações gerais, roadmap, épicos, OKRs
  ├── current-sprint.json   # Sprint atual com todas as tasks
  ├── task-log.jsonl        # Log append-only de todas as mudanças
  ├── README.md             # Esta documentação
  ├── templates/            # Templates de referência
  │   ├── task-template.json
  │   └── sprint-template.json
  └── scripts/              # Scripts auxiliares
      └── pm-helpers.sh
```

## 🔄 Workflow do Gerente de Projetos

### Regra dos 4 Passos

Para TODA ação, o gerente DEVE:

1. **📖 LER** o estado atual
2. **🎯 EXECUTAR** a ação 
3. **✍️ ATUALIZAR** o estado
4. **📝 LOGAR** a mudança

## 📊 Schemas dos Arquivos

### project.json

Contém informações de alto nível do projeto:

```json
{
  "project_name": "Nome do Projeto",
  "description": "Descrição",
  "tech_stack": { },
  "team": [ ],
  "roadmap": [
    {
      "epic_id": "EPIC-XXX",
      "title": "Título do Épico",
      "status": "PLANNED|IN_PROGRESS|DONE",
      "priority": "P0|P1|P2",
      "start_date": "YYYY-MM-DD",
      "target_date": "YYYY-MM-DD",
      "description": "Descrição detalhada",
      "sprints": [12, 13]
    }
  ],
  "okrs": { },
  "metadata": {
    "current_sprint": 12,
    "total_sprints_completed": 11
  }
}
```

### current-sprint.json

Contém o sprint ativo com todas as tasks:

```json
{
  "sprint": 12,
  "start_date": "YYYY-MM-DD",
  "end_date": "YYYY-MM-DD",
  "goal": "Objetivo do sprint",
  "epic": "EPIC-XXX",
  "metrics": {
    "total_points": 21,
    "completed_points": 8,
    "tasks": {
      "total": 8,
      "todo": 3,
      "in_progress": 2,
      "done": 3,
      "blocked": 0
    }
  },
  "tasks": [ ... ]
}
```

### Task Schema

Cada task no array `tasks` tem este formato:

```json
{
  "id": "TASK-XXX",
  "title": "Título descritivo",
  "agent": "Nome do Agente",
  "status": "TODO|IN_PROGRESS|DONE|BLOCKED",
  "priority": "P0|P1|P2",
  "story_points": 5,
  "created_at": "ISO 8601 timestamp",
  "started_at": "ISO 8601 timestamp ou null",
  "completed_at": "ISO 8601 timestamp ou null",
  "context": "Por que essa task existe",
  "acceptance_criteria": [
    "Critério 1",
    "Critério 2"
  ],
  "dependencies": ["TASK-YYY"],
  "notes": "Observações adicionais"
}
```

### task-log.jsonl

Log append-only. Cada linha é um JSON independente:

```json
{"timestamp":"2025-11-18T10:00:00Z","action":"task_created","task_id":"TASK-001","agent":"DevOps Agent","title":"...","story_points":2}
{"timestamp":"2025-11-18T10:30:00Z","action":"task_started","task_id":"TASK-001","notes":"..."}
{"timestamp":"2025-11-18T14:30:00Z","action":"task_completed","task_id":"TASK-001","notes":"..."}
{"timestamp":"2025-11-19T09:00:00Z","action":"task_updated","task_id":"TASK-002","field":"notes","value":"..."}
{"timestamp":"2025-11-20T11:00:00Z","action":"task_blocked","task_id":"TASK-003","reason":"..."}
```

**Tipos de action:**
- `sprint_started`
- `sprint_completed`
- `task_created`
- `task_started`
- `task_updated`
- `task_completed`
- `task_blocked`
- `task_unblocked`

## 🛠️ Comandos Úteis

### Consultas Básicas

```bash
# Ver todas as tasks do sprint
cat current-sprint.json | jq '.tasks[]'

# Ver apenas títulos e status
cat current-sprint.json | jq '.tasks[] | {id, title, status, agent}'

# Métricas do sprint
cat current-sprint.json | jq '.metrics'

# Tasks de um agente específico
cat current-sprint.json | jq '.tasks[] | select(.agent=="FastAPI Agent")'

# Tasks por status
cat current-sprint.json | jq '.tasks[] | select(.status=="TODO")'
cat current-sprint.json | jq '.tasks[] | select(.status=="IN_PROGRESS")'
cat current-sprint.json | jq '.tasks[] | select(.status=="DONE")'
cat current-sprint.json | jq '.tasks[] | select(.status=="BLOCKED")'

# Tasks bloqueadas
cat current-sprint.json | jq '.tasks[] | select(.status=="BLOCKED")'

# Tasks por prioridade
cat current-sprint.json | jq '.tasks[] | select(.priority=="P0")'
```

### Análises

```bash
# Contagem por agente
cat current-sprint.json | jq '[.tasks[] | .agent] | group_by(.) | map({agent: .[0], count: length})'

# Velocity (pontos concluídos)
cat current-sprint.json | jq '[.tasks[] | select(.status=="DONE") | .story_points] | add'

# Taxa de conclusão
cat current-sprint.json | jq '(.tasks | map(select(.status=="DONE")) | length) / (.tasks | length) * 100'

# Histórico de mudanças (últimas 10)
tail -n 10 task-log.jsonl | jq '.'

# Todas as ações de uma task específica
cat task-log.jsonl | jq 'select(.task_id=="TASK-001")'

# Contagem de ações por tipo
cat task-log.jsonl | jq -s 'group_by(.action) | map({action: .[0].action, count: length})'
```

### Atualização de Tasks

```bash
# Atualizar status de uma task
cat current-sprint.json | \
  jq '(.tasks[] | select(.id=="TASK-004")) |= . + {
    "status": "DONE",
    "completed_at": "'$(date -Iseconds)'"
  } | 
  .metrics.tasks.in_progress -= 1 | 
  .metrics.tasks.done += 1 | 
  .metrics.completed_points += 5' \
  > current-sprint.json.tmp && \
  mv current-sprint.json.tmp current-sprint.json

# Logar a mudança
echo '{"timestamp":"'$(date -Iseconds)'","action":"task_completed","task_id":"TASK-004","notes":"Implementação finalizada"}' >> task-log.jsonl
```

### Adicionar Nova Task

```bash
# Gerar ID único
TASK_ID="TASK-$(date +%s | tail -c 4)"

# Adicionar task
cat current-sprint.json | \
  jq --arg id "$TASK_ID" \
     --arg now "$(date -Iseconds)" \
     '.tasks += [{
       "id": $id,
       "title": "Nova task",
       "agent": "FastAPI Agent",
       "status": "TODO",
       "priority": "P1",
       "story_points": 3,
       "created_at": $now,
       "started_at": null,
       "completed_at": null,
       "context": "Contexto da task",
       "acceptance_criteria": ["Critério 1"],
       "dependencies": [],
       "notes": ""
     }] | 
     .metrics.tasks.total += 1 | 
     .metrics.tasks.todo += 1 | 
     .metrics.total_points += 3' \
  > current-sprint.json.tmp && \
  mv current-sprint.json.tmp current-sprint.json

# Logar criação
echo '{"timestamp":"'$(date -Iseconds)'","action":"task_created","task_id":"'$TASK_ID'","agent":"FastAPI Agent","title":"Nova task","story_points":3}' >> task-log.jsonl
```

## 📈 Relatórios

### Sprint Report

```bash
cat current-sprint.json | jq '{
  sprint: .sprint,
  periodo: "\(.start_date) a \(.end_date)",
  objetivo: .goal,
  metricas: .metrics,
  progresso_percentual: ((.metrics.completed_points / .metrics.total_points) * 100 | round),
  tasks_por_status: {
    todo: [.tasks[] | select(.status=="TODO") | {id, title, agent, points: .story_points}],
    in_progress: [.tasks[] | select(.status=="IN_PROGRESS") | {id, title, agent, points: .story_points}],
    done: [.tasks[] | select(.status=="DONE") | {id, title, agent, points: .story_points}],
    blocked: [.tasks[] | select(.status=="BLOCKED") | {id, title, agent, points: .story_points}]
  }
}'
```

### Velocity por Agente

```bash
cat current-sprint.json | jq '[
  .tasks[] | 
  select(.status=="DONE") | 
  {agent, points: .story_points}
] | 
group_by(.agent) | 
map({
  agent: .[0].agent, 
  velocity: ([.[].points] | add)
})'
```

### Timeline de Eventos

```bash
cat task-log.jsonl | jq -s 'group_by(.action) | map({
  action: .[0].action,
  count: length,
  tasks: [.[].task_id] | unique
})'
```

## 🎯 Exemplos Práticos

### Exemplo 1: Criar Nova Task

**Situação:** Usuário pede "Adicionar validação de email no formulário de cadastro"

```bash
# 1. LER estado
cat current-sprint.json | jq '.sprint, .metrics'

# 2. ANALISAR
# - Camada: Frontend (Vue)
# - Estimativa: 2 SP
# - Prioridade: P1

# 3. CRIAR TASK
TASK_ID="TASK-$(date +%s | tail -c 4)"
cat current-sprint.json | \
  jq --arg id "$TASK_ID" --arg now "$(date -Iseconds)" \
  '.tasks += [{
    "id": $id,
    "title": "Adicionar validação de email no formulário de cadastro",
    "agent": "Vue Agent",
    "status": "TODO",
    "priority": "P1",
    "story_points": 2,
    "created_at": $now,
    "started_at": null,
    "completed_at": null,
    "context": "Melhorar UX e prevenir emails inválidos",
    "acceptance_criteria": [
      "Validação em tempo real implementada",
      "Mensagens de erro claras",
      "Regex de validação testado",
      "Acessibilidade (aria-labels) implementada"
    ],
    "dependencies": [],
    "notes": ""
  }] | .metrics.tasks.total += 1 | .metrics.tasks.todo += 1 | .metrics.total_points += 2' \
  > current-sprint.json.tmp && mv current-sprint.json.tmp current-sprint.json

# 4. LOGAR
echo '{"timestamp":"'$(date -Iseconds)'","action":"task_created","task_id":"'$TASK_ID'","agent":"Vue Agent","title":"Adicionar validação de email no formulário de cadastro","story_points":2}' >> task-log.jsonl

# 5. RESPONDER
echo "✅ Task criada: $TASK_ID - Adicionar validação de email no formulário de cadastro"
echo "Delegando ao Vue Agent para implementação."
```

### Exemplo 2: Atualizar Status

**Situação:** Vue Agent reporta conclusão de TASK-003

```bash
# 1. LER
cat current-sprint.json | jq '.tasks[] | select(.id=="TASK-003")'

# 2. ATUALIZAR
cat current-sprint.json | \
  jq '(.tasks[] | select(.id=="TASK-003")) |= . + {
    "status": "DONE",
    "completed_at": "'$(date -Iseconds)'",
    "notes": "UI finalizada conforme design. Componente em src/views/auth/LoginView.vue"
  } | 
  .metrics.tasks.in_progress -= 1 | 
  .metrics.tasks.done += 1 | 
  .metrics.completed_points += 3' \
  > current-sprint.json.tmp && mv current-sprint.json.tmp current-sprint.json

# 3. LOGAR
echo '{"timestamp":"'$(date -Iseconds)'","action":"task_completed","task_id":"TASK-003","notes":"UI finalizada"}' >> task-log.jsonl
```

### Exemplo 3: Consultar Status do Sprint

**Situação:** Usuário pergunta "Qual o status do sprint?"

```bash
# 1. LER e FORMATAR
cat current-sprint.json | jq '{
  sprint: .sprint,
  periodo: "\(.start_date) a \(.end_date)",
  objetivo: .goal,
  metricas: .metrics,
  progresso: "\(.metrics.completed_points) / \(.metrics.total_points) pontos (\((.metrics.completed_points / .metrics.total_points * 100) | round)%)",
  tasks_por_status: {
    concluidas: (.metrics.tasks.done),
    em_progresso: (.metrics.tasks.in_progress),
    a_fazer: (.metrics.tasks.todo),
    bloqueadas: (.metrics.tasks.blocked)
  }
}'
```

## ⚠️ Validações Importantes

Antes de cada resposta, o gerente deve verificar:

- [ ] Li o estado atual? (`cat current-sprint.json`)
- [ ] Se for diretiva, atualizei o estado?
- [ ] Loguei a mudança no task-log.jsonl?
- [ ] As métricas estão consistentes?

## 🚨 Troubleshooting

### Métricas Inconsistentes

Se as métricas não batem com as tasks:

```bash
# Recalcular métricas
cat current-sprint.json | jq '
  .metrics.tasks.total = (.tasks | length) |
  .metrics.tasks.todo = (.tasks | map(select(.status=="TODO")) | length) |
  .metrics.tasks.in_progress = (.tasks | map(select(.status=="IN_PROGRESS")) | length) |
  .metrics.tasks.done = (.tasks | map(select(.status=="DONE")) | length) |
  .metrics.tasks.blocked = (.tasks | map(select(.status=="BLOCKED")) | length) |
  .metrics.total_points = ([.tasks[].story_points] | add) |
  .metrics.completed_points = ([.tasks[] | select(.status=="DONE") | .story_points] | add)
' > current-sprint.json.tmp && mv current-sprint.json.tmp current-sprint.json
```

### JSON Inválido

```bash
# Validar JSON
jq empty current-sprint.json && echo "✅ JSON válido" || echo "❌ JSON inválido"
```

### Backup

```bash
# Fazer backup antes de grandes mudanças
cp current-sprint.json current-sprint.backup.json
cp task-log.jsonl task-log.backup.jsonl
```

## 📚 Referências

- Templates disponíveis em `/project-state/templates/`
- Scripts auxiliares em `/project-state/scripts/`
- Para mais comandos jq: https://stedolan.github.io/jq/manual/
