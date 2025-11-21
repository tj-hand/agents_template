# New Project Setup - Complete Guide

## 🎯 Goal

Set up a brand new project from scratch with automated deployment to the scrum server.

## 📋 Prerequisites

- GitHub account with repository creation permissions
- Access to scrum server (SSH)
- DNS configuration access (for subdomain setup)
- This template repository cloned locally

## 🚀 Complete Workflow (Step-by-Step)

### Phase 1: Local Setup

#### Step 1: Create New Repository on GitHub

```bash
# Option A: Using GitHub CLI (recommended)
gh repo create my-new-project --public --clone

# Option B: Create on GitHub.com web interface, then clone
git clone https://github.com/YOUR-USERNAME/my-new-project.git
cd my-new-project
```

#### Step 2: Copy Template Files

```bash
# From this template repository, copy essential directories
cp -r /path/to/agents_template/project-state ./
cp -r /path/to/agents_template/agents ./
cp -r /path/to/agents_template/deployment ./
cp /path/to/agents_template/Orchestrator.md ./
cp /path/to/agents_template/.gitignore ./
```

#### Step 3: Customize Project Files

**Update `project-state/project.json`:**
```json
{
  "name": "My New Project",
  "description": "Description of your new project",
  "team": ["Your Name"],
  "tech_stack": ["Technology", "Stack"],
  "roadmap": []
}
```

**Update `project-state/projects.json`:**
```json
{
  "projects": [
    {
      "id": "my-new-project",
      "name": "My New Project",
      "description": "Description of your new project",
      "color": "#3b82f6",
      "repository": "https://github.com/YOUR-USERNAME/my-new-project.git",
      "branch": "main"
    }
  ],
  "default": "my-new-project"
}
```

**Clear existing task data:**
```bash
# Start with empty sprint
echo '{"current_sprint": {"number": 1, "objective": "", "tasks": []}}' > project-state/current-sprint.json

# Clear task log
echo '' > project-state/task-log.jsonl
```

#### Step 4: Initial Commit and Push

```bash
git add .
git commit -m "feat: initialize project from agents_template"
git push -u origin main
```

### Phase 2: Server Deployment

#### Step 5: Choose Project Naming

**CRITICAL:** Choose names carefully - they cannot be easily changed later.

| Item | Rules | Good Examples | Bad Examples |
|------|-------|---------------|--------------|
| **Project Name** | Lowercase, hyphens, no spaces | `my-project`, `api-gateway`, `user-portal` | `My Project`, `api_gateway`, `Project 1` |
| **Subdomain** | Lowercase, must be unique | `myproject.domain.com`, `api.domain.com` | `my project.domain.com`, existing subdomain |
| **Project ID** | Same as project name | `my-project` | Different from project name |

#### Step 6: Configure DNS

**Before deploying**, set up DNS A record:

| Type | Host | Value | TTL |
|------|------|-------|-----|
| A | myproject | 216.238.99.183 | 300 |

**Wait for DNS propagation** (check with `dig myproject.yourdomain.com`)

#### Step 7: Deploy to Scrum Server

```bash
# SSH into scrum server
ssh user@scrum.dotmkt.com.br

# Run project manager
sudo bash /var/www/project-agents-template/deployment/project-manager.sh

# Choose option: 1) Add a new project
```

**Provide values:**
```
Project name: my-new-project
Subdomain: myproject.dotmkt.com.br
Git repository URL: https://github.com/YOUR-USERNAME/my-new-project.git
Git branch: main
Auto-pull interval: 5
Setup SSL: y
```

**Verify:**
- Nginx configuration succeeds
- SSL certificate obtained
- Auto-pull timer started

#### Step 8: Verify Deployment

```bash
# Check project status
sudo bash /var/www/project-agents-template/deployment/project-manager.sh
# Choose option: 5) View project status
# Enter: my-new-project

# Check auto-pull timer
systemctl status project-my-new-project-autopull.timer

# View recent logs
journalctl -u project-my-new-project-autopull.service -n 20
```

**Visit dashboard:**
```
https://myproject.dotmkt.com.br
```

### Phase 3: Verification and Testing

#### Step 9: Test Auto-Pull

**Make a test change:**
```bash
# On your local machine
cd my-new-project
echo "test: verify auto-pull works" >> project-state/task-log.jsonl
git add .
git commit -m "test: verify auto-pull system"
git push
```

**Wait 5 minutes** (or trigger webhook for instant update)

**Verify on server:**
```bash
# On scrum server
cd /var/www/project-my-new-project
git log -1 --oneline
# Should show your latest commit
```

**Refresh dashboard** - should show updated data

#### Step 10: Configure Webhook (Optional, for Instant Updates)

**On your local machine:**
```bash
cd my-new-project

# Copy webhook config
cp .webhook-config.example .webhook-config

# Edit with your values
nano .webhook-config
```

**Edit `.webhook-config`:**
```bash
WEBHOOK_URL="https://scrum.dotmkt.com.br/webhook.php"
WEBHOOK_SECRET="your-secret-key-here"  # Get from server admin
PROJECT_NAME="my-new-project"
```

**Test webhook:**
```bash
# After pushing changes
source .webhook-config
curl -X POST "${WEBHOOK_URL}?secret=${WEBHOOK_SECRET}"
```

## 🎯 Summary Checklist

- [ ] Created GitHub repository
- [ ] Copied template files
- [ ] Customized `project-state/projects.json` with repository URL
- [ ] Updated `project-state/project.json` with project details
- [ ] Cleared old task data
- [ ] Pushed initial commit to GitHub
- [ ] Configured DNS A record
- [ ] Deployed using `project-manager.sh` with correct naming (no spaces!)
- [ ] Verified nginx, SSL, and auto-pull configuration
- [ ] Tested auto-pull by making a change
- [ ] (Optional) Configured webhook for instant updates
- [ ] Dashboard accessible at chosen subdomain

## 🐛 Common Issues

### Issue: "nginx: [emerg] invalid number of arguments in 'root' directive"

**Cause:** Project name contains spaces

**Fix:**
```bash
# Remove failed project
sudo bash project-manager.sh  # Option 3
# Re-add with hyphenated name (e.g., 'my-project' not 'My Project')
```

### Issue: "Subdomain already in use"

**Cause:** Another project is using the same subdomain

**Fix:**
```bash
# List existing projects
sudo bash project-manager.sh  # Option 2
# Choose a different subdomain
```

### Issue: "SSL certificate failed"

**Cause:** DNS not configured or not propagated

**Fix:**
```bash
# Verify DNS
dig your-subdomain.yourdomain.com

# If returns server IP, manually retry SSL
certbot --nginx -d your-subdomain.yourdomain.com
```

### Issue: "Auto-pull not working"

**Cause:** Various (permissions, git config, network)

**Fix:**
```bash
# Check timer status
systemctl status project-my-new-project-autopull.timer

# Check logs
journalctl -u project-my-new-project-autopull.service -n 50

# Manually test pull
cd /var/www/project-my-new-project
sudo -u www-data git pull  # Should pull as nginx user
```

## 📚 Next Steps

After successful setup:

1. **Work with Claude** - Tell Claude which project you're working on
2. **Make changes** - Claude updates files and commits
3. **Auto-deployment** - Changes appear on dashboard within 5 minutes
4. **Monitor progress** - Use dashboard to track sprint and tasks

## 🔗 Related Documentation

- [MULTI-PROJECT-GUIDE.md](./MULTI-PROJECT-GUIDE.md) - Managing multiple projects
- [WEBHOOK-GUIDE.md](./WEBHOOK-GUIDE.md) - Setting up instant updates
- [SERVER-SETUP-GUIDE.md](./SERVER-SETUP-GUIDE.md) - Initial server configuration
- [ARCHITECTURE.md](./ARCHITECTURE.md) - System architecture overview

---

**Questions or issues?** Check the troubleshooting section or examine logs on the server.
