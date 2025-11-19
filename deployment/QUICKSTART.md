# Quick Start - 3 Steps to Deploy

## Step 1: Get the Repository URL

This repository's clone URL:
- **HTTPS:** `https://github.com/tj-hand/agents_template.git`
- **SSH:** `git@github.com:tj-hand/agents_template.git`

## Step 2: Run Setup on Your Server

```bash
# Connect to your server via PuTTY, then run:

# Method A: Direct download (if curl/wget works)
curl -o setup.sh https://raw.githubusercontent.com/tj-hand/agents_template/main/deployment/setup.sh
chmod +x setup.sh
sudo bash setup.sh

# Method B: Manual copy-paste (if download doesn't work)
# 1. Open deployment/setup.sh in this repo
# 2. Copy all content
# 3. On your server, create a file: nano setup.sh
# 4. Paste the content
# 5. Save and run: chmod +x setup.sh && sudo bash setup.sh
```

## Step 3: Enter Configuration

The script will ask for:

```
Enter your subdomain: dashboard.yourdomain.com
Enter installation path [/var/www/project-state]: <press enter>
Enter git repository URL: https://github.com/tj-hand/agents_template.git
Enter git branch [main]: <press enter>
Do you want to set up SSL/HTTPS with Let's Encrypt? (y/n) [y]: y
Auto-pull interval in minutes [5]: 5
```

**Done!** Your dashboard is live and will auto-update every 5 minutes! 🎉

**Want instant updates?** Set up the webhook - see [WEBHOOK-GUIDE.md](./WEBHOOK-GUIDE.md)

## What Happens Next?

1. ✅ Server clones this repository
2. ✅ Nginx is configured to serve `project-state/dashboard.html`
3. ✅ Auto-pull is set up (checks for updates every 1 minute)
4. ✅ SSL certificate is obtained (if you chose yes)
5. ✅ Dashboard is accessible at your subdomain

## From Now On...

When I (Claude) make changes to the project-state files and push to this repo:
- Your server auto-pulls within 1 minute
- Changes appear on your dashboard immediately
- No manual intervention needed!

## Quick Commands

```bash
# Check if auto-update is working
systemctl status project-state-autopull.timer

# View update logs
journalctl -u project-state-autopull.service -f

# Manually trigger an update
cd /var/www/project-state && git pull
```

## 🌟 Multiple Projects?

This same server can host **unlimited projects**, each with its own:
- Git repository
- Subdomain
- Auto-deployment
- Project dashboard

**To add more projects:**
```bash
# Use the project manager
sudo bash project-manager.sh
# Choose option 1: Add a new project
```

See [MULTI-PROJECT-GUIDE.md](./MULTI-PROJECT-GUIDE.md) for details!

---

**Documentation:**
- [Full Deployment Guide](./README.md)
- [Multi-Project Setup](./MULTI-PROJECT-GUIDE.md)
- [New Project Template](./NEW-PROJECT-TEMPLATE.md)
