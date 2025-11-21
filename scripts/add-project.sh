#!/bin/bash

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}=== Add New Project to Dashboard ===${NC}"
echo ""

# Get project details
read -p "Project ID (lowercase-hyphens, e.g., 'nginx-api-gateway'): " PROJECT_ID

# Validate project ID
if [[ ! "$PROJECT_ID" =~ ^[a-z0-9-]+$ ]]; then
    echo -e "${RED}✗ Invalid project ID!${NC}"
    echo "  Rules: lowercase letters, numbers, and hyphens only"
    exit 1
fi

read -p "Project Name (display name, e.g., 'Nginx API Gateway'): " PROJECT_NAME
read -p "Project Description: " PROJECT_DESC
read -p "GitHub Repository URL (leave empty if local): " PROJECT_REPO
read -p "Branch [main]: " PROJECT_BRANCH
PROJECT_BRANCH=${PROJECT_BRANCH:-main}
read -p "Color (hex, e.g., '#3b82f6'): " PROJECT_COLOR
PROJECT_COLOR=${PROJECT_COLOR:-#3b82f6}

echo ""
echo -e "${YELLOW}Summary:${NC}"
echo "  ID: $PROJECT_ID"
echo "  Name: $PROJECT_NAME"
echo "  Description: $PROJECT_DESC"
echo "  Repository: ${PROJECT_REPO:-[Local Project]}"
echo "  Branch: $PROJECT_BRANCH"
echo "  Color: $PROJECT_COLOR"
echo ""
read -p "Continue? (y/n): " CONFIRM

if [ "$CONFIRM" != "y" ]; then
    echo "Cancelled."
    exit 0
fi

# Update projects.json
echo ""
echo -e "${BLUE}Updating projects.json...${NC}"

PROJECTS_FILE="project-state/projects.json"

# Create temporary JSON with new project
if [ -z "$PROJECT_REPO" ]; then
    # Local project (no repository)
    NEW_PROJECT=$(cat <<EOF
{
  "id": "$PROJECT_ID",
  "name": "$PROJECT_NAME",
  "description": "$PROJECT_DESC",
  "color": "$PROJECT_COLOR"
}
EOF
)
else
    # External repository project
    NEW_PROJECT=$(cat <<EOF
{
  "id": "$PROJECT_ID",
  "name": "$PROJECT_NAME",
  "description": "$PROJECT_DESC",
  "color": "$PROJECT_COLOR",
  "repository": "$PROJECT_REPO",
  "branch": "$PROJECT_BRANCH"
}
EOF
)
fi

# Add project to projects.json using jq
jq --argjson newProject "$NEW_PROJECT" '.projects += [$newProject]' "$PROJECTS_FILE" > "$PROJECTS_FILE.tmp"
mv "$PROJECTS_FILE.tmp" "$PROJECTS_FILE"

echo -e "${GREEN}✓ Added to projects.json${NC}"

# Create project directory
PROJECT_DIR="project-state/projects/$PROJECT_ID"
mkdir -p "$PROJECT_DIR"

echo -e "${GREEN}✓ Created directory: $PROJECT_DIR${NC}"

# Create initial files if local project
if [ -z "$PROJECT_REPO" ]; then
    echo ""
    echo -e "${BLUE}Creating initial project files...${NC}"

    # Create project.json
    cat > "$PROJECT_DIR/project.json" <<EOF
{
  "name": "$PROJECT_NAME",
  "description": "$PROJECT_DESC",
  "team": [],
  "tech_stack": [],
  "roadmap": []
}
EOF

    # Create current-sprint.json
    cat > "$PROJECT_DIR/current-sprint.json" <<EOF
{
  "current_sprint": {
    "number": 1,
    "objective": "Initial setup",
    "start_date": "$(date +%Y-%m-%d)",
    "end_date": "$(date -d '+14 days' +%Y-%m-%d)",
    "tasks": []
  }
}
EOF

    # Create empty task-log.jsonl
    touch "$PROJECT_DIR/task-log.jsonl"

    echo -e "${GREEN}✓ Created initial project files${NC}"
else
    echo ""
    echo -e "${YELLOW}External repository project${NC}"
    echo "  Files will be synced automatically from: $PROJECT_REPO"
    echo "  GitHub Actions will sync within 15 minutes"
    echo "  Or trigger manually: gh workflow run sync-projects.yml"
fi

echo ""
echo -e "${GREEN}=== Project Added Successfully! ===${NC}"
echo ""
echo "Next steps:"
if [ -z "$PROJECT_REPO" ]; then
    echo "  1. Edit files in $PROJECT_DIR/"
    echo "  2. Commit and push changes"
else
    echo "  1. Ensure your external repo has project-state/ directory with:"
    echo "     - current-sprint.json"
    echo "     - project.json"
    echo "     - task-log.jsonl"
    echo "  2. GitHub Actions will sync automatically every 15 minutes"
    echo "  3. Or trigger sync manually: gh workflow run sync-projects.yml"
fi
echo "  3. Dashboard will show new project in dropdown"
echo ""
