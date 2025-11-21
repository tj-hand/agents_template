# Automated Multi-Repo Sync Guide

## 🎯 Overview

This system automatically synchronizes project data from **multiple external repositories** into a single dashboard at `scrum.dotmkt.com.br`.

## 🏗️ Architecture

```
External Repos               agents_template (Dashboard Hub)
┌─────────────────┐         ┌──────────────────────────────┐
│ nginx_api_gateway│         │ project-state/               │
│ ├── project-state│   ┌────→│ ├── dashboard.html ◄───┐     │
│ │   ├── *.json   │───┘     │ ├── projects.json      │     │
│ │   └── *.jsonl  │         │ └── projects/          │     │
└─────────────────┘         │     ├── agents-template/│     │
                            │     └── nginx-api-gateway│    │
┌─────────────────┐         │                          │     │
│ user-portal     │         │ GitHub Actions           │     │
│ ├── project-state│   ┌────→│ ↓ Syncs every 15 min   │     │
│ │   ├── *.json   │───┘     │ ↓ Commits changes      ├─────┘
│ │   └── *.jsonl  │         │ ↓ Triggers webhook     │   Auto-pull
└─────────────────┘         └──────────────────────────┘   every 5min
                                                              │
                                                              ▼
                                                    scrum.dotmkt.com.br
                                                    Shows all projects!
```

## ✨ Key Features

### ✅ Fully Automated
- **No manual intervention** after initial setup
- **Auto-syncs** every 15 minutes
- **Auto-commits** changes to agents_template
- **Auto-deploys** to scrum server

### ✅ Multi-Repository Support
- **External repos** - Each project has its own GitHub repository
- **Independent development** - Teams work on their own repos
- **Centralized dashboard** - All projects visible in one place

### ✅ Zero Downtime
- **Non-blocking** - Sync failures don't affect other projects
- **Automatic retry** - Runs every 15 minutes
- **Manual trigger** - Can trigger sync anytime

## 🚀 Quick Start

### For Adding a New Project

#### Option 1: Using the Script (Recommended)

```bash
# In agents_template repo
bash scripts/add-project.sh
```

Follow the prompts:
```
Project ID: nginx-api-gateway
Project Name: Nginx API Gateway
Project Description: API Gateway for microservices
GitHub Repository URL: https://github.com/tj-hand/nginx_api_gateway_b
Branch: main
Color: #10b981
```

The script will:
1. ✅ Add project to `projects.json`
2. ✅ Create directory structure
3. ✅ Commit and push changes

Then:
```bash
git push
```

**Done!** GitHub Actions will sync the external repo automatically.

#### Option 2: Manual Setup

**Step 1: Update projects.json**

```json
{
  "projects": [
    {
      "id": "agents-template",
      "name": "Agents Template",
      "description": "Multi-agent development template project",
      "color": "#3b82f6",
      "repository": "https://github.com/tj-hand/agents_template.git",
      "branch": "main"
    },
    {
      "id": "nginx-api-gateway",
      "name": "Nginx API Gateway",
      "description": "API Gateway for microservices",
      "color": "#10b981",
      "repository": "https://github.com/tj-hand/nginx_api_gateway_b.git",
      "branch": "main"
    }
  ],
  "default": "agents-template"
}
```

**Step 2: Commit and push**

```bash
git add project-state/projects.json
git commit -m "feat: add nginx-api-gateway project"
git push
```

**Step 3: Wait for GitHub Actions** (15 minutes max)

Or trigger manually:
```bash
gh workflow run sync-projects.yml
```

## 🔄 How the Sync Works

### Every 15 Minutes:

1. **GitHub Actions reads** `projects.json`
2. **For each project** with a `repository` URL:
   - Clones the external repo (shallow clone)
   - Checks for `project-state/` directory
   - Syncs these files to `project-state/projects/{id}/`:
     - `current-sprint.json`
     - `project.json`
     - `task-log.jsonl`
3. **If changes detected:**
   - Commits to agents_template
   - Pushes to GitHub
   - Triggers webhook (optional)
4. **Scrum server** auto-pulls within 5 minutes
5. **Dashboard** shows updated data

## 📋 Requirements for External Repos

Each external repository must have:

```
your-project/
└── project-state/
    ├── current-sprint.json    ← Required
    ├── project.json           ← Required
    └── task-log.jsonl         ← Required
```

### File Formats

**current-sprint.json:**
```json
{
  "current_sprint": {
    "number": 1,
    "objective": "Sprint objective",
    "start_date": "2024-11-01",
    "end_date": "2024-11-14",
    "tasks": [
      {
        "id": "1",
        "description": "Task description",
        "status": "in_progress",
        "assignee": "Developer Name"
      }
    ]
  }
}
```

**project.json:**
```json
{
  "name": "Project Name",
  "description": "Project description",
  "team": ["Member 1", "Member 2"],
  "tech_stack": ["Technology 1", "Technology 2"],
  "roadmap": []
}
```

**task-log.jsonl:**
```jsonl
{"timestamp":"2024-11-21T10:00:00Z","action":"created","task_id":"1","description":"Task created"}
{"timestamp":"2024-11-21T11:00:00Z","action":"updated","task_id":"1","status":"in_progress"}
```

## 🛠️ Configuration

### GitHub Secrets (Optional)

For automatic webhook triggering:

```bash
# In agents_template repository settings → Secrets and variables → Actions
WEBHOOK_URL=https://scrum.dotmkt.com.br/webhook.php
WEBHOOK_SECRET=your-secret-key
```

### Sync Frequency

Edit `.github/workflows/sync-projects.yml`:

```yaml
schedule:
  - cron: '*/15 * * * *'  # Every 15 minutes
  # Change to:
  - cron: '*/5 * * * *'   # Every 5 minutes
  # Or:
  - cron: '0 * * * *'     # Every hour
```

## 🎛️ Manual Operations

### Trigger Sync Manually

```bash
# Using GitHub CLI
gh workflow run sync-projects.yml

# Or via web interface
# GitHub → Actions → Sync Multi-Repo Projects → Run workflow
```

### Check Sync Status

```bash
# View latest workflow run
gh run list --workflow=sync-projects.yml

# View logs
gh run view --log
```

### Force Sync a Specific Project

```bash
# Delete the project directory to force re-sync
rm -rf project-state/projects/nginx-api-gateway
git add -A
git commit -m "chore: force re-sync nginx-api-gateway"
git push

# Wait for GitHub Actions or trigger manually
gh workflow run sync-projects.yml
```

## 🐛 Troubleshooting

### Project Not Showing in Dashboard

**Check 1: Is project in projects.json?**
```bash
cat project-state/projects.json | jq '.projects[] | .id'
```

**Check 2: Did GitHub Actions run?**
```bash
gh run list --workflow=sync-projects.yml
```

**Check 3: Are files synced?**
```bash
ls -la project-state/projects/your-project-id/
```

**Check 4: Did server update?**
```bash
# On scrum server
cd /var/www/project-agents-template
git log -1 --oneline
```

### Sync Failing for a Project

**Check Actions logs:**
```bash
gh run view --log
```

Common issues:
- ❌ **Repository URL wrong** - Fix in projects.json
- ❌ **Branch doesn't exist** - Check branch name
- ❌ **No project-state/ directory** - Add to external repo
- ❌ **Missing files** - Ensure all 3 required files exist
- ❌ **Private repo** - See "Private Repository Access" below

### Private Repository Access

For private external repositories:

1. **Create Personal Access Token** (PAT)
   - GitHub → Settings → Developer settings → Personal access tokens
   - Scopes: `repo` (full control)

2. **Add as Secret**
   - agents_template → Settings → Secrets → Actions
   - Name: `EXTERNAL_REPO_TOKEN`
   - Value: Your PAT

3. **Update workflow** (.github/workflows/sync-projects.yml):
   ```yaml
   - name: Clone external repository
     run: |
       git clone --depth 1 --branch "$PROJECT_BRANCH" \
         "https://${{ secrets.EXTERNAL_REPO_TOKEN }}@github.com/user/repo.git" \
         "$TEMP_DIR"
   ```

## 📊 Monitoring

### Dashboard Health Check

Visit: `https://scrum.dotmkt.com.br`

- ✅ All projects visible in dropdown
- ✅ Can switch between projects
- ✅ Data loads without errors

### Sync Health Check

```bash
# Check last sync time
git log --grep="auto-sync" -1 --format="%h %ad %s" --date=relative

# Check how many projects are synced
ls project-state/projects/ | wc -l

# Compare with projects.json
cat project-state/projects.json | jq '.projects | length'
```

## 💡 Best Practices

### 1. Keep External Repos Clean
```
✅ DO: Use project-state/ directory
❌ DON'T: Mix project data with code
```

### 2. Consistent File Formats
```
✅ DO: Follow the JSON schemas
❌ DON'T: Add custom fields without updating dashboard
```

### 3. Regular Commits in External Repos
```
✅ DO: Commit sprint updates frequently
❌ DON'T: Wait weeks between commits
```

### 4. Monitor Sync Status
```
✅ DO: Check Actions tab regularly
❌ DON'T: Assume it's always working
```

### 5. Test Changes Locally
```bash
# Test projects.json syntax
jq '.' project-state/projects.json

# Test that all repos are accessible
for repo in $(cat project-state/projects.json | jq -r '.projects[].repository // empty'); do
    echo "Testing: $repo"
    git ls-remote "$repo" HEAD
done
```

## 🚀 Workflow Summary

### Developer Workflow (External Repo)

```bash
# 1. Work in your project repo
cd my-project
vim project-state/current-sprint.json

# 2. Commit and push
git add project-state/
git commit -m "update: sprint progress"
git push

# 3. Done! GitHub Actions syncs automatically
# Your changes appear on dashboard within 15-20 minutes
```

### Dashboard Admin Workflow (agents_template)

```bash
# 1. Add new project
cd agents_template
bash scripts/add-project.sh

# 2. Push changes
git push

# 3. Done! Project appears in dashboard automatically
```

## 🎯 Result

**Zero manual intervention** needed after initial setup:

1. ✅ Developers work in their repos
2. ✅ GitHub Actions syncs automatically
3. ✅ Dashboard updates automatically
4. ✅ Everyone sees latest data

**Single source of truth** for all projects at `scrum.dotmkt.com.br`!

---

**Questions?** Check the main [MULTI-PROJECT-GUIDE.md](./MULTI-PROJECT-GUIDE.md) or [NEW-PROJECT-SETUP.md](./NEW-PROJECT-SETUP.md).
