# Frequently Asked Questions

## General Questions

### What is Rails Blueprint?

Rails Blueprint is a comprehensive Rails application template that provides a production-ready starting point for new Rails applications. It includes authentication, authorization, admin panel, and many other features configured and ready to use.

### What versions does Rails Blueprint use?

- **Ruby**: 3.4.4 (with YJIT and jemalloc optimizations)
- **Rails**: 8.0.2
- **PostgreSQL**: 14+
- **Redis**: 6+
- **Node.js**: 18+

### What's included in the Basic edition?

The Basic edition includes:
- User authentication (Devise)
- Role-based authorization (Pundit + Rolify)
- Admin panel
- Blog system with SEO-friendly URLs
- Static pages CMS
- Email templates (database-backed)
- Background jobs (GoodJob)
- Bootstrap 5 design system
- Deployment configuration (Mina)
- Comprehensive test suite

### How do I get updates?

If you're tracking updates:
```bash
git fetch origin
git merge origin/blueprint-basic-master
```

If you started fresh, you'll need to manually apply updates or use a diff tool to see changes.

## Setup Questions

### How do I change the application name?

Run the blueprint initialization with your app name:
```bash
bundle exec rails blueprint:init[my_app_name]
```

Then update:
- `config/application.rb` - module name
- `config/database.yml` - database names
- `config/app.yml` - application display name

### Can I use MySQL instead of PostgreSQL?

While possible, Rails Blueprint is optimized for PostgreSQL. To use MySQL:
1. Change adapter in `config/database.yml`
2. Update Gemfile (replace `pg` with `mysql2`)
3. Some features may need adjustment (JSON columns, full-text search)

### How do I change the default admin credentials?

The default superadmin (superadmin@localhost / 12345678) should be changed immediately:

```ruby
# Rails console
admin = User.find_by(email: 'superadmin@localhost')
admin.email = 'admin@mycompany.com'
admin.password = 'new_secure_password'
admin.save!
```

### Do I need Redis?

Yes, Redis is required for:
- Session storage
- Cache storage
- Action Cable (WebSockets)
- Background job locks

## Feature Questions

### How do I add new roles?

Roles are created dynamically:

```ruby
# Add role to user
user.add_role(:moderator)

# Check role
user.has_role?(:moderator)

# Create policy for new role
class PostPolicy < ApplicationPolicy
  def moderate?
    user.has_role?(:moderator) || user.has_role?(:admin)
  end
end
```

### How do I create custom email templates?

1. Create template in admin panel (`/admin/mail_templates`)
2. Or via migration:

```ruby
MailTemplate.create!(
  name: 'order_confirmation',
  subject: 'Order #{{order_number}} Confirmed',
  body: 'Thank you for your order...',
  variables: 'order_number, customer_name, total'
)
```

### How do I add OAuth login?

OAuth is a Plus tier feature. For Basic tier, you can:
1. Add omniauth gems manually
2. Configure providers
3. Implement callbacks
4. See Plus tier documentation for reference

### Can I use a different CSS framework?

Yes, but it requires significant work:
1. Remove Bootstrap from Gemfile and package.json
2. Update all views and components
3. Rewrite the design system
4. Update admin panel styling

### How do I add API endpoints?

Create API controllers:

```ruby
# app/controllers/api/v1/base_controller.rb
class Api::V1::BaseController < ActionController::API
  include Pundit
  before_action :authenticate_api_user!
  
  private
  
  def authenticate_api_user!
    # Implement API authentication
  end
end

# app/controllers/api/v1/posts_controller.rb
class Api::V1::PostsController < Api::V1::BaseController
  def index
    @posts = policy_scope(Post).published
    render json: @posts
  end
end
```

## Deployment Questions

### Can I deploy to Heroku?

Yes, but you'll need to:
1. Add `Procfile` for Heroku
2. Use Heroku Postgres and Redis add-ons
3. Configure environment variables
4. Adjust asset compilation settings
5. Set up worker dynos for background jobs

### How do I deploy to multiple servers?

Modify Mina configuration:

```ruby
# config/deploy.rb
set :domains, ['web1.example.com', 'web2.example.com']

task :deploy_all do
  domains.each do |domain|
    set :domain, domain
    invoke :deploy
  end
end
```

### What about Docker deployment?

Rails Blueprint doesn't include Docker configuration, but you can add it:
1. Create `Dockerfile`
2. Add `docker-compose.yml`
3. Configure for your container orchestration
4. Ensure all services (PostgreSQL, Redis) are accessible

### How do I handle SSL certificates?

Use Let's Encrypt with Certbot:
```bash
sudo certbot --nginx -d example.com -d www.example.com
```

See the [SSL Setup guide](deployment/ssl.md) for details.

## Performance Questions

### How can I improve performance?

1. **Enable caching**:
   ```ruby
   # Use fragment caching
   <% cache @post do %>
     <%= render @post %>
   <% end %>
   ```

2. **Add database indexes**:
   ```ruby
   add_index :posts, :published_at
   add_index :users, [:email, :confirmed_at]
   ```

3. **Use eager loading**:
   ```ruby
   @posts = Post.includes(:author, :categories).published
   ```

4. **Configure CDN** for assets

### What about scaling?

Rails Blueprint is designed to scale:
1. Horizontal scaling with multiple servers
2. Database read replicas
3. Redis clustering
4. Background job workers
5. CDN for assets

### How do I monitor performance?

1. Use the built-in PgHero (`/admin/pg_hero`)
2. Add APM tool (New Relic, Scout)
3. Monitor logs
4. Set up error tracking (Rollbar, Sentry)

## Troubleshooting Questions

### Why am I getting "missing template" errors?

Check that:
1. Template file exists in correct location
2. File extension is correct (`.html.erb`, `.html.slim`)
3. Controller action has corresponding view
4. Rendering the correct format

### How do I debug email sending?

In development:
```ruby
# Check Letter Opener
http://localhost:3000/letter_opener

# Test in console
ActionMailer::Base.delivery_method
UserMailer.welcome_email(User.first).deliver_now
```

### Why are my tests failing?

Common causes:
1. Database not migrated: `RAILS_ENV=test rails db:migrate`
2. Missing test data: Check factories
3. JavaScript tests: Ensure JS driver configured
4. Timezone issues: Set test timezone

### How do I reset everything?

In development only:
```bash
# Reset database
rails db:drop db:create db:migrate:with_data db:seed

# Clear cache
rails tmp:clear
rails assets:clobber

# Reinstall dependencies
rm -rf node_modules vendor/bundle
bundle install
yarn install
```

## Security Questions

### Is Rails Blueprint secure?

Rails Blueprint follows security best practices:
- CSRF protection enabled
- SQL injection prevention
- XSS protection
- Secure password storage
- Session security
- Regular dependency updates

### How do I add 2FA?

Two-factor authentication is a Pro tier feature. For Basic tier:
1. Add devise-two-factor gem
2. Implement TOTP support
3. Add backup codes
4. Update user interface

### What about GDPR compliance?

Rails Blueprint provides tools, but compliance is your responsibility:
1. Add privacy policy page
2. Implement data export
3. Add data deletion
4. Cookie consent
5. Audit logging

## Business Questions

### Can I use Rails Blueprint for commercial projects?

Yes! Rails Blueprint is open source and can be used for commercial projects. Check the license file for details.

### Is there support available?

- Community support via GitHub issues
- Documentation at docs.railsblueprint.com
- Commercial support for Plus/Pro tiers

### How do I contribute?

1. Fork the repository
2. Create feature branch
3. Add tests for changes
4. Submit pull request
5. Follow contribution guidelines

### What's the roadmap?

Check DEVELOPMENT_PRIORITIES.md for current plans:
- Regular security updates
- New tier features
- Performance improvements
- Additional integrations