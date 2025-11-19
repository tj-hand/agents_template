# Webhook Integration Guide

## 📋 Overview

While the system auto-pulls every 5 minutes, you can trigger **instant updates** via webhooks. This is perfect for:
- Immediate deployment after pushing changes
- Integrating with CI/CD pipelines
- Manual instant updates from anywhere

## 🚀 Quick Setup

### Option 1: PHP Webhook (Recommended)

#### Step 1: Copy Webhook to Server

```bash
# On your server
cd /var/www/project-agents-template/project-state
curl -o webhook.php https://raw.githubusercontent.com/tj-hand/agents_template/main/deployment/webhook.php
```

#### Step 2: Configure Secret

```bash
# Generate a secure secret
SECRET=$(openssl rand -hex 32)
echo "Your webhook secret: $SECRET"

# Update webhook.php
nano webhook.php
# Change: define('WEBHOOK_SECRET', 'change-this-secret-key');
# To:     define('WEBHOOK_SECRET', 'your-generated-secret');
```

#### Step 3: Set Permissions

```bash
chmod 644 webhook.php
chown www-data:www-data webhook.php
```

#### Step 4: Test

```bash
# Test locally first
curl -X POST "http://localhost/webhook.php?secret=your-secret-here"

# Should return: {"status":"success","message":"Updated successfully",...}
```

#### Step 5: Use from Anywhere

```bash
# Trigger update from your local machine or CI/CD
curl -X POST "https://scrum.dotmkt.com.br/webhook.php?secret=your-secret-here"
```

---

### Option 2: Shell Script Webhook

For servers without PHP:

#### Step 1: Install as CGI

```bash
# Copy script to cgi-bin
sudo cp deployment/webhook.sh /usr/lib/cgi-bin/webhook
sudo chmod +x /usr/lib/cgi-bin/webhook

# Set webhook secret
sudo bash -c 'echo "export WEBHOOK_SECRET=your-secret-here" >> /etc/environment'
```

#### Step 2: Configure Nginx for CGI

```nginx
location /webhook {
    gzip off;
    root /usr/lib/cgi-bin;
    fastcgi_pass unix:/var/run/fcgiwrap.socket;
    include /etc/nginx/fastcgi_params;
    fastcgi_param SCRIPT_FILENAME /usr/lib/cgi-bin$fastcgi_script_name;
}
```

```bash
# Install fcgiwrap
sudo apt-get install fcgiwrap

# Restart nginx
sudo systemctl restart nginx
```

---

## 🎯 Integration Examples

### From Claude Code (Me!)

When I push changes, I can trigger instant deployment:

```bash
# After git push
curl -X POST "https://scrum.dotmkt.com.br/webhook.php?secret=YOUR_SECRET"
```

### From GitHub Actions

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy to Server

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Trigger Webhook
        run: |
          curl -X POST "https://scrum.dotmkt.com.br/webhook.php?secret=${{ secrets.WEBHOOK_SECRET }}"
```

Add `WEBHOOK_SECRET` to GitHub repository secrets:
- Settings → Secrets and variables → Actions → New repository secret

### From GitLab CI

`.gitlab-ci.yml`:

```yaml
deploy:
  stage: deploy
  script:
    - curl -X POST "https://scrum.dotmkt.com.br/webhook.php?secret=$WEBHOOK_SECRET"
  only:
    - main
```

### From Local Git Hook

`.git/hooks/post-commit`:

```bash
#!/bin/bash
curl -X POST "https://scrum.dotmkt.com.br/webhook.php?secret=YOUR_SECRET"
```

```bash
chmod +x .git/hooks/post-commit
```

Now every commit triggers deployment!

### From Postman/API Client

```
POST https://scrum.dotmkt.com.br/webhook.php?secret=YOUR_SECRET
```

---

## 🔐 Security Best Practices

### 1. Use Strong Secret

```bash
# Generate cryptographically secure secret
openssl rand -hex 32
```

### 2. Use HTTPS Only

Never send webhook secrets over HTTP.

### 3. Restrict Access by IP (Optional)

In webhook.php, add:

```php
// Whitelist IPs
$allowedIPs = ['123.456.789.0', '98.765.43.21'];
$clientIP = $_SERVER['REMOTE_ADDR'] ?? '';

if (!in_array($clientIP, $allowedIPs)) {
    jsonResponse(403, 'Forbidden');
}
```

### 4. Use GitHub Webhook Signature (If Using GitHub)

Uncomment and configure the signature verification in webhook.php:

```php
$signature = $_SERVER['HTTP_X_HUB_SIGNATURE_256'] ?? '';
$payload = file_get_contents('php://input');
$expected = 'sha256=' . hash_hmac('sha256', $payload, WEBHOOK_SECRET);
if (!hash_equals($expected, $signature)) {
    jsonResponse(401, 'Invalid signature');
}
```

### 5. Monitor Logs

```bash
# View webhook activity
sudo tail -f /var/log/project-webhook.log

# Check for suspicious activity
sudo grep "ERROR\|Invalid" /var/log/project-webhook.log
```

---

## 📊 Monitoring

### View Recent Webhook Calls

```bash
# Last 20 webhook calls
sudo tail -n 20 /var/log/project-webhook.log
```

### Real-Time Monitoring

```bash
# Watch webhook calls live
sudo tail -f /var/log/project-webhook.log
```

### Check Success Rate

```bash
# Count successful vs failed
grep "SUCCESS" /var/log/project-webhook.log | wc -l
grep "ERROR" /var/log/project-webhook.log | wc -l
```

---

## 🐛 Troubleshooting

### Webhook Returns 401 Unauthorized

- **Check secret:** Ensure secret matches in webhook file and request
- **Check logs:** `sudo tail /var/log/project-webhook.log`

### Webhook Returns 404 Not Found

- **Check file exists:** `ls /var/www/project-*/project-state/webhook.php`
- **Check nginx config:** Verify root path in nginx

### Webhook Returns 500 Error

- **Check permissions:**
  ```bash
  ls -la /var/www/project-*/project-state/webhook.php
  # Should be readable by www-data
  ```

- **Check git permissions:**
  ```bash
  sudo -u www-data git -C /var/www/project-agents-template pull
  # Should work without errors
  ```

### No Response / Timeout

- **Check nginx logs:**
  ```bash
  sudo tail /var/log/nginx/error.log
  ```

- **Test locally first:**
  ```bash
  cd /var/www/project-agents-template/project-state
  php webhook.php
  ```

---

## 🔄 Webhook + Auto-Pull Strategy

**Best practice:** Use both!

- **Auto-Pull (5 min):** Safety net, always catches changes
- **Webhook:** Instant updates when you push

This gives you:
- ✅ **Speed:** Instant updates via webhook
- ✅ **Reliability:** Auto-pull catches anything webhook misses
- ✅ **Flexibility:** Manual updates always available

---

## 📈 Advanced: Multi-Project Webhooks

For managing multiple projects, create a router webhook:

```php
<?php
// webhook-router.php
define('WEBHOOK_SECRET', 'your-secret');

$project = $_GET['project'] ?? '';
$secret = $_GET['secret'] ?? '';

if ($secret !== WEBHOOK_SECRET) {
    http_response_code(401);
    exit('Unauthorized');
}

$projectPath = "/var/www/project-$project";

if (!is_dir($projectPath)) {
    http_response_code(404);
    exit('Project not found');
}

chdir($projectPath);
exec('git pull 2>&1', $output, $code);

http_response_code($code === 0 ? 200 : 500);
echo json_encode(['project' => $project, 'output' => $output]);
```

**Usage:**
```bash
# Update specific project
curl -X POST "https://scrum.dotmkt.com.br/webhook-router.php?project=myapp&secret=SECRET"
```

---

## 💡 Tips

1. **Keep it Simple:** PHP webhook is easiest for most setups
2. **Log Everything:** Helpful for debugging and auditing
3. **Test Thoroughly:** Always test locally before using in production
4. **Rotate Secrets:** Change webhook secrets periodically
5. **Document Secret Location:** Keep secret in password manager

---

## 📚 Related Documentation

- [Main Deployment Guide](./README.md)
- [Server Setup Guide](./SERVER-SETUP-GUIDE.md)
- [Architecture](./ARCHITECTURE.md)

---

## 🎯 Quick Reference

```bash
# Setup webhook
cd /var/www/project-agents-template/project-state
curl -O https://raw.githubusercontent.com/tj-hand/agents_template/main/deployment/webhook.php
nano webhook.php  # Change secret
chmod 644 webhook.php

# Test webhook
curl -X POST "https://scrum.dotmkt.com.br/webhook.php?secret=YOUR_SECRET"

# View logs
sudo tail -f /var/log/project-webhook.log

# Trigger from anywhere
curl -X POST "https://scrum.dotmkt.com.br/webhook.php?secret=YOUR_SECRET"
```

**That's it!** You now have instant deployment on demand. 🚀
