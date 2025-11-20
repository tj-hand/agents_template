# AI-Powered Multi-Project Development Platform

**A complete development platform combining AI agents, automated deployment, and real-time project tracking for managing unlimited projects from a single dashboard.**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

---

## 🎯 What Is This?

A production-ready template that provides:
- **🤖 6 Specialized AI Agents** - Coordinate development tasks automatically
- **📊 Multi-Project Dashboard** - Manage unlimited projects from one interface
- **🚀 Auto-Deployment** - Git push → Server updates in 1 minute
- **📈 Sprint Tracking** - Real-time task and progress visualization
- **🔄 Remote Deployment** - Deploy to Ubuntu servers with one command

Perfect for:
- Solo developers managing multiple projects
- Small teams coordinating development
- Agencies managing client projects
- Learning AI-assisted development workflows

---

## ✨ Key Features

### 🤖 AI Agents System
- **DevOps Agent** - Infrastructure, deployment, Docker
- **FastAPI Agent** - Backend API development
- **Vue Agent** - Frontend development
- **Database Agent** - Schema design, migrations
- **QA Agent** - Testing and code review
- **UX/UI Agent** - Design and user experience
- **Claude** - Main project manager coordinating all agents

### 📊 Multi-Project Dashboard
- **Project Selector** - Switch between projects instantly
- **Real-Time Updates** - Auto-refresh from git
- **Sprint Tracking** - Tasks, metrics, velocity
- **Activity Log** - Complete audit trail
- **Single Subdomain** - All projects at one URL

### 🚀 Automated Deployment
- **Git-Based** - Push changes, server auto-pulls (5 min)
- **Instant Updates** - Webhook for immediate deployment
- **SSL/HTTPS** - Auto-configured Let's Encrypt
- **Nginx** - Production-ready web server
- **Multi-Server** - Deploy to unlimited servers
- **Zero Downtime** - Seamless updates

---

---

## 🎯 USE THIS AS A TEMPLATE

### One-Command Setup

```bash
git clone https://github.com/tj-hand/agents_template.git my-project
cd my-project
./template-init.sh
```

The init script will:
- ✅ Set up project structure for your project
- ✅ Create customized project-state files
- ✅ Generate README with your project name
- ✅ Clean up example data
- ✅ Initialize Git repository

**See [TEMPLATE-SETUP.md](TEMPLATE-SETUP.md) for detailed template usage guide.**

---

## 🚀 Quick Start (3 Steps)

### 1. Clone This Template

```bash
git clone https://github.com/tj-hand/agents_template.git my-project
cd my-project
```

### 2. Initialize Your Project

```bash
./template-init.sh
```

Follow the prompts to set up your project name and details.

### 3. Deploy to Server

```bash
# On your Ubuntu server (one-time setup)
curl -O https://raw.githubusercontent.com/tj-hand/agents_template/main/deployment/project-manager.sh
chmod +x project-manager.sh
sudo bash project-manager.sh

# Follow prompts:
#   - Project name
#   - Subdomain
#   - Git URL
#   - SSL setup
```

**Done!** Your dashboard is live with auto-deployment. 🎉

---

## 📁 Project Structure

```
agents_template/
├── agents/                      # AI Agent Definitions
│   ├── devops-agent.md
│   ├── fastapi-agent.md
│   ├── vue-agent.md
│   ├── database-agent.md
│   ├── qa-agent.md
│   └── uxui-agent.md
│
├── deployment/                  # Deployment System
│   ├── setup.sh                 # Single-project setup
│   ├── project-manager.sh       # Multi-project manager
│   ├── QUICKSTART.md
│   ├── README.md
│   ├── ARCHITECTURE.md
│   ├── MULTI-PROJECT-GUIDE.md
│   ├── SERVER-SETUP-GUIDE.md
│   ├── AGENTS-IMPLEMENTATION-GUIDE.md
│   └── PROJECT-DEPLOYMENT-GUIDE.md
│
├── project-state/               # Project Tracking
│   ├── dashboard.html           # Multi-project dashboard
│   ├── projects.json            # Project registry
│   ├── projects/                # Project data folders
│   │   └── agents-template/
│   │       ├── current-sprint.json
│   │       ├── project.json
│   │       └── task-log.jsonl
│   ├── templates/
│   ├── scripts/
│   └── README.md
│
├── Claude.md                    # Main AI Project Manager
├── template-init.sh             # Template initialization script
├── TEMPLATE-SETUP.md            # Template usage guide
├── .gitignore                   # Security (keys protected)
└── README.md                    # This file
```

---

## 🎨 How It Works

### Development Workflow

```
You: "Add user authentication to my project"
         ↓
Claude analyzes request
         ↓
Creates tasks in project-state
         ↓
Delegates to agents:
├── DevOps Agent (environment setup)
├── Database Agent (users table)
├── FastAPI Agent (auth endpoints)
├── Vue Agent (login UI)
└── QA Agent (tests)
         ↓
Agents coordinate and execute
         ↓
Commit changes with TASK-XXX
         ↓
Push to git
         ↓
Server auto-pulls (5 minutes or instant via webhook)
         ↓
Dashboard updates automatically
```

### Multi-Project Management

```
scrum.yourdomain.com
         ↓
Dashboard loads
         ↓
Dropdown shows all projects:
├── Project Alpha
├── Project Beta
└── Project Gamma
         ↓
Select project → Load data
         ↓
View/track tasks and sprints
         ↓
Switch projects instantly
```

---

## 📚 Documentation

### Getting Started
- **[Template Setup Guide](TEMPLATE-SETUP.md)** - Complete guide to using this template
- **[Quick Start](deployment/QUICKSTART.md)** - Deploy in 3 steps
- **[Architecture](deployment/ARCHITECTURE.md)** - System design and data flow

### Deployment Guides
- **[Server Setup](deployment/SERVER-SETUP-GUIDE.md)** - Configure Ubuntu servers
- **[Multi-Project Setup](deployment/MULTI-PROJECT-GUIDE.md)** - Host multiple projects
- **[Project Deployment](deployment/PROJECT-DEPLOYMENT-GUIDE.md)** - Add new projects

### Agent System
- **[Agents Implementation](deployment/AGENTS-IMPLEMENTATION-GUIDE.md)** - Use agents in your projects
- **[Claude - Main Manager](Claude.md)** - Main AI project manager and coordination rules
- **[Individual Agents](agents/)** - Detailed agent specs

### Project Tracking
- **[Project State README](project-state/README.md)** - Task management system
- **[Dashboard Guide](project-state/DASHBOARD-GUIDE.md)** - Dashboard usage
- **[Projects Folder](project-state/projects/README.md)** - Adding projects

---

## 🎯 Use Cases

### Solo Developer
```
One server, multiple personal projects
├── Portfolio website
├── SaaS side project
├── Client work
└── Experiments
```

### Small Team
```
Shared dashboard for coordination
├── Main product (production)
├── Main product (staging)
├── Internal tools
└── Documentation site
```

### Agency
```
Client project management
├── Client A - Website
├── Client B - E-commerce
├── Client C - Mobile app
└── Internal - Admin panel
```

### Microservices
```
Service-based architecture
├── User service
├── Payment service
├── Inventory service
└── Notification service
```

---

## 🛠️ Tech Stack

### Frontend
- Vue 3 (or customize to React/Angular)
- Dashboard: Vanilla JS (no dependencies)
- Responsive, mobile-friendly

### Backend
- FastAPI (or customize to Django/Node)
- RESTful API design
- JWT authentication

### Infrastructure
- Ubuntu 20.04+ servers
- Nginx (reverse proxy, SSL)
- Docker (containerization)
- Let's Encrypt (SSL certificates)
- Git (version control + deployment)
- Systemd (auto-pull timers)

### Database
- PostgreSQL (or customize to MySQL/MongoDB)
- SQLAlchemy ORM
- Alembic migrations

---

## 🚀 Deployment Options

### Option 1: Single Project, Single Server
```
scrum.yourdomain.com → One project dashboard
```
**Use:** Personal projects, small teams

### Option 2: Multi-Project, Single Server
```
scrum.yourdomain.com → Multiple projects in dropdown
```
**Use:** Managing related projects, agencies

### Option 3: Multiple Subdomains, Single Server
```
projecta.yourdomain.com → Project A
projectb.yourdomain.com → Project B
```
**Use:** Separate client access, independent projects

### Option 4: Multiple Servers
```
Server 1: Production projects
Server 2: Staging/development
Server 3: Client-specific
```
**Use:** Large scale, high traffic, isolation needs

---

## 💡 Key Concepts

### AI Agents
Specialized assistants that handle specific aspects of development. Each agent knows its domain deeply and coordinates with others through Claude (the main project manager).

### Project State
JSON-based task tracking system that serves as the single source of truth for project status, sprint progress, and task history.

### Auto-Deployment
Git-based continuous deployment: changes pushed to repository are automatically pulled by server within 1 minute and reflected on the dashboard.

### Multi-Project Dashboard
Single interface to manage unlimited projects. Switch between projects via dropdown, each with its own sprints and tasks.

---

## 🔐 Security

### Built-In Protections
- ✅ `.gitignore` prevents credential commits
- ✅ SSH keys never in repository
- ✅ SSL/HTTPS enforced
- ✅ Security headers configured
- ✅ No code execution on server (static files only)

### Best Practices
- Use deploy keys for private repositories
- Enable UFW firewall on servers
- Regular system updates
- Monitor access logs
- Use strong passwords for basic auth (if needed)

---

## 🎓 Learning Resources

### For Beginners
1. Start with [QUICKSTART.md](deployment/QUICKSTART.md)
2. Deploy one project
3. Add a task, watch it update
4. Read [AGENTS-IMPLEMENTATION-GUIDE.md](deployment/AGENTS-IMPLEMENTATION-GUIDE.md)

### For Advanced Users
1. Review [ARCHITECTURE.md](deployment/ARCHITECTURE.md)
2. Set up multi-project dashboard
3. Deploy to multiple servers
4. Customize agents for your stack
5. Create custom deployment workflows

---

## 🤝 Contributing

Contributions welcome! This is an open-source template.

### Ways to Contribute
- Report bugs and issues
- Suggest new features
- Improve documentation
- Share your use cases
- Create custom agents
- Add integrations

### Guidelines
1. Test changes in a real project first
2. Document thoroughly
3. Keep agents focused and concise
4. Follow existing patterns

---

## 📊 Roadmap

- [x] Multi-agent system
- [x] Project-state tracking
- [x] Automated deployment
- [x] Multi-project dashboard
- [x] SSL/HTTPS support
- [x] Comprehensive documentation
- [ ] Master dashboard (aggregated view)
- [ ] Webhook-based instant updates
- [ ] Mobile-responsive improvements
- [ ] Integration with GitHub Issues
- [ ] Slack/Discord notifications
- [ ] Custom agent templates
- [ ] Docker Compose for complex stacks
- [ ] Kubernetes deployment option

---

## ❓ FAQ

**Q: Do I need to know the tech stack (Vue/FastAPI)?**
A: No! The agents handle the implementation. You can also customize agents for your preferred stack (React, Django, etc.).

**Q: Can I use this for non-web projects?**
A: Yes! The project tracking works for any software project. Just customize the agents for your domain.

**Q: How many projects can I manage?**
A: Unlimited! The multi-project dashboard scales infinitely.

**Q: What if my server goes down?**
A: Your data is safe in git. Redeploy to a new server in 5 minutes using the setup scripts.

**Q: Can I self-host everything?**
A: Yes! The entire system runs on your infrastructure. No external dependencies except git hosting.

**Q: Is this production-ready?**
A: Yes! Includes SSL, security headers, proper nginx configuration, and auto-updates.

---

## 📝 License

MIT License - Use freely in your projects, commercial or personal.

---

## 🙏 Acknowledgments

Built with:
- Claude AI (Anthropic)
- Vue.js community
- FastAPI community
- Open source tools and libraries

---

## 📞 Support

- **Documentation:** See `/deployment/` folder
- **Issues:** Open a GitHub issue
- **Discussions:** GitHub Discussions
- **Examples:** See `/project-state/projects/` for samples

---

## 🚀 Get Started Now

```bash
# Clone template
git clone https://github.com/tj-hand/agents_template.git my-project

# Customize
cd my-project
# Edit project-state files

# Deploy
# Follow deployment/QUICKSTART.md
```

**Build faster with AI agents. Track better with automated dashboards. Deploy easier with git-based automation.** 🎉

---

**⭐ Star this repo if you find it useful!**
