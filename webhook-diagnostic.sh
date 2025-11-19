#!/bin/bash
# Webhook Diagnostic Script
# This script checks all webhook-related configurations

echo "=========================================="
echo "WEBHOOK DIAGNOSTIC SCRIPT"
echo "=========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 1. Check file existence
echo "1. Checking webhook.php file..."
if [ -f "/var/www/project-agents-template/project-state/webhook.php" ]; then
    echo -e "${GREEN}✓${NC} webhook.php exists"
    ls -lah /var/www/project-agents-template/project-state/webhook.php
else
    echo -e "${RED}✗${NC} webhook.php NOT FOUND"
fi
echo ""

# 2. Check file permissions
echo "2. Checking file permissions..."
PERMS=$(stat -c "%a" /var/www/project-agents-template/project-state/webhook.php 2>/dev/null)
OWNER=$(stat -c "%U:%G" /var/www/project-agents-template/project-state/webhook.php 2>/dev/null)
echo "Permissions: $PERMS"
echo "Owner: $OWNER"
if [ "$PERMS" != "644" ]; then
    echo -e "${YELLOW}⚠${NC} Recommended permissions: 644"
fi
if [ "$OWNER" != "www-data:www-data" ] && [ "$OWNER" != "root:root" ]; then
    echo -e "${YELLOW}⚠${NC} Recommended owner: www-data:www-data or root:root"
fi
echo ""

# 3. Check webhook secret
echo "3. Checking webhook secret configuration..."
SECRET=$(grep "WEBHOOK_SECRET" /var/www/project-agents-template/project-state/webhook.php | head -1)
if echo "$SECRET" | grep -q "change-this-secret-key"; then
    echo -e "${RED}✗${NC} Using default secret (not secure!)"
else
    echo -e "${GREEN}✓${NC} Custom secret configured"
fi
echo "Secret line: $SECRET"
echo ""

# 4. Check PHP-FPM status
echo "4. Checking PHP-FPM service..."
if systemctl is-active --quiet php8.3-fpm; then
    echo -e "${GREEN}✓${NC} php8.3-fpm is running"
elif systemctl is-active --quiet php8.4-fpm; then
    echo -e "${GREEN}✓${NC} php8.4-fpm is running"
else
    echo -e "${RED}✗${NC} PHP-FPM is NOT running"
    echo "Available PHP-FPM services:"
    systemctl list-units --type=service | grep php
fi
echo ""

# 5. Check PHP-FPM socket
echo "5. Checking PHP-FPM socket..."
for socket in /var/run/php/php*.sock; do
    if [ -S "$socket" ]; then
        echo -e "${GREEN}✓${NC} Found socket: $socket"
        ls -lah "$socket"
    fi
done
echo ""

# 6. Check nginx configuration
echo "6. Checking nginx configuration..."
echo "Nginx config file: /etc/nginx/sites-enabled/scrum.dotmkt.com.br"
echo ""
echo "Root directory:"
grep "root" /etc/nginx/sites-enabled/scrum.dotmkt.com.br | head -1
echo ""
echo "PHP location block:"
if grep -q "location ~ \\\.php\$" /etc/nginx/sites-enabled/scrum.dotmkt.com.br; then
    echo -e "${GREEN}✓${NC} PHP location block found"
    grep -A 5 "location ~ \\\.php\$" /etc/nginx/sites-enabled/scrum.dotmkt.com.br
else
    echo -e "${RED}✗${NC} PHP location block NOT FOUND"
fi
echo ""

# 7. Test nginx configuration
echo "7. Testing nginx configuration..."
if nginx -t 2>&1 | grep -q "successful"; then
    echo -e "${GREEN}✓${NC} Nginx configuration is valid"
else
    echo -e "${RED}✗${NC} Nginx configuration has errors:"
    nginx -t 2>&1
fi
echo ""

# 8. Check nginx service
echo "8. Checking nginx service..."
if systemctl is-active --quiet nginx; then
    echo -e "${GREEN}✓${NC} nginx is running"
else
    echo -e "${RED}✗${NC} nginx is NOT running"
fi
echo ""

# 9. Check nginx error log
echo "9. Recent nginx error log (last 10 lines)..."
tail -10 /var/log/nginx/error.log 2>/dev/null || echo "No error log available"
echo ""

# 10. Check if fastcgi snippet exists
echo "10. Checking FastCGI configuration..."
if [ -f "/etc/nginx/snippets/fastcgi-php.conf" ]; then
    echo -e "${GREEN}✓${NC} fastcgi-php.conf exists"
    cat /etc/nginx/snippets/fastcgi-php.conf
else
    echo -e "${RED}✗${NC} fastcgi-php.conf NOT FOUND"
fi
echo ""

# 11. Test webhook access
echo "11. Testing webhook endpoint..."
echo "Testing: curl -X POST http://localhost/webhook.php -H 'X-Webhook-Secret: test'"
RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" -X POST "http://localhost/webhook.php" \
    -H "X-Webhook-Secret: test" 2>&1)
HTTP_CODE=$(echo "$RESPONSE" | grep "HTTP_CODE" | cut -d: -f2)
BODY=$(echo "$RESPONSE" | grep -v "HTTP_CODE")

echo "HTTP Code: $HTTP_CODE"
echo "Response: $BODY"

if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "401" ]; then
    echo -e "${GREEN}✓${NC} Webhook is accessible (PHP is working)"
elif [ "$HTTP_CODE" = "404" ]; then
    echo -e "${RED}✗${NC} 404 Not Found - PHP not being executed"
else
    echo -e "${YELLOW}⚠${NC} Unexpected response"
fi
echo ""

# 12. Check project directory structure
echo "12. Project directory structure..."
echo "/var/www/project-agents-template/project-state/"
ls -lah /var/www/project-agents-template/project-state/ | head -15
echo ""

# 13. Summary and recommendations
echo "=========================================="
echo "SUMMARY & RECOMMENDATIONS"
echo "=========================================="

# Check all critical components
ISSUES=0

if [ ! -f "/var/www/project-agents-template/project-state/webhook.php" ]; then
    echo -e "${RED}✗${NC} webhook.php file missing"
    ((ISSUES++))
fi

if ! grep -q "location ~ \\\.php\$" /etc/nginx/sites-enabled/scrum.dotmkt.com.br; then
    echo -e "${RED}✗${NC} PHP location block missing in nginx config"
    echo "   Fix: Add PHP location block before 'listen 443 ssl;' line"
    ((ISSUES++))
fi

if ! systemctl is-active --quiet php8.3-fpm && ! systemctl is-active --quiet php8.4-fpm; then
    echo -e "${RED}✗${NC} PHP-FPM service not running"
    echo "   Fix: systemctl start php8.3-fpm"
    ((ISSUES++))
fi

if ! systemctl is-active --quiet nginx; then
    echo -e "${RED}✗${NC} Nginx service not running"
    echo "   Fix: systemctl start nginx"
    ((ISSUES++))
fi

if [ "$HTTP_CODE" = "404" ]; then
    echo -e "${RED}✗${NC} Webhook returns 404"
    echo "   Most likely cause: nginx PHP block missing or incorrect"
    ((ISSUES++))
fi

if [ $ISSUES -eq 0 ]; then
    echo -e "${GREEN}✓${NC} All checks passed!"
else
    echo ""
    echo "Found $ISSUES issue(s) that need attention"
fi

echo ""
echo "=========================================="
echo "DIAGNOSTIC COMPLETE"
echo "=========================================="
