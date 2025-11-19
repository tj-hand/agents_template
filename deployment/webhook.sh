#!/bin/bash
# Webhook endpoint to trigger git pull for a project
# Usage: Call this from nginx or as a systemd service

set -e

# Configuration
WEBHOOK_SECRET="${WEBHOOK_SECRET:-change-this-secret}"
LOG_FILE="/var/log/project-webhook.log"

# Function to log messages
log_message() {
    echo "[$(date -Iseconds)] $1" >> "$LOG_FILE"
}

# Get project name from URL parameter or environment
PROJECT_NAME="${1:-$QUERY_STRING}"
PROJECT_NAME=$(echo "$PROJECT_NAME" | sed 's/project=//')

# Validate project name (security)
if [[ ! "$PROJECT_NAME" =~ ^[a-z0-9-]+$ ]]; then
    log_message "ERROR: Invalid project name: $PROJECT_NAME"
    echo "Status: 400 Bad Request"
    echo "Content-Type: text/plain"
    echo ""
    echo "Invalid project name"
    exit 1
fi

PROJECT_PATH="/var/www/project-$PROJECT_NAME"

# Check if project exists
if [ ! -d "$PROJECT_PATH" ]; then
    log_message "ERROR: Project not found: $PROJECT_NAME"
    echo "Status: 404 Not Found"
    echo "Content-Type: text/plain"
    echo ""
    echo "Project not found"
    exit 1
fi

# Verify webhook secret from header or query param
RECEIVED_SECRET="${HTTP_X_WEBHOOK_SECRET:-${2}}"

if [ "$RECEIVED_SECRET" != "$WEBHOOK_SECRET" ]; then
    log_message "ERROR: Invalid webhook secret for project: $PROJECT_NAME"
    echo "Status: 401 Unauthorized"
    echo "Content-Type: text/plain"
    echo ""
    echo "Unauthorized"
    exit 1
fi

# Pull latest changes
log_message "INFO: Triggering update for project: $PROJECT_NAME"

cd "$PROJECT_PATH"
BEFORE_COMMIT=$(git rev-parse HEAD)

git fetch origin > /dev/null 2>&1
git pull origin "$(git rev-parse --abbrev-ref HEAD)" > /dev/null 2>&1

AFTER_COMMIT=$(git rev-parse HEAD)

if [ "$BEFORE_COMMIT" != "$AFTER_COMMIT" ]; then
    log_message "SUCCESS: Updated project $PROJECT_NAME from $BEFORE_COMMIT to $AFTER_COMMIT"
    MESSAGE="Updated successfully"
else
    log_message "INFO: Project $PROJECT_NAME already up to date"
    MESSAGE="Already up to date"
fi

# Return success response
echo "Status: 200 OK"
echo "Content-Type: application/json"
echo ""
echo "{\"status\":\"success\",\"message\":\"$MESSAGE\",\"project\":\"$PROJECT_NAME\",\"commit\":\"$AFTER_COMMIT\"}"

exit 0
