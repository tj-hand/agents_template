# AI-Powered Multi-Project Development Platform

A production-ready template combining AI agents, automated deployment, and real-time project tracking for managing unlimited projects from a single dashboard.

## 🚀 Quick Start

```bash
git clone https://github.com/tj-hand/agents_template.git my-project
cd my-project
./template-init.sh
```

The init script automatically:
- ✅ Sets up project structure
- ✅ Creates project-state tracking
- ✅ Renames Orchestrator → Claude (your AI manager)
- ✅ Generates customized README
- ✅ Initializes Git repository

## ✨ What You Get

### 🤖 6 Specialized AI Agents
- **DevOps Agent** - Infrastructure, deployment, Docker
- **FastAPI Agent** - Backend API development
- **Vue Agent** - Frontend development
- **Database Agent** - Schema design, migrations
- **QA Agent** - Testing and code review
- **UX/UI Agent** - Design and user experience
- **Orchestrator/Claude** - Main coordinator

### 📊 Multi-Project Dashboard
- Project selector with unlimited projects
- Real-time sprint tracking
- Task management with metrics
- Activity logging and history
- Auto-refresh from Git

### 🚀 Automated Deployment
- Git-based continuous deployment
- Auto-pull every 5 minutes
- Webhook support for instant updates
- SSL/HTTPS with Let's Encrypt
- Production-ready Nginx config
- Deploy to unlimited Ubuntu servers

## 🎯 Perfect For

- Solo developers managing multiple projects
- Small teams coordinating development
- Agencies managing client projects
- Learning AI-assisted development workflows

## 📚 Tech Stack

**Pre-configured for:**
- Frontend: Vue 3 + TypeScript + Tailwind CSS
- Backend: FastAPI + Python
- Database: PostgreSQL
- Infrastructure: Docker + Nginx

**Fully customizable** - Use with React, Django, Node.js, or any stack

## 🌐 Deployment Options

**Single Project, Single Server** - One dashboard per project
**Multi-Project, Single Server** - Dropdown selector for multiple projects
**Multiple Subdomains** - Separate domains per project
**Multiple Servers** - Distributed deployments

## 📖 Documentation

- [Template Setup Guide](TEMPLATE-SETUP.md) - Complete usage guide
- [Quick Start](deployment/QUICKSTART.md) - Deploy in 3 steps
- [Multi-Project Setup](deployment/MULTI-PROJECT-GUIDE.md) - Multiple projects
- [Agents Implementation](deployment/AGENTS-IMPLEMENTATION-GUIDE.md) - Customize agents
- [Architecture](deployment/ARCHITECTURE.md) - System design

## 🔑 Key Features

✅ JSON-based project tracking
✅ Real-time dashboard updates
✅ Git-based deployment automation
✅ Multi-project management
✅ Specialized AI agents
✅ Production-ready infrastructure
✅ SSL/HTTPS auto-configuration
✅ Webhook support
✅ Comprehensive documentation
✅ MIT License

## 🎓 How It Works

```
You: "Add user authentication"
         ↓
Claude/Orchestrator analyzes request
         ↓
Creates tasks in project-state
         ↓
Delegates to specialized agents:
├── DevOps Agent (environment)
├── Database Agent (users table)
├── FastAPI Agent (auth endpoints)
├── Vue Agent (login UI)
└── QA Agent (tests)
         ↓
Push to Git → Server auto-deploys → Dashboard updates
```

## 📝 License

MIT License - Use freely in commercial or personal projects

---

**Built with Claude AI • Ready for production • Fully customizable**

[View Documentation](https://github.com/tj-hand/agents_template) | [Report Issues](https://github.com/tj-hand/agents_template/issues)
