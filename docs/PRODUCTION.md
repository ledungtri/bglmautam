# Production Server Guide

Complete guide for deploying, managing, and debugging the bglmautam.com production server.

## Table of Contents
- [Server Information](#server-information)
- [Deployment](#deployment)
- [Server Management](#server-management)
- [Debugging](#debugging)
- [SSL/TLS Management](#ssltls-management)
- [Monitoring](#monitoring)
- [Common Issues](#common-issues)

---

## Server Information

### Infrastructure
- **Domain**: bglmautam.com (Rails API), acadex.bglmautam.com (React frontend)
- **Hosting**: Hostinger VPS
- **Server IP**: 72.61.116.204
- **OS**: Ubuntu
- **Web Server**: Nginx 1.24.0
- **Application Server**: Puma (via Rails)
- **Process Manager**: PM2
- **CDN/SSL**: Cloudflare (proxy enabled)

### Access
```bash
# SSH into production server
ssh root@72.61.116.204

# Rails API directory
cd /root/bglmautam

# React frontend directory
cd /root/bglmautam-react
```

### Architecture
```
bglmautam.com     → Cloudflare → Nginx (443) → Rails/Puma (3000) → PostgreSQL (5432)
acadex.bglmautam.com → Cloudflare → Nginx (443) → Static files (/root/bglmautam-react/build)
```

---

## Deployment

### Standard Deployment Process

#### 1. Push Changes to GitHub
```bash
# On local machine
git add .
git commit -m "Your commit message"
git push origin master
```

#### 2. SSH into Production Server
```bash
ssh root@72.61.116.204
cd /root/bglmautam
```

#### 3. Pull Latest Code
```bash
git pull origin master
```

#### 4. Install Dependencies (if Gemfile changed)
```bash
bundle install --deployment --without development test
```

#### 5. Run Database Migrations (if any)
```bash
RAILS_ENV=production bundle exec rake db:migrate
```

#### 6. Precompile Assets (if views/assets changed)
```bash
RAILS_ENV=production bundle exec rake assets:precompile
```

#### 7. Restart Rails Application
```bash
pm2 restart bglmautam
```

#### 8. Verify Deployment
```bash
# Check PM2 status
pm2 status

# Check application logs
pm2 logs bglmautam --lines 50

# Check if site is responding
curl -I https://bglmautam.com
```

### Quick Deployment Script

Save this as `deploy.sh` on the production server:

```bash
#!/bin/bash
set -e

echo "🚀 Starting deployment..."

# Navigate to app directory
cd /root/bglmautam

# Pull latest code
echo "📥 Pulling latest code..."
git pull origin master

# Install dependencies
echo "📦 Installing dependencies..."
bundle install --deployment --without development test

# Run migrations
echo "🗄️  Running migrations..."
RAILS_ENV=production bundle exec rake db:migrate

# Precompile assets
echo "🎨 Precompiling assets..."
RAILS_ENV=production bundle exec rake assets:precompile

# Restart application
echo "♻️  Restarting application..."
pm2 restart bglmautam

# Show status
echo "✅ Deployment complete!"
pm2 status
```

Make it executable:
```bash
chmod +x deploy.sh
```

Run deployment:
```bash
./deploy.sh
```

### React Frontend Deployment (acadex.bglmautam.com)

#### First-Time Setup

##### 1. Clone the React repository on the server

```bash
ssh root@72.61.116.204
cd /root
git clone <your-react-repo-url> bglmautam-react
cd bglmautam-react
npm install
npm run build
```

##### 2. Add DNS record in Cloudflare

1. Go to Cloudflare Dashboard → DNS → Records
2. Add a new **A record**:
   - **Name**: `acadex`
   - **IPv4 address**: `72.61.116.204`
   - **Proxy status**: Proxied (orange cloud)

##### 3. Update Cloudflare Origin Certificate (if needed)

If the existing origin certificate only covers `bglmautam.com`, generate a new one that also covers `*.bglmautam.com`:

1. Go to Cloudflare Dashboard → SSL/TLS → Origin Server
2. Create a new Origin Certificate with hostnames: `bglmautam.com`, `*.bglmautam.com`
3. Replace the certificate files on the server (see [SSL/TLS Management](#ssltls-management))

##### 4. Create Nginx server block for the React app

```bash
sudo nano /etc/nginx/sites-available/acadex.bglmautam.com
```

Paste the following configuration:

```nginx
server {
    listen 443 ssl;
    server_name acadex.bglmautam.com;

    ssl_certificate /etc/ssl/cloudflare/cert.pem;
    ssl_certificate_key /etc/ssl/cloudflare/key.pem;

    root /root/bglmautam-react/build;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    # Cache static assets
    location /static/ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    access_log /var/log/nginx/acadex_bglmautam_access.log;
    error_log /var/log/nginx/acadex_bglmautam_error.log;
}
```

Enable the site and reload Nginx:

```bash
sudo ln -s /etc/nginx/sites-available/acadex.bglmautam.com /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx
```

##### 5. Verify

```bash
curl -I https://acadex.bglmautam.com
```

#### Standard React Deployment Process

```bash
ssh root@72.61.116.204
cd /root/bglmautam-react
git pull origin master
npm install
npm run build
# No restart needed — Nginx serves the new static files immediately
```

#### Quick React Deployment Script

Save as `deploy-react.sh` on the production server:

```bash
#!/bin/bash
set -e

echo "Starting React deployment..."

cd /root/bglmautam-react

echo "Pulling latest code..."
git pull origin master

echo "Installing dependencies..."
npm install

echo "Building production bundle..."
npm run build

echo "React deployment complete!"
curl -s -o /dev/null -w "acadex.bglmautam.com HTTP Status: %{http_code}\n" https://acadex.bglmautam.com
```

Make it executable and run:
```bash
chmod +x deploy-react.sh
./deploy-react.sh
```

---

## Server Management

### PM2 Process Management

#### Check Application Status
```bash
# View all processes
pm2 status

# View detailed info for bglmautam
pm2 show bglmautam

# View resource usage
pm2 monit
```

#### Control Application
```bash
# Restart application
pm2 restart bglmautam

# Stop application
pm2 stop bglmautam

# Start application
pm2 start bglmautam

# Delete from PM2 (requires re-add)
pm2 delete bglmautam

# Start fresh (if ecosystem.config.js exists)
pm2 start ecosystem.config.js
```

#### PM2 Logs
```bash
# View real-time logs
pm2 logs bglmautam

# View last 100 lines
pm2 logs bglmautam --lines 100

# View only error logs
pm2 logs bglmautam --err

# Clear logs
pm2 flush
```

#### PM2 Startup on Boot
```bash
# Generate startup script
pm2 startup systemd

# Save current PM2 process list
pm2 save

# Update saved process list after changes
pm2 save --force
```

### Nginx Management

#### Control Nginx
```bash
# Check Nginx status
sudo systemctl status nginx

# Restart Nginx
sudo systemctl restart nginx

# Reload Nginx (graceful restart)
sudo systemctl reload nginx

# Stop Nginx
sudo systemctl stop nginx

# Start Nginx
sudo systemctl start nginx

# Enable Nginx on boot
sudo systemctl enable nginx
```

#### Test Nginx Configuration
```bash
# Test config syntax
sudo nginx -t

# View current configuration
cat /etc/nginx/sites-available/bglmautam.com

# Edit configuration
sudo nano /etc/nginx/sites-available/bglmautam.com

# After editing, always test and reload
sudo nginx -t && sudo systemctl reload nginx
```

### Database Management

#### Access PostgreSQL
```bash
# Connect to production database
psql -U bglmautam bglmautam_production

# Common commands in psql:
\dt          # List all tables
\d users     # Describe users table
\q           # Quit
```

#### Database Backup
```bash
# Create backup
pg_dump bglmautam_production > /root/backups/db_$(date +%Y%m%d_%H%M%S).sql

# Create compressed backup
pg_dump bglmautam_production | gzip > /root/backups/db_$(date +%Y%m%d_%H%M%S).sql.gz

# Restore from backup
psql -U bglmautam bglmautam_production < /root/backups/db_20251126.sql
```

#### Using seed_dump for Backups
```bash
# Backup current database to seeds file
RAILS_ENV=production bundle exec rake db:seed:dump FILE=db/backups/$(date +%Y%m%d).rb EXCLUDE=[]

# Restore from seeds file
RAILS_ENV=production bundle exec rake db:seed:load FILE=db/backups/20251126.rb
```

---

## Debugging

### Application Logs

#### Rails Logs
```bash
# Real-time Rails log
tail -f /root/bglmautam/log/production.log

# Last 100 lines
tail -n 100 /root/bglmautam/log/production.log

# Search for errors
grep -i error /root/bglmautam/log/production.log

# Search for specific request ID
grep "ea47f7e9-f902-4f59-8a1d-36981bf3d3da" /root/bglmautam/log/production.log
```

#### PM2 Logs
```bash
# Real-time application output
pm2 logs bglmautam

# View errors only
pm2 logs bglmautam --err --lines 50
```

#### Nginx Logs
```bash
# Rails API logs
tail -f /var/log/nginx/bglmautam_access.log
tail -f /var/log/nginx/bglmautam_error.log

# React frontend logs
tail -f /var/log/nginx/acadex_bglmautam_access.log
tail -f /var/log/nginx/acadex_bglmautam_error.log

# Find 5xx errors
grep " 50[0-9] " /var/log/nginx/bglmautam_access.log

# Find 4xx errors
grep " 40[0-9] " /var/log/nginx/bglmautam_access.log
```

### Rails Console on Production

⚠️ **Warning**: Be extremely careful with production console!

```bash
# Open Rails console
RAILS_ENV=production bundle exec rails console

# Read-only operations are safe
User.count
Teacher.first
Classroom.where(active: true).count

# AVOID destructive operations unless absolutely necessary
# Never run: User.delete_all, update_all without where clause, etc.
```

### Common Debugging Commands

#### Check if Rails is responding
```bash
# Check if port 3000 is listening
sudo lsof -i :3000

# Test Rails directly (bypassing Nginx)
curl http://127.0.0.1:3000
```

#### Check if Nginx is responding
```bash
# Check if port 443 is listening
sudo lsof -i :443

# Test HTTPS locally
curl -k https://127.0.0.1
```

#### Check System Resources
```bash
# CPU and memory usage
top

# Or use htop (more user-friendly)
htop

# Disk space
df -h

# Check specific directory size
du -sh /root/bglmautam

# Check database size
du -sh /var/lib/postgresql
```

#### Network Debugging
```bash
# Check DNS resolution
dig bglmautam.com

# Check if Cloudflare proxy is working
curl -I https://bglmautam.com | grep -i server
# Should show: server: cloudflare

# Test SSL certificate
echo | openssl s_client -connect bglmautam.com:443 -servername bglmautam.com | grep -A 5 "Certificate chain"
```

---

## SSL/TLS Management

### Cloudflare SSL Settings

#### Current Configuration
- **SSL/TLS Mode**: Full (strict)
- **Certificate Type**: Cloudflare Origin Certificate (15-year validity)
- **Minimum TLS Version**: TLS 1.2
- **Always Use HTTPS**: Enabled

#### Certificate Locations on VPS
```bash
# Origin Certificate
/etc/ssl/cloudflare/cert.pem

# Private Key
/etc/ssl/cloudflare/key.pem

# Verify certificates exist and permissions
ls -la /etc/ssl/cloudflare/
```

#### Renewing Cloudflare Origin Certificate

1. Go to Cloudflare Dashboard → SSL/TLS → Origin Server
2. Revoke old certificate
3. Create new Origin Certificate
4. Update certificates on VPS:

```bash
# Backup old certificates
sudo cp /etc/ssl/cloudflare/cert.pem /etc/ssl/cloudflare/cert.pem.old
sudo cp /etc/ssl/cloudflare/key.pem /etc/ssl/cloudflare/key.pem.old

# Create new certificate file
sudo nano /etc/ssl/cloudflare/cert.pem
# Paste new certificate

# Create new private key file
sudo nano /etc/ssl/cloudflare/key.pem
# Paste new private key

# Set correct permissions
sudo chmod 644 /etc/ssl/cloudflare/cert.pem
sudo chmod 600 /etc/ssl/cloudflare/key.pem

# Test Nginx configuration
sudo nginx -t

# Reload Nginx
sudo systemctl reload nginx
```

#### Verify SSL is Working
```bash
# Check SSL certificate details
echo | openssl s_client -connect bglmautam.com:443 -servername bglmautam.com 2>/dev/null | openssl x509 -noout -text | grep -A 2 "Validity"

# Test SSL Labs (external service)
# Visit: https://www.ssllabs.com/ssltest/analyze.html?d=bglmautam.com
```

---

## Monitoring

### Health Checks

#### Quick Health Check Script

Save as `/root/healthcheck.sh`:

```bash
#!/bin/bash

echo "=== System Health Check ==="
echo ""

# Check disk space
echo "📀 Disk Space:"
df -h | grep -E "/$|/root"
echo ""

# Check memory
echo "💾 Memory Usage:"
free -h
echo ""

# Check PM2 status
echo "🔄 PM2 Status:"
pm2 status
echo ""

# Check Nginx status
echo "🌐 Nginx Status:"
sudo systemctl status nginx --no-pager | head -3
echo ""

# Check if applications are responding
echo "🔍 Application Response:"
curl -s -o /dev/null -w "bglmautam.com HTTP Status: %{http_code}\n" https://bglmautam.com
curl -s -o /dev/null -w "acadex.bglmautam.com HTTP Status: %{http_code}\n" https://acadex.bglmautam.com
echo ""

# Check database connection
echo "🗄️  Database Status:"
psql -U bglmautam -d bglmautam_production -c "SELECT 1" > /dev/null 2>&1 && echo "✅ Database OK" || echo "❌ Database Error"
echo ""

# Recent errors in logs
echo "⚠️  Recent Errors (last 10 minutes):"
sudo grep -i error /var/log/nginx/bglmautam_error.log | tail -5
echo ""

echo "=== Health Check Complete ==="
```

Make it executable:
```bash
chmod +x /root/healthcheck.sh
```

Run it:
```bash
./healthcheck.sh
```

### Setting Up Monitoring Alerts (Optional)

#### Simple Uptime Monitoring
- Use free service like [UptimeRobot](https://uptimerobot.com/)
- Monitor: https://bglmautam.com
- Get email alerts when site goes down

#### Server Monitoring
```bash
# Install htop for better resource monitoring
apt-get install htop

# Check historical resource usage
sar -u 1 10  # CPU usage, 10 samples at 1-second intervals
```

---

## Common Issues

### Issue: Site Not Loading (502 Bad Gateway)

**Symptoms**: Nginx shows 502 error page

**Cause**: Rails application is not running

**Solution**:
```bash
# Check PM2 status
pm2 status

# If stopped, restart
pm2 restart bglmautam

# Check logs for errors
pm2 logs bglmautam --err
```

---

### Issue: Site Not Loading (503 Service Unavailable)

**Symptoms**: Nginx shows 503 error

**Cause**: Nginx can't connect to Rails

**Solution**:
```bash
# Check if Rails is listening on port 3000
sudo lsof -i :3000

# Check PM2 logs
pm2 logs bglmautam

# Restart both Nginx and Rails
pm2 restart bglmautam
sudo systemctl restart nginx
```

---

### Issue: Assets Not Loading (Images, CSS, JS)

**Symptoms**: Page loads but no styling, missing images

**Cause**: Assets not precompiled or permission issues

**Solution**:
```bash
# Precompile assets
RAILS_ENV=production bundle exec rake assets:precompile

# Fix permissions
chmod -R 755 /root/bglmautam/public
chmod 755 /root

# Restart application
pm2 restart bglmautam
```

---

### Issue: "Not Secure" Warning in Browser

**Symptoms**: Browser shows certificate warning

**Cause**: Cloudflare proxy not enabled

**Solution**:
1. Go to Cloudflare Dashboard → DNS
2. Make sure A record and CNAME have **orange cloud** enabled
3. Clear browser cache (Ctrl+Shift+R or Cmd+Shift+R)
4. Try incognito/private window

---

### Issue: Database Connection Error

**Symptoms**: Application shows "can't connect to database"

**Cause**: PostgreSQL not running or wrong credentials

**Solution**:
```bash
# Check PostgreSQL status
sudo systemctl status postgresql

# Restart PostgreSQL
sudo systemctl restart postgresql

# Check database.yml configuration
cat /root/bglmautam/config/database.yml | grep -A 10 production

# Test database connection
psql -U bglmautam -d bglmautam_production -c "SELECT 1"
```

---

### Issue: High Memory Usage

**Symptoms**: Server running slow, out of memory errors

**Cause**: Too many Rails processes or memory leak

**Solution**:
```bash
# Check memory usage
free -h

# Restart Rails to free memory
pm2 restart bglmautam

# Check for memory leaks in logs
grep -i "memory" /root/bglmautam/log/production.log

# Consider upgrading server if consistently high
```

---

### Issue: Slow Performance

**Symptoms**: Site takes long to load

**Solutions**:
```bash
# Check if database needs optimization
psql -U bglmautam -d bglmautam_production
# Run: VACUUM ANALYZE;

# Check Rails log for slow queries
grep "Completed.*in.*ms" /root/bglmautam/log/production.log | sort -t '(' -k 2 -n | tail -20

# Enable Cloudflare caching
# Cloudflare Dashboard → Caching → Configuration

# Check system resources
top
```

---

## Security Best Practices

### Regular Maintenance

```bash
# Update system packages monthly
apt-get update
apt-get upgrade

# Update Ruby gems quarterly
bundle update

# Rotate logs monthly
pm2 flush
sudo logrotate -f /etc/logrotate.conf
```

### Backup Schedule

**Daily**: Database backup
```bash
# Add to crontab: crontab -e
0 2 * * * pg_dump bglmautam_production | gzip > /root/backups/daily/db_$(date +\%Y\%m\%d).sql.gz
```

**Weekly**: Full application backup
```bash
# Add to crontab: crontab -e
0 3 * * 0 tar -czf /root/backups/weekly/bglmautam_$(date +\%Y\%m\%d).tar.gz /root/bglmautam
```

### Access Control

- **Never share root password**
- Use SSH keys instead of passwords
- Regularly review Cloudflare access logs
- Keep Rails and dependencies updated

---

## Emergency Procedures

### Complete Server Restart

```bash
# 1. Stop application
pm2 stop bglmautam

# 2. Stop Nginx
sudo systemctl stop nginx

# 3. Stop PostgreSQL
sudo systemctl stop postgresql

# 4. Start PostgreSQL
sudo systemctl start postgresql

# 5. Start Nginx
sudo systemctl start nginx

# 6. Start application
pm2 start bglmautam

# 7. Verify everything is running
./healthcheck.sh
```

### Rollback to Previous Version

```bash
# 1. SSH into server
ssh root@72.61.116.204
cd /root/bglmautam

# 2. Check git log
git log --oneline -10

# 3. Rollback to specific commit
git reset --hard <commit-hash>

# 4. Restore dependencies
bundle install --deployment --without development test

# 5. Precompile assets
RAILS_ENV=production bundle exec rake assets:precompile

# 6. Restart application
pm2 restart bglmautam
```

---

## Useful Aliases

Add these to `/root/.bashrc` for convenience:

```bash
# Rails aliases
alias prod-logs='tail -f /root/bglmautam/log/production.log'
alias prod-console='cd /root/bglmautam && RAILS_ENV=production bundle exec rails console'
alias prod-restart='cd /root/bglmautam && pm2 restart bglmautam'

# React aliases
alias react-deploy='bash /root/deploy-react.sh'
alias react-logs='sudo tail -f /var/log/nginx/acadex_bglmautam_error.log'

# Nginx aliases
alias nginx-reload='sudo systemctl reload nginx'
alias nginx-test='sudo nginx -t'
alias nginx-logs='sudo tail -f /var/log/nginx/bglmautam_error.log'

# System aliases
alias health='bash /root/healthcheck.sh'

# Apply changes
source ~/.bashrc
```

---

## Contact & Support

- **Server Provider**: Hostinger (ledungtri.2202@gmail.com)
- **Cloudflare Account**: ledungtri.2202@gmail.com
- **Server Costs**:
  - VPS: 24 months @ US$ 263.74 including tax
  - Domain: $11/year

For urgent production issues, always check logs first and try restarting the application before making configuration changes.
