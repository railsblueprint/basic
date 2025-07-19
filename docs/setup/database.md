# Database Setup

This guide covers database creation, migration, and seeding for Rails Blueprint.

## Prerequisites

- PostgreSQL 14+ installed and running
- Database user with create database permissions
- Redis 6+ installed and running (for caching and sessions)

## Database Creation

### 1. Create Databases

If your PostgreSQL user has create database permissions:

```bash
bundle exec rails db:create
```

This creates both development and test databases.

### 2. Manual Database Creation

If you need to create databases manually:

```sql
-- Connect to PostgreSQL
psql -U postgres

-- Create databases
CREATE DATABASE myapp_development;
CREATE DATABASE myapp_test;

-- Create user if needed
CREATE USER myapp WITH PASSWORD 'password';
GRANT ALL PRIVILEGES ON DATABASE myapp_development TO myapp;
GRANT ALL PRIVILEGES ON DATABASE myapp_test TO myapp;
```

## Running Migrations

Rails Blueprint uses both schema migrations and data migrations.

### 1. Run All Migrations

```bash
bundle exec rails db:migrate:with_data
```

This runs:
- Schema migrations (create tables, indexes)
- Data migrations (seed initial settings, configurations)

### 2. Schema Migrations Only

```bash
bundle exec rails db:migrate
```

### 3. Data Migrations Only

```bash
bundle exec rails data:migrate
```

## Database Seeding

### 1. Create Admin User

Create the default superadmin user:

```bash
bundle exec rails db:seed
```

Default credentials:
- Email: `superadmin@localhost`
- Password: `12345678`

**Important**: Change these credentials immediately in production!

### 2. Create Demo Data

For development/testing, create sample data:

```bash
bundle exec rails db:seed what=demo
```

This creates:
- Sample users with different roles
- Blog posts and pages
- Example settings
- Test email templates

### 3. Custom Seeding

Create your own seed data in `db/seeds.rb`:

```ruby
# Create custom admin
User.create!(
  email: 'admin@company.com',
  password: 'secure_password',
  password_confirmation: 'secure_password',
  confirmed_at: Time.current
).add_role(:admin)

# Create sample content
10.times do |i|
  Post.create!(
    title: "Sample Post #{i + 1}",
    content: "Content for post #{i + 1}",
    author: User.admin.first,
    published: true
  )
end
```

## Database Structure

### Core Tables

Rails Blueprint includes these essential tables:

- **users** - User accounts with Devise authentication
- **roles** - Role definitions (admin, user, etc.)
- **users_roles** - User-role associations
- **posts** - Blog posts with slugs
- **pages** - Static/CMS pages
- **settings** - Application settings
- **mail_templates** - Email templates
- **good_jobs** - Background job queue

### Key Migrations

Important migrations that set up the application:

1. **Devise Users** - Authentication system
2. **Rolify Roles** - Role-based authorization
3. **FriendlyId Slugs** - SEO-friendly URLs
4. **Settings** - Configuration storage
5. **Good Job** - Background job processing

## Database Maintenance

### Reset Database

To completely reset the database:

```bash
# Drop, create, migrate, and seed
bundle exec rails db:reset

# With demo data
bundle exec rails db:reset && bundle exec rails db:seed what=demo
```

### Check Migration Status

```bash
# Check schema migrations
bundle exec rails db:migrate:status

# Check data migrations
bundle exec rails data:migrate:status
```

### Rollback Migrations

```bash
# Rollback last migration
bundle exec rails db:rollback

# Rollback specific number of migrations
bundle exec rails db:rollback STEP=3

# Rollback data migration
bundle exec rails data:rollback
```

## Redis Setup

Rails Blueprint uses Redis for:
- Session storage
- Cache storage
- Action Cable (WebSockets)

### Verify Redis Connection

```bash
# In Rails console
rails console
> Redis.new.ping
=> "PONG"
```

### Redis Configuration

Configure Redis URL in:
- `.env` file: `REDIS_URL=redis://localhost:6379/0`
- Or in credentials: `redis: { url: 'redis://localhost:6379/0' }`

## Troubleshooting

### Database Connection Issues

1. **Check PostgreSQL is running**
   ```bash
   # macOS
   brew services list | grep postgresql
   
   # Linux
   sudo systemctl status postgresql
   ```

2. **Verify connection settings**
   ```bash
   rails console
   > ActiveRecord::Base.connection.active?
   ```

3. **Check database.yml configuration**
   - Ensure host, port, username, password are correct
   - Try connecting with psql to verify credentials

### Migration Failures

1. **Check for pending migrations**
   ```bash
   bundle exec rails db:migrate:status
   ```

2. **Fix broken migrations**
   ```bash
   # Mark migration as run without executing
   bundle exec rails db:migrate:up VERSION=20230101000000
   ```

3. **Reset specific tables**
   ```bash
   # In Rails console
   ActiveRecord::Base.connection.drop_table(:table_name)
   # Then run migrations again
   ```

### Redis Connection Issues

1. **Check Redis is running**
   ```bash
   redis-cli ping
   ```

2. **Verify Redis URL**
   ```bash
   echo $REDIS_URL
   ```

3. **Test connection**
   ```bash
   rails console
   > Redis.new(url: ENV['REDIS_URL']).ping
   ```

## Next Steps

- [Start the development server](development.md)
- [Explore the admin panel](../features/admin-panel.md)
- [Learn about deployment](../deployment/index.md)