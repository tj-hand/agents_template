# Multi-Project Deployment Guide

## 🎯 Overview

This guide shows you how to use your Ubuntu server as a **platform for multiple projects**, each with:
- ✅ Its own git repository
- ✅ Its own project-state dashboard
- ✅ Its own subdomain
- ✅ Automated deployments
- ✅ The same agents system

## 📚 Quick Links

- **[Complete Step-by-Step Setup Guide](./NEW-PROJECT-SETUP.md)** ← Start here for new projects
- [Webhook Integration](./WEBHOOK-GUIDE.md) - For instant updates
- [Server Setup](./SERVER-SETUP-GUIDE.md) - Initial server configuration
- [Architecture Overview](./ARCHITECTURE.md) - System design

## ⚠️ CRITICAL: Naming Conventions

**MUST READ** before adding projects:

| Item | Rules | ✅ Good Examples | ❌ Bad Examples |
|------|-------|------------------|-----------------|
| **Project Name** | • Lowercase only<br>• Hyphens (not underscores)<br>• No spaces<br>• Alphanumeric + hyphens | `my-project`<br>`api-gateway`<br>`user-portal` | `My Project` ← spaces<br>`my_project` ← underscores<br>`Project 1` ← capital, space |
| **Subdomain** | • Must be unique<br>• Lowercase<br>• Valid DNS name | `myapp.domain.com`<br>`api.domain.com`<br>`staging-app.domain.com` | `my app.domain.com` ← space<br>`scrum.dotmkt.com.br` ← already used |
| **Project ID** | • Same as project name<br>• Used in paths and configs | `my-project` | Different from project name |

**Why this matters:**
- Spaces break nginx configuration
- Uppercase causes DNS/SSL issues
- Duplicate subdomains cause conflicts
- Invalid names prevent deployment

**The script now validates** these rules automatically!

## 🏗️ Architecture

```
Your Ubuntu Server (216.238.99.183)
├── Project Alpha          → alpha.yourdomain.com
│   ├── project-state/
│   ├── agents/
│   └── auto-pull (every 1 min)
│
├── Project Beta           → beta.yourdomain.com
│   ├── project-state/
│   ├── agents/
│   └── auto-pull (every 1 min)
│
└── Project Gamma          → gamma.yourdomain.com
    ├── project-state/
    ├── agents/
    └── auto-pull (every 1 min)
```

Each project:
- **Independent** - Has its own repo, dashboard, and domain
- **Automated** - Auto-pulls from git every minute
- **Isolated** - No conflicts between projects
- **Reusable** - Uses the same agents and project-state framework

## 🚀 Quick Start

### 1. Initial Server Setup (One Time)

Transfer the `project-manager.sh` script to your server:

```bash
# On your server (via PuTTY)
curl -o project-manager.sh https://raw.githubusercontent.com/tj-hand/agents_template/main/deployment/project-manager.sh
chmod +x project-manager.sh
```

### 2. Add Your First Project

```bash
sudo bash project-manager.sh
# Choose option 1: Add a new project
```

You'll be asked:
```
Project name: myapp
Subdomain: myapp.yourdomain.com
Git repository URL: https://github.com/yourname/myapp.git
Git branch: main
Auto-pull interval: 1
Setup SSL: y
```

**Done!** Your project is live at `myapp.yourdomain.com`

### 3. Add More Projects

Run the same script again for each new project:

```bash
sudo bash project-manager.sh
# Choose option 1
# Enter different project name and subdomain
```

## 📦 Setting Up a New Repository

When creating a new project repository, copy these from this template:

### Required Files/Folders

```
your-new-repo/
├── project-state/              ← Copy entire folder
│   ├── dashboard.html
│   ├── current-sprint.json
│   ├── project.json
│   ├── task-log.jsonl
│   ├── templates/
│   └── scripts/
│
├── agents/                     ← Copy entire folder
│   ├── devops-agent.md
│   ├── fastapi-agent.md
│   ├── vue-agent.md
│   ├── database-agent.md
│   ├── qa-agent.md
│   └── uxui-agent.md
│
├── deployment/                 ← Copy entire folder
│   ├── setup.sh
│   ├── project-manager.sh
│   ├── README.md
│   └── MULTI-PROJECT-GUIDE.md
│
├── Orchestrator.md             ← Copy file
├── .gitignore                  ← Copy file
└── README.md                   ← Customize for your project
```

### Quick Copy Command

```bash
# Clone this template repo
git clone https://github.com/tj-hand/agents_template.git my-new-project
cd my-new-project

# Remove git history and start fresh
rm -rf .git
git init
git add .
git commit -m "Initial commit from agents_template"

# Add your remote and push
git remote add origin https://github.com/yourname/my-new-project.git
git push -u origin main
```

### Customize for Your Project

1. **Update `project-state/projects.json`** with your repository details:
   ```json
   {
     "projects": [
       {
         "id": "my-new-project",
         "name": "My New Project",
         "description": "Description of your project",
         "color": "#3b82f6",
         "repository": "https://github.com/yourname/my-new-project.git",
         "branch": "main"
       }
     ],
     "default": "my-new-project"
   }
   ```

2. **Update `project-state/project.json`** with your project details
3. **Clear `project-state/current-sprint.json`** (or start with your sprint)
4. **Clear `project-state/task-log.jsonl`** (start fresh)
5. **Update `README.md`** with your project description
6. **Customize agents/** if you need different agents

## 🎛️ Managing Multiple Projects

### List All Projects

```bash
sudo bash project-manager.sh
# Choose option 2: List all projects
```

Output:
```
Project: myapp
  Path: /var/www/project-myapp
  Auto-pull: active
  Repository: https://github.com/yourname/myapp.git
  Branch: main

Project: webapp
  Path: /var/www/project-webapp
  Auto-pull: active
  Repository: https://github.com/yourname/webapp.git
  Branch: main

Total projects: 2
```

### Check Project Status

```bash
sudo bash project-manager.sh
# Choose option 5: View project status
# Enter project name
```

Shows:
- Git status
- Recent commits
- Auto-pull timer status
- Recent auto-pull logs

### Manually Update a Project

```bash
sudo bash project-manager.sh
# Choose option 4: Update a project
# Enter project name
```

### Remove a Project

```bash
sudo bash project-manager.sh
# Choose option 3: Remove a project
# Enter project name
# Confirm with 'yes'
```

This removes:
- All project files
- Nginx configuration
- Auto-pull timer
- SSL certificate

## 🌍 DNS Configuration

For each project, create a DNS A record:

| Type | Host | Value | TTL |
|------|------|-------|-----|
| A | myapp | 216.238.99.183 | 300 |
| A | webapp | 216.238.99.183 | 300 |
| A | api | 216.238.99.183 | 300 |

**Wildcard Option:** If you control the domain, set up a wildcard:

| Type | Host | Value | TTL |
|------|------|-------|-----|
| A | * | 216.238.99.183 | 300 |

This allows any subdomain to work automatically.

## 🔄 Development Workflow

### Working with Claude on a Project

1. **Tell Claude which project** you're working on
2. **Claude makes changes** to that project's repo
3. **Claude commits and pushes** to that repo
4. **Server auto-pulls** within 1 minute
5. **Visit the subdomain** to see changes

### Example

```
User: "I'm working on the 'myapp' project.
       Add a new feature to track user sessions."

Claude: [Makes changes to myapp repo]
        [Commits: "feat: add user session tracking"]
        [Pushes to github.com/yourname/myapp]

Server: [Auto-pulls within 1 min]
        [Updates myapp.yourdomain.com]

User: [Visits myapp.yourdomain.com]
      [Sees updated dashboard with new task]
```

## 📊 Monitoring Multiple Projects

### View All Auto-Pull Timers

```bash
systemctl list-timers | grep project-
```

### View Logs for Specific Project

```bash
# Auto-pull logs
journalctl -u project-myapp-autopull.service -f

# Nginx access logs
tail -f /var/log/nginx/myapp.yourdomain.com-access.log

# Nginx error logs
tail -f /var/log/nginx/myapp.yourdomain.com-error.log
```

### Monitor All Projects at Once

```bash
# Create a monitoring script
cat > monitor-all.sh <<'EOF'
#!/bin/bash
for PROJECT_DIR in /var/www/project-*; do
    PROJECT_NAME=$(basename "$PROJECT_DIR" | sed 's/^project-//')
    echo "=== $PROJECT_NAME ==="
    systemctl status "project-$PROJECT_NAME-autopull.timer" --no-pager | grep Active
    echo ""
done
EOF

chmod +x monitor-all.sh
./monitor-all.sh
```

## 🎨 Optional: Master Dashboard

Want one dashboard to see all projects? Create a master dashboard:

### 1. Create Master Dashboard Repo

```bash
# New repo: dashboard-master
mkdir dashboard-master
cd dashboard-master

# Create index.html
cat > index.html <<'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>All Projects Dashboard</title>
    <style>
        body { font-family: Arial; max-width: 1200px; margin: 50px auto; }
        .project { border: 1px solid #ddd; padding: 20px; margin: 20px 0; }
        .project h2 { margin: 0; }
        .project a { color: #0066cc; text-decoration: none; }
        .project a:hover { text-decoration: underline; }
    </style>
</head>
<body>
    <h1>All Projects</h1>

    <div class="project">
        <h2>Project Alpha</h2>
        <p>Description of Project Alpha</p>
        <a href="https://alpha.yourdomain.com" target="_blank">View Dashboard →</a>
    </div>

    <div class="project">
        <h2>Project Beta</h2>
        <p>Description of Project Beta</p>
        <a href="https://beta.yourdomain.com" target="_blank">View Dashboard →</a>
    </div>

    <!-- Add more projects here -->
</body>
</html>
EOF

git init
git add .
git commit -m "Initial master dashboard"
git remote add origin https://github.com/yourname/dashboard-master.git
git push -u origin main
```

### 2. Deploy Master Dashboard

```bash
# On your server
sudo bash project-manager.sh
# Add new project: dashboard-master
# Subdomain: dashboard.yourdomain.com
```

Now `dashboard.yourdomain.com` shows links to all projects!

## 🔒 Security Best Practices

### Use Deploy Keys for Private Repos

For each private repository:

```bash
# On server
ssh-keygen -t ed25519 -C "project-myapp-deploy" -f ~/.ssh/myapp_deploy_key

# Add to GitHub:
# Repo → Settings → Deploy keys → Add deploy key
# Paste contents of ~/.ssh/myapp_deploy_key.pub

# Configure git to use this key
cd /var/www/project-myapp
git config core.sshCommand "ssh -i ~/.ssh/myapp_deploy_key"
```

### Restrict Dashboard Access

Add basic auth to nginx:

```bash
# Install apache2-utils
apt-get install apache2-utils

# Create password file
htpasswd -c /etc/nginx/.htpasswd username

# Edit nginx config
nano /etc/nginx/sites-available/myapp.yourdomain.com

# Add inside server block:
auth_basic "Restricted";
auth_basic_user_file /etc/nginx/.htpasswd;

# Reload nginx
nginx -t && systemctl reload nginx
```

## 💡 Tips & Tricks

### Shared Resources Across Projects

Create a shared directory for common files:

```bash
mkdir -p /var/www/shared
# Put common scripts, configs, etc.
```

Link from projects:
```bash
cd /var/www/project-myapp
ln -s /var/www/shared ./shared
```

### Different Auto-Pull Intervals

Some projects update more frequently:

```bash
# Edit timer
nano /etc/systemd/system/project-myapp-autopull.timer

# Change interval
OnUnitActiveSec=30s  # Every 30 seconds

# Reload
systemctl daemon-reload
systemctl restart project-myapp-autopull.timer
```

### Staging vs Production

Use branches for environments:

```bash
# Production (main branch)
sudo bash project-manager.sh
Project: myapp
Subdomain: myapp.yourdomain.com
Branch: main

# Staging (develop branch)
sudo bash project-manager.sh
Project: myapp-staging
Subdomain: staging.myapp.yourdomain.com
Branch: develop
```

## 🐛 Troubleshooting

### Project Not Updating

```bash
# Check timer status
systemctl status project-myapp-autopull.timer

# Check recent logs
journalctl -u project-myapp-autopull.service --since "10 minutes ago"

# Manually pull to see error
cd /var/www/project-myapp
git pull
```

### Nginx 404 Error

```bash
# Verify dashboard exists
ls -la /var/www/project-myapp/project-state/dashboard.html

# Check nginx config
cat /etc/nginx/sites-enabled/myapp.yourdomain.com

# Verify root path matches
```

### SSL Certificate Failed

```bash
# Verify DNS is configured
dig myapp.yourdomain.com

# Manually obtain certificate
certbot --nginx -d myapp.yourdomain.com
```

## 📚 Summary

**To add a new project:**
1. Create repo from this template
2. Push to GitHub
3. Run `project-manager.sh` → Add project
4. Configure DNS
5. Done! Project is live and auto-updating

**Your server becomes a platform** for unlimited projects, each with automated deployments and the full agents system!

---

**Questions?** Check the main [README.md](./README.md) or examine the scripts in this folder.
