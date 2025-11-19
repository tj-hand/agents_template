#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Project State Dashboard - Auto-Deploy Setup${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Please run as root (use sudo)${NC}"
    exit 1
fi

# Configuration
echo -e "${YELLOW}Configuration:${NC}"
read -p "Enter your subdomain (e.g., dashboard.yourdomain.com): " SUBDOMAIN
read -p "Enter installation path [/var/www/project-state]: " INSTALL_PATH
INSTALL_PATH=${INSTALL_PATH:-/var/www/project-state}

read -p "Enter git repository URL: " REPO_URL
read -p "Enter git branch [main]: " GIT_BRANCH
GIT_BRANCH=${GIT_BRANCH:-main}

read -p "Do you want to set up SSL/HTTPS with Let's Encrypt? (y/n) [y]: " SETUP_SSL
SETUP_SSL=${SETUP_SSL:-y}

read -p "Auto-pull interval in minutes [5]: " PULL_INTERVAL
PULL_INTERVAL=${PULL_INTERVAL:-5}

echo ""
echo -e "${GREEN}Summary:${NC}"
echo "  Subdomain: $SUBDOMAIN"
echo "  Install Path: $INSTALL_PATH"
echo "  Repository: $REPO_URL"
echo "  Branch: $GIT_BRANCH"
echo "  SSL: $SETUP_SSL"
echo "  Auto-pull: Every $PULL_INTERVAL minute(s)"
echo ""
read -p "Continue with installation? (y/n): " CONFIRM
if [ "$CONFIRM" != "y" ]; then
    echo "Installation cancelled."
    exit 0
fi

echo ""
echo -e "${GREEN}[1/7] Checking prerequisites...${NC}"

# Check for required tools
command -v git >/dev/null 2>&1 || { echo -e "${RED}git is required but not installed. Installing...${NC}"; apt-get update && apt-get install -y git; }
command -v nginx >/dev/null 2>&1 || { echo -e "${RED}nginx is required but not installed. Installing...${NC}"; apt-get update && apt-get install -y nginx; }

if [ "$SETUP_SSL" = "y" ]; then
    command -v certbot >/dev/null 2>&1 || { echo -e "${YELLOW}certbot not found. Installing...${NC}"; apt-get update && apt-get install -y certbot python3-certbot-nginx; }
fi

echo -e "${GREEN}✓ Prerequisites checked${NC}"

echo ""
echo -e "${GREEN}[2/7] Setting up repository...${NC}"

# Create parent directory if needed
mkdir -p "$(dirname "$INSTALL_PATH")"

# Clone or update repository
if [ -d "$INSTALL_PATH/.git" ]; then
    echo "Repository already exists, updating..."
    cd "$INSTALL_PATH"
    git fetch origin
    git checkout "$GIT_BRANCH"
    git pull origin "$GIT_BRANCH"
else
    echo "Cloning repository..."
    git clone -b "$GIT_BRANCH" "$REPO_URL" "$INSTALL_PATH"
    cd "$INSTALL_PATH"
fi

echo -e "${GREEN}✓ Repository ready at $INSTALL_PATH${NC}"

echo ""
echo -e "${GREEN}[3/7] Configuring nginx...${NC}"

# Create nginx configuration
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

        # CORS headers (if needed for API calls)
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

    # Logging
    access_log /var/log/nginx/$SUBDOMAIN-access.log;
    error_log /var/log/nginx/$SUBDOMAIN-error.log;
}
EOF

# Enable site
ln -sf "/etc/nginx/sites-available/$SUBDOMAIN" "/etc/nginx/sites-enabled/$SUBDOMAIN"

# Test nginx configuration
nginx -t

# Reload nginx
systemctl reload nginx

echo -e "${GREEN}✓ Nginx configured and reloaded${NC}"

echo ""
echo -e "${GREEN}[4/7] Setting up auto-pull mechanism...${NC}"

# Create auto-pull script
cat > "$INSTALL_PATH/auto-pull.sh" <<'AUTOPULL'
#!/bin/bash
cd "$(dirname "$0")"
git fetch origin >/dev/null 2>&1
LOCAL=$(git rev-parse @)
REMOTE=$(git rev-parse @{u})

if [ $LOCAL != $REMOTE ]; then
    echo "[$(date)] Pulling updates..."
    git pull origin $(git rev-parse --abbrev-ref HEAD) >/dev/null 2>&1
    echo "[$(date)] Dashboard updated"
fi
AUTOPULL

chmod +x "$INSTALL_PATH/auto-pull.sh"

# Create systemd service for auto-pull
cat > "/etc/systemd/system/project-state-autopull.service" <<EOF
[Unit]
Description=Project State Dashboard Auto-Pull
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
cat > "/etc/systemd/system/project-state-autopull.timer" <<EOF
[Unit]
Description=Project State Dashboard Auto-Pull Timer

[Timer]
OnBootSec=1min
OnUnitActiveSec=${PULL_INTERVAL}min
AccuracySec=1s

[Install]
WantedBy=timers.target
EOF

# Enable and start timer
systemctl daemon-reload
systemctl enable project-state-autopull.timer
systemctl start project-state-autopull.timer

echo -e "${GREEN}✓ Auto-pull configured (every ${PULL_INTERVAL} minute)${NC}"

echo ""
echo -e "${GREEN}[5/7] Setting up SSL/HTTPS...${NC}"

if [ "$SETUP_SSL" = "y" ]; then
    echo "Obtaining SSL certificate from Let's Encrypt..."
    echo "Make sure your DNS is configured to point $SUBDOMAIN to this server!"
    read -p "Press Enter when DNS is ready, or Ctrl+C to skip SSL setup..."

    certbot --nginx -d "$SUBDOMAIN" --non-interactive --agree-tos --register-unsafely-without-email || {
        echo -e "${YELLOW}SSL setup failed. You can run it manually later with:${NC}"
        echo "  certbot --nginx -d $SUBDOMAIN"
    }
    echo -e "${GREEN}✓ SSL configured${NC}"
else
    echo -e "${YELLOW}Skipping SSL setup. You can set it up later with:${NC}"
    echo "  certbot --nginx -d $SUBDOMAIN"
fi

echo ""
echo -e "${GREEN}[6/7] Setting correct permissions...${NC}"

chown -R www-data:www-data "$INSTALL_PATH"
chmod -R 755 "$INSTALL_PATH"

echo -e "${GREEN}✓ Permissions set${NC}"

echo ""
echo -e "${GREEN}[7/7] Testing deployment...${NC}"

# Check if dashboard.html exists
if [ -f "$INSTALL_PATH/project-state/dashboard.html" ]; then
    echo -e "${GREEN}✓ Dashboard file found${NC}"
else
    echo -e "${RED}✗ dashboard.html not found at $INSTALL_PATH/project-state/${NC}"
fi

# Check nginx status
if systemctl is-active --quiet nginx; then
    echo -e "${GREEN}✓ Nginx is running${NC}"
else
    echo -e "${RED}✗ Nginx is not running${NC}"
fi

# Check auto-pull timer
if systemctl is-active --quiet project-state-autopull.timer; then
    echo -e "${GREEN}✓ Auto-pull timer is active${NC}"
else
    echo -e "${RED}✗ Auto-pull timer is not active${NC}"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Installation Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "Your dashboard is accessible at:"
if [ "$SETUP_SSL" = "y" ]; then
    echo -e "${GREEN}  https://$SUBDOMAIN${NC}"
else
    echo -e "${GREEN}  http://$SUBDOMAIN${NC}"
fi
echo ""
echo "Auto-pull status:"
echo "  systemctl status project-state-autopull.timer"
echo ""
echo "View auto-pull logs:"
echo "  journalctl -u project-state-autopull.service -f"
echo ""
echo "Manual pull:"
echo "  cd $INSTALL_PATH && git pull"
echo ""
echo "Nginx logs:"
echo "  tail -f /var/log/nginx/$SUBDOMAIN-access.log"
echo "  tail -f /var/log/nginx/$SUBDOMAIN-error.log"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Ensure DNS for $SUBDOMAIN points to this server"
if [ "$SETUP_SSL" != "y" ]; then
    echo "2. Set up SSL: certbot --nginx -d $SUBDOMAIN"
fi
echo ""
