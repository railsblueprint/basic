# Environment Configuration

Rails Blueprint supports multiple deployment environments with different configurations for development, staging, and production.

## Environment Overview

| Environment | Purpose | Branch | Domain | SSL |
|------------|---------|---------|---------|-----|
| Development | Local development | any | localhost:3000 | No |
| Test | Automated testing | any | N/A | No |
| Staging | Pre-production testing | develop | staging.example.com | Yes |
| Production | Live application | main | example.com | Yes |

## Rails Environments

### Development Environment

Default settings for local development:

```ruby
# config/environments/development.rb
Rails.application.configure do
  config.cache_classes = false
  config.eager_load = false
  config.consider_all_requests_local = true
  config.server_timing = true
  
  # Enable caching
  config.action_controller.perform_caching = true
  config.cache_store = :redis_cache_store, { url: ENV.fetch("REDIS_URL") }
  
  # Print deprecation notices
  config.active_support.deprecation = :log
  
  # Raise error on missing translations
  config.i18n.raise_on_missing_translations = true
  
  # Email settings
  config.action_mailer.delivery_method = :letter_opener
  config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
end
```

### Staging Environment

Mirror production with debugging enabled:

```ruby
# config/environments/staging.rb
Rails.application.configure do
  # Production-like settings
  config.cache_classes = true
  config.eager_load = true
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true
  
  # But with more verbose logging
  config.log_level = :debug
  config.log_tags = [:request_id]
  
  # Force SSL
  config.force_ssl = true
  
  # Email settings for staging
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.default_url_options = { host: 'staging.example.com' }
  
  # Show full error reports for easier debugging
  config.consider_all_requests_local = true
end
```

### Production Environment

Optimized for performance and security:

```ruby
# config/environments/production.rb
Rails.application.configure do
  config.cache_classes = true
  config.eager_load = true
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true
  
  # Compress CSS using a preprocessor
  config.assets.css_compressor = :sass
  
  # Do not fallback to assets pipeline
  config.assets.compile = false
  
  # Force SSL
  config.force_ssl = true
  
  # Use lowest log level to ensure availability of diagnostic information
  config.log_level = :info
  
  # Prepend all log lines with the following tags
  config.log_tags = [:request_id]
  
  # Use a different cache store in production
  config.cache_store = :redis_cache_store, {
    url: ENV.fetch("REDIS_URL"),
    expires_in: 90.minutes
  }
  
  # Email configuration
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.default_url_options = { host: 'example.com' }
end
```

## Credentials Management

### Environment-Specific Credentials

Rails Blueprint uses separate credentials for each environment:

```bash
# Edit credentials
rails credentials:edit                    # Development/test
rails credentials:edit --environment staging
rails credentials:edit --environment production
```

### Credential Structure

```yaml
# Common structure for all environments
secret_key_base: your_secret_key_base

# Database
database:
  username: deploy
  password: secure_password

# Redis
redis:
  url: redis://localhost:6379/0

# Email service (example with SendGrid)
smtp:
  address: smtp.sendgrid.net
  port: 587
  user_name: apikey
  password: your_sendgrid_api_key
  domain: example.com

# Third-party services
aws:
  access_key_id: your_key_id
  secret_access_key: your_secret_key
  region: us-east-1
  bucket: myapp-production

# Error tracking
rollbar:
  access_token: your_rollbar_token
  environment: production

# Analytics
google_analytics:
  tracking_id: UA-XXXXXXXX-X
```

## Application Configuration

### Environment-Specific Settings

In `config/app.yml`:

```yaml
defaults: &defaults
  name: 'Rails Blueprint'
  support_email: 'support@example.com'
  mail_from: 'noreply@example.com'
  
development:
  <<: *defaults
  domain: 'localhost:3000'
  protocol: 'http'
  
staging:
  <<: *defaults
  domain: 'staging.example.com'
  protocol: 'https'
  mail_from: 'noreply@staging.example.com'
  
production:
  <<: *defaults
  domain: 'example.com'
  protocol: 'https'
  mail_from: 'noreply@example.com'
```

### Environment Variables

#### Development (.env)

```bash
# Rails
RAILS_ENV=development
PORT=3000
WEB_CONCURRENCY=1
RAILS_MAX_THREADS=5

# Database
DB_HOST=localhost
DB_NAME=myapp_development
DB_USER=postgres
DB_PASSWORD=

# Redis
REDIS_URL=redis://localhost:6379/0

# Optional services
ROLLBAR_ACCESS_TOKEN=
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
```

#### Staging/Production

Set on server or in deployment tool:

```bash
# Required
RAILS_ENV=production
SECRET_KEY_BASE=generated_secret_key
DATABASE_URL=postgres://user:pass@localhost/myapp_production
REDIS_URL=redis://localhost:6379/0

# Performance
WEB_CONCURRENCY=2
RAILS_MAX_THREADS=5
RAILS_SERVE_STATIC_FILES=false

# Services
SMTP_ADDRESS=smtp.sendgrid.net
SMTP_PORT=587
SMTP_USER_NAME=apikey
SMTP_PASSWORD=your_api_key

# Monitoring
ROLLBAR_ACCESS_TOKEN=your_token
NEW_RELIC_LICENSE_KEY=your_key
```

## Database Configuration

### Multi-Environment Setup

```yaml
# config/database.yml
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

test:
  <<: *default
  database: myapp_test

staging:
  <<: *default
  database: myapp_staging
  username: deploy
  password: <%= Rails.application.credentials.dig(:database, :password) %>

production:
  <<: *default
  url: <%= ENV['DATABASE_URL'] %>
```

## Email Configuration

### Development (Letter Opener)

```ruby
# Shows emails in browser
config.action_mailer.delivery_method = :letter_opener
config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
```

### Staging (SMTP with Sandbox)

```ruby
config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = {
  address: Rails.application.credentials.dig(:smtp, :address),
  port: 587,
  domain: 'staging.example.com',
  user_name: Rails.application.credentials.dig(:smtp, :user_name),
  password: Rails.application.credentials.dig(:smtp, :password),
  authentication: 'plain',
  enable_starttls_auto: true
}

# Intercept all emails
class StagingEmailInterceptor
  def self.delivering_email(message)
    message.to = ['staging@example.com']
  end
end

ActionMailer::Base.register_interceptor(StagingEmailInterceptor) if Rails.env.staging?
```

### Production (SMTP)

```ruby
config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = {
  address: ENV['SMTP_ADDRESS'],
  port: ENV['SMTP_PORT'],
  domain: ENV['SMTP_DOMAIN'],
  user_name: ENV['SMTP_USER_NAME'],
  password: ENV['SMTP_PASSWORD'],
  authentication: 'plain',
  enable_starttls_auto: true
}
```

## Asset Configuration

### Development

```ruby
# Live compilation
config.assets.debug = true
config.assets.quiet = true
```

### Staging/Production

```ruby
# Precompiled assets
config.assets.compile = false
config.assets.digest = true

# CDN configuration (optional)
config.action_controller.asset_host = ENV['CDN_HOST']
```

## Cache Configuration

### Development

```ruby
# Enable/disable caching with rails dev:cache
if Rails.root.join('tmp', 'caching-dev.txt').exist?
  config.cache_store = :redis_cache_store, { url: ENV['REDIS_URL'] }
else
  config.cache_store = :null_store
end
```

### Staging/Production

```ruby
config.cache_store = :redis_cache_store, {
  url: ENV['REDIS_URL'],
  expires_in: 90.minutes,
  namespace: "myapp_#{Rails.env}"
}

# HTTP caching
config.public_file_server.headers = {
  'Cache-Control' => "public, max-age=#{1.year.to_i}"
}
```

## Background Jobs

### Development

```ruby
# Inline execution for immediate feedback
config.active_job.queue_adapter = :good_job
config.good_job.execution_mode = :inline
```

### Staging/Production

```ruby
# Async execution with separate workers
config.active_job.queue_adapter = :good_job
config.good_job.execution_mode = :external

# config/good_job.yml
production:
  queues: "urgent:3;default:2;low:1"
  max_threads: 5
  poll_interval: 5
  cleanup_preserved_jobs_before_seconds_ago: 86400
```

## Security Settings

### Force SSL

```ruby
# staging.rb and production.rb
config.force_ssl = true

# Exclude health check
config.ssl_options = { 
  redirect: { 
    exclude: -> request { request.path =~ /health/ } 
  } 
}
```

### CORS Configuration

```ruby
# config/initializers/cors.rb
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins ENV['CORS_ORIGINS']&.split(',') || []
    
    resource '/api/*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: true
  end
end
```

## Monitoring

### Error Tracking

```ruby
# config/initializers/rollbar.rb
Rollbar.configure do |config|
  config.access_token = Rails.application.credentials.dig(:rollbar, :access_token)
  
  # Only report in staging/production
  if Rails.env.test? || Rails.env.development?
    config.enabled = false
  end
  
  config.environment = Rails.env
end
```

### Performance Monitoring

```ruby
# config/newrelic.yml
production:
  license_key: <%= ENV['NEW_RELIC_LICENSE_KEY'] %>
  app_name: Rails Blueprint Production
  
staging:
  license_key: <%= ENV['NEW_RELIC_LICENSE_KEY'] %>
  app_name: Rails Blueprint Staging
```

## Environment-Specific Features

### Feature Flags

```ruby
# Use settings to control features per environment
if AppConfig.features.beta_enabled
  # Enable beta features
end

# Or use Rails.env
if Rails.env.production?
  # Production-only code
elsif Rails.env.staging?
  # Staging-only code
end
```

### Robots.txt

Different robots.txt per environment:

```
# public/robots-staging.txt
User-agent: *
Disallow: /

# public/robots-production.txt
User-agent: *
Disallow: /admin
Disallow: /api
Allow: /
```

## Testing Environment Configuration

```bash
# Run staging environment locally
RAILS_ENV=staging rails server

# Test production settings
RAILS_ENV=production RAILS_SERVE_STATIC_FILES=true rails server

# Debug credential loading
RAILS_ENV=production rails credentials:show
```

## Best Practices

1. **Never commit secrets** - Use credentials or environment variables
2. **Keep staging close to production** - Same services and configuration
3. **Use environment variables** - For deployment-specific settings
4. **Separate credentials** - Different keys per environment
5. **Monitor all environments** - Even staging needs monitoring
6. **Test configuration** - Verify settings work before deploying

## Next Steps

- [Set up SSL](ssl.md) for secure connections
- Review [Mina configuration](mina.md)
- Complete [server setup](server-setup.md)