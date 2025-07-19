# Server Setup

This guide covers preparing a fresh Ubuntu server for Rails Blueprint deployment.

## Initial Server Setup

### 1. Create Deploy User

```bash
# As root
adduser deploy
usermod -aG sudo deploy

# Set up SSH access
su - deploy
mkdir ~/.ssh
chmod 700 ~/.ssh
touch ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

# Add your public key to authorized_keys
```

### 2. Update System

```bash
sudo apt update
sudo apt upgrade -y
sudo apt install -y curl wget git build-essential
```

### 3. Install Required Packages

```bash
# Development tools
sudo apt install -y libssl-dev libreadline-dev zlib1g-dev \
  libyaml-dev libxml2-dev libxslt1-dev libcurl4-openssl-dev \
  libffi-dev libgdbm-dev libncurses5-dev automake libtool bison

# PostgreSQL
sudo apt install -y postgresql postgresql-contrib libpq-dev

# Redis
sudo apt install -y redis-server

# Nginx
sudo apt install -y nginx

# Node.js and Yarn
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs
npm install -g yarn

# ImageMagick (if using image processing)
sudo apt install -y imagemagick
```

## Ruby Installation

### Install rbenv

```bash
# Install rbenv
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
source ~/.bashrc

# Install ruby-build
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build

# Install dependencies for YJIT and jemalloc
sudo apt install -y rustc libjemalloc-dev
```

### Install Ruby with Optimizations

```bash
# Install Ruby 3.4.4 with performance optimizations
RUBY_CONFIGURE_OPTS="--enable-yjit --with-jemalloc" rbenv install 3.4.4
rbenv global 3.4.4

# Verify installation
ruby --version
ruby --yjit -e "puts RubyVM::YJIT.enabled?"  # Should output: true
```

### Install Bundler

```bash
gem install bundler
rbenv rehash
```

## PostgreSQL Setup

### 1. Configure PostgreSQL

```bash
# Switch to postgres user
sudo -u postgres psql

# Create database user
CREATE USER deploy WITH PASSWORD 'secure_password';
ALTER USER deploy CREATEDB;

# Exit psql
\q
```

### 2. Configure Authentication

```bash
# Edit PostgreSQL config
sudo nano /etc/postgresql/14/main/pg_hba.conf

# Change this line:
# local   all   postgres   peer
# To:
# local   all   postgres   md5

# Add line for deploy user:
# local   all   deploy   md5

# Restart PostgreSQL
sudo systemctl restart postgresql
```

### 3. Create Databases

```bash
# As deploy user
createdb myapp_production
createdb myapp_staging
```

## Redis Configuration

### 1. Configure Redis

```bash
# Edit Redis config
sudo nano /etc/redis/redis.conf

# Set supervised mode
supervised systemd

# Set max memory policy
maxmemory-policy allkeys-lru

# Bind to localhost only
bind 127.0.0.1 ::1
```

### 2. Enable and Start Redis

```bash
sudo systemctl enable redis-server
sudo systemctl start redis-server
sudo systemctl status redis-server
```

## Nginx Setup

### 1. Remove Default Site

```bash
sudo rm /etc/nginx/sites-enabled/default
```

### 2. Configure Firewall

```bash
# Install UFW if not present
sudo apt install -y ufw

# Configure firewall
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 'Nginx Full'
sudo ufw --force enable
```

## Application Directory Structure

### Create Directory Structure

```bash
# As deploy user
mkdir -p ~/apps/myapp
cd ~/apps/myapp
mkdir -p shared/config shared/log shared/tmp/pids shared/tmp/cache shared/tmp/sockets

# Set permissions
chmod -R 755 ~/apps
```

### Shared Files

Create these files in `~/apps/myapp/shared/config/`:

#### database.yml

```yaml
production:
  adapter: postgresql
  encoding: unicode
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  database: myapp_production
  username: deploy
  password: <%= ENV['DATABASE_PASSWORD'] %>
  host: localhost
```

#### master.key

```bash
# Copy your local master.key
echo "your_master_key_content" > ~/apps/myapp/shared/config/master.key
chmod 600 ~/apps/myapp/shared/config/master.key
```

## Environment Variables

### 1. Create Environment File

```bash
# Create .env file
nano ~/apps/myapp/shared/.env

# Add environment variables
RAILS_ENV=production
SECRET_KEY_BASE=your_secret_key_base
DATABASE_PASSWORD=your_database_password
REDIS_URL=redis://localhost:6379/0
RAILS_SERVE_STATIC_FILES=false
RAILS_LOG_TO_STDOUT=true
```

### 2. Load Environment Variables

```bash
# Add to ~/.bashrc
echo 'export $(cat ~/apps/myapp/shared/.env | xargs)' >> ~/.bashrc
source ~/.bashrc
```

## Systemd Service Setup

### 1. Create Puma Service

```bash
# This will be done by Mina, but here's the template
sudo nano /etc/systemd/system/puma_myapp_production.service

[Unit]
Description=Puma HTTP Server for myapp (production)
After=network.target

[Service]
Type=notify
WatchdogSec=10
User=deploy
WorkingDirectory=/home/deploy/apps/myapp/current
ExecStart=/home/deploy/.rbenv/bin/rbenv exec bundle exec puma -C config/puma.rb
ExecReload=/bin/kill -SIGUSR1 $MAINPID
Restart=always
RestartSec=1
StandardOutput=append:/home/deploy/apps/myapp/shared/log/puma.log
StandardError=append:/home/deploy/apps/myapp/shared/log/puma.log
EnvironmentFile=/home/deploy/apps/myapp/shared/.env
SyslogIdentifier=puma

[Install]
WantedBy=multi-user.target
```

### 2. Enable Service

```bash
sudo systemctl daemon-reload
sudo systemctl enable puma_myapp_production
```

## Security Hardening

### 1. SSH Configuration

```bash
# Edit SSH config
sudo nano /etc/ssh/sshd_config

# Disable root login
PermitRootLogin no

# Disable password authentication
PasswordAuthentication no

# Restart SSH
sudo systemctl restart sshd
```

### 2. Fail2ban

```bash
# Install fail2ban
sudo apt install -y fail2ban

# Create jail configuration
sudo nano /etc/fail2ban/jail.local

[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 3600

# Start fail2ban
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```

### 3. Automatic Updates

```bash
# Install unattended-upgrades
sudo apt install -y unattended-upgrades

# Enable automatic updates
sudo dpkg-reconfigure -plow unattended-upgrades
```

## Performance Tuning

### 1. Swap File

```bash
# Create swap file (if not exists)
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# Make permanent
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

### 2. System Limits

```bash
# Edit limits
sudo nano /etc/security/limits.conf

# Add these lines
deploy soft nofile 65536
deploy hard nofile 65536
deploy soft nproc 65536
deploy hard nproc 65536
```

## Monitoring Setup

### 1. Install monitoring tools

```bash
# htop for process monitoring
sudo apt install -y htop

# netdata for system monitoring (optional)
bash <(curl -Ss https://my-netdata.io/kickstart.sh)
```

### 2. Log Rotation

```bash
# Create logrotate config
sudo nano /etc/logrotate.d/myapp

/home/deploy/apps/myapp/shared/log/*.log {
  daily
  missingok
  rotate 14
  compress
  delaycompress
  notifempty
  create 0640 deploy deploy
  sharedscripts
  postrotate
    systemctl reload puma_myapp_production.service
  endscript
}
```

## Verification

### Check All Services

```bash
# PostgreSQL
sudo systemctl status postgresql
psql -U deploy -d myapp_production -c "SELECT 1;"

# Redis
redis-cli ping
# Should return: PONG

# Nginx
sudo nginx -t
sudo systemctl status nginx

# Ruby
ruby --version
gem --version
bundle --version
```

## Next Steps

Your server is now ready for deployment:

1. [Configure Mina](mina.md) for deployment
2. [Set up environments](environments.md)
3. [Configure SSL](ssl.md) for HTTPS
4. Run your first deployment