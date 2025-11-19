# Projects Directory

This directory contains data for all projects managed by the multi-project dashboard.

## Structure

```
projects/
├── project-alpha/
│   ├── current-sprint.json
│   ├── project.json
│   └── task-log.jsonl
├── project-beta/
│   ├── current-sprint.json
│   ├── project.json
│   └── task-log.jsonl
└── README.md (this file)
```

## Adding a New Project

### Step 1: Create Project Folder

```bash
mkdir -p project-state/projects/your-project-name
```

### Step 2: Add Project Files

Create these three files in your project folder:

**current-sprint.json** - Current sprint data
```json
{
  "sprint": 1,
  "start_date": "2025-11-19",
  "end_date": "2025-12-02",
  "goal": "Your sprint goal",
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
```

**project.json** - Project metadata
```json
{
  "project_name": "Your Project Name",
  "description": "Project description",
  "tech_stack": {},
  "team": [],
  "roadmap": [],
  "okrs": {},
  "metadata": {
    "current_sprint": 1,
    "total_sprints_completed": 0
  }
}
```

**task-log.jsonl** - Task activity log (can be empty initially)
```
```

### Step 3: Register Project

Edit `project-state/projects.json` and add your project:

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
      "id": "your-project-name",
      "name": "Your Project Display Name",
      "description": "Brief description",
      "color": "#10b981"
    }
  ],
  "default": "agents-template"
}
```

### Step 4: Commit and Push

```bash
git add project-state/projects/
git commit -m "feat: add new project - your-project-name"
git push
```

The dashboard will automatically detect the new project within 1 minute!

## Project ID Guidelines

- Use lowercase with hyphens: `my-project-name`
- Keep it short and memorable
- No spaces or special characters
- Should match the folder name

## Colors

Suggested color codes for projects:
- Blue: `#3b82f6`
- Green: `#10b981`
- Purple: `#8b5cf6`
- Orange: `#f59e0b`
- Red: `#ef4444`
- Pink: `#ec4899`

## Managing Multiple Projects

The dashboard dropdown automatically shows all projects defined in `projects.json`. Users can switch between projects, and the selection is saved in their browser's localStorage.

## Auto-Deployment

When you commit changes to any project's JSON files, the server will auto-pull the updates within 1 minute. Users can also click the "🔄 Atualizar" button to fetch the latest data immediately.
