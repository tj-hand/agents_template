# Deploying New Projects to Multi-Project Dashboard

## 📋 Overview

This guide shows you how to add new projects to your multi-project dashboard system. Each project gets its own data folder and appears in the project selector dropdown.

## 🎯 Two Deployment Approaches

### Approach 1: Single Repository (Recommended for Related Projects)
All projects in one repository, organized by folders.

### Approach 2: Separate Repositories
Each project has its own git repository (for completely independent projects).

---

## 🚀 Approach 1: Single Repository Multi-Project

### Use Case
- Multiple related projects (different client websites, microservices, etc.)
- Centralized management
- Shared deployment repository

### Step-by-Step

#### 1. Create New Project Folder

In your local repository:

```bash
cd project-state/projects/
mkdir my-new-project
```

#### 2. Create Project Files

```bash
cd my-new-project/

# Create current-sprint.json
cat > current-sprint.json << 'EOF'
{
  "sprint": 1,
  "start_date": "2025-11-20",
  "end_date": "2025-12-03",
  "goal": "Initial project setup and foundation",
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

# Create project.json
cat > project.json << 'EOF'
{
  "project_name": "My New Project",
  "description": "Description of my new project",
  "tech_stack": {
    "frontend": "React",
    "backend": "Node.js",
    "database": "PostgreSQL"
  },
  "team": [],
  "roadmap": [],
  "okrs": {},
  "metadata": {
    "current_sprint": 1,
    "total_sprints_completed": 0
  }
}
EOF

# Create empty task log
touch task-log.jsonl
```

#### 3. Register Project in projects.json

Edit `project-state/projects.json`:

```json
{
  "projects": [
    {
      "id": "agents-template",
      "name": "Agents Template",
      "description": "Multi-agent development template project",
      "color": "#3b82f6"
    },
    {
      "id": "my-new-project",
      "name": "My New Project",
      "description": "My awesome new project",
      "color": "#10b981"
    }
  ],
  "default": "agents-template"
}
```

#### 4. Commit and Push

```bash
git add project-state/projects/
git commit -m "feat: add my-new-project to dashboard"
git push
```

#### 5. Wait for Auto-Deploy

The server will auto-pull within 1 minute. Then:

1. Visit your dashboard: `https://scrum.dotmkt.com.br`
2. Click the project dropdown
3. Select "My New Project"
4. See your new project data!

**Done!** ✅

---

## 🔄 Approach 2: Separate Repository per Project

### Use Case
- Completely independent projects
- Different teams
- Separate access control needed

### Method A: Deploy to Same Server, Different Subdomain

Each project gets its own subdomain and repository:

```
projecta.dotmkt.com.br → github.com/you/projecta
projectb.dotmkt.com.br → github.com/you/projectb
```

#### Step-by-Step

1. **Create new repository from template:**
```bash
git clone https://github.com/tj-hand/agents_template.git projecta
cd projecta
rm -rf .git
git init
# Customize project files
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/you/projecta.git
git push -u origin main
```

2. **Configure DNS:**
```
Type: A
Host: projecta
Value: YOUR_SERVER_IP
TTL: 300
```

3. **Deploy to server:**
```bash
# SSH to server
cd ~/deployment
sudo bash project-manager.sh

# Choose option 1: Add a new project
# Enter:
#   Project name: projecta
#   Subdomain: projecta.dotmkt.com.br
#   Git URL: https://github.com/you/projecta.git
#   Branch: main
#   Auto-pull: 1
#   SSL: y
```

4. **Access:**
- `https://projecta.dotmkt.com.br`

### Method B: Combine Separate Repos into One Dashboard

Deploy multiple repos but show them in one dashboard:

1. **On server, create a dashboard aggregator project:**

```bash
mkdir -p /var/www/multi-dashboard/project-state/projects/
```

2. **Set up sync from each repo:**

```bash
# Cron job to sync project data
*/1 * * * * rsync -a /var/www/project-projecta/project-state/ /var/www/multi-dashboard/project-state/projects/projecta/
*/1 * * * * rsync -a /var/www/project-projectb/project-state/ /var/www/multi-dashboard/project-state/projects/projectb/
```

3. **Configure nginx for the aggregated dashboard**

Now one dashboard shows all projects from different repos!

---

## 📊 Managing Project Data with Claude

### Adding Tasks to a Project

When working with Claude:

```
You: "Working on my-new-project. Add a task to implement user login"

Claude:
1. Identifies project: my-new-project
2. Loads: project-state/projects/my-new-project/current-sprint.json
3. Adds task to the JSON
4. Updates metrics
5. Commits and pushes
6. Server auto-pulls
7. Dashboard updates automatically
```

### Switching Projects Mid-Session

```
You: "Now let's work on projecta"

Claude:
1. Switches context to projecta
2. Loads different project-state files
3. Works on that project's tasks
```

---

## 🎨 Project Colors

Choose distinct colors for easy visual identification:

```json
{
  "projects": [
    {"id": "website-redesign", "color": "#3b82f6"},  // Blue
    {"id": "mobile-app", "color": "#10b981"},        // Green
    {"id": "api-service", "color": "#8b5cf6"},       // Purple
    {"id": "admin-panel", "color": "#f59e0b"},       // Orange
    {"id": "analytics", "color": "#ef4444"}          // Red
  ]
}
```

---

## 🔄 Workflow Examples

### Scenario 1: Agency Managing Client Projects

```
project-state/projects/
├── client-acme/
│   └── (their project data)
├── client-widgets/
│   └── (their project data)
└── client-gadgets/
    └── (their project data)
```

**Dashboard:** One dropdown to switch between all clients

### Scenario 2: Microservices Architecture

```
project-state/projects/
├── user-service/
├── payment-service/
├── inventory-service/
└── notification-service/
```

**Dashboard:** Switch between services to track each one's sprints

### Scenario 3: Different Stages

```
project-state/projects/
├── myapp-production/
├── myapp-staging/
└── myapp-development/
```

**Dashboard:** Same app, different environments

---

## 🐛 Troubleshooting

### Project Not Appearing in Dropdown

1. **Check projects.json syntax:**
```bash
cat project-state/projects.json | jq .
# Should output valid JSON
```

2. **Verify project folder exists:**
```bash
ls -la project-state/projects/my-new-project/
# Should show current-sprint.json, project.json, task-log.jsonl
```

3. **Check browser console:**
- F12 → Console
- Look for fetch errors

4. **Clear browser cache:**
- Ctrl+Shift+Delete
- Clear cached files

### Project Shows "Error Loading Data"

1. **Verify JSON files are valid:**
```bash
cat project-state/projects/my-new-project/current-sprint.json | jq .
# Should parse without errors
```

2. **Check file permissions:**
```bash
ls -la project-state/projects/my-new-project/
# All files should be readable
```

3. **Test direct file access:**
- Visit: `https://scrum.dotmkt.com.br/projects/my-new-project/current-sprint.json`
- Should download/show JSON

### Changes Not Appearing

1. **Verify commit was pushed:**
```bash
git log --oneline -3
git push
```

2. **Check server auto-pull:**
```bash
# On server
journalctl -u project-agents-template-autopull.service --since "5 minutes ago"
```

3. **Manual pull on server:**
```bash
cd /var/www/project-agents-template
sudo git pull
```

4. **Hard refresh browser:**
- Ctrl+F5

---

## 📈 Best Practices

1. **Consistent Naming** - Use lowercase-with-hyphens for project IDs
2. **Meaningful Names** - Choose descriptive project names
3. **Document Projects** - Add good descriptions in projects.json
4. **Test Locally** - Validate JSON before pushing
5. **One Project at a Time** - Add projects incrementally
6. **Track in Git** - Commit each project addition separately

---

## 🔐 Security Considerations

### Private Projects

If project data is sensitive:

1. **Use Private Repository:**
- Make repository private on GitHub
- Use deploy keys on server

2. **Protect Dashboard:**
```nginx
# Add to nginx config
auth_basic "Restricted";
auth_basic_user_file /etc/nginx/.htpasswd;
```

3. **Separate Servers:**
- Public projects: Server A
- Private projects: Server B (no public access)

---

## 📚 Quick Reference

### Add Project (Single Repo)
```bash
mkdir project-state/projects/new-project
# Create JSON files
# Edit projects.json
git add . && git commit -m "feat: add new-project"
git push
# Wait 1 minute or refresh dashboard
```

### Add Project (Separate Repo)
```bash
# On server
sudo bash project-manager.sh
# Option 1, enter details
```

### Remove Project
```bash
# Delete folder
rm -rf project-state/projects/old-project/
# Remove from projects.json
git add . && git commit -m "chore: remove old-project"
git push
```

### Rename Project
```bash
# Rename folder
mv project-state/projects/old-name project-state/projects/new-name
# Update projects.json (change id)
git add . && git commit -m "refactor: rename project"
git push
```

---

## 🎯 Next Steps

1. **Add your first project** using one of the methods above
2. **Test the dropdown selector** on the dashboard
3. **Start tracking work** in the new project
4. **Scale up** - Add more projects as needed

The multi-project system can handle unlimited projects! 🚀

---

**Need help?** Check the [projects/README.md](../project-state/projects/README.md) for more examples.
