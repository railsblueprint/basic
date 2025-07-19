# Troubleshooting Guide

Common issues and solutions for Rails Blueprint applications.

## Installation Issues

### Bundle Install Fails

**Problem**: `bundle install` fails with native extension errors

**Solutions**:

1. **Missing PostgreSQL**:
   ```bash
   # macOS
   brew install postgresql@14
   bundle config build.pg --with-pg-config=/usr/local/opt/postgresql@14/bin/pg_config
   
   # Ubuntu/Debian
   sudo apt-get install libpq-dev
   ```

2. **Missing dependencies**:
   ```bash
   # Ubuntu/Debian
   sudo apt-get install build-essential libssl-dev libreadline-dev zlib1g-dev
   
   # macOS
   xcode-select --install
   ```

3. **Wrong Ruby version**:
   ```bash
   rbenv install 3.4.4
   rbenv local 3.4.4
   gem install bundler
   ```

### Yarn/Node Issues

**Problem**: JavaScript dependencies won't install

**Solutions**:

```bash
# Check Node version (should be 18+)
node --version

# Update Node
# macOS
brew upgrade node

# Ubuntu (using NodeSource)
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Clear yarn cache
yarn cache clean
yarn install --check-files
```

## Database Issues

### Database Connection Failed

**Problem**: Can't connect to PostgreSQL

**Solutions**:

1. **Check PostgreSQL is running**:
   ```bash
   # macOS
   brew services start postgresql@14
   
   # Linux
   sudo systemctl start postgresql
   sudo systemctl status postgresql
   ```

2. **Verify credentials**:
   ```bash
   # Test connection
   psql -U postgres -h localhost
   
   # Check database.yml
   cat config/database.yml
   ```

3. **Create missing database**:
   ```bash
   bundle exec rails db:create
   # or manually
   createdb myapp_development
   ```

### Migration Errors

**Problem**: Migrations fail to run

**Solutions**:

1. **Pending migrations**:
   ```bash
   # Check status
   bundle exec rails db:migrate:status
   
   # Run pending migrations
   bundle exec rails db:migrate
   ```

2. **Data migrations**:
   ```bash
   # Rails Blueprint uses data migrations
   bundle exec rails db:migrate:with_data
   
   # Run only data migrations
   bundle exec rails data:migrate
   ```

3. **Reset database**:
   ```bash
   # Development only!
   bundle exec rails db:drop
   bundle exec rails db:create
   bundle exec rails db:migrate:with_data
   bundle exec rails db:seed
   ```

## Authentication Issues

### Can't Login

**Problem**: Login fails with correct credentials

**Solutions**:

1. **Account not confirmed**:
   ```ruby
   # Rails console
   user = User.find_by(email: 'user@example.com')
   user.confirmed?
   user.confirm! # Force confirmation
   ```

2. **Account locked**:
   ```ruby
   user.locked_at
   user.unlock_access!
   ```

3. **Password reset**:
   ```ruby
   user.password = 'new_password'
   user.password_confirmation = 'new_password'
   user.save!
   ```

### Email Confirmation Not Sent

**Problem**: Confirmation emails not delivered

**Solutions**:

1. **Development - Check Letter Opener**:
   ```
   http://localhost:3000/letter_opener
   ```

2. **Check email configuration**:
   ```ruby
   # Rails console
   ActionMailer::Base.delivery_method
   ActionMailer::Base.smtp_settings
   ```

3. **Send test email**:
   ```ruby
   UserMailer.welcome_email(User.first).deliver_now
   ```

## Asset Issues

### Assets Not Loading

**Problem**: CSS/JS not loading in development

**Solutions**:

1. **Compile assets**:
   ```bash
   # Development
   bundle exec rails assets:precompile
   
   # Clean and recompile
   bundle exec rails assets:clobber
   bundle exec rails assets:precompile
   ```

2. **Check asset pipeline**:
   ```bash
   # Start with asset debugging
   bin/dev
   
   # Check for compilation errors in terminal
   ```

3. **Clear cache**:
   ```bash
   bundle exec rails tmp:clear
   bundle exec rails assets:clean
   ```

### Assets Missing in Production

**Problem**: 404 errors for assets in production

**Solutions**:

1. **Precompile before deploy**:
   ```bash
   RAILS_ENV=production bundle exec rails assets:precompile
   ```

2. **Check nginx configuration**:
   ```nginx
   location ~ ^/assets/ {
     gzip_static on;
     expires max;
     add_header Cache-Control public;
   }
   ```

3. **Verify files exist**:
   ```bash
   ls -la public/assets/
   ```

## Background Job Issues

### Jobs Not Processing

**Problem**: Background jobs stuck in queue

**Solutions**:

1. **Check GoodJob process**:
   ```bash
   # Development
   bundle exec good_job start
   
   # Production - check systemd
   sudo systemctl status good_job_myapp_production
   ```

2. **Clear stuck jobs**:
   ```ruby
   # Rails console
   GoodJob::Job.where(finished_at: nil).where('created_at < ?', 1.hour.ago).destroy_all
   ```

3. **Monitor queue**:
   ```
   http://localhost:3000/admin/good_job
   ```

### Job Failures

**Problem**: Jobs failing repeatedly

**Solutions**:

1. **Check job logs**:
   ```ruby
   # Find failed jobs
   GoodJob::Job.where.not(error: nil).last(10)
   
   # Retry failed job
   job = GoodJob::Job.find(id)
   job.retry_job
   ```

2. **Disable retries temporarily**:
   ```ruby
   class ProblematicJob < ApplicationJob
     # Skip retries while debugging
     retry_on StandardError, attempts: 0
   end
   ```

## Performance Issues

### Slow Page Loads

**Problem**: Application running slowly

**Solutions**:

1. **Check for N+1 queries**:
   ```ruby
   # Enable Bullet in development
   # Check browser console for warnings
   
   # Fix with includes
   @posts = Post.includes(:author, :categories).published
   ```

2. **Database indexes**:
   ```ruby
   # Check slow queries
   # Visit /admin/pg_hero
   
   # Add missing indexes
   add_index :posts, :published_at
   add_index :users, :email
   ```

3. **Enable caching**:
   ```bash
   # Toggle caching in development
   rails dev:cache
   ```

### High Memory Usage

**Problem**: Application using too much memory

**Solutions**:

1. **Check for memory leaks**:
   ```ruby
   # Monitor object allocation
   GC.stat
   ObjectSpace.each_object(Class).count
   ```

2. **Optimize workers**:
   ```bash
   # Reduce worker count
   WEB_CONCURRENCY=1
   RAILS_MAX_THREADS=3
   ```

## Deployment Issues

### Deploy Fails

**Problem**: Mina deployment errors

**Solutions**:

1. **SSH connection**:
   ```bash
   # Test SSH
   ssh deploy@server.com
   
   # Check SSH agent
   ssh-add -l
   ssh-add ~/.ssh/id_rsa
   ```

2. **Git issues**:
   ```bash
   # Push changes
   git push origin main
   
   # Skip git check
   bundle exec mina production deploy skip_git_push=true
   ```

3. **Bundle failures**:
   ```bash
   # Clear bundle cache on server
   bundle exec mina production run "cd current && rm -rf vendor/bundle"
   bundle exec mina production deploy
   ```

### Application Won't Start

**Problem**: Site shows 502 error after deploy

**Solutions**:

1. **Check Puma**:
   ```bash
   bundle exec mina production run "systemctl status puma_myapp_production"
   bundle exec mina production logs:tail
   ```

2. **Environment variables**:
   ```bash
   # Verify on server
   bundle exec mina production run "cd current && bundle exec rails runner 'puts ENV.keys.sort'"
   ```

3. **Database migrations**:
   ```bash
   bundle exec mina production rails:db_migrate
   ```

## Common Rails Console Commands

### User Management
```ruby
# Find user
u = User.find_by(email: 'user@example.com')

# Unlock account
u.unlock_access!

# Confirm email
u.confirm!

# Reset password
u.password = 'newpassword123'
u.save!

# Add admin role
u.add_role(:admin)
```

### Data Cleanup
```ruby
# Remove old logs
Log.where('created_at < ?', 30.days.ago).destroy_all

# Clear cache
Rails.cache.clear

# Reset counters
Post.reset_counters(post.id, :comments)
```

### Debugging
```ruby
# Check environment
Rails.env
Rails.application.config.force_ssl

# View settings
Setting.pluck(:key, :value)
AppConfig.mail.from

# Test mailers
ActionMailer::Base.deliveries.clear
UserMailer.welcome_email(User.first).deliver_now
ActionMailer::Base.deliveries.last
```

## Getting Help

### Resources

1. **Rails Blueprint Issues**: 
   - Check existing issues on GitHub
   - Open new issue with details

2. **Rails Guides**: 
   - https://guides.rubyonrails.org/

3. **Error Messages**:
   - Google the exact error message
   - Check Stack Overflow

### Debug Information to Collect

When reporting issues, include:

```bash
# Ruby version
ruby --version

# Rails version
bundle exec rails --version

# Database version
psql --version

# Full error message and backtrace
# Relevant log entries
# Steps to reproduce
```

## Prevention Tips

1. **Keep dependencies updated**:
   ```bash
   bundle update --conservative
   yarn upgrade
   ```

2. **Run tests before deploying**:
   ```bash
   bundle exec rspec
   bundle exec rubocop
   ```

3. **Monitor logs**:
   - Check application logs regularly
   - Set up error tracking (Rollbar/Sentry)
   - Monitor performance

4. **Regular backups**:
   - Database backups
   - Credential backups
   - Configuration backups