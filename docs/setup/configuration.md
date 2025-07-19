# Configuration Guide

Rails Blueprint uses multiple configuration methods to provide flexibility across environments.

## Configuration Overview

Rails Blueprint uses a hierarchical configuration system:

1. **Environment Variables** - Highest priority
2. **Rails Credentials** - Encrypted secrets
3. **Database Settings** - Dynamic runtime configuration
4. **YAML Configuration** - Default values

## Application Configuration

### 1. Main Configuration File

After running `blueprint:init`, you'll have `config/app.yml`:

```yaml
defaults: &defaults
  name: 'Your App Name'
  domain: 'localhost:3000'
  protocol: 'http'
  mail_from: 'noreply@localhost'
  support_email: 'support@localhost'

development:
  <<: *defaults

test:
  <<: *defaults

staging:
  <<: *defaults
  domain: 'staging.yourdomain.com'
  protocol: 'https'
  mail_from: 'noreply@staging.yourdomain.com'

production:
  <<: *defaults
  domain: 'yourdomain.com'
  protocol: 'https'
  mail_from: 'noreply@yourdomain.com'
```

**Important**: Update the domain settings for staging and production before deployment.

### 2. Database Configuration

Edit `config/database.yml` if you need non-default database settings:

```yaml
default: &default
  adapter: postgresql
  encoding: unicode
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>

development:
  <<: *default
  database: <%= ENV['DB_NAME'] || 'myapp_development' %>
  username: <%= ENV['DB_USER'] %>
  password: <%= ENV['DB_PASSWORD'] %>
  host: <%= ENV['DB_HOST'] || 'localhost' %>
```

## Rails Credentials

Rails Blueprint uses encrypted credentials for sensitive data.

### Editing Credentials

```bash
# Development/Test credentials
rails credentials:edit

# Staging credentials
rails credentials:edit --environment staging

# Production credentials
rails credentials:edit --environment production
```

### Credential Structure

```yaml
secret_key_base: your_generated_secret_key

# Database credentials (if not using ENV vars)
database:
  user: postgres
  password: secure_password

# Redis configuration
redis:
  url: redis://localhost:6379/1

# Email service credentials
smtp:
  address: smtp.example.com
  port: 587
  user_name: smtp_user
  password: smtp_password

# Third-party service keys
aws:
  access_key_id: your_key
  secret_access_key: your_secret

# Error tracking
rollbar:
  token: your_rollbar_token
```

## Email Configuration

### SMTP Settings

Rails Blueprint supports multiple email delivery methods:

1. **Letter Opener (Development)**
   - Emails open in browser
   - No configuration needed

2. **SMTP**
   ```yaml
   # In credentials
   smtp:
     address: smtp.gmail.com
     port: 587
     domain: yourdomain.com
     user_name: your_email@gmail.com
     password: app_specific_password
     authentication: plain
     enable_starttls_auto: true
   ```

3. **Mailgun**
   ```yaml
   mailgun:
     api_key: your_mailgun_api_key
     domain: mg.yourdomain.com
   ```

4. **AWS SES**
   ```yaml
   ses:
     access_key_id: your_access_key
     secret_access_key: your_secret_key
     region: us-east-1
   ```

### Email Templates

Rails Blueprint stores email templates in the database. Access them at `/admin/mail_templates`.

## Environment Variables

### Development (.env file)

```bash
# Server
PORT=3000
WEB_CONCURRENCY=1

# Database
DB_HOST=localhost
DB_NAME=myapp_development
DB_USER=postgres
DB_PASSWORD=

# Redis
REDIS_URL=redis://localhost:6379/0

# Rails
RAILS_ENV=development
RAILS_LOG_TO_STDOUT=true
RAILS_SERVE_STATIC_FILES=true
```

### Production Environment

Set these on your server:

```bash
# Required
SECRET_KEY_BASE=your_production_secret
DATABASE_URL=postgres://user:pass@host/dbname
REDIS_URL=redis://localhost:6379/0

# Recommended
RAILS_ENV=production
RAILS_LOG_TO_STDOUT=true
RAILS_SERVE_STATIC_FILES=false
WEB_CONCURRENCY=2
RAILS_MAX_THREADS=5
```

## Settings System

Rails Blueprint includes a database-backed settings system accessible at `/admin/settings`.

### Using Settings in Code

```ruby
# Get a setting
AppConfig.mail.from
AppConfig.features.signup_enabled

# Check if setting exists
if AppConfig.features.beta_features_enabled
  # Enable beta features
end

# With default value
AppConfig.get('features.new_feature', default: false)
```

### Creating Settings via Migration

```ruby
# In a data migration
Setting.create!(
  key: 'features.new_feature',
  value: 'true',
  type: 'boolean',
  section: 'features',
  description: 'Enable new feature'
)
```

## Security Considerations

1. **Never commit credentials** - Use encrypted credentials or environment variables
2. **Rotate keys regularly** - Especially after team changes
3. **Use strong secrets** - Generate with `rails secret`
4. **Limit production access** - Only deployment systems should have production keys
5. **Backup encryption keys** - Store securely in password manager

## Next Steps

- [Set up the database](database.md)
- [Configure deployment](../deployment/environments.md)
- [Manage settings](../features/settings.md)