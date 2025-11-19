# Architecture Overview

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        GitHub Repositories                       │
├─────────────────────────────────────────────────────────────────┤
│  agents_template    │  project-alpha   │  project-beta   │ ...  │
│  (this template)    │  (your project)  │  (your project) │      │
└──────────┬───────────┴────────┬─────────┴────────┬──────────────┘
           │                    │                   │
           │ git push           │ git push          │ git push
           │ (by Claude)        │ (by Claude)       │ (by Claude)
           ▼                    ▼                   ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Ubuntu Server (216.238.99.183)               │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌────────────────┐  ┌────────────────┐  ┌────────────────┐   │
│  │ Project Alpha  │  │ Project Beta   │  │ Project Gamma  │   │
│  ├────────────────┤  ├────────────────┤  ├────────────────┤   │
│  │ Git Auto-Pull  │  │ Git Auto-Pull  │  │ Git Auto-Pull  │   │
│  │ (every 1 min)  │  │ (every 1 min)  │  │ (every 1 min)  │   │
│  ├────────────────┤  ├────────────────┤  ├────────────────┤   │
│  │ project-state/ │  │ project-state/ │  │ project-state/ │   │
│  │ agents/        │  │ agents/        │  │ agents/        │   │
│  │ src/           │  │ src/           │  │ src/           │   │
│  └───────┬────────┘  └───────┬────────┘  └───────┬────────┘   │
│          │                   │                   │              │
│          └───────────────────┴───────────────────┘              │
│                              │                                  │
│                     ┌────────▼────────┐                         │
│                     │   Nginx Server   │                        │
│                     │   (Reverse Proxy) │                       │
│                     └────────┬────────┘                         │
│                              │                                  │
└──────────────────────────────┼──────────────────────────────────┘
                               │
            ┌──────────────────┼──────────────────┐
            │                  │                  │
            ▼                  ▼                  ▼
    alpha.domain.com    beta.domain.com    gamma.domain.com
         (HTTPS)            (HTTPS)            (HTTPS)
            │                  │                  │
            └──────────────────┴──────────────────┘
                               │
                               ▼
                         Public Users
```

## 🔄 Deployment Flow

```
Developer (You + Claude)
         │
         │ 1. Request changes
         ▼
    Claude Code
         │
         │ 2. Make changes
         │ 3. Commit to git
         │ 4. Push to GitHub
         ▼
    GitHub Repository
         │
         │ 5. Auto-pull (systemd timer)
         │    Runs every 1 minute
         ▼
    Ubuntu Server
         │
         │ 6. Update local files
         ▼
    Nginx Web Server
         │
         │ 7. Serve updated content
         ▼
    Public URL (HTTPS)
         │
         │ 8. View changes
         ▼
    You (Browser)
```

## 📁 File Structure on Server

```
/var/www/
│
├── project-alpha/                    ← Project 1
│   ├── .git/                         ← Git repository
│   ├── project-state/                ← Dashboard files
│   │   ├── dashboard.html            ← Served at alpha.domain.com
│   │   ├── current-sprint.json
│   │   ├── project.json
│   │   └── task-log.jsonl
│   ├── agents/                       ← AI agent definitions
│   │   ├── devops-agent.md
│   │   ├── fastapi-agent.md
│   │   └── ...
│   ├── deployment/                   ← Deployment scripts
│   ├── src/                          ← Your application code
│   └── auto-pull.sh                  ← Auto-update script
│
├── project-beta/                     ← Project 2
│   ├── .git/
│   ├── project-state/
│   ├── agents/
│   └── ...
│
├── project-gamma/                    ← Project 3
│   └── ...
│
└── .project-manager/                 ← Metadata
    └── projects.json

/etc/nginx/
├── sites-available/
│   ├── alpha.domain.com              ← Nginx configs
│   ├── beta.domain.com
│   └── gamma.domain.com
└── sites-enabled/                    ← Symlinks to above
    ├── alpha.domain.com -> ../sites-available/alpha.domain.com
    ├── beta.domain.com -> ../sites-available/beta.domain.com
    └── gamma.domain.com -> ../sites-available/gamma.domain.com

/etc/systemd/system/
├── project-alpha-autopull.service    ← Systemd services
├── project-alpha-autopull.timer
├── project-beta-autopull.service
├── project-beta-autopull.timer
├── project-gamma-autopull.service
└── project-gamma-autopull.timer
```

## 🔐 Security Layers

```
Internet
    │
    ▼
┌─────────────────┐
│ Cloudflare/DNS  │  ← Layer 1: DNS (optional)
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Firewall/UFW   │  ← Layer 2: Network firewall
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Nginx + SSL    │  ← Layer 3: HTTPS encryption
│  (Let's Encrypt)│
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Basic Auth     │  ← Layer 4: Password protection (optional)
│  (htpasswd)     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Dashboard      │  ← Layer 5: Static files (no code execution)
│  (HTML/JS/JSON) │
└─────────────────┘
```

## 🎯 Component Responsibilities

### GitHub
- **Store** source code
- **Version control** and history
- **Trigger point** for deployments (via git push)

### Ubuntu Server
- **Host** all projects
- **Auto-pull** from GitHub every minute
- **Run** nginx web server
- **Manage** SSL certificates
- **Log** all activity

### Nginx
- **Serve** static files (dashboards)
- **Handle** HTTPS/SSL
- **Route** subdomains to projects
- **Provide** security headers
- **Log** access and errors

### Systemd
- **Schedule** auto-pull timers
- **Ensure** services restart on failure
- **Manage** service lifecycle
- **Provide** logging via journalctl

### Project Manager Script
- **Add** new projects
- **Remove** old projects
- **List** all projects
- **Monitor** project status

## 🔄 Auto-Pull Mechanism

```
┌────────────────────────────────────────────┐
│  Systemd Timer (every 1 minute)            │
└───────────────┬────────────────────────────┘
                │
                │ triggers
                ▼
┌────────────────────────────────────────────┐
│  Systemd Service                           │
│  (project-alpha-autopull.service)          │
└───────────────┬────────────────────────────┘
                │
                │ executes
                ▼
┌────────────────────────────────────────────┐
│  auto-pull.sh script                       │
├────────────────────────────────────────────┤
│  1. git fetch origin                       │
│  2. Compare local vs remote hash           │
│  3. If different:                          │
│     - git pull origin main                 │
│     - Log update                           │
│  4. If same: exit silently                 │
└───────────────┬────────────────────────────┘
                │
                │ updates
                ▼
┌────────────────────────────────────────────┐
│  Project Files                             │
│  (including dashboard.html)                │
└───────────────┬────────────────────────────┘
                │
                │ served by
                ▼
┌────────────────────────────────────────────┐
│  Nginx (no reload needed)                  │
└────────────────────────────────────────────┘
```

## 📊 Data Flow

### User Requests Dashboard

```
User Browser
    │
    │ HTTPS GET https://alpha.domain.com
    ▼
Nginx Server
    │
    │ Read file: /var/www/project-alpha/project-state/dashboard.html
    ▼
Dashboard HTML
    │
    │ JavaScript loads JSON files via fetch()
    ▼
Nginx Server
    │
    │ Serve: current-sprint.json, project.json, task-log.jsonl
    ▼
User Browser
    │
    │ Render dashboard with data
    ▼
User sees dashboard
```

### Claude Updates Project

```
Claude Code
    │
    │ Edit: project-state/current-sprint.json
    │ (add new task)
    ▼
Git Commit
    │
    │ git commit -m "feat: add new task"
    ▼
Git Push
    │
    │ git push origin main
    ▼
GitHub Repository
    │
    │ (waits up to 1 minute)
    ▼
Systemd Timer Triggers
    │
    │ Execute: auto-pull.sh
    ▼
Server Pulls Update
    │
    │ git pull origin main
    │ Updated: current-sprint.json
    ▼
User Refreshes Browser
    │
    │ Fetch updated current-sprint.json
    ▼
User sees new task
```

## 🎨 Customization Points

### 1. Auto-Pull Interval
**File:** `/etc/systemd/system/project-alpha-autopull.timer`
**Change:** `OnUnitActiveSec=1min` → `OnUnitActiveSec=30s`

### 2. Nginx Configuration
**File:** `/etc/nginx/sites-available/alpha.domain.com`
**Customize:** Headers, caching, redirects, auth

### 3. SSL Certificate
**Managed by:** Let's Encrypt (certbot)
**Auto-renewal:** Yes (certbot renew via cron)

### 4. Project Location
**Default:** `/var/www/project-{name}`
**Customizable:** During setup or in project-manager.sh

### 5. Branch Selection
**Default:** `main`
**Customizable:** Any branch (e.g., `develop`, `staging`)

## 🔍 Monitoring Points

### System Level
```bash
# All timers
systemctl list-timers

# All nginx sites
ls -la /etc/nginx/sites-enabled/

# Disk usage
df -h
```

### Project Level
```bash
# Timer status
systemctl status project-alpha-autopull.timer

# Recent updates
journalctl -u project-alpha-autopull.service -n 20

# Git status
cd /var/www/project-alpha && git status
```

### Web Level
```bash
# Access logs
tail -f /var/log/nginx/alpha.domain.com-access.log

# Error logs
tail -f /var/log/nginx/alpha.domain.com-error.log

# SSL certificate
certbot certificates
```

## 💡 Scaling Strategies

### Horizontal Scaling
- Add more Ubuntu servers
- Use load balancer (nginx, HAProxy)
- Sync git repos across servers

### Vertical Scaling
- Increase server resources (CPU, RAM)
- Optimize nginx configuration
- Enable caching (Redis, Varnish)

### Content Delivery
- Use CDN (Cloudflare, AWS CloudFront)
- Cache static assets
- Optimize images and assets

### Database Projects
- Separate database server
- Connection pooling
- Read replicas

## 🎯 Best Practices

1. **One project = One repository** - Keep projects isolated
2. **Use branches** for environments (main=prod, develop=staging)
3. **Monitor logs** regularly via journalctl and nginx logs
4. **Backup regularly** - Projects are in git, but backup server config
5. **Update system** - Keep Ubuntu, nginx, certbot updated
6. **Use SSL** - Always enable HTTPS with Let's Encrypt
7. **Document changes** - Update README in each project
8. **Test before deploy** - Use staging branches/subdomains

---

This architecture provides a **solid foundation** for managing multiple projects with automated deployments, while keeping everything simple and maintainable! 🚀
