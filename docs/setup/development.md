# Development Environment

This guide covers running Rails Blueprint in development mode.

## Starting the Development Server

Rails Blueprint provides multiple ways to start the development server:

### 1. Using bin/dev (Recommended)

```bash
bin/dev
```

This starts all necessary processes:
- Rails server (Puma)
- Asset compilation (DartSass)
- JavaScript bundling
- Background job processor (GoodJob)

### 2. Using Overmind

If you have [Overmind](https://github.com/DarthSim/overmind) installed:

```bash
overmind start
```

Benefits:
- Better process management
- Separate logs per process
- Easy to restart individual services

### 3. Using Foreman

```bash
foreman start -f Procfile.dev
```

### 4. Manual Start

Run each process in separate terminals:

```bash
# Terminal 1: Rails server
bundle exec rails server

# Terminal 2: CSS compilation
bundle exec rails dartsass:watch

# Terminal 3: Background jobs
bundle exec good_job start
```

## Accessing the Application

Once started, access the application at:
- **Application**: http://localhost:3000
- **Admin Panel**: http://localhost:3000/admin
- **Letter Opener**: http://localhost:3000/letter_opener (view sent emails)

Default login credentials:
- Email: `superadmin@localhost`
- Password: `12345678`

## Development Tools

### Rails Console

Access the Rails console for debugging:

```bash
rails console
# or shorter
rails c
```

Useful console commands:
```ruby
# Find users
User.all
User.find_by(email: 'user@example.com')

# Check roles
User.first.roles
User.with_role(:admin)

# Test email sending
UserMailer.welcome_email(User.first).deliver_now

# Check settings
Setting.all
AppConfig.mail.from
```

### Database Console

Access PostgreSQL directly:

```bash
rails dbconsole
# or shorter
rails db
```

### Routes

View all application routes:

```bash
# All routes
rails routes

# Filter routes
rails routes | grep admin
rails routes -c users
rails routes -g POST
```

### Background Jobs

Monitor background jobs:

1. **Web Interface**: http://localhost:3000/admin/good_job
2. **Console**:
   ```ruby
   GoodJob::Job.count
   GoodJob::Job.finished.count
   GoodJob::Job.pending.count
   ```

## Live Reloading

Rails Blueprint includes live reloading for a smooth development experience:

### CSS Changes
- Automatically recompiled and reloaded
- No page refresh needed with Turbo

### Ruby/Rails Changes
- Server automatically restarts
- Page refresh required

### JavaScript Changes
- Automatically reloaded
- Stimulus controllers hot reload

## Development Features

### Design System

View Bootstrap components and design patterns:
- http://localhost:3000/admin/design_system

### Email Preview

Preview email templates without sending:

```ruby
# In Rails console
UserMailer.welcome_email(User.first).deliver_now
# Check http://localhost:3000/letter_opener
```

### Database Monitoring

Monitor database performance:
- http://localhost:3000/admin/pg_hero

Features:
- Slow queries
- Index usage
- Table sizes
- Active connections

## Environment Configuration

### Port Configuration

Change the default port in `.env`:

```bash
PORT=3001
```

Useful when running multiple Rails apps.

### Environment Variables

Common development environment variables:

```bash
# .env
RAILS_ENV=development
PORT=3000
WEB_CONCURRENCY=1
RAILS_MAX_THREADS=5
RAILS_LOG_TO_STDOUT=true

# Database
DB_HOST=localhost
DB_USER=postgres
DB_PASSWORD=

# Redis
REDIS_URL=redis://localhost:6379/0

# Debugging
RAILS_LOG_LEVEL=debug
VERBOSE_QUERY_LOGS=true
```

## Debugging

### Debugging with pry

Add `pry-rails` to Gemfile for better debugging:

```ruby
group :development do
  gem 'pry-rails'
  gem 'pry-byebug'
end
```

Then use in code:
```ruby
def some_method
  binding.pry  # Execution stops here
  # Continue with 'exit' or 'continue'
end
```

### Rails Logger

Use Rails logger for debugging:

```ruby
Rails.logger.debug "Debug information"
Rails.logger.info "User created: #{user.email}"
Rails.logger.error "Error: #{e.message}"
```

View logs:
```bash
tail -f log/development.log
```

### Better Errors

Rails Blueprint includes `better_errors` gem for enhanced error pages:
- Interactive console in error pages
- Variable inspection
- Source code context

## Testing

### Running Tests

```bash
# Run all tests
bundle exec rspec

# Run specific test file
bundle exec rspec spec/models/user_spec.rb

# Run specific test
bundle exec rspec spec/models/user_spec.rb:42

# Run with coverage report
COVERAGE=true bundle exec rspec
```

### Test Database

```bash
# Prepare test database
bundle exec rails db:test:prepare

# Run migrations on test database
RAILS_ENV=test bundle exec rails db:migrate
```

## Code Quality

### Rubocop

Check code style:

```bash
# Check all files
bundle exec rubocop

# Auto-fix issues
bundle exec rubocop -a

# Check changed files only
bundle exec rails rubocop:changed
```

### Security Audit

Check for security vulnerabilities:

```bash
# Check gems
bundle audit

# Check npm packages
yarn audit
```

## Performance Monitoring

### Bullet Gem

Rails Blueprint includes Bullet for N+1 query detection:
- Alerts appear in browser console
- Check log/bullet.log for details

### Rack Mini Profiler

For detailed performance metrics:
- Add `?pp=help` to any URL
- Shows database queries, rendering time

## Common Issues

### Port Already in Use

```bash
# Find process using port 3000
lsof -i :3000

# Kill the process
kill -9 <PID>
```

### Asset Compilation Issues

```bash
# Clear asset cache
rails tmp:clear
rails assets:clobber

# Rebuild assets
rails assets:precompile
```

### Database Connection Issues

```bash
# Check PostgreSQL is running
brew services list | grep postgresql

# Restart PostgreSQL
brew services restart postgresql
```

## Next Steps

- [Explore features](../features/index.md)
- [Learn about the admin panel](../features/admin-panel.md)
- [Understand the architecture](../api/index.md)