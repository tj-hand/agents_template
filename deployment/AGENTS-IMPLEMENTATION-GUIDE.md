# Implementing Agents in New Projects

## 📋 Overview

This guide shows you how to use the AI agents system in your new projects, whether you're building a web app, API, mobile app, or any software project.

## 🎯 What Are the Agents?

The agents system provides specialized AI assistants that work together on your project:

- **DevOps Agent** - Infrastructure, deployment, CI/CD
- **FastAPI Agent** - Backend API development
- **Vue Agent** - Frontend development (Vue.js)
- **Database Agent** - Database design and queries
- **QA Agent** - Testing and quality assurance
- **UX/UI Agent** - Design and user experience

## 🚀 Quick Start: Add Agents to Your Project

### Method 1: Clone This Template (Recommended)

```bash
# Clone this repository as your new project
git clone https://github.com/tj-hand/agents_template.git my-new-project
cd my-new-project

# Remove git history
rm -rf .git

# Initialize fresh repository
git init
git add .
git commit -m "Initial commit from agents_template"

# Add your remote
git remote add origin https://github.com/yourname/my-new-project.git
git push -u origin main
```

**You now have:**
- ✅ All agents configured
- ✅ Project-state dashboard
- ✅ Deployment system
- ✅ Orchestrator rules

**Customize:**
1. Edit `project-state/project.json` - Your project details
2. Edit `project-state/projects/your-project/` - Your sprint data
3. Modify agents if needed (see below)

---

### Method 2: Copy Agents to Existing Project

If you already have a project:

```bash
# In your existing project directory
mkdir -p agents

# Copy agent files
curl -o agents/devops-agent.md https://raw.githubusercontent.com/tj-hand/agents_template/main/agents/devops-agent.md
curl -o agents/fastapi-agent.md https://raw.githubusercontent.com/tj-hand/agents_template/main/agents/fastapi-agent.md
curl -o agents/vue-agent.md https://raw.githubusercontent.com/tj-hand/agents_template/main/agents/vue-agent.md
curl -o agents/database-agent.md https://raw.githubusercontent.com/tj-hand/agents_template/main/agents/database-agent.md
curl -o agents/qa-agent.md https://raw.githubusercontent.com/tj-hand/agents_template/main/agents/qa-agent.md
curl -o agents/uxui-agent.md https://raw.githubusercontent.com/tj-hand/agents_template/main/agents/uxui-agent.md

# Copy Orchestrator
curl -o Orchestrator.md https://raw.githubusercontent.com/tj-hand/agents_template/main/Orchestrator.md
```

---

## 🎨 Customizing Agents for Your Project

### Example 1: React Instead of Vue

Edit `agents/vue-agent.md` → `agents/react-agent.md`:

```markdown
# React Agent - Frontend Specialist

## Identity
You are the React Agent, specializing in React 18+ development...

## Tech Stack
- React 18+ with TypeScript
- React Router for navigation
- TanStack Query for data fetching
- Tailwind CSS for styling
- Vite as build tool

## Responsibilities
- Component development with functional components and hooks
- State management (Context API, Zustand, or Redux)
- Performance optimization (React.memo, useMemo, useCallback)
...
```

Update `Orchestrator.md`:
```markdown
- **React Agent**: Frontend development (React 18+, hooks, components)
```

### Example 2: Django Instead of FastAPI

Edit `agents/fastapi-agent.md` → `agents/django-agent.md`:

```markdown
# Django Agent - Backend Specialist

## Identity
You are the Django Agent, specializing in Django 4+ development...

## Tech Stack
- Django 4+
- Django REST Framework
- PostgreSQL
- Celery for async tasks
- Django ORM

## Responsibilities
- Models, views, serializers
- URL routing and middleware
- Authentication and permissions
...
```

### Example 3: Mobile App (React Native)

Create `agents/mobile-agent.md`:

```markdown
# Mobile Agent - React Native Specialist

## Identity
You are the Mobile Agent, specializing in cross-platform mobile development...

## Tech Stack
- React Native
- Expo
- TypeScript
- React Navigation
- AsyncStorage

## Responsibilities
- Mobile UI components
- Platform-specific code (iOS/Android)
- App store deployments
- Push notifications
...
```

Add to `Orchestrator.md`:
```markdown
- **Mobile Agent**: Mobile app development (React Native, iOS, Android)
```

### Example 4: Microservices Architecture

Keep multiple backend agents for different services:

```
agents/
├── user-service-agent.md      (User authentication service)
├── payment-service-agent.md   (Payment processing service)
├── inventory-service-agent.md (Inventory management service)
├── devops-agent.md            (Kubernetes, Docker, deployment)
└── qa-agent.md                (Testing all services)
```

---

## 🔄 How to Work with Agents

### Working with Orchestrator

When you work with Orchestrator on your project:

```
You: "I need to add user authentication to my app"

Orchestrator (Project Manager):
- Analyzes the request
- Delegates to appropriate agents
- Coordinates the work

DevOps Agent:
- Sets up environment variables
- Configures security

FastAPI Agent:
- Creates auth endpoints
- Implements JWT tokens

Database Agent:
- Creates users table
- Sets up auth schema

Vue Agent:
- Creates login UI
- Implements auth flow

QA Agent:
- Tests auth flow
- Security testing
```

### Agent Coordination

The **Orchestrator** ensures agents work together:

1. **No Overlap** - Each agent has clear boundaries
2. **Dependencies** - Agents wait for prerequisites
3. **Communication** - Agents share context
4. **Task Tracking** - All work logged in project-state

---

## 📊 Project-State Integration

Agents automatically update the project-state dashboard:

```javascript
// Agent creates task
{
  "id": "TASK-001",
  "title": "Implement user authentication",
  "agent": "FastAPI Agent",
  "status": "IN_PROGRESS",
  "story_points": 5,
  ...
}

// Progress tracked automatically
// Visible on dashboard.html
```

---

## 🎯 Agent Selection Guide

Choose agents based on your project type:

### Full-Stack Web App
```
✅ DevOps Agent
✅ FastAPI Agent (or Django Agent)
✅ Vue Agent (or React Agent)
✅ Database Agent
✅ QA Agent
✅ UX/UI Agent
```

### API-Only Project
```
✅ DevOps Agent
✅ FastAPI Agent
✅ Database Agent
✅ QA Agent
❌ Vue Agent
❌ UX/UI Agent
```

### Frontend-Only Project
```
✅ DevOps Agent (deployment)
✅ Vue Agent (or React Agent)
✅ QA Agent
✅ UX/UI Agent
❌ FastAPI Agent
❌ Database Agent
```

### Mobile App
```
✅ DevOps Agent (app stores, CI/CD)
✅ Mobile Agent (React Native)
✅ FastAPI Agent (if has backend)
✅ QA Agent
✅ UX/UI Agent
```

### CLI Tool / Script
```
✅ DevOps Agent
✅ Python Agent (create if needed)
✅ QA Agent
❌ Frontend agents
```

---

## 🛠️ Creating Custom Agents

### Template for New Agent

```markdown
# [Agent Name] - [Specialization]

## Identity
You are the [Agent Name], specializing in [technology/domain].

## Tech Stack
- Technology 1
- Technology 2
- Tool 3

## Responsibilities
- Core responsibility 1
- Core responsibility 2
- Integration with other agents

## Development Approach
1. Step-by-step methodology
2. Best practices
3. Code quality standards

## Coordination
- **Dependencies**: What this agent needs from others
- **Provides**: What this agent provides to others
- **Communication**: How this agent coordinates

## Example Tasks
1. Common task type 1
2. Common task type 2

## Anti-Patterns
- What NOT to do
- Common mistakes to avoid

## Success Criteria
- How to measure success
- Quality metrics
```

### Register in Orchestrator

```markdown
## Agents and Responsibilities

- **[Your New Agent]**: [Brief description]
```

---

## 💡 Best Practices

1. **Keep Agents Focused** - One clear responsibility each
2. **Update Orchestrator** - Always reflect agent changes
3. **Document Tech Stack** - Keep agent files current
4. **Test Integration** - Ensure agents work together
5. **Track in Project-State** - Use dashboard for visibility

---

## 📚 Examples

### Example: E-commerce Project

```
agents/
├── devops-agent.md        (Deployment, CI/CD)
├── product-api-agent.md   (Product catalog API)
├── cart-api-agent.md      (Shopping cart logic)
├── payment-agent.md       (Payment processing)
├── react-agent.md         (Storefront UI)
├── admin-panel-agent.md   (Admin dashboard)
├── database-agent.md      (PostgreSQL, Redis)
└── qa-agent.md            (E2E testing)
```

### Example: SaaS Analytics Platform

```
agents/
├── devops-agent.md        (AWS infrastructure)
├── data-pipeline-agent.md (Data ingestion)
├── analytics-api-agent.md (Analytics API)
├── dashboard-ui-agent.md  (Vue.js dashboard)
├── database-agent.md      (TimescaleDB)
└── qa-agent.md            (Testing)
```

---

## 🔍 Monitoring Agent Performance

Use the project-state dashboard to track:
- Tasks per agent
- Completion velocity
- Blocked tasks
- Sprint progress

---

## 🎯 Next Steps

1. **Choose agents** for your project type
2. **Customize tech stack** in agent files
3. **Update Orchestrator** with your agents
4. **Start working** with Orchestrator
5. **Track progress** on dashboard

The agents will automatically coordinate and manage your project development!

---

**Questions?** Check the [Orchestrator.md](../Orchestrator.md) file for coordination rules and agent interactions.
