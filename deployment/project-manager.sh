#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Multi-Project Dashboard Manager${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Please run as root (use sudo)${NC}"
    exit 1
fi

# Menu
echo "What would you like to do?"
echo "1) Add a new project"
echo "2) List all projects"
echo "3) Remove a project"
echo "4) Update a project (manual pull)"
echo "5) View project status"
echo "6) Exit"
echo ""
read -p "Choose an option (1-6): " OPTION

case $OPTION in
    1)
        echo ""
        echo -e "${BLUE}=== Add New Project ===${NC}"
        echo ""

        read -p "Project name (e.g., 'alpha', 'myapp'): " PROJECT_NAME
        read -p "Subdomain (e.g., '$PROJECT_NAME.yourdomain.com'): " SUBDOMAIN
        read -p "Git repository URL: " REPO_URL
        read -p "Git branch [main]: " GIT_BRANCH
        GIT_BRANCH=${GIT_BRANCH:-main}
        read -p "Auto-pull interval in minutes [5]: " PULL_INTERVAL
        PULL_INTERVAL=${PULL_INTERVAL:-5}
        read -p "Setup SSL/HTTPS? (y/n) [y]: " SETUP_SSL
        SETUP_SSL=${SETUP_SSL:-y}

        INSTALL_PATH="/var/www/project-$PROJECT_NAME"

        echo ""
        echo -e "${YELLOW}Summary:${NC}"
        echo "  Project: $PROJECT_NAME"
        echo "  Subdomain: $SUBDOMAIN"
        echo "  Path: $INSTALL_PATH"
        echo "  Repository: $REPO_URL"
        echo "  Branch: $GIT_BRANCH"
        echo "  Auto-pull: Every $PULL_INTERVAL minute(s)"
        echo "  SSL: $SETUP_SSL"
        echo ""
        read -p "Continue? (y/n): " CONFIRM
        if [ "$CONFIRM" != "y" ]; then
            echo "Cancelled."
            exit 0
        fi

        echo ""
        echo -e "${GREEN}[1/6] Cloning repository...${NC}"

        if [ -d "$INSTALL_PATH" ]; then
            echo -e "${RED}Project already exists at $INSTALL_PATH${NC}"
            exit 1
        fi

        git clone -b "$GIT_BRANCH" "$REPO_URL" "$INSTALL_PATH"
        cd "$INSTALL_PATH"

        echo -e "${GREEN}✓ Repository cloned${NC}"

        echo ""
        echo -e "${GREEN}[2/6] Configuring nginx...${NC}"

        cat > "/etc/nginx/sites-available/$SUBDOMAIN" <<EOF
server {
    listen 80;
    listen [::]:80;
    server_name $SUBDOMAIN;

    root $INSTALL_PATH/project-state;
    index dashboard.html;

    # Enable gzip compression
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

    location / {
        try_files \$uri \$uri/ =404;
        add_header Access-Control-Allow-Origin *;
        add_header Access-Control-Allow-Methods "GET, OPTIONS";
        add_header Access-Control-Allow-Headers "Content-Type";
    }

    # Serve JSON files
    location ~* \\.json$ {
        add_header Content-Type application/json;
        add_header Cache-Control "no-cache, must-revalidate";
    }

    # Serve JSONL files
    location ~* \\.jsonl$ {
        add_header Content-Type application/x-ndjson;
        add_header Cache-Control "no-cache, must-revalidate";
    }

    # Cache static assets
    location ~* \\.(html|css|js|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1h;
        add_header Cache-Control "public, immutable";
    }

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    access_log /var/log/nginx/$SUBDOMAIN-access.log;
    error_log /var/log/nginx/$SUBDOMAIN-error.log;
}
EOF

        ln -sf "/etc/nginx/sites-available/$SUBDOMAIN" "/etc/nginx/sites-enabled/$SUBDOMAIN"
        nginx -t
        systemctl reload nginx

        echo -e "${GREEN}✓ Nginx configured${NC}"

        echo ""
        echo -e "${GREEN}[3/6] Setting up auto-pull...${NC}"

        cat > "$INSTALL_PATH/auto-pull.sh" <<'AUTOPULL'
#!/bin/bash
cd "$(dirname "$0")"
git fetch origin >/dev/null 2>&1
LOCAL=$(git rev-parse @)
REMOTE=$(git rev-parse @{u})

if [ $LOCAL != $REMOTE ]; then
    echo "[$(date)] Pulling updates..."
    git pull origin $(git rev-parse --abbrev-ref HEAD) >/dev/null 2>&1
    echo "[$(date)] Updated successfully"
fi
AUTOPULL

        chmod +x "$INSTALL_PATH/auto-pull.sh"

        # Create systemd service
        cat > "/etc/systemd/system/project-$PROJECT_NAME-autopull.service" <<EOF
[Unit]
Description=Project $PROJECT_NAME Auto-Pull
After=network.target

[Service]
Type=oneshot
ExecStart=$INSTALL_PATH/auto-pull.sh
WorkingDirectory=$INSTALL_PATH
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

        # Create systemd timer
        cat > "/etc/systemd/system/project-$PROJECT_NAME-autopull.timer" <<EOF
[Unit]
Description=Project $PROJECT_NAME Auto-Pull Timer

[Timer]
OnBootSec=1min
OnUnitActiveSec=${PULL_INTERVAL}min
AccuracySec=1s

[Install]
WantedBy=timers.target
EOF

        systemctl daemon-reload
        systemctl enable "project-$PROJECT_NAME-autopull.timer"
        systemctl start "project-$PROJECT_NAME-autopull.timer"

        echo -e "${GREEN}✓ Auto-pull configured${NC}"

        echo ""
        echo -e "${GREEN}[4/6] Setting permissions...${NC}"

        chown -R www-data:www-data "$INSTALL_PATH"
        chmod -R 755 "$INSTALL_PATH"

        echo -e "${GREEN}✓ Permissions set${NC}"

        echo ""
        echo -e "${GREEN}[5/6] Setting up SSL...${NC}"

        if [ "$SETUP_SSL" = "y" ]; then
            echo "Make sure DNS for $SUBDOMAIN points to this server!"
            read -p "Press Enter when ready, or Ctrl+C to skip..."
            certbot --nginx -d "$SUBDOMAIN" --non-interactive --agree-tos --register-unsafely-without-email || {
                echo -e "${YELLOW}SSL setup failed. Run manually: certbot --nginx -d $SUBDOMAIN${NC}"
            }
            echo -e "${GREEN}✓ SSL configured${NC}"
        else
            echo -e "${YELLOW}Skipped SSL setup${NC}"
        fi

        echo ""
        echo -e "${GREEN}[6/6] Saving project metadata...${NC}"

        mkdir -p /var/www/.project-manager
        cat >> /var/www/.project-manager/projects.json <<EOF
{
  "name": "$PROJECT_NAME",
  "subdomain": "$SUBDOMAIN",
  "path": "$INSTALL_PATH",
  "repo": "$REPO_URL",
  "branch": "$GIT_BRANCH",
  "created": "$(date -Iseconds)"
}
EOF

        echo -e "${GREEN}✓ Metadata saved${NC}"

        echo ""
        echo -e "${GREEN}========================================${NC}"
        echo -e "${GREEN}Project Added Successfully!${NC}"
        echo -e "${GREEN}========================================${NC}"
        echo ""
        echo -e "Dashboard URL: ${BLUE}http://$SUBDOMAIN${NC}"
        if [ "$SETUP_SSL" = "y" ]; then
            echo -e "            or ${BLUE}https://$SUBDOMAIN${NC}"
        fi
        echo ""
        echo "Useful commands:"
        echo "  systemctl status project-$PROJECT_NAME-autopull.timer"
        echo "  journalctl -u project-$PROJECT_NAME-autopull.service -f"
        echo "  tail -f /var/log/nginx/$SUBDOMAIN-access.log"
        echo ""
        ;;

    2)
        echo ""
        echo -e "${BLUE}=== Active Projects ===${NC}"
        echo ""

        if [ ! -d /var/www/.project-manager ]; then
            echo "No projects found."
            exit 0
        fi

        COUNT=0
        for PROJECT_DIR in /var/www/project-*; do
            if [ -d "$PROJECT_DIR" ]; then
                PROJECT_NAME=$(basename "$PROJECT_DIR" | sed 's/^project-//')
                TIMER_STATUS=$(systemctl is-active "project-$PROJECT_NAME-autopull.timer" 2>/dev/null || echo "inactive")

                echo -e "${GREEN}Project:${NC} $PROJECT_NAME"
                echo -e "  Path: $PROJECT_DIR"
                echo -e "  Auto-pull: $TIMER_STATUS"

                if [ -f "$PROJECT_DIR/.git/config" ]; then
                    REPO=$(git -C "$PROJECT_DIR" remote get-url origin 2>/dev/null || echo "unknown")
                    BRANCH=$(git -C "$PROJECT_DIR" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
                    echo -e "  Repository: $REPO"
                    echo -e "  Branch: $BRANCH"
                fi

                echo ""
                COUNT=$((COUNT + 1))
            fi
        done

        echo -e "Total projects: ${GREEN}$COUNT${NC}"
        echo ""
        ;;

    3)
        echo ""
        echo -e "${RED}=== Remove Project ===${NC}"
        echo ""

        read -p "Project name to remove: " PROJECT_NAME
        INSTALL_PATH="/var/www/project-$PROJECT_NAME"

        if [ ! -d "$INSTALL_PATH" ]; then
            echo -e "${RED}Project not found: $PROJECT_NAME${NC}"
            exit 1
        fi

        echo -e "${YELLOW}WARNING: This will remove:${NC}"
        echo "  - Project files: $INSTALL_PATH"
        echo "  - Nginx configuration"
        echo "  - Auto-pull timer"
        echo "  - SSL certificate (if any)"
        echo ""
        read -p "Are you sure? Type 'yes' to confirm: " CONFIRM

        if [ "$CONFIRM" != "yes" ]; then
            echo "Cancelled."
            exit 0
        fi

        echo ""
        echo "Removing project $PROJECT_NAME..."

        # Stop and remove services
        systemctl stop "project-$PROJECT_NAME-autopull.timer" 2>/dev/null || true
        systemctl disable "project-$PROJECT_NAME-autopull.timer" 2>/dev/null || true
        rm -f "/etc/systemd/system/project-$PROJECT_NAME-autopull.timer"
        rm -f "/etc/systemd/system/project-$PROJECT_NAME-autopull.service"
        systemctl daemon-reload

        # Find and remove nginx config
        for CONF in /etc/nginx/sites-enabled/*; do
            if grep -q "$INSTALL_PATH" "$CONF" 2>/dev/null; then
                CONF_NAME=$(basename "$CONF")
                rm -f "/etc/nginx/sites-enabled/$CONF_NAME"
                rm -f "/etc/nginx/sites-available/$CONF_NAME"
                echo "  Removed nginx config: $CONF_NAME"
            fi
        done

        nginx -t && systemctl reload nginx

        # Remove files
        rm -rf "$INSTALL_PATH"

        echo ""
        echo -e "${GREEN}Project removed successfully${NC}"
        echo ""
        ;;

    4)
        echo ""
        echo -e "${BLUE}=== Update Project ===${NC}"
        echo ""

        read -p "Project name to update: " PROJECT_NAME
        INSTALL_PATH="/var/www/project-$PROJECT_NAME"

        if [ ! -d "$INSTALL_PATH" ]; then
            echo -e "${RED}Project not found: $PROJECT_NAME${NC}"
            exit 1
        fi

        echo "Pulling latest changes..."
        cd "$INSTALL_PATH"
        git fetch origin
        git pull origin "$(git rev-parse --abbrev-ref HEAD)"

        echo ""
        echo -e "${GREEN}✓ Project updated${NC}"
        echo ""
        ;;

    5)
        echo ""
        echo -e "${BLUE}=== Project Status ===${NC}"
        echo ""

        read -p "Project name: " PROJECT_NAME
        INSTALL_PATH="/var/www/project-$PROJECT_NAME"

        if [ ! -d "$INSTALL_PATH" ]; then
            echo -e "${RED}Project not found: $PROJECT_NAME${NC}"
            exit 1
        fi

        echo -e "${GREEN}Project:${NC} $PROJECT_NAME"
        echo -e "${GREEN}Path:${NC} $INSTALL_PATH"
        echo ""

        echo -e "${YELLOW}Git Status:${NC}"
        cd "$INSTALL_PATH"
        git status
        echo ""

        echo -e "${YELLOW}Recent Commits:${NC}"
        git log --oneline -5
        echo ""

        echo -e "${YELLOW}Auto-Pull Timer:${NC}"
        systemctl status "project-$PROJECT_NAME-autopull.timer" --no-pager
        echo ""

        echo -e "${YELLOW}Recent Auto-Pull Logs:${NC}"
        journalctl -u "project-$PROJECT_NAME-autopull.service" --no-pager -n 10
        echo ""
        ;;

    6)
        echo "Goodbye!"
        exit 0
        ;;

    *)
        echo -e "${RED}Invalid option${NC}"
        exit 1
        ;;
esac
