# 🎯 Local Scrum System

Git-based Scrum board management system for Claude.md orchestrator workflow.

## 📊 How to View the Scrum Board

### Option 1: Terminal View (Quick)
```bash
python3 .scrum/scrum_cli.py board
```
ASCII board in your terminal - fast and simple.

### Option 2: Static HTML on GitHub ⭐ (Best for Remote)
```bash
python3 .scrum/generate_static.py
# Commit and push the updated dashboard-static.html
```
Then view directly on GitHub (no cloning needed!):
- **GitHub HTML preview:** Click on `dashboard-static.html` in GitHub
- **Raw view:** https://github.com/tj-hand/agents_template/blob/main/.scrum/dashboard-static.html

**Perfect for viewing from anywhere without cloning the repo!**

### Option 3: Local HTML Dashboard (Best Visual, Requires Clone)
```bash
# First clone the repo
git clone https://github.com/tj-hand/agents_template.git
cd agents_template/.scrum
python3 -m http.server 8000
```
Then open: http://localhost:8000/dashboard.html

Interactive, beautiful, auto-refreshing dashboard!

### Option 4: Markdown Report
```bash
python3 .scrum/scrum_cli.py markdown
```
Generates markdown report + saves to `.scrum/reports/`

### Quick Script (All-in-one)
```bash
.scrum/view_board.sh             # Terminal view (default)
.scrum/view_board.sh static      # Generate static HTML for GitHub ⭐
.scrum/view_board.sh html        # Start local web server
.scrum/view_board.sh markdown    # Generate markdown report
.scrum/view_board.sh list        # List all issues
```

---

## 🛠️ CLI Commands

### Create Issue
```bash
python3 .scrum/scrum_cli.py create \
  "Issue title" \
  "Agent-Name" \
  "label1,label2"
```

### Update Issue Status
```bash
python3 .scrum/scrum_cli.py status <issue_id> <new_status>
```
Status: `backlog`, `todo`, `in_progress`, `review`, `done`

### Show Issue Details
```bash
python3 .scrum/scrum_cli.py show <issue_id>
```

### List Issues
```bash
python3 .scrum/scrum_cli.py list              # All issues
python3 .scrum/scrum_cli.py list backlog      # Filter by status
```

---

## 📁 Structure

```
.scrum/
├── config.json           # Project config, next issue ID
├── board.json            # Current board state
├── issues/
│   ├── 001.json         # Issue #1
│   ├── 002.json         # Issue #2
│   └── ...
├── sprints/             # Sprint metadata (future)
├── reports/             # Generated markdown reports
├── scrum_cli.py         # CLI tool
├── dashboard.html       # Interactive web dashboard
├── view_board.sh        # Quick view script
└── README.md            # This file
```

---

## 🔄 Claude.md Integration

### PM Agent → Git Agent Flow

**PM Agent classifies and breaks down:**
```
User: "Add user login"
PM: FEATURE → 4 issues needed
```

**PM Agent delegates to Git Agent:**
```
"Git Agent: create issue 'Create users table'
           assigned:Database-Agent
           label:feature,database"
```

**Git Agent executes (automated):**
```bash
python3 .scrum/scrum_cli.py create \
  "Create users table" \
  "Database-Agent" \
  "feature,database"
```

**Result:**
- ✅ Issue created with auto-ID
- ✅ Added to backlog
- ✅ Visible on board
- ✅ Ready for development

### Full Workflow

1. **Backlog** - PM Agent creates issues
2. **In Progress** - Git Agent creates branch, Dev Agent implements
3. **Review** - Git Agent creates PR, QA Agent reviews
4. **Done** - Git Agent merges, closes issue

---

## 📈 Benefits

- ✅ **100% Automated** - I manage everything
- ✅ **Visual Scrum** - See progress at a glance
- ✅ **Git History** - Full audit trail
- ✅ **No GitHub API** - Works offline
- ✅ **Issue Tracking** - #N references in commits
- ✅ **Sprint Ready** - Add sprints when needed

---

## 🚀 Quick Start

1. **View current board:**
   ```bash
   python3 .scrum/scrum_cli.py board
   ```

2. **Open web dashboard:**
   ```bash
   cd .scrum && python3 -m http.server 8000
   # Open http://localhost:8000/dashboard.html
   ```

3. **Create an issue:**
   ```bash
   python3 .scrum/scrum_cli.py create \
     "My new feature" \
     "FastAPI-Agent" \
     "feature"
   ```

4. **Update issue status:**
   ```bash
   python3 .scrum/scrum_cli.py status 1 in_progress
   ```

---

**Enjoy your visual Scrum board!** 🎉
