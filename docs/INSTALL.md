# Installation Guide

Complete step-by-step installation instructions for Wedly.

## System Requirements

- Ruby 3.2.0 or higher
- MySQL 5.7+ or MariaDB 10.3+
- Git
- Node.js (for asset compilation in production)

## Development Setup

### 1. Install Ruby

#### macOS (using rbenv)
```bash
brew install rbenv ruby-build
rbenv install 3.2.0
rbenv global 3.2.0
```

#### Ubuntu/Debian
```bash
sudo apt-get update
sudo apt-get install -y rbenv ruby-build
rbenv install 3.2.0
rbenv global 3.2.0
```

### 2. Install MySQL

#### macOS
```bash
brew install mysql
brew services start mysql
```

#### Ubuntu/Debian
```bash
sudo apt-get install mysql-server
sudo systemctl start mysql
sudo systemctl enable mysql
```

### 3. Clone and Setup

```bash
# Clone repository
git clone <repository-url>
cd wedly

# Make sure rbenv is loaded (or open a new terminal)
source ~/.zshrc

# Option 1: Use setup script (recommended)
./setup.sh

# Option 2: Manual installation
gem install bundler
bundle install
cp .env.example .env

# Edit .env with your configuration
# Required variables:
# - DATABASE_USERNAME
# - DATABASE_PASSWORD
# - SMTP_ADDRESS (optional, for invitations)
# - SMTP_USERNAME (optional)
# - SMTP_PASSWORD (optional)
```

### 4. Database Setup

```bash
# Create database
rails db:create

# Run migrations
rails db:migrate

# Load seed data (optional)
rails db:seed
```

The seed data creates:
- Default admin user (admin@wedly.com / password)
- Sample wedding with events
- Sample household and guests

### 5. Verify Installation

```bash
# Start Rails server
./start.sh

# Or manually (ensure rbenv is loaded first)
rails server

# In another terminal, test the setup
curl http://localhost:3000
```

Visit http://localhost:3000/admin/login to access the admin panel.

**Note**: If you get bundler errors, ensure you're using Ruby 3.2.0:
```bash
ruby --version  # Should show 3.2.0
# If not, run: source ~/.zshrc
```

## Production Setup

### 1. Server Requirements

- Ubuntu 20.04+ or similar Linux distribution
- 1GB+ RAM
- 20GB+ disk space
- Public IP address or domain name

### 2. Install System Dependencies

```bash
# Update system
sudo apt-get update
sudo apt-get upgrade -y

# Install Ruby dependencies
sudo apt-get install -y git curl libssl-dev libreadline-dev \
  zlib1g-dev autoconf bison build-essential libyaml-dev \
  libreadline-dev libncurses5-dev libffi-dev libgdbm-dev

# Install Ruby (using rbenv)
curl -fsSL https://github.com/rbenv/rbenv-installer/raw/main/bin/rbenv-installer | bash
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
source ~/.bashrc

rbenv install 3.2.0
rbenv global 3.2.0

# Install MySQL
sudo apt-get install -y mysql-server mysql-client libmysqlclient-dev
sudo systemctl start mysql
sudo systemctl enable mysql

# Secure MySQL installation
sudo mysql_secure_installation
```

### 3. Deploy Application

```bash
# Create app directory
sudo mkdir -p /var/www/wedly
sudo chown $USER:$USER /var/www/wedly

# Clone application
cd /var/www/wedly
git clone <repository-url> .

# Install dependencies
bundle install --deployment --without development test

# Setup environment
cp .env.example .env
nano .env  # Edit with production values

# Setup database
RAILS_ENV=production rails db:create
RAILS_ENV=production rails db:migrate
RAILS_ENV=production rails db:seed

# Precompile assets
RAILS_ENV=production rails assets:precompile

# Generate secret key
RAILS_ENV=production rails secret
# Add to .env as SECRET_KEY_BASE
```

### 4. Configure Web Server

#### Option A: Puma with Systemd

Create `/etc/systemd/system/wedly.service`:

```ini
[Unit]
Description=Wedly Rails Application
After=network.target

[Service]
Type=simple
User=deploy
WorkingDirectory=/var/www/wedly
ExecStart=/home/deploy/.rbenv/shims/bundle exec puma -C config/puma.rb
Restart=always
Environment=RAILS_ENV=production

[Install]
WantedBy=multi-user.target
```

Start the service:
```bash
sudo systemctl daemon-reload
sudo systemctl start wedly
sudo systemctl enable wedly
```

#### Option B: Using Nginx as Reverse Proxy

Install Nginx:
```bash
sudo apt-get install -y nginx
```

Create `/etc/nginx/sites-available/wedly`:

```nginx
upstream wedly {
  server unix:///var/www/wedly/tmp/sockets/puma.sock;
}

server {
  listen 80;
  server_name your-domain.com;

  root /var/www/wedly/public;

  location / {
    try_files $uri @app;
  }

  location @app {
    proxy_pass http://wedly;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
  }
}
```

Enable the site:
```bash
sudo ln -s /etc/nginx/sites-available/wedly /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

### 5. SSL Certificate (Optional but Recommended)

```bash
# Install Certbot
sudo apt-get install -y certbot python3-certbot-nginx

# Obtain certificate
sudo certbot --nginx -d your-domain.com
```

## Troubleshooting

### Database Connection Issues

```bash
# Check MySQL is running
sudo systemctl status mysql

# Test MySQL connection
mysql -u root -p

# Grant permissions if needed
mysql -u root -p
CREATE DATABASE wedly_production;
CREATE USER 'wedly'@'localhost' IDENTIFIED BY 'your_password';
GRANT ALL PRIVILEGES ON wedly_production.* TO 'wedly'@'localhost';
FLUSH PRIVILEGES;
```

### Permission Issues

```bash
# Fix file permissions
sudo chown -R www-data:www-data /var/www/wedly
sudo chmod -R 755 /var/www/wedly
```

### Asset Compilation Issues

```bash
# Clear assets and recompile
RAILS_ENV=production rails assets:clobber
RAILS_ENV=production rails assets:precompile
```

### View Logs

```bash
# Development
tail -f log/development.log

# Production
tail -f log/production.log

# Systemd service logs
sudo journalctl -u wedly -f
```

## Next Steps

After installation:

1. [Configure SMTP](SMTP_SETUP.md) for email delivery
2. [Set up admin authentication](ADMIN_AUTH.md)
3. Review [RSVP flow documentation](RSVP_FLOW.md)
4. Configure your wedding details in the admin panel
