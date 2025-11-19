# Setting Up Additional Remote Servers

## 📋 Overview

This guide shows you how to set up additional Ubuntu servers to host your multi-project dashboards, identical to your first server setup.

## Prerequisites

- Ubuntu 20.04+ server with root access
- Domain/subdomain pointing to server IP
- SSH access (PuTTY or terminal)

## 🚀 Quick Setup (5 Minutes)

### Step 1: Connect to Your Server

Using PuTTY or SSH:
```bash
ssh root@your-server-ip
```

### Step 2: Install Prerequisites

```bash
# Update package list
sudo apt-get update

# Install required tools
sudo apt-get install -y git nginx certbot python3-certbot-nginx docker.io

# Verify installations
git --version
nginx -v
docker --version
certbot --version
```

### Step 3: Download Project Manager

```bash
# Create deployment directory
mkdir -p ~/deployment
cd ~/deployment

# Clone this repository temporarily to get the script
git clone --depth 1 https://github.com/tj-hand/agents_template.git temp-repo
cp temp-repo/deployment/project-manager.sh ./
chmod +x project-manager.sh
rm -rf temp-repo

# Verify
ls -lh project-manager.sh
```

### Step 4: Configure DNS

Before proceeding, ensure your subdomain points to this server:

| Type | Host | Value | TTL |
|------|------|-------|-----|
| A | scrum | YOUR_SERVER_IP | 300 |

Verify:
```bash
nslookup scrum.yourdomain.com
# Should return your server IP
```

### Step 5: Deploy Your First Project

```bash
sudo bash project-manager.sh

# Choose option 1: Add a new project
# Enter:
#   Project name: agents-template
#   Subdomain: scrum.yourdomain.com
#   Git URL: https://github.com/tj-hand/agents_template.git
#   Branch: main (or your branch)
#   Auto-pull: 1
#   SSL: y
```

Wait for SSL certificate and setup to complete.

### Step 6: Test

Visit: `https://scrum.yourdomain.com`

You should see the multi-project dashboard!

## ✅ What Was Configured

- ✅ Git, Nginx, Docker, Certbot installed
- ✅ Project deployed to `/var/www/project-{name}`
- ✅ Nginx configured with SSL (Let's Encrypt)
- ✅ Auto-pull timer running (every 1 minute)
- ✅ Dashboard accessible via HTTPS

## 🔧 Post-Setup Configuration

### Configure Firewall (Optional)

```bash
sudo ufw allow 'Nginx Full'
sudo ufw allow OpenSSH
sudo ufw enable
sudo ufw status
```

### Add More Projects

```bash
cd ~/deployment
sudo bash project-manager.sh
# Choose option 1 for each new project
```

### Monitor Auto-Pull

```bash
# View all timers
systemctl list-timers | grep project-

# View logs for specific project
journalctl -u project-{name}-autopull.service -f
```

## 🌍 Multi-Server Setup

If you're running multiple servers for different purposes:

### Server 1: Production Dashboard
```
scrum.yourdomain.com
├── Production projects
├── Client dashboards
└── Main operations
```

### Server 2: Staging/Development
```
staging.yourdomain.com
├── Test projects
├── Development branches
└── Experimentation
```

### Server 3: Specific Client
```
client.yourdomain.com
├── Client-specific projects
└── Isolated environment
```

## 🔄 Keeping Servers in Sync

### Option 1: Same Repository, Different Branches

```bash
# Server 1 (Production)
git push origin main

# Server 2 (Staging)
git push origin staging

Each server auto-pulls from its configured branch.
```

### Option 2: Separate Repositories

```bash
# Server 1
Repo: github.com/you/production-dashboards

# Server 2
Repo: github.com/you/staging-dashboards
```

## 📊 Management Commands

### List All Projects on Server

```bash
sudo bash project-manager.sh
# Choose option 2
```

### Update a Project Manually

```bash
sudo bash project-manager.sh
# Choose option 4
# Enter project name
```

### Remove a Project

```bash
sudo bash project-manager.sh
# Choose option 3
# Enter project name
# Confirm with 'yes'
```

## 🐛 Troubleshooting

### SSL Certificate Fails

```bash
# Check DNS propagation
dig scrum.yourdomain.com +short

# Manually obtain certificate
sudo certbot --nginx -d scrum.yourdomain.com
```

### Auto-Pull Not Working

```bash
# Check timer status
systemctl status project-{name}-autopull.timer

# Restart timer
sudo systemctl restart project-{name}-autopull.timer

# Check logs
journalctl -u project-{name}-autopull.service --since "10 minutes ago"
```

### Nginx Errors

```bash
# Test configuration
sudo nginx -t

# View error logs
sudo tail -f /var/log/nginx/error.log

# Restart nginx
sudo systemctl restart nginx
```

## 🔐 Security Best Practices

1. **Use SSH Keys** instead of passwords
2. **Enable UFW firewall** (allow only 80, 443, 22)
3. **Regular Updates**: `sudo apt-get update && sudo apt-get upgrade`
4. **Use Deploy Keys** for private repositories
5. **Limit root access** - create sudo user
6. **Monitor logs** regularly

## 📚 Additional Resources

- [Full Deployment Guide](./README.md)
- [Multi-Project Setup](./MULTI-PROJECT-GUIDE.md)
- [Architecture Overview](./ARCHITECTURE.md)

## 💡 Tips

- **Document your servers** - Keep a list of which projects are on which servers
- **Backup configurations** - Save nginx configs and project-manager settings
- **Use staging first** - Test changes on staging server before production
- **Monitor resources** - Check disk space, memory, CPU usage
- **Set up monitoring** - Use tools like UptimeRobot for availability alerts

---

**That's it!** Your new server is ready to host unlimited projects with automated deployments. 🚀
