# Template Setup Guide

## 🎯 Using This Repository as a Template

This repository is designed to be used as a **template** for new software projects with AI-assisted development using specialized agents.

## 🚀 Quick Start (3 Steps)

### Step 1: Clone This Template

```bash
git clone https://github.com/tj-hand/agents_template.git my-new-project
cd my-new-project
```

### Step 2: Initialize Your Project

Run the initialization script:

```bash
./template-init.sh
```

This will:
- ✅ Set up your project structure
- ✅ Create project-state files for your project
- ✅ Update the projects registry
- ✅ Generate a customized README
- ✅ Rename `Orchestrator.md` → `Claude.md` (personalize for your project)
- ✅ Clean up example data
- ✅ Initialize Git repository

> **Note:** The template uses `Orchestrator.md` as the generic coordinator. When you initialize your project, it becomes `Claude.md` - your personal AI project manager.

### Step 3: Push to Your Repository

```bash
git remote add origin https://github.com/your-username/your-project.git
git push -u origin main
```

**Done!** Your project is ready for AI-assisted development.

---

## 📁 What's Included

When you use this template, you get:

### 🤖 AI Agents System
- **Orchestrator.md** - Generic coordinator (becomes **Claude.md** when initialized)
- **6 Specialized Agents** in `/agents/` directory:
  - DevOps Agent (infrastructure, deployment)
  - FastAPI Agent (backend development)
  - Vue Agent (frontend development)
  - Database Agent (schema, migrations)
  - QA Agent (testing, code review)
  - UX/UI Agent (design, user experience)

> When you run `template-init.sh`, Orchestrator.md is renamed to Claude.md for your project.

### 📊 Project State Management
- **dashboard.html** - Real-time project dashboard
- **projects/** - Multi-project tracking system
- **projects.json** - Project registry
- JSON-based task and sprint tracking

### 🚀 Deployment System
- **project-manager.sh** - Multi-project deployment script
- **Auto-pull timers** - Sync from Git every 5 minutes
- **Webhook support** - Instant deployments
- **SSL/HTTPS** - Let's Encrypt integration
- **Nginx configs** - Production-ready web server

---

## 🎨 Customization Options

### Option 1: Use As-Is (Vue + FastAPI)

The template comes pre-configured for:
- **Frontend:** Vue 3 + TypeScript + Tailwind CSS
- **Backend:** FastAPI + Python
- **Database:** PostgreSQL
- **Infrastructure:** Docker + Nginx

Just run `./template-init.sh` and start coding!

### Option 2: Customize Tech Stack

Modify the agents for your stack:

#### Example: React Instead of Vue

1. Rename `agents/vue-agent.md` → `agents/react-agent.md`
2. Update agent content for React patterns
3. Update `project.json` tech_stack

#### Example: Django Instead of FastAPI

1. Rename `agents/fastapi-agent.md` → `agents/django-agent.md`
2. Update agent content for Django patterns
3. Update `project.json` tech_stack

#### Example: Add Mobile App Agent

1. Create `agents/react-native-agent.md`
2. Define mobile-specific responsibilities
3. Add to team in `project.json`

See [AGENTS-IMPLEMENTATION-GUIDE.md](deployment/AGENTS-IMPLEMENTATION-GUIDE.md) for detailed examples.

---

## 📚 Understanding the Agent System

> **Note:** In your initialized project, the Orchestrator becomes **Claude** - your personal AI project manager.

### How Agents Work

**Claude** (your AI project manager) is the main coordinator who:
- Receives your requests
- Analyzes requirements
- Creates tasks in project-state
- Delegates to specialized agents
- Tracks progress

**Specialized Agents** are domain experts who:
- Execute specific tasks
- Follow best practices for their domain
- Coordinate with other agents
- Report completion to Claude

### Example Workflow

```
You: "Add user authentication to my app"
     ↓
Claude: Analyzes request, creates tasks
     ↓
Delegates to agents:
├─ Database Agent → Creates users table
├─ FastAPI Agent → Implements auth endpoints
├─ Vue Agent → Creates login UI
└─ QA Agent → Tests everything
     ↓
Updates project-state → Dashboard shows progress
     ↓
You see real-time status on dashboard
```

---

## 🌐 Deployment Architectures

### Architecture A: Single Repo, Multi-Project Dashboard

One repository tracks multiple projects:

```
one-repo/
├── project-state/
│   ├── dashboard.html
│   ├── projects.json
│   └── projects/
│       ├── project-a/
│       ├── project-b/
│       └── project-c/
```

**Dashboard shows dropdown to switch between projects**

Use when:
- Related projects
- Same team
- Centralized tracking

### Architecture B: Multiple Repos, Individual Dashboards

Each project = separate repo with own dashboard:

```
Server:
├── /var/www/project-alpha/  → alpha.yourdomain.com
├── /var/www/project-beta/   → beta.yourdomain.com
└── /var/www/project-gamma/  → gamma.yourdomain.com
```

Use when:
- Unrelated projects
- Different teams
- Independent deployments

Both architectures are fully supported!

---

## 🔧 Configuration Files

### project-state/projects.json

Registry of all projects in the dashboard:

```json
{
  "projects": [
    {
      "id": "my-project",
      "name": "My Project",
      "description": "Project description",
      "color": "#3b82f6"
    }
  ],
  "default": "my-project"
}
```

### project-state/projects/my-project/project.json

Project-specific configuration:

```json
{
  "project_name": "My Project",
  "description": "...",
  "tech_stack": { ... },
  "team": [ ... ],
  "roadmap": [ ... ],
  "okrs": { ... }
}
```

### project-state/projects/my-project/current-sprint.json

Active sprint with tasks:

```json
{
  "sprint": 1,
  "start_date": "2025-11-20",
  "end_date": "2025-12-04",
  "goal": "Sprint objective",
  "tasks": [ ... ]
}
```

---

## 🚀 Deployment Guide

### Local Development

1. Initialize template: `./template-init.sh`
2. Start coding with agents
3. Track progress on dashboard (open `project-state/dashboard.html`)

### Remote Server Deployment

1. **Prepare your Ubuntu server** (20.04+)

2. **Run the deployment script:**
   ```bash
   curl -O https://raw.githubusercontent.com/tj-hand/agents_template/main/deployment/project-manager.sh
   chmod +x project-manager.sh
   sudo bash project-manager.sh
   ```

3. **Configure project:**
   - Project name: `my-project`
   - Subdomain: `scrum.yourdomain.com`
   - Git URL: `https://github.com/you/my-project.git`
   - Branch: `main`
   - Auto-pull: `5` minutes
   - SSL: `y`

4. **Access dashboard:**
   - Visit: `https://scrum.yourdomain.com`
   - Dashboard auto-syncs from git

See [QUICKSTART.md](deployment/QUICKSTART.md) for detailed deployment instructions.

---

## 🎓 Learning Path

### For Beginners

1. ✅ Clone template: `git clone ...`
2. ✅ Run init script: `./template-init.sh`
3. ✅ Explore agents: Read `agents/*.md`
4. ✅ Check dashboard: Open `project-state/dashboard.html`
5. ✅ Deploy locally first

### For Advanced Users

1. ✅ Customize agents for your stack
2. ✅ Set up multi-project dashboard
3. ✅ Deploy to remote server
4. ✅ Configure webhooks for instant deploys
5. ✅ Create custom deployment workflows

---

## 🛠️ Troubleshooting

### Q: template-init.sh doesn't run

Make sure it's executable:
```bash
chmod +x template-init.sh
./template-init.sh
```

### Q: Dashboard doesn't show my project

Check `project-state/projects.json`:
- Project ID matches folder name
- JSON is valid (use `jq` to validate)

### Q: Agents don't know about my tech stack

Update agent files in `agents/` directory:
- Customize for your stack (React, Django, etc.)
- Update responsibilities and patterns

### Q: Can I use this for non-web projects?

Yes! Customize agents for any software project:
- Mobile apps (React Native, Flutter)
- APIs/Microservices
- CLI tools
- Desktop apps
- Any software development

---

## 📖 Additional Resources

- [Main README](README.md) - Overview and features
- [Quick Start Guide](deployment/QUICKSTART.md) - Deploy in 3 steps
- [Multi-Project Setup](deployment/MULTI-PROJECT-GUIDE.md) - Managing multiple projects
- [Agents Implementation](deployment/AGENTS-IMPLEMENTATION-GUIDE.md) - Customizing agents
- [Project State README](project-state/README.md) - Understanding project tracking

---

## 🤝 Contributing

Have improvements for the template?

1. Fork this repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

We welcome:
- New agent templates
- Deployment improvements
- Documentation enhancements
- Bug fixes

---

## 📝 License

MIT License - Use freely in your projects, commercial or personal.

---

## 🙏 Credits

Built with:
- Claude AI (Anthropic)
- Open source communities
- Contributors like you!

---

**Ready to start?**

```bash
git clone https://github.com/tj-hand/agents_template.git my-project
cd my-project
./template-init.sh
```

**Questions?** Open an issue on GitHub!
