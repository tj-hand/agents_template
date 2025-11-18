#!/bin/bash
# PM Helper Scripts - Comandos auxiliares para gerenciamento de projeto

PROJECT_DIR="/project-state"
SPRINT_FILE="$PROJECT_DIR/current-sprint.json"
LOG_FILE="$PROJECT_DIR/task-log.jsonl"

# Cores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função: Gerar ID único de task
generate_task_id() {
    echo "TASK-$(date +%s | tail -c 4)"
}

# Função: Obter timestamp ISO 8601
get_timestamp() {
    date -Iseconds
}

# Função: Criar nova task
create_task() {
    local title="$1"
    local agent="$2"
    local priority="${3:-P1}"
    local points="${4:-3}"
    
    local task_id=$(generate_task_id)
    local now=$(get_timestamp)
    
    cat "$SPRINT_FILE" | \
        jq --arg id "$task_id" \
           --arg title "$title" \
           --arg agent "$agent" \
           --arg priority "$priority" \
           --argjson points "$points" \
           --arg now "$now" \
           '.tasks += [{
             "id": $id,
             "title": $title,
             "agent": $agent,
             "status": "TODO",
             "priority": $priority,
             "story_points": $points,
             "created_at": $now,
             "started_at": null,
             "completed_at": null,
             "context": "",
             "acceptance_criteria": [],
             "dependencies": [],
             "notes": ""
           }] | 
           .metrics.tasks.total += 1 | 
           .metrics.tasks.todo += 1 | 
           .metrics.total_points += $points' \
        > "$SPRINT_FILE.tmp" && mv "$SPRINT_FILE.tmp" "$SPRINT_FILE"
    
    echo "{\"timestamp\":\"$now\",\"action\":\"task_created\",\"task_id\":\"$task_id\",\"agent\":\"$agent\",\"title\":\"$title\",\"story_points\":$points}" >> "$LOG_FILE"
    
    echo -e "${GREEN}✅ Task criada: $task_id - $title${NC}"
    echo -e "   Agente: $agent | Prioridade: $priority | Pontos: $points"
}

# Função: Atualizar status de task
update_status() {
    local task_id="$1"
    local new_status="$2"
    local notes="${3:-}"
    local now=$(get_timestamp)
    
    # Obter status atual
    local old_status=$(cat "$SPRINT_FILE" | jq -r ".tasks[] | select(.id==\"$task_id\") | .status")
    
    if [ -z "$old_status" ]; then
        echo -e "${RED}❌ Task $task_id não encontrada${NC}"
        return 1
    fi
    
    # Obter pontos para atualizar métricas
    local points=$(cat "$SPRINT_FILE" | jq -r ".tasks[] | select(.id==\"$task_id\") | .story_points")
    
    # Atualizar JSON
    local update_expr='(.tasks[] | select(.id=="'$task_id'")) |= . + {"status": "'$new_status'"'
    
    if [ "$new_status" = "IN_PROGRESS" ] && [ "$old_status" = "TODO" ]; then
        update_expr+=', "started_at": "'$now'"'
    elif [ "$new_status" = "DONE" ]; then
        update_expr+=', "completed_at": "'$now'"'
    fi
    
    if [ -n "$notes" ]; then
        update_expr+=', "notes": "'$notes'"'
    fi
    
    update_expr+='}'
    
    # Atualizar métricas
    if [ "$old_status" != "$new_status" ]; then
        case "$old_status" in
            "TODO") update_expr+=' | .metrics.tasks.todo -= 1' ;;
            "IN_PROGRESS") update_expr+=' | .metrics.tasks.in_progress -= 1' ;;
            "DONE") update_expr+=' | .metrics.tasks.done -= 1 | .metrics.completed_points -= '$points ;;
            "BLOCKED") update_expr+=' | .metrics.tasks.blocked -= 1' ;;
        esac
        
        case "$new_status" in
            "TODO") update_expr+=' | .metrics.tasks.todo += 1' ;;
            "IN_PROGRESS") update_expr+=' | .metrics.tasks.in_progress += 1' ;;
            "DONE") update_expr+=' | .metrics.tasks.done += 1 | .metrics.completed_points += '$points ;;
            "BLOCKED") update_expr+=' | .metrics.tasks.blocked += 1' ;;
        esac
    fi
    
    cat "$SPRINT_FILE" | jq "$update_expr" > "$SPRINT_FILE.tmp" && mv "$SPRINT_FILE.tmp" "$SPRINT_FILE"
    
    # Logar
    local action="task_updated"
    [ "$new_status" = "IN_PROGRESS" ] && action="task_started"
    [ "$new_status" = "DONE" ] && action="task_completed"
    [ "$new_status" = "BLOCKED" ] && action="task_blocked"
    
    echo "{\"timestamp\":\"$now\",\"action\":\"$action\",\"task_id\":\"$task_id\",\"old_status\":\"$old_status\",\"new_status\":\"$new_status\",\"notes\":\"$notes\"}" >> "$LOG_FILE"
    
    echo -e "${GREEN}✅ Task $task_id atualizada: $old_status → $new_status${NC}"
}

# Função: Ver status do sprint
sprint_status() {
    echo -e "${BLUE}📊 Status do Sprint${NC}"
    echo ""
    
    cat "$SPRINT_FILE" | jq -r '
        "Sprint: \(.sprint)",
        "Período: \(.start_date) a \(.end_date)",
        "Objetivo: \(.goal)",
        "",
        "Métricas:",
        "  Total de Tasks: \(.metrics.tasks.total)",
        "  Story Points: \(.metrics.completed_points) / \(.metrics.total_points) (\((.metrics.completed_points / .metrics.total_points * 100) | round)%)",
        "",
        "Status:",
        "  ✅ Concluídas: \(.metrics.tasks.done)",
        "  🔄 Em Progresso: \(.metrics.tasks.in_progress)",
        "  📋 A Fazer: \(.metrics.tasks.todo)",
        "  🚫 Bloqueadas: \(.metrics.tasks.blocked)"
    '
}

# Função: Listar tasks
list_tasks() {
    local status="${1:-all}"
    
    echo -e "${BLUE}📋 Tasks do Sprint${NC}"
    echo ""
    
    if [ "$status" = "all" ]; then
        cat "$SPRINT_FILE" | jq -r '.tasks[] | "\(.id) | \(.status) | \(.agent) | \(.title) (\(.story_points) SP)"'
    else
        cat "$SPRINT_FILE" | jq -r ".tasks[] | select(.status==\"$status\") | \"\(.id) | \(.agent) | \(.title) (\(.story_points) SP)\""
    fi
}

# Função: Ver detalhes de uma task
task_details() {
    local task_id="$1"
    
    cat "$SPRINT_FILE" | jq ".tasks[] | select(.id==\"$task_id\")"
}

# Função: Ver tasks de um agente
agent_tasks() {
    local agent="$1"
    
    echo -e "${BLUE}📋 Tasks de: $agent${NC}"
    echo ""
    
    cat "$SPRINT_FILE" | jq -r ".tasks[] | select(.agent==\"$agent\") | \"\(.id) | \(.status) | \(.title) (\(.story_points) SP)\""
}

# Função: Validar consistência
validate() {
    echo -e "${YELLOW}🔍 Validando consistência...${NC}"
    
    # Validar JSON
    if ! jq empty "$SPRINT_FILE" 2>/dev/null; then
        echo -e "${RED}❌ JSON inválido em $SPRINT_FILE${NC}"
        return 1
    fi
    
    # Recalcular métricas
    local calc_total=$(cat "$SPRINT_FILE" | jq '.tasks | length')
    local calc_todo=$(cat "$SPRINT_FILE" | jq '.tasks | map(select(.status=="TODO")) | length')
    local calc_progress=$(cat "$SPRINT_FILE" | jq '.tasks | map(select(.status=="IN_PROGRESS")) | length')
    local calc_done=$(cat "$SPRINT_FILE" | jq '.tasks | map(select(.status=="DONE")) | length')
    local calc_blocked=$(cat "$SPRINT_FILE" | jq '.tasks | map(select(.status=="BLOCKED")) | length')
    
    local stored_total=$(cat "$SPRINT_FILE" | jq '.metrics.tasks.total')
    
    if [ "$calc_total" != "$stored_total" ]; then
        echo -e "${RED}❌ Métricas inconsistentes! Recalculando...${NC}"
        
        cat "$SPRINT_FILE" | jq '
            .metrics.tasks.total = (.tasks | length) |
            .metrics.tasks.todo = (.tasks | map(select(.status=="TODO")) | length) |
            .metrics.tasks.in_progress = (.tasks | map(select(.status=="IN_PROGRESS")) | length) |
            .metrics.tasks.done = (.tasks | map(select(.status=="DONE")) | length) |
            .metrics.tasks.blocked = (.tasks | map(select(.status=="BLOCKED")) | length) |
            .metrics.total_points = ([.tasks[].story_points] | add) |
            .metrics.completed_points = ([.tasks[] | select(.status=="DONE") | .story_points] | add)
        ' > "$SPRINT_FILE.tmp" && mv "$SPRINT_FILE.tmp" "$SPRINT_FILE"
        
        echo -e "${GREEN}✅ Métricas corrigidas${NC}"
    else
        echo -e "${GREEN}✅ Métricas consistentes${NC}"
    fi
}

# Menu de ajuda
show_help() {
    cat << EOF
${BLUE}PM Helper Scripts - Comandos Disponíveis${NC}

${YELLOW}Gerenciamento de Tasks:${NC}
  create <título> <agente> [prioridade] [pontos]
      Criar nova task
      Exemplo: create "Implementar API" "FastAPI Agent" P0 5
      
  update <task-id> <status> [notas]
      Atualizar status de task
      Status: TODO | IN_PROGRESS | DONE | BLOCKED
      Exemplo: update TASK-001 IN_PROGRESS "Iniciando desenvolvimento"
      
  details <task-id>
      Ver detalhes completos de uma task
      
${YELLOW}Consultas:${NC}
  status
      Ver status geral do sprint
      
  list [status]
      Listar tasks (all, TODO, IN_PROGRESS, DONE, BLOCKED)
      Exemplo: list IN_PROGRESS
      
  agent <nome-agente>
      Ver tasks de um agente específico
      Exemplo: agent "FastAPI Agent"

${YELLOW}Manutenção:${NC}
  validate
      Validar consistência do JSON e recalcular métricas
      
  help
      Mostrar esta ajuda

EOF
}

# Main
case "${1:-help}" in
    create)
        if [ $# -lt 3 ]; then
            echo "Uso: $0 create <título> <agente> [prioridade] [pontos]"
            exit 1
        fi
        create_task "$2" "$3" "${4:-P1}" "${5:-3}"
        ;;
    update)
        if [ $# -lt 3 ]; then
            echo "Uso: $0 update <task-id> <status> [notas]"
            exit 1
        fi
        update_status "$2" "$3" "${4:-}"
        ;;
    status)
        sprint_status
        ;;
    list)
        list_tasks "${2:-all}"
        ;;
    details)
        if [ $# -lt 2 ]; then
            echo "Uso: $0 details <task-id>"
            exit 1
        fi
        task_details "$2"
        ;;
    agent)
        if [ $# -lt 2 ]; then
            echo "Uso: $0 agent <nome-agente>"
            exit 1
        fi
        agent_tasks "$2"
        ;;
    validate)
        validate
        ;;
    help|*)
        show_help
        ;;
esac
