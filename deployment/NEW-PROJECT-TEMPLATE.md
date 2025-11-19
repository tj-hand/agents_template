# Creating a New Project from This Template

## 🎯 Quick Start

This template provides a complete development platform with:
- **AI Agents System** - DevOps, FastAPI, Vue, Database, QA, UX/UI agents
- **Project State Management** - Dashboard with sprints, tasks, OKRs
- **Auto-Deployment** - Git-based automated deployments
- **Ready for Production** - Nginx, SSL, monitoring included

## 📋 Steps to Create a New Project

### 1. Clone This Template

```bash
# Clone the template
git clone https://github.com/tj-hand/agents_template.git my-new-project
cd my-new-project

# Remove template git history
rm -rf .git

# Start fresh
git init
```

### 2. Customize Project Files

#### A. Update `project-state/project.json`

```json
{
  "project_name": "My New Project",
  "description": "Description of your project",
  "tech_stack": {
    "frontend": "Vue.js 3",
    "backend": "FastAPI",
    "database": "PostgreSQL",
    "infrastructure": "Docker, Nginx"
  },
  "team": [
    {"name": "You", "role": "Full Stack Developer"}
  ],
  "roadmap": [],
  "okrs": {},
  "metadata": {
    "current_sprint": 1,
    "total_sprints_completed": 0
  }
}
```

#### B. Update `project-state/current-sprint.json`

```json
{
  "sprint": 1,
  "start_date": "2025-11-19",
  "end_date": "2025-12-02",
  "goal": "Initial setup and foundation",
  "epic": "EPIC-001",
  "metrics": {
    "total_points": 0,
    "completed_points": 0,
    "tasks": {
      "total": 0,
      "todo": 0,
      "in_progress": 0,
      "done": 0,
      "blocked": 0
    }
  },
  "tasks": []
}
```

#### C. Clear Task Log

```bash
# Start with empty task log
> project-state/task-log.jsonl
```

#### D. Update Main README

Create your own `README.md`:

```markdown
# My New Project

## Description

[Your project description here]

## Tech Stack

- Frontend: Vue.js 3
- Backend: FastAPI
- Database: PostgreSQL
- Deployment: Docker, Nginx

## Getting Started

[Your setup instructions]

## Project Management

This project uses an AI-driven project management system. View the dashboard at:
- Production: https://myproject.yourdomain.com
- Staging: https://staging.myproject.yourdomain.com

## Deployment

Auto-deploys from git on every push. See `deployment/` folder for details.
```

### 3. Customize Agents (Optional)

The `agents/` folder contains:
- `devops-agent.md` - Infrastructure and deployment
- `fastapi-agent.md` - Backend API development
- `vue-agent.md` - Frontend development
- `database-agent.md` - Database management
- `qa-agent.md` - Testing and quality assurance
- `uxui-agent.md` - Design and user experience

**Keep the agents you need**, remove or modify others.

For example, if you're building a Python CLI tool (no frontend):
- Keep: `devops-agent.md`, `fastapi-agent.md`, `qa-agent.md`
- Remove: `vue-agent.md`, `uxui-agent.md`
- Modify: Update tech stack in remaining agents

### 4. Commit and Push

```bash
git add .
git commit -m "Initial commit from agents_template"

# Create repo on GitHub, then:
git remote add origin https://github.com/yourname/my-new-project.git
git branch -M main
git push -u origin main
```

### 5. Deploy to Your Server

```bash
# SSH to your Ubuntu server (via PuTTY)
sudo bash project-manager.sh

# Choose option 1: Add a new project
# Enter:
#   Project name: myproject
#   Subdomain: myproject.yourdomain.com
#   Git URL: https://github.com/yourname/my-new-project.git
#   Branch: main
#   Auto-pull: 1 (minute)
#   SSL: y
```

### 6. Configure DNS

Add DNS A record:
```
Type: A
Host: myproject
Value: 216.238.99.183 (your server IP)
TTL: 300
```

### 7. Done! 🎉

Your project is now:
- ✅ Live at `https://myproject.yourdomain.com`
- ✅ Auto-deploying from git every minute
- ✅ Running with AI agents
- ✅ Tracked with project-state dashboard

## 🔄 Development Workflow

### 1. Work with Claude

```
You: "I'm working on myproject. Add user authentication."

Claude: [Makes changes to your repo]
        [Commits and pushes]

Server: [Auto-pulls within 1 minute]
        [Dashboard updates automatically]
```

### 2. View Progress

Visit `https://myproject.yourdomain.com` to see:
- Current sprint status
- All tasks and their status
- Project velocity
- Timeline

### 3. Iterate

Claude can:
- Add features
- Fix bugs
- Run tests
- Update documentation
- All automatically deployed!

## 📊 Project Structure

```
my-new-project/
├── project-state/          ← Project dashboard
│   ├── dashboard.html      ← View at your subdomain
│   ├── current-sprint.json
│   ├── project.json
│   └── task-log.jsonl
│
├── agents/                 ← AI agent definitions
│   ├── devops-agent.md
│   ├── fastapi-agent.md
│   └── ...
│
├── deployment/             ← Deployment scripts
│   ├── setup.sh
│   ├── project-manager.sh
│   └── docs
│
├── src/                    ← Your actual code (create this)
│   ├── backend/
│   ├── frontend/
│   └── ...
│
├── Orchestrator.md         ← Agent orchestration rules
├── .gitignore
└── README.md               ← Your custom README
```

## 🎨 Customization Ideas

### Frontend-Only Project

Remove backend-related agents:
```bash
rm agents/fastapi-agent.md
rm agents/database-agent.md
```

Update `Orchestrator.md` to remove references to these agents.

### API-Only Project

Remove frontend agents:
```bash
rm agents/vue-agent.md
rm agents/uxui-agent.md
```

### Monorepo

Keep all agents, organize your code:
```
src/
├── packages/
│   ├── web/          ← Vue.js app
│   ├── api/          ← FastAPI
│   ├── mobile/       ← Mobile app
│   └── shared/       ← Shared code
```

### Microservices

Create separate projects for each service:
```bash
# Service 1: User Service
git clone agents_template user-service
cd user-service
# Customize and deploy as "users.yourdomain.com"

# Service 2: Payment Service
git clone agents_template payment-service
cd payment-service
# Customize and deploy as "payments.yourdomain.com"
```

## 🛠️ Advanced Configuration

### Multiple Environments

Deploy the same repo on different branches:

```bash
# Production
Project: myproject
Subdomain: myproject.yourdomain.com
Branch: main

# Staging
Project: myproject-staging
Subdomain: staging.myproject.yourdomain.com
Branch: develop
```

### Custom Agent

Create a new agent for your specific needs:

```markdown
# agents/mobile-agent.md

# Mobile Agent - React Native Specialist

## Identity
You are the Mobile Agent specializing in React Native...

## Responsibilities
- Mobile app development
- iOS and Android builds
- App store deployments
- Push notifications
...
```

Update `Orchestrator.md` to include the new agent.

### Dashboard Customization

The dashboard is a single HTML file with embedded JavaScript. You can:
- Change colors/theme
- Add custom charts
- Modify metrics
- Add project-specific views

Edit `project-state/dashboard.html` directly.

## 📚 Resources

- **Multi-Project Guide**: `deployment/MULTI-PROJECT-GUIDE.md`
- **Deployment README**: `deployment/README.md`
- **Quick Start**: `deployment/QUICKSTART.md`
- **Project State Docs**: `project-state/README.md`

## 🤝 Contributing Back to Template

If you make improvements to:
- Agent definitions
- Deployment scripts
- Dashboard features
- Documentation

Consider contributing back to the template repo!

## 🎯 Next Steps

1. **Customize** your project files
2. **Push** to GitHub
3. **Deploy** to your server
4. **Start coding** with Claude!

The agents and deployment system handle the rest automatically.

---

**Happy coding!** 🚀
