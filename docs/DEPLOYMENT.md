# Deployment Guide

Production deployment options for Wedly.

## Deployment Options

1. **Traditional VPS** (DigitalOcean, Linode, Vultr)
2. **PaaS** (Heroku, Render, Fly.io)
3. **Container-Based** (Docker, Kubernetes)
4. **Shared Hosting** (if Rails supported)

## Option 1: Traditional VPS (Recommended)

Best for full control and lowest cost.

### Prerequisites

- Ubuntu 20.04+ server
- Domain name pointed to server IP
- SSH access
- Sudo privileges

### Deployment Steps

See [INSTALL.md](INSTALL.md) for detailed server setup.

Quick overview:
```bash
# 1. Provision server
# 2. Install dependencies (Ruby, MySQL, Nginx)
# 3. Clone application
# 4. Configure environment
# 5. Setup database
# 6. Configure web server
# 7. Install SSL certificate
```

### Estimated Costs

- **DigitalOcean Droplet**: $6/month (1GB RAM)
- **Domain**: $12/year
- **SSL**: Free (Let's Encrypt)
- **Total**: ~$84/year

## Option 2: Heroku (Easiest)

Simplest deployment but higher cost.

### Setup

```bash
# Install Heroku CLI
brew install heroku/brew/heroku

# Login
heroku login

# Create app
heroku create your-wedding-name

# Add MySQL addon
heroku addons:create jawsdb:kitefin  # Free tier

# Set environment variables
heroku config:set RAILS_MASTER_KEY=$(cat config/master.key)
heroku config:set SMTP_ADDRESS=smtp.gmail.com
heroku config:set SMTP_USERNAME=your-email@gmail.com
heroku config:set SMTP_PASSWORD=your-app-password

# Deploy
git push heroku main

# Run migrations
heroku run rails db:migrate
heroku run rails db:seed

# Open app
heroku open
```

### Procfile

Create `Procfile` in project root:
```
web: bundle exec puma -C config/puma.rb
```

### Cost

- **Free tier**: Not suitable (sleeps after 30 min)
- **Hobby**: $7/month (no sleep)
- **MySQL addon**: $10/month
- **Total**: ~$204/year

## Option 3: Render

Modern PaaS with free tier.

### Setup

1. Create account at [render.com](https://render.com)
2. Connect GitHub repository
3. Create new Web Service
4. Configure:

```yaml
# render.yaml
services:
  - type: web
    name: wedly
    env: ruby
    buildCommand: bundle install && rails assets:precompile
    startCommand: bundle exec puma -C config/puma.rb
    envVars:
      - key: DATABASE_URL
        fromDatabase:
          name: wedly-db
          property: connectionString
      - key: RAILS_MASTER_KEY
        sync: false
      - key: SMTP_ADDRESS
        value: smtp.gmail.com

databases:
  - name: wedly-db
    databaseName: wedly_production
    user: wedly
```

### Cost

- **Free tier**: $0/month (limited)
- **Starter**: $7/month
- **MySQL**: $7/month
- **Total**: ~$168/year

## Option 4: Fly.io

Modern container platform.

### Setup

```bash
# Install flyctl
curl -L https://fly.io/install.sh | sh

# Login
flyctl auth login

# Launch app
flyctl launch

# Create MySQL
flyctl mysql create

# Deploy
flyctl deploy

# Run migrations
flyctl ssh console
rails db:migrate
rails db:seed
```

### Cost

- **Free tier**: Limited but workable
- **Paid**: ~$5-10/month
- **Total**: ~$60-120/year

## Environment Variables

All deployment options need these variables:

```bash
# Required
DATABASE_URL=mysql2://user:pass@host/database
RAILS_MASTER_KEY=your-master-key
SMTP_ADDRESS=smtp.gmail.com
SMTP_USERNAME=your-email@gmail.com
SMTP_PASSWORD=your-app-password
APP_HOST=your-domain.com

# Optional
SMTP_PORT=587
RAILS_LOG_LEVEL=info
RAILS_MAX_THREADS=5
WEB_CONCURRENCY=2
```

## Database Setup

### MySQL Configuration

For production MySQL:

```sql
CREATE DATABASE wedly_production CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'wedly'@'localhost' IDENTIFIED BY 'secure_password';
GRANT ALL PRIVILEGES ON wedly_production.* TO 'wedly'@'localhost';
FLUSH PRIVILEGES;
```

### Connection String Format

```
mysql2://username:password@hostname:port/database_name
```

Example:
```
mysql2://wedly:SecurePass123@localhost:3306/wedly_production
```

## SSL Certificate

### Let's Encrypt (Free)

```bash
# Install Certbot
sudo apt-get install certbot python3-certbot-nginx

# Obtain certificate
sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com

# Auto-renewal
sudo certbot renew --dry-run
```

Certificate auto-renews via cron job.

## Monitoring

### Application Monitoring

Add basic error tracking:

```ruby
# Gemfile
gem 'exception_notification'

# config/environments/production.rb
config.middleware.use ExceptionNotification::Rack,
  email: {
    email_prefix: '[Wedly Error] ',
    sender_address: ENV['SMTP_USERNAME'],
    exception_recipients: ['admin@yourdomain.com']
  }
```

### Server Monitoring

#### Uptime Monitoring
- [UptimeRobot](https://uptimerobot.com) (free)
- [Pingdom](https://www.pingdom.com)

#### Performance Monitoring
- [New Relic](https://newrelic.com) (free tier)
- [Scout APM](https://scoutapm.com)

### Log Management

```bash
# View logs
tail -f log/production.log

# Rotate logs
# Add to /etc/logrotate.d/wedly
/var/www/wedly/log/*.log {
  daily
  missingok
  rotate 14
  compress
  delaycompress
  notifempty
  sharedscripts
}
```

## Backups

### Database Backups

```bash
# Manual backup
mysqldump -u wedly -p wedly_production > backup.sql

# Automated backup script
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
mysqldump -u wedly -p wedly_production | gzip > /backups/wedly_$DATE.sql.gz
find /backups -mtime +30 -delete
```

Add to crontab:
```bash
0 2 * * * /path/to/backup-script.sh
```

### File Backups

If using Active Storage for photos:
```bash
# Backup storage directory
tar -czf storage_backup.tar.gz storage/
```

## Continuous Deployment

### GitHub Actions

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy to Production

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Deploy to server
        uses: appleboy/ssh-action@master
        with:
          host: ${{ secrets.HOST }}
          username: ${{ secrets.USERNAME }}
          key: ${{ secrets.SSH_KEY }}
          script: |
            cd /var/www/wedly
            git pull origin main
            bundle install
            rails db:migrate
            rails assets:precompile
            sudo systemctl restart wedly
```

## Performance Optimization

### Asset Compilation

```bash
# Precompile assets
RAILS_ENV=production rails assets:precompile

# Use CDN (optional)
# config/environments/production.rb
config.asset_host = 'https://cdn.yourdomain.com'
```

### Database Optimization

```ruby
# Add database indexes
add_index :guests, :invite_code
add_index :rsvps, [:guest_id, :status]
add_index :invitations, [:guest_id, :sent_at]
```

### Caching

Enable caching in production:

```ruby
# config/environments/production.rb
config.action_controller.perform_caching = true
config.cache_store = :memory_store
```

## Scaling

### Vertical Scaling (Upgrade Server)

Increase server resources:
- More RAM for handling concurrent requests
- More CPU for faster processing
- More disk for database growth

### Horizontal Scaling (Multiple Servers)

For high traffic:
1. Load balancer
2. Multiple app servers
3. Separate database server
4. Redis for session storage

## Security Checklist

- [ ] SSL certificate installed
- [ ] Force HTTPS in production
- [ ] Environment variables secured
- [ ] Database password strong
- [ ] Admin password changed
- [ ] CSRF protection enabled
- [ ] SQL injection protection (Active Record)
- [ ] XSS protection enabled
- [ ] Security headers configured
- [ ] Firewall configured (only 80, 443, 22)
- [ ] SSH key authentication only
- [ ] Regular security updates
- [ ] Backups configured
- [ ] Monitoring enabled

## Troubleshooting

### 500 Internal Server Error

Check logs:
```bash
tail -f log/production.log
```

Common causes:
- Missing environment variables
- Database connection issues
- Asset compilation errors

### Database Connection Failed

```bash
# Test MySQL connection
mysql -u wedly -p wedly_production

# Check environment variables
printenv | grep DATABASE

# Restart database
sudo systemctl restart mysql
```

### Assets Not Loading

```bash
# Recompile assets
RAILS_ENV=production rails assets:clobber
RAILS_ENV=production rails assets:precompile

# Check Nginx config
sudo nginx -t
```

### Out of Memory

Increase swap:
```bash
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

## Post-Deployment

1. **Test Everything**
   - Login to admin
   - Create test guest
   - Send test invitation
   - Complete test RSVP
   - Check dashboard stats

2. **Configure DNS**
   - A record to server IP
   - CNAME for www
   - MX records (if custom email)

3. **Set Up Monitoring**
   - Uptime monitoring
   - Error notifications
   - Performance tracking

4. **Schedule Backups**
   - Daily database backups
   - Weekly file backups
   - Test restore process

5. **Documentation**
   - Document deployment process
   - Create runbook for common issues
   - Share access with team

## Support Resources

- [Rails Guides](https://guides.rubyonrails.org)
- [DigitalOcean Community](https://www.digitalocean.com/community)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/ruby-on-rails)
- Wedly GitHub Issues
