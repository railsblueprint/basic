# Deployment Guide

Rails Blueprint uses [Mina](https://github.com/mina-deploy/mina) for fast, reliable deployments. This guide covers deploying to staging and production environments.

## Overview

The deployment system provides:
- **Zero-downtime deployments** - Seamless updates
- **Rollback capability** - Quick recovery
- **Asset compilation** - Optimized assets
- **Database migrations** - Automated updates
- **Service management** - Puma and background jobs
- **SSL support** - Secure connections

## Prerequisites

### Server Requirements

- Ubuntu 20.04+ or similar Linux distribution
- Ruby 3.4.4 (with YJIT and jemalloc)
- PostgreSQL 14+
- Redis 6+
- Nginx
- Git
- Node.js 18+ and Yarn

### Local Requirements

- SSH access to servers
- Deployment keys configured
- Mina gem installed

## Quick Start

### Initial Setup

```bash
# Configure deployment settings
# Edit config/deploy/staging.rb and production.rb

# Setup server (first time only)
bundle exec mina staging setup

# Configure nginx
bundle exec mina staging nginx:setup

# Setup Puma service
bundle exec mina staging puma:setup

# Deploy
bundle exec mina staging deploy
```

### Subsequent Deployments

```bash
# Deploy default branch
bundle exec mina staging deploy

# Deploy current branch
bundle exec mina staging deploy:current

# Deploy specific branch
BRANCH=feature-branch bundle exec mina staging deploy
```

## Detailed Guides

- **[Server Setup](server-setup.md)** - Prepare your server
- **[Mina Configuration](mina.md)** - Configure deployments
- **[Environment Configuration](environments.md)** - Staging vs Production
- **[SSL Setup](ssl.md)** - Configure HTTPS

## Deployment Workflow

### 1. Pre-deployment Checks

```bash
# Run tests locally
bundle exec rspec

# Check for security issues
bundle audit

# Verify assets compile
RAILS_ENV=production bundle exec rails assets:precompile
```

### 2. Deploy to Staging

```bash
# Deploy to staging first
bundle exec mina staging deploy

# Test on staging
# - Verify features work
# - Check for errors
# - Test integrations
```

### 3. Deploy to Production

```bash
# After staging verification
bundle exec mina production deploy

# Monitor logs
bundle exec mina production logs:tail
```

## Common Tasks

### Running Migrations

```bash
# Migrations run automatically during deploy
# To run manually:
bundle exec mina staging rails:db_migrate
```

### Accessing Console

```bash
# Rails console on server
bundle exec mina staging rails:console

# Database console
bundle exec mina staging rails:dbconsole
```

### Managing Services

```bash
# Restart application
bundle exec mina staging puma:restart

# Check status
bundle exec mina staging puma:status

# Stop/start services
bundle exec mina staging puma:stop
bundle exec mina staging puma:start
```

### Logs and Debugging

```bash
# Tail application logs
bundle exec mina staging logs:tail

# View specific log
bundle exec mina staging run "tail -n 100 /path/to/app/shared/log/production.log"

# Check nginx logs
bundle exec mina staging run "sudo tail -f /var/log/nginx/error.log"
```

## Rollback

If something goes wrong:

```bash
# Rollback to previous release
bundle exec mina staging rollback

# Or manually
bundle exec mina staging run "cd /path/to/app && ln -nfs releases/20240101120000 current"
bundle exec mina staging puma:restart
```

## Troubleshooting

### Common Issues

1. **Bundle install fails**
   - Check Ruby version on server
   - Ensure all system dependencies installed
   - Review Gemfile.lock

2. **Assets not compiling**
   - Verify Node.js and Yarn versions
   - Check for missing packages
   - Review asset pipeline errors

3. **Database migrations fail**
   - Check database credentials
   - Verify database exists
   - Review migration files

4. **Application won't start**
   - Check Puma logs
   - Verify environment variables
   - Review application logs

### Debug Commands

```bash
# Check deployment directory
bundle exec mina staging run "ls -la /path/to/app/current"

# Verify environment
bundle exec mina staging run "cd /path/to/app/current && bundle exec rails runner 'puts Rails.env'"

# Test database connection
bundle exec mina staging run "cd /path/to/app/current && bundle exec rails db:version"
```

## Best Practices

### 1. Always Deploy to Staging First

Test everything on staging before production:
- New features
- Database migrations
- Configuration changes
- Third-party integrations

### 2. Use Environment Variables

Store sensitive data securely:
```bash
# On server
export SECRET_KEY_BASE=your_secret_key
export DATABASE_URL=postgres://user:pass@localhost/db
```

### 3. Monitor After Deployment

Check these after deploying:
- Application logs
- Error tracking (Rollbar/Sentry)
- Performance metrics
- Background job queues

### 4. Automate Health Checks

Use monitoring tools:
- Uptime monitoring
- Health endpoint checks
- Performance tracking
- Error rate monitoring

## Security Considerations

1. **Use Deploy Keys** - Never use personal SSH keys
2. **Limit Server Access** - Only deployment user
3. **Secure Credentials** - Use encrypted credentials
4. **Regular Updates** - Keep server packages updated
5. **Firewall Rules** - Only open necessary ports

## Next Steps

- [Set up your server](server-setup.md)
- [Configure Mina](mina.md)
- [Set up SSL](ssl.md)
- [Configure environments](environments.md)