# API Reference

Technical reference documentation for Rails Blueprint's models, controllers, commands, and helpers.

## Overview

Rails Blueprint follows these architectural patterns:

- **MVC Architecture** - Models, Views, Controllers
- **Command Pattern** - Business logic in command objects
- **Policy Pattern** - Authorization with Pundit
- **Service Pattern** - External integrations
- **Component Pattern** - Reusable view components

## Core Components

### Models
- **[Models Reference](models.md)** - Database models and associations
  - User model with authentication
  - Post and Page models for content
  - Settings for configuration
  - Role-based permissions

### Controllers
- **[Controllers Reference](controllers.md)** - Request handling
  - Base controllers and inheritance
  - Admin namespace controllers
  - API patterns
  - Authentication flows

### Commands
- **[Commands Reference](commands.md)** - Business logic
  - Command pattern implementation
  - Validation with dry-validation
  - Error handling
  - Transaction management

### Helpers
- **[Helpers Reference](helpers.md)** - View and application helpers
  - View helpers
  - Form builders
  - URL helpers
  - Custom utilities

## Architecture Patterns

### Command Pattern

Commands encapsulate business logic:

```ruby
class CreateUserCommand < BaseCommand
  def initialize(params)
    @params = params
  end

  def execute
    return false unless valid?
    
    ActiveRecord::Base.transaction do
      create_user
      send_welcome_email
      log_creation
    end
    
    true
  rescue => e
    errors.add(:base, e.message)
    false
  end
end
```

### Policy Pattern

Policies handle authorization:

```ruby
class PostPolicy < ApplicationPolicy
  def create?
    user.has_any_role?(:admin, :editor)
  end

  def update?
    user_is_owner? || user.has_role?(:admin)
  end

  private

  def user_is_owner?
    record.author_id == user.id
  end
end
```

### Service Objects

Services handle external integrations:

```ruby
class EmailService
  def self.send_template(template_name, recipient, variables = {})
    template = MailTemplate.find_by!(name: template_name)
    
    TemplateMailer.send_email(
      to: recipient.email,
      subject: render_template(template.subject, variables),
      body: render_template(template.body, variables)
    ).deliver_later
  end
end
```

## Database Schema

### Core Tables

| Table | Purpose | Key Fields |
|-------|---------|------------|
| users | User accounts | email, encrypted_password, confirmed_at |
| roles | Role definitions | name, resource_type, resource_id |
| posts | Blog posts | title, slug, content, published |
| pages | Static pages | title, slug, content, template |
| settings | App configuration | key, value, type, section |
| mail_templates | Email templates | name, subject, body, locale |

### Associations

```ruby
# User associations
has_many :posts, foreign_key: :author_id
has_and_belongs_to_many :roles

# Post associations  
belongs_to :author, class_name: 'User'
has_and_belongs_to_many :categories

# Role associations
has_and_belongs_to_many :users
belongs_to :resource, polymorphic: true, optional: true
```

## Request/Response Cycle

### Authentication Flow

1. User submits credentials
2. Devise authenticates
3. Session created
4. User redirected to dashboard

### Authorization Flow

1. Controller action called
2. Pundit policy checked
3. Action authorized or denied
4. Response rendered

### Admin Request Flow

1. Authentication verified
2. Admin role checked
3. Resource loaded
4. Policy authorized
5. Action performed
6. Response rendered

## Configuration

### Application Configuration

Accessed via `AppConfig`:

```ruby
AppConfig.app.name          # Application name
AppConfig.mail.from         # Default from address
AppConfig.features.enabled  # Feature flags
```

### Environment Configuration

Environment-specific settings:

```ruby
Rails.application.configure do
  config.force_ssl = true  # Production only
  config.cache_store = :redis_cache_store
end
```

## Extension Points

### Adding Models

1. Generate model: `rails g model ModelName`
2. Add validations and associations
3. Create policy: `app/policies/model_name_policy.rb`
4. Add to admin if needed

### Adding Controllers

1. Create controller
2. Inherit from appropriate base
3. Add routes
4. Implement actions
5. Add views

### Adding Commands

1. Create command class
2. Inherit from `BaseCommand`
3. Implement validation
4. Implement execution
5. Handle errors

## Testing

### Model Tests

```ruby
RSpec.describe User do
  it { should have_many(:posts) }
  it { should validate_presence_of(:email) }
end
```

### Controller Tests

```ruby
RSpec.describe PostsController do
  let(:user) { create(:user) }
  
  before { sign_in user }
  
  describe "GET #index" do
    it "returns success" do
      get :index
      expect(response).to be_successful
    end
  end
end
```

### Command Tests

```ruby
RSpec.describe CreateUserCommand do
  let(:params) { { email: 'test@example.com', password: 'password' } }
  let(:command) { described_class.new(params) }
  
  it "creates a user" do
    expect { command.execute }.to change(User, :count).by(1)
  end
end
```

## Performance Considerations

### Database Queries

- Use `includes` to prevent N+1 queries
- Add indexes on foreign keys
- Use counter caches where appropriate
- Implement query scopes

### Caching

- Fragment cache views
- Cache expensive computations
- Use Redis for session/cache store
- Implement Russian doll caching

### Background Jobs

- Move heavy operations to background
- Use appropriate queue priorities
- Implement idempotent jobs
- Monitor job performance

## Security

### Authentication

- Devise handles authentication
- Passwords encrypted with BCrypt
- Session security configured
- CSRF protection enabled

### Authorization

- Pundit policies for all actions
- Default deny approach
- Role-based permissions
- Resource-level checks

### Data Protection

- Strong parameters required
- SQL injection prevention
- XSS protection enabled
- Secure headers configured

## Next Steps

- Explore [Models](models.md) in detail
- Review [Controllers](controllers.md) patterns
- Understand [Commands](commands.md) architecture
- Learn about [Helpers](helpers.md)