# Project State Dashboard - Deployment Guide

## 🚀 Overview

This deployment setup provides **fully automated** git-based deployment for your Project State Dashboard. Once configured, any changes pushed to this repository will automatically appear on your server within minutes.

## ✨ Features

- ✅ **Fully Automated** - Push to git, server auto-updates
- ✅ **SSL/HTTPS Support** - Auto-configures Let's Encrypt
- ✅ **Nginx Configuration** - Production-ready web server setup
- ✅ **Auto-Pull Mechanism** - Uses systemd timer (configurable interval)
- ✅ **Security Headers** - CORS, XSS, Frame protection
- ✅ **Logging** - Full access and error logs
- ✅ **Zero Downtime** - Updates happen seamlessly

## 📋 Prerequisites

Your Ubuntu server needs:
- Ubuntu 20.04+ (tested on Ubuntu)
- Root or sudo access
- Git installed (script will install if missing)
- Nginx installed (script will install if missing)
- Domain/subdomain with DNS pointing to your server

## 🎯 One-Time Setup (5 minutes)

### Step 1: Connect to Your Server

Using PuTTY, connect to your server as root.

### Step 2: Download the Setup Script

```bash
# Download the setup script
curl -o setup.sh https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/deployment/setup.sh

# Or if you prefer wget
wget https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/deployment/setup.sh

# Make it executable
chmod +x setup.sh
```

**Alternative:** If you can't download directly, copy the script content from this repository and paste it into a file on your server.

### Step 3: Run the Setup Script

```bash
sudo bash setup.sh
```

The script will ask you for:
1. **Subdomain** (e.g., `dashboard.yourdomain.com`)
2. **Installation path** (default: `/var/www/project-state`)
3. **Git repository URL** (this repo's URL)
4. **Git branch** (default: `main`)
5. **SSL setup** (recommended: yes)
6. **Auto-pull interval** (default: 1 minute)

### Step 4: Configure DNS

Point your subdomain to your server's IP:

```
Type: A Record
Host: dashboard (or your subdomain)
Value: 216.238.99.183 (your server IP)
TTL: 300
```

### Step 5: Done! 🎉

Your dashboard is now live at:
- `https://your-subdomain.com` (if SSL enabled)
- `http://your-subdomain.com` (if SSL skipped)

## 🔄 How Auto-Deploy Works

```
┌─────────────────┐
│  Developer      │
│  (Claude Code)  │
└────────┬────────┘
         │
         │ git push
         ▼
┌─────────────────┐
│  GitHub Repo    │
└────────┬────────┘
         │
         │ git pull (every 1 min)
         ▼
┌─────────────────┐
│  Your Server    │
│  (Ubuntu)       │
└────────┬────────┘
         │
         │ nginx serves
         ▼
┌─────────────────┐
│  Public URL     │
│  dashboard.com  │
└─────────────────┘
```

1. **I push changes** to this GitHub repository
2. **Server auto-pulls** every minute (via systemd timer)
3. **Nginx serves** the updated files immediately
4. **Your dashboard updates** automatically!

## 🛠️ Management Commands

### Check Auto-Pull Status

```bash
# Check if timer is active
systemctl status project-state-autopull.timer

# View auto-pull logs
journalctl -u project-state-autopull.service -f

# Manually trigger a pull
systemctl start project-state-autopull.service
```

### Nginx Management

```bash
# Check nginx status
systemctl status nginx

# View access logs
tail -f /var/log/nginx/your-subdomain-access.log

# View error logs
tail -f /var/log/nginx/your-subdomain-error.log

# Reload nginx (after config changes)
nginx -t && systemctl reload nginx
```

### Manual Updates

```bash
# Navigate to installation directory
cd /var/www/project-state

# Check current status
git status

# Pull latest changes manually
git pull origin main

# View commit history
git log --oneline -10
```

### Change Auto-Pull Interval

```bash
# Edit the timer
nano /etc/systemd/system/project-state-autopull.timer

# Change this line (example: 5 minutes)
OnUnitActiveSec=5min

# Reload and restart
systemctl daemon-reload
systemctl restart project-state-autopull.timer
```

## 🔒 Security

The setup includes:
- **HTTPS/SSL** via Let's Encrypt (auto-renewal)
- **Security Headers** (X-Frame-Options, XSS Protection, etc.)
- **Proper Permissions** (www-data:www-data, 755)
- **CORS Configuration** (customizable)
- **No exposed credentials** (git pull is public repo or SSH key)

### Using Private Repository

If your repo is private, set up SSH keys on your server:

```bash
# Generate SSH key on server
ssh-keygen -t ed25519 -C "server-deploy-key"

# Display public key
cat ~/.ssh/id_ed25519.pub

# Add this key to your GitHub repo:
# Settings → Deploy Keys → Add deploy key
```

Then update the repo URL in `/var/www/project-state/.git/config` to use SSH:
```
url = git@github.com:username/repo.git
```

## 🐛 Troubleshooting

### Dashboard Not Updating

```bash
# Check if auto-pull is running
systemctl status project-state-autopull.timer

# View recent logs
journalctl -u project-state-autopull.service --since "10 minutes ago"

# Manually pull to see errors
cd /var/www/project-state && git pull
```

### Nginx Not Serving Files

```bash
# Check nginx error logs
tail -f /var/log/nginx/your-subdomain-error.log

# Verify file permissions
ls -la /var/www/project-state/project-state/

# Test nginx config
nginx -t
```

### SSL Certificate Issues

```bash
# Renew certificate manually
certbot renew

# Test automatic renewal
certbot renew --dry-run

# View certificate info
certbot certificates
```

### 502 Bad Gateway

This usually means nginx can't find the files:

```bash
# Check installation path
ls -la /var/www/project-state/project-state/dashboard.html

# Verify nginx config
cat /etc/nginx/sites-enabled/your-subdomain

# Reload nginx
systemctl reload nginx
```

## 📊 Monitoring

### View Real-Time Access

```bash
# Watch access logs
tail -f /var/log/nginx/your-subdomain-access.log

# Filter for errors only
tail -f /var/log/nginx/your-subdomain-error.log | grep ERROR
```

### Check Disk Usage

```bash
# Check overall disk usage
df -h

# Check project-state size
du -sh /var/www/project-state
```

## 🔄 Updating the Setup

If you need to reconfigure:

```bash
# Re-run the setup script
cd /var/www/project-state/deployment
sudo bash setup.sh

# Or manually edit nginx config
sudo nano /etc/nginx/sites-available/your-subdomain
sudo nginx -t
sudo systemctl reload nginx
```

## ❌ Uninstall

To completely remove the setup:

```bash
# Stop and disable auto-pull
systemctl stop project-state-autopull.timer
systemctl disable project-state-autopull.timer
rm /etc/systemd/system/project-state-autopull.timer
rm /etc/systemd/system/project-state-autopull.service
systemctl daemon-reload

# Remove nginx config
rm /etc/nginx/sites-enabled/your-subdomain
rm /etc/nginx/sites-available/your-subdomain
systemctl reload nginx

# Remove files
rm -rf /var/www/project-state

# Remove SSL certificate (optional)
certbot delete --cert-name your-subdomain
```

## 📞 Support

If you encounter issues:
1. Check the troubleshooting section above
2. View logs: `journalctl -u project-state-autopull.service -f`
3. Check nginx logs: `tail -f /var/log/nginx/*error.log`

## 🎯 Quick Reference

| Command | Purpose |
|---------|---------|
| `systemctl status project-state-autopull.timer` | Check auto-pull status |
| `journalctl -u project-state-autopull.service -f` | View auto-pull logs |
| `tail -f /var/log/nginx/your-subdomain-access.log` | View access logs |
| `cd /var/www/project-state && git pull` | Manual update |
| `nginx -t && systemctl reload nginx` | Reload nginx |
| `certbot renew` | Renew SSL certificate |

---

**That's it!** Your dashboard is now fully automated. Push changes to git, and they appear on your server automatically! 🚀
