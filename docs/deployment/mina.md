# Mina Configuration

Mina is a fast deployment tool that Rails Blueprint uses for zero-downtime deployments. This guide covers configuring and using Mina.

## Overview

Mina provides:
- **Fast deployments** - Typically under 60 seconds
- **Single SSH connection** - Efficient and secure
- **Ruby DSL** - Easy to customize
- **Rollback support** - Quick recovery
- **Task automation** - Custom deployment tasks

## Configuration Files

### Base Configuration

The base configuration is in `config/deploy.rb`:

```ruby
require 'mina/rails'
require 'mina/git'
require 'mina/rbenv'
require 'mina_extensions/helpers'

# Basic settings
set :application_name, 'myapp'
set :domain, 'your-server.com'
set :deploy_to, '/home/deploy/apps/myapp'
set :repository, 'git@github.com:yourusername/myapp.git'
set :branch, 'main'
set :user, 'deploy'
set :forward_agent, true

# Shared paths
set :shared_dirs, fetch(:shared_dirs, []).push(
  'log',
  'tmp/pids',
  'tmp/cache',
  'tmp/sockets',
  'public/uploads',
  'node_modules',
  'storage'
)

set :shared_files, fetch(:shared_files, []).push(
  'config/database.yml',
  'config/master.key',
  '.env'
)

# Ruby version management
task :remote_environment do
  invoke :'rbenv:load'
end

# Setup task
task :setup do
  command %{mkdir -p "#{fetch(:shared_path)}/log"}
  command %{mkdir -p "#{fetch(:shared_path)}/config"}
  command %{mkdir -p "#{fetch(:shared_path)}/tmp/pids"}
  command %{mkdir -p "#{fetch(:shared_path)}/tmp/cache"}
  command %{mkdir -p "#{fetch(:shared_path)}/tmp/sockets"}
  
  command %{touch "#{fetch(:shared_path)}/config/database.yml"}
  command %{touch "#{fetch(:shared_path)}/config/master.key"}
  command %{touch "#{fetch(:shared_path)}/.env"}
  
  comment "Be sure to edit shared files."
end

# Deployment task
task :deploy do
  deploy do
    invoke :'git:ensure_pushed'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
    invoke :'rails:assets_precompile'
    invoke :'deploy:cleanup'

    on :launch do
      invoke :'puma:phased_restart'
      invoke :'good_job:restart'
    end
  end
end
```

### Environment-Specific Configuration

#### Staging (config/deploy/staging.rb)

```ruby
require_relative '../deploy'

set :domain, 'staging.example.com'
set :deploy_to, '/home/deploy/apps/myapp_staging'
set :branch, 'develop'
set :rails_env, 'staging'

# Staging-specific settings
set :keep_releases, 3

# Staging credentials
set :shared_files, fetch(:shared_files, []).push(
  'config/credentials/staging.key'
)
```

#### Production (config/deploy/production.rb)

```ruby
require_relative '../deploy'

set :domain, 'example.com'
set :deploy_to, '/home/deploy/apps/myapp'
set :branch, 'main'
set :rails_env, 'production'

# Production-specific settings
set :keep_releases, 5

# Production credentials  
set :shared_files, fetch(:shared_files, []).push(
  'config/credentials/production.key'
)
```

## Deployment Tasks

### Basic Deployment

```bash
# Deploy to staging
bundle exec mina staging deploy

# Deploy to production
bundle exec mina production deploy

# Deploy current branch
bundle exec mina staging deploy:current

# Deploy specific branch
BRANCH=feature-xyz bundle exec mina staging deploy
```

### Initial Setup

```bash
# First-time setup
bundle exec mina staging setup

# Verify setup
bundle exec mina staging setup:check
```

### Service Management

```ruby
# In config/deploy.rb

# Puma tasks
namespace :puma do
  desc "Start puma"
  task :start do
    command "sudo systemctl start puma_#{fetch(:application_name)}_#{fetch(:rails_env)}"
  end

  desc "Stop puma"
  task :stop do
    command "sudo systemctl stop puma_#{fetch(:application_name)}_#{fetch(:rails_env)}"
  end

  desc "Restart puma"
  task :restart do
    command "sudo systemctl restart puma_#{fetch(:application_name)}_#{fetch(:rails_env)}"
  end

  desc "Phased restart puma"
  task :phased_restart do
    command "sudo systemctl reload puma_#{fetch(:application_name)}_#{fetch(:rails_env)}"
  end
end

# Good Job tasks
namespace :good_job do
  desc "Start Good Job"
  task :start do
    command "sudo systemctl start good_job_#{fetch(:application_name)}_#{fetch(:rails_env)}"
  end

  desc "Stop Good Job"
  task :stop do
    command "sudo systemctl stop good_job_#{fetch(:application_name)}_#{fetch(:rails_env)}"
  end

  desc "Restart Good Job"
  task :restart do
    command "sudo systemctl restart good_job_#{fetch(:application_name)}_#{fetch(:rails_env)}"
  end
end
```

### Database Tasks

```ruby
namespace :rails do
  desc "Run migrations with data"
  task :db_migrate do
    command "#{fetch(:rails)} db:migrate:with_data"
  end

  desc "Seed database"
  task :db_seed do
    command "#{fetch(:rails)} db:seed"
  end

  desc "Create database"
  task :db_create do
    command "#{fetch(:rails)} db:create"
  end
end
```

### Maintenance Mode

```ruby
namespace :maintenance do
  desc "Enable maintenance mode"
  task :on do
    command "touch #{fetch(:current_path)}/tmp/maintenance.txt"
  end

  desc "Disable maintenance mode"
  task :off do
    command "rm -f #{fetch(:current_path)}/tmp/maintenance.txt"
  end
end
```

## Custom Tasks

### Backup Task

```ruby
desc "Backup database"
task :backup do
  command %{
    backup_name="backup_$(date +%Y%m%d_%H%M%S).sql"
    pg_dump #{fetch(:db_name)} > #{fetch(:shared_path)}/backups/$backup_name
    echo "Backup created: $backup_name"
  }
end
```

### Cache Clear

```ruby
desc "Clear application cache"
task :cache_clear do
  command "cd #{fetch(:current_path)} && #{fetch(:rails)} cache:clear"
  command "cd #{fetch(:current_path)} && #{fetch(:rails)} tmp:clear"
end
```

### Log Tasks

```ruby
namespace :logs do
  desc "Tail application logs"
  task :tail do
    command "tail -f #{fetch(:shared_path)}/log/#{fetch(:rails_env)}.log"
  end

  desc "Download logs"
  task :download do
    queue! %[scp #{fetch(:user)}@#{fetch(:domain)}:#{fetch(:shared_path)}/log/#{fetch(:rails_env)}.log ./]
  end
end
```

## Advanced Configuration

### Multiple Servers

```ruby
# For load-balanced setup
set :domain, 'web1.example.com'
set :domains, ['web1.example.com', 'web2.example.com']

task :deploy do
  isolate do
    domains.each do |domain|
      set :domain, domain
      invoke :deploy_single
    end
  end
end
```

### Environment Variables

```ruby
# Load from .env file
task :load_env do
  command %{export $(cat #{fetch(:shared_path)}/.env | xargs)}
end

# Use in other tasks
task :console do
  invoke :load_env
  command "cd #{fetch(:current_path)} && #{fetch(:rails)} console"
end
```

### Asset Compilation

```ruby
# Skip assets if no changes
task :check_assets do
  command %{
    if git diff --name-only HEAD HEAD~1 | grep -E "(app/assets|vendor/assets|Gemfile.lock)" > /dev/null; then
      echo "Asset changes detected, compiling..."
      invoke :'rails:assets_precompile'
    else
      echo "No asset changes, skipping compilation"
    fi
  }
end
```

## Nginx Configuration

### Setup Nginx

```ruby
namespace :nginx do
  desc "Setup nginx configuration"
  task :setup do
    erb_path = File.expand_path('../templates/nginx.conf.erb', __FILE__)
    erb = File.read(erb_path)
    config = ERB.new(erb).result(binding)
    
    command %{echo "#{config}" > /tmp/nginx_#{fetch(:application_name)}}
    command %{sudo mv /tmp/nginx_#{fetch(:application_name)} /etc/nginx/sites-available/#{fetch(:application_name)}}
    command %{sudo ln -nfs /etc/nginx/sites-available/#{fetch(:application_name)} /etc/nginx/sites-enabled/#{fetch(:application_name)}}
    command %{sudo nginx -t}
    command %{sudo systemctl reload nginx}
  end
end
```

### Nginx Template

```erb
# config/deploy/templates/nginx.conf.erb
upstream <%= fetch(:application_name) %>_puma {
  server unix:<%= fetch(:puma_socket) %> fail_timeout=0;
}

server {
  listen 80;
  server_name <%= fetch(:domain) %>;

  root <%= fetch(:current_path) %>/public;
  try_files $uri/index.html $uri @app;

  location @app {
    proxy_pass http://<%= fetch(:application_name) %>_puma;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Forwarded-Host $host;
    proxy_set_header Host $http_host;
    proxy_redirect off;
  }

  location ~ ^/assets/ {
    gzip_static on;
    expires max;
    add_header Cache-Control public;
  }

  error_page 500 502 503 504 /500.html;
  client_max_body_size 4G;
  keepalive_timeout 10;
}
```

## Rollback

### Manual Rollback

```ruby
desc "Rollback to previous release"
task :rollback do
  command %{
    if [ -d "#{fetch(:deploy_to)}/releases" ] && [ "$(ls -1 #{fetch(:deploy_to)}/releases | wc -l)" -gt 1 ]; then
      echo "Rolling back to previous release..."
      cd #{fetch(:deploy_to)}
      mv current current_tmp
      mv releases/$(ls -1 releases | tail -2 | head -1) current
      rm -rf current_tmp
      #{echo_cmd %[invoke :'puma:phased_restart']}
    else
      echo "No previous releases found"
    fi
  }
end
```

## Troubleshooting

### Debug Mode

```bash
# Run with verbose output
bundle exec mina staging deploy --verbose

# Simulate deployment
bundle exec mina staging deploy --simulate
```

### Common Issues

1. **SSH Connection Failed**
   ```bash
   # Test SSH connection
   ssh deploy@your-server.com
   
   # Check SSH agent
   ssh-add -l
   ```

2. **Git Push Required**
   ```bash
   # Push your changes
   git push origin branch-name
   
   # Or skip check
   bundle exec mina staging deploy skip_git_push=true
   ```

3. **Bundle Install Fails**
   ```bash
   # Clear bundler cache
   bundle exec mina staging run "cd current && rm -rf vendor/bundle"
   bundle exec mina staging deploy
   ```

## Best Practices

### 1. Test Deployments

Always test deployment scripts:
```bash
bundle exec mina staging deploy --simulate
```

### 2. Use Shared Files

Keep sensitive files out of repository:
- database.yml
- master.key
- .env files

### 3. Monitor Deployments

```ruby
# Add notifications
task :notify do
  # Slack notification
  command %{curl -X POST -H 'Content-type: application/json' \
    --data '{"text":"Deployment completed for #{fetch(:application_name)}"}' \
    YOUR_SLACK_WEBHOOK_URL}
end
```

### 4. Backup Before Major Changes

```bash
bundle exec mina production backup
bundle exec mina production deploy
```

## Next Steps

- [Configure environments](environments.md)
- [Set up SSL](ssl.md)
- Review [deployment guide](index.md)