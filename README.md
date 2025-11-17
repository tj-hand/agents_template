# Scrum Agents System

Multi-agent development system for Claude Code Web with GitHub integration and Scrum methodology.

---

## Overview

This system implements a complete development workflow using:
- **Claude Code Web** - Development environment
- **GitHub** - Version control, issues, milestones, PRs, project boards
- **Scrum** - Via Git native features (no external tools)
- **9 Specialized Agents** + 1 Orchestrator

---

## How It Works
```
User Request
    ↓
Orchestrator (Claude.md)
    ↓
Classifies: QUERY, CHANGE, or DIRECT (override)
    ↓
Delegates to Agent(s)
    ↓
Agent executes (with issue or override)
    ↓
QA reviews (if tracked)
    ↓
Deployed
```

**Key principle:** Every change requires an issue. 
**Exception:** User can explicitly override with "skip issue", "no issue", "direct" for emergencies/experiments.

---

## Agents

**Claude.md** - Orchestrator
- Classifies all prompts (QUERY/CHANGE)
- Delegates to appropriate agents
- Coordinates multi-agent work

**PM Agent** - Planning & Strategy
- Breaks epics into granular issues
- Sprint planning
- Unknown territory decisions

**Git Agent** - GitHub Operations
- Issues, PRs, milestones, project boards
- Branch management
- Central hub for GitHub

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
- Code review (all PRs)
- Testing strategy
- Approval/rejection decisions

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
cp .agents/Claude.md .
cp -r .agents/agents .
```

### 2. Configure GitHub
```bash
# Authenticate GitHub CLI
gh auth login

# Create standard labels
gh label create "feature" --color "0E8A16"
gh label create "bug" --color "D73A4A"
gh label create "tech-debt" --color "FBCA04"
gh label create "blocked" --color "B60205"
gh label create "research-spike" --color "D876E3"

# Create project board
gh project create "Project Board" --owner @me
```

### 3. Start First Sprint
```bash
# Create sprint milestone
gh milestone create "Sprint-1" --due-date "2025-12-31"

# Create first issue
gh issue create \
  --title "Setup project structure" \
  --label "feature" \
  --milestone "Sprint-1"
```

### 4. Start Development

Open Claude Code Web and start with:
```
"Claude, I need to implement user authentication"
```

Claude.md (Orchestrator) will:
1. Classify as CHANGE
2. Delegate to PM Agent for breakdown
3. PM creates issues via Git Agent
4. Orchestrator distributes work to dev agents

---

## Project Structure
```
your-project/
├── Claude.md                # Orchestrator (root)
├── agents/                  # Agent definitions
│   ├── project-manager.md
│   ├── git-agent.md
│   ├── database-agent.md
│   ├── uxui-agent.md
│   ├── vue-agent.md
│   ├── fastapi-agent.md
│   ├── qa-agent.md
│   └── devops-agent.md
├── backend/                 # FastAPI application
├── frontend/                # Vue 3 application
├── docker-compose.yml
├── .env.example
└── README.md
```

---

## Workflow Examples

**Bug Fix:** User → PM creates issue → Dev fixes → QA reviews → Git merges  
**Feature:** User → PM breaks into issues → Devs work → QA reviews each → Git merges  
**Epic:** User → PM creates sprint with issues → Orchestrator distributes → QA validates → DevOps deploys

---

## GitHub Project Board

**Columns:**
- **Backlog** - All issues without milestone
- **Sprint Backlog (Todo)** - Current sprint issues
- **In Progress** - Active development
- **Review** - PR created, awaiting QA
- **Done** - Merged and closed

**Git Agent manages card movement automatically based on status.**

---

## Best Practices

### Issue Management
- One issue = one agent = one branch = one PR
- Target: < 1 day of work per issue
- Always reference issue in commits: `feat: add login #45`

### Branch Strategy
- `main` - production
- `feat/N-description` - feature branches
- `fix/N-description` - bug fixes
- PR required for all merges

### Sprint Cadence
- Planning: Define goal, select issues
- Daily: Check progress via GitHub board
- Review: Demo completed work
- Retro: Lessons learned

---

## Troubleshooting

**Agent not responding:** Check file path `/agents/agent-name.md` and Claude.md in root  
**Can't create issues:** Run `gh auth status` and re-login if needed  
**Unknown technology:** PM Agent creates research-spike issue or assigns to closest agent

---

## Quality Gates

**Before PR merge:**
- [ ] All tests pass
- [ ] QA Agent approved
- [ ] Issue referenced in commits
- [ ] Documentation updated
- [ ] No hardcoded secrets

**Layer 2 Protection:**
Every agent validates issue exists before ANY change.
No issue = STOP immediately.

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
A: Start with core (PM, Git, QA, DevOps) + your stack agents.

**Q: Can I add custom agents?**  
A: Absolutely. Follow the pattern in existing agents.

**Q: What if I don't use Vue/FastAPI?**  
A: Replace with your stack agents (React, Django, etc).

---

**Remember:** 
- Every change needs an issue
- QA reviews every PR
- Agents coordinate directly
- Git is the source of truth
