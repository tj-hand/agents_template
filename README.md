# Scrum Agents System

Multi-agent development system for Claude Code Web with local project-state management and Scrum methodology.

---

## Overview

This system implements a complete development workflow using:
- **Claude Code Web** - Development environment
- **Local Project-State** - Task tracking via JSON files (`project-state/`)
- **Scrum** - Sprint-based planning with roadmap and tasks
- **6 Specialized Agents** + 1 Orchestrator (with planning + project-state management)

---

## How It Works
```
User Request
    ↓
Orchestrator (Orchestrator.md)
    ↓
Classifies: QUERY or CHANGE
    ↓
Creates task in project-state/current-sprint.json
    ↓
Delegates to Agent(s) with TASK-XXX
    ↓
Agent executes and reports back
    ↓
Orchestrator updates task status
    ↓
QA reviews
    ↓
Orchestrator marks DONE
    ↓
Deployed
```

**Key principle:** Every change requires a task. No exceptions.

---

## Agents

**Orchestrator.md** - Central Coordinator
- Classifies all prompts (QUERY/CHANGE)
- Analyzes complexity (TASK/FEATURE/EPIC)
- Breaks epics into granular tasks
- Sprint planning and strategy
- Project-state management (reads/writes `project-state/` files)
- Unknown territory decisions
- Delegates to appropriate agents
- Coordinates multi-agent work
- Updates task status and logs changes

**Database Agent** - Data Layer
- PostgreSQL schema design
- Alembic migrations
- SQLAlchemy models

**UX/UI Agent** - Visual Design
- Component library in `/components/ui/`
- Design system (Golden Ratio, rem-based)
- Responsive layouts, accessibility

**Vue Agent** - Frontend Logic
- Feature components in `/components/features/`
- State management (Pinia)
- API integration, form validation

**FastAPI Agent** - Backend API
- RESTful endpoints
- Business logic (service layer)
- Pydantic schemas

**QA Agent** - Quality Assurance
- Code review (all completed tasks)
- Testing strategy
- Approval/rejection/block decisions

**DevOps Agent** - Infrastructure
- Docker & docker-compose
- Deployment (staging/production)
- Environment management

---

## Quick Start

### 1. Setup Repository
```bash
# Clone this repo to your project
git clone https://github.com/your-org/scrum-agents.git .agents

# Copy agent files to your project root
cp .agents/Orchestrator.md .
cp -r .agents/agents .
cp -r .agents/project-state .
```

### 2. Initialize Project State
The `project-state/` folder contains:
- `project.json` - Roadmap, epics, OKRs
- `current-sprint.json` - Active sprint with tasks
- `task-log.jsonl` - Audit log
- `dashboard.html` - Visual project board
- `README.md` - Complete documentation

### 3. Start Development

Open Claude Code Web and start with:
```
"Claude, I need to implement user authentication"
```

Orchestrator will:
1. Classify as CHANGE
2. Analyze complexity (TASK/FEATURE/EPIC)
3. Create tasks in `project-state/current-sprint.json`
4. Assign TASK-XXX to appropriate agents
5. Update task status as work progresses
6. Log all changes to `task-log.jsonl`

---

## Project Structure
```
your-project/
├── Orchestrator.md          # Central coordinator - planning + project-state
├── agents/                  # Agent definitions
│   ├── database-agent.md
│   ├── uxui-agent.md
│   ├── vue-agent.md
│   ├── fastapi-agent.md
│   ├── qa-agent.md
│   └── devops-agent.md
├── project-state/           # Project management (Orchestrator only)
│   ├── project.json         # Roadmap, epics, OKRs
│   ├── current-sprint.json  # Active tasks
│   ├── task-log.jsonl       # Audit log
│   ├── dashboard.html       # Visual board
│   └── README.md            # Full documentation
├── backend/                 # FastAPI application
├── frontend/                # Vue 3 application
├── docker-compose.yml
├── .env.example
└── README.md
```

---

## Workflow Examples

**Bug Fix:** User → Orchestrator creates TASK-XXX → Dev fixes → QA reviews → Orchestrator marks DONE
**Feature:** User → Orchestrator breaks into tasks → Devs work → QA reviews each → Orchestrator marks DONE
**Epic:** User → Orchestrator creates sprint with tasks → distributes work → QA validates → DevOps deploys

---

## Project-State Dashboard

**Task States:**
- **TODO** - Not started
- **IN_PROGRESS** - Active development
- **DONE** - Completed and approved
- **BLOCKED** - Waiting on dependency/external

**View dashboard:** Open `project-state/dashboard.html` in browser
**View tasks:** `cat project-state/current-sprint.json | jq '.tasks'`
**View metrics:** `cat project-state/current-sprint.json | jq '.metrics'`

**Orchestrator manages task status automatically based on agent reports.**

---

## Best Practices

### Task Management
- One task = one agent = focused change
- Target: < 1 day of work per task
- Always reference task in commits: `feat: add login TASK-045`
- Use TASK-XXX format (3-digit)

### Task Breakdown
- TASK: Single feature or fix (2-8 story points)
- FEATURE: Multiple related tasks (epic subset)
- EPIC: Large initiative spanning multiple sprints

### Sprint Cadence
- Planning: Define goal, create tasks in `project-state/`
- Daily: Check progress via `dashboard.html` or `jq` queries
- Review: Demo completed work
- Retro: Lessons learned, update task-log analysis

---

## Troubleshooting

**Agent not responding:** Check file path `/agents/agent-name.md` and Orchestrator.md in root
**Can't read project-state:** Ensure `project-state/current-sprint.json` exists and is valid JSON
**Task not found:** Verify task exists in `current-sprint.json` before agent execution
**Unknown technology:** Orchestrator creates research-spike task or assigns to closest agent

---

## Quality Gates

**Before marking task DONE:**
- [ ] All tests pass
- [ ] QA Agent approved
- [ ] Task referenced in commits (TASK-XXX)
- [ ] Documentation updated
- [ ] No hardcoded secrets

**Layer 2 Protection:**
Every agent validates TASK-XXX was assigned by Orchestrator before ANY change.
No task assignment = STOP immediately.

---

## Tech Stack

**Frontend:**
- Vue 3 (Composition API + TypeScript)
- Tailwind CSS (Golden Ratio design system)
- Pinia (state management)
- Vite

**Backend:**
- FastAPI (Python)
- SQLAlchemy + Alembic (ORM + migrations)
- PostgreSQL
- JWT authentication

**DevOps:**
- Docker & docker-compose
- GitHub Actions (optional)
- Staging + Production environments

---

## Contributing

This is a development methodology system. To improve:

1. Test changes in a pilot project
2. Document results
3. Propose agent updates with examples
4. Keep agents concise and focused

**Philosophy:** Agents should define WHAT and WHEN, not HOW (LLMs already know HOW).

---

## License

MIT License - Use freely in your projects.

---

## Support

**Common Questions:**

**Q: Can I modify agents?**  
A: Yes! Customize for your project needs.

**Q: Do I need all agents?**
A: Start with core (QA, DevOps) + your stack agents. Orchestrator handles planning and project-state management.

**Q: Can I add custom agents?**  
A: Absolutely. Follow the pattern in existing agents.

**Q: What if I don't use Vue/FastAPI?**  
A: Replace with your stack agents (React, Django, etc).

---

**Remember:**
- Every change needs a task (TASK-XXX)
- QA reviews every completed task
- Agents coordinate directly via CONSULT
- Orchestrator is the only one who touches project-state
- project-state/ is the source of truth
