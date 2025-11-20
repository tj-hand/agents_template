#!/bin/bash

# Template Initialization Script
# Prepares the agents_template for use as a new project

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Agents Template Initialization${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Get project information
read -p "Enter your project name (e.g., 'my-awesome-project'): " PROJECT_NAME
read -p "Enter project display name (e.g., 'My Awesome Project'): " PROJECT_DISPLAY_NAME
read -p "Enter project description: " PROJECT_DESCRIPTION
read -p "Enter your GitHub username: " GITHUB_USERNAME

if [ -z "$PROJECT_NAME" ] || [ -z "$PROJECT_DISPLAY_NAME" ]; then
    echo -e "${RED}Error: Project name is required${NC}"
    exit 1
fi

# Confirm
echo ""
echo -e "${YELLOW}Summary:${NC}"
echo "  Project ID: $PROJECT_NAME"
echo "  Display Name: $PROJECT_DISPLAY_NAME"
echo "  Description: $PROJECT_DESCRIPTION"
echo "  GitHub: $GITHUB_USERNAME/$PROJECT_NAME"
echo ""
read -p "Continue? (y/n): " CONFIRM

if [ "$CONFIRM" != "y" ]; then
    echo "Cancelled."
    exit 0
fi

echo ""
echo -e "${GREEN}[1/6] Setting up project directories...${NC}"

# Create new project directory structure
mkdir -p "project-state/projects/$PROJECT_NAME"

# Initialize empty project files
cat > "project-state/projects/$PROJECT_NAME/current-sprint.json" <<EOF
{
  "sprint": 1,
  "start_date": "$(date +%Y-%m-%d)",
  "end_date": "$(date -d '+14 days' +%Y-%m-%d)",
  "goal": "Initial project setup and planning",
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
EOF

cat > "project-state/projects/$PROJECT_NAME/project.json" <<EOF
{
  "project_name": "$PROJECT_DISPLAY_NAME",
  "description": "$PROJECT_DESCRIPTION",
  "start_date": "$(date +%Y-%m-%d)",
  "tech_stack": {
    "frontend": "Vue 3 + TypeScript + Tailwind CSS",
    "backend": "FastAPI + Python",
    "database": "PostgreSQL",
    "infrastructure": "Docker + Nginx"
  },
  "team": [
    "Database Agent",
    "UX/UI Agent",
    "Vue Agent",
    "FastAPI Agent",
    "QA Agent",
    "DevOps Agent"
  ],
  "roadmap": [
    {
      "epic_id": "EPIC-001",
      "title": "Initial Setup",
      "status": "IN_PROGRESS",
      "priority": "P0",
      "start_date": "$(date +%Y-%m-%d)",
      "target_date": "$(date -d '+30 days' +%Y-%m-%d)",
      "description": "Set up project infrastructure and development environment",
      "sprints": [1]
    }
  ],
  "okrs": {
    "Q1_$(date +%Y)": {
      "objective": "Launch MVP",
      "key_results": [
        "Complete core functionality",
        "Deploy to production",
        "Achieve 90% test coverage"
      ]
    }
  },
  "metadata": {
    "last_updated": "$(date -Iseconds)",
    "current_sprint": 1,
    "total_sprints_completed": 0
  }
}
EOF

# Initialize empty task log
touch "project-state/projects/$PROJECT_NAME/task-log.jsonl"

echo -e "${GREEN}✓ Project directories created${NC}"

echo ""
echo -e "${GREEN}[2/6] Updating projects.json...${NC}"

# Update projects.json
cat > project-state/projects.json <<EOF
{
  "projects": [
    {
      "id": "$PROJECT_NAME",
      "name": "$PROJECT_DISPLAY_NAME",
      "description": "$PROJECT_DESCRIPTION",
      "color": "#3b82f6"
    }
  ],
  "default": "$PROJECT_NAME"
}
EOF

echo -e "${GREEN}✓ Projects registry updated${NC}"

echo ""
echo -e "${GREEN}[3/6] Updating README.md...${NC}"

# Create a basic README
cat > README.md <<EOF
# $PROJECT_DISPLAY_NAME

$PROJECT_DESCRIPTION

## 🚀 Quick Start

This project uses the AI Agents Template for development coordination.

### Agents Available

- **DevOps Agent** - Infrastructure, deployment, Docker
- **FastAPI Agent** - Backend API development
- **Vue Agent** - Frontend development
- **Database Agent** - Schema design, migrations
- **QA Agent** - Testing and code review
- **UX/UI Agent** - Design and user experience
- **Claude** - Main project manager coordinating all agents

### Project Dashboard

Track project progress with the multi-project dashboard:
- Sprint planning and tracking
- Task management
- Team velocity metrics
- Activity logging

## 📊 Project Structure

\`\`\`
$PROJECT_NAME/
├── agents/                # AI agent definitions
├── project-state/         # Project tracking dashboard
│   ├── dashboard.html
│   └── projects/
│       └── $PROJECT_NAME/
├── deployment/            # Deployment scripts
├── Claude.md              # Main project manager
└── README.md
\`\`\`

## 🛠️ Development

### Prerequisites

- Git
- Docker & Docker Compose (for containerized apps)
- Your tech stack requirements

### Setup

\`\`\`bash
# Clone repository
git clone https://github.com/$GITHUB_USERNAME/$PROJECT_NAME.git
cd $PROJECT_NAME

# See deployment guides in /deployment/ folder
\`\`\`

### Using Agents

Interact with specialized agents for different tasks:

\`\`\`
You: "Add user authentication to the app"
Claude: Analyzes request, creates tasks, delegates to agents
  → Database Agent: Creates user tables
  → FastAPI Agent: Implements auth endpoints
  → Vue Agent: Creates login UI
  → QA Agent: Tests the implementation
\`\`\`

## 📚 Documentation

- [Deployment Guide](deployment/QUICKSTART.md)
- [Multi-Project Setup](deployment/MULTI-PROJECT-GUIDE.md)
- [Agent Implementation](deployment/AGENTS-IMPLEMENTATION-GUIDE.md)
- [Project State README](project-state/README.md)

## 🤝 Contributing

This project uses AI-assisted development. Contributions are welcome!

## 📝 License

MIT License - See LICENSE file for details

---

**Built with [AI Agents Template](https://github.com/tj-hand/agents_template)**
EOF

echo -e "${GREEN}✓ README.md created${NC}"

echo ""
echo -e "${GREEN}[4/6] Removing example project...${NC}"

# Remove agents-template example project if it exists
if [ -d "project-state/projects/agents-template" ]; then
    rm -rf project-state/projects/agents-template
    echo -e "${GREEN}✓ Example project removed${NC}"
else
    echo -e "${YELLOW}⚠ No example project found${NC}"
fi

echo ""
echo -e "${GREEN}[5/6] Cleaning up...${NC}"

# Remove old Orchestrator.md if it still exists (shouldn't, but just in case)
if [ -f "Orchestrator.md" ]; then
    rm Orchestrator.md
    echo -e "${GREEN}✓ Old Orchestrator.md removed${NC}"
fi

echo -e "${GREEN}✓ Cleanup complete${NC}"

echo ""
echo -e "${GREEN}[6/6] Initializing Git repository...${NC}"

# Git operations
if [ -d ".git" ]; then
    echo -e "${YELLOW}⚠ Git repository already exists. Skipping git init.${NC}"
    echo -e "${YELLOW}  To start fresh, manually run: rm -rf .git && git init${NC}"
else
    git init
    git add .
    git commit -m "Initial commit from agents_template

Project: $PROJECT_DISPLAY_NAME
Template: https://github.com/tj-hand/agents_template"
    echo -e "${GREEN}✓ Git repository initialized${NC}"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  ✅ Template Initialized Successfully!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${BLUE}Next Steps:${NC}"
echo ""
echo "1. ${YELLOW}Connect to your remote repository:${NC}"
echo "   git remote add origin https://github.com/$GITHUB_USERNAME/$PROJECT_NAME.git"
echo "   git push -u origin main"
echo ""
echo "2. ${YELLOW}Customize your project:${NC}"
echo "   - Edit project-state/projects/$PROJECT_NAME/project.json"
echo "   - Modify agents/ if needed for your tech stack"
echo "   - Update README.md with specific details"
echo ""
echo "3. ${YELLOW}Deploy to remote server:${NC}"
echo "   - See deployment/QUICKSTART.md"
echo "   - Use deployment/project-manager.sh on your server"
echo ""
echo "4. ${YELLOW}Start using agents:${NC}"
echo "   - Claude is your main project manager (Claude.md)"
echo "   - Specialized agents in agents/ directory"
echo "   - Track progress in dashboard"
echo ""
echo -e "${BLUE}Happy coding! 🚀${NC}"
