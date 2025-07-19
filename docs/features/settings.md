# Settings System

Rails Blueprint includes a powerful database-backed settings system that allows dynamic configuration of your application without code changes or deployments.

## Overview

The settings system provides:
- Database-stored configuration values
- Type-safe value handling
- Hierarchical organization
- Admin interface for management
- Caching for performance
- Default value support

## Architecture

### Setting Model

```ruby
class Setting < ApplicationRecord
  # Fields:
  # - key: String (unique identifier)
  # - value: Text (stored value)
  # - type: String (data type)
  # - section: String (grouping)
  # - description: Text (help text)
  
  TYPES = %w[string integer boolean decimal section].freeze
  
  validates :key, presence: true, uniqueness: true
  validates :type, inclusion: { in: TYPES }
  
  scope :by_section, -> { order(:section, :key) }
end
```

### AppConfig Access

Settings are accessed through the `AppConfig` module:

```ruby
# Get a setting
AppConfig.mail.from
# => "noreply@example.com"

# Nested settings
AppConfig.features.registration_enabled
# => true

# With default value
AppConfig.get('features.beta', default: false)
# => false
```

## Setting Types

### String
Basic text values:
```ruby
Setting.create!(
  key: 'app.name',
  value: 'My Application',
  type: 'string',
  section: 'app',
  description: 'Application display name'
)
```

### Integer
Whole numbers:
```ruby
Setting.create!(
  key: 'app.items_per_page',
  value: '25',
  type: 'integer',
  section: 'app',
  description: 'Number of items to display per page'
)
```

### Boolean
True/false values:
```ruby
Setting.create!(
  key: 'features.registration_enabled',
  value: 'true',
  type: 'boolean',
  section: 'features',
  description: 'Allow new user registrations'
)
```

### Decimal
Floating point numbers:
```ruby
Setting.create!(
  key: 'billing.tax_rate',
  value: '0.0875',
  type: 'decimal',
  section: 'billing',
  description: 'Sales tax rate'
)
```

### Section
Group related settings:
```ruby
Setting.create!(
  key: 'features',
  value: '',
  type: 'section',
  section: '',
  description: 'Feature flags and toggles'
)
```

## Common Settings

### Application Settings

```ruby
# Basic configuration
app.name                    # Application name
app.domain                  # Primary domain
app.support_email          # Support contact
app.items_per_page         # Pagination size
app.timezone               # Default timezone

# Feature flags
features.registration_enabled    # Allow signups
features.comments_enabled       # Enable comments
features.api_enabled           # API access
features.maintenance_mode      # Maintenance mode

# Email settings
mail.from                  # Default from address
mail.reply_to             # Reply-to address
mail.admin_notifications  # Admin email address

# SEO settings
seo.default_title         # Default page title
seo.default_description   # Default meta description
seo.google_analytics_id   # GA tracking ID
```

## Admin Interface

### Managing Settings

Access settings at `/admin/settings`:

1. **View all settings** - Organized by section
2. **Edit values** - Inline editing with type validation
3. **Add new settings** - Create custom settings
4. **Search** - Find settings by key or description
5. **Bulk operations** - Export/import settings

### Setting Sections

Settings are organized into logical sections:
- **App** - General application settings
- **Features** - Feature flags and toggles
- **Mail** - Email configuration
- **SEO** - Search engine optimization
- **Social** - Social media links
- **Custom** - Your custom settings

## Creating Settings

### Via Data Migration

The recommended way to add settings:

```ruby
# db/data/20240101000000_add_custom_settings.rb
class AddCustomSettings < ActiveRecord::Migration[7.0]
  def up
    Setting.create!(
      key: 'features.custom_feature',
      value: 'false',
      type: 'boolean',
      section: 'features',
      description: 'Enable custom feature'
    )
  end

  def down
    Setting.find_by(key: 'features.custom_feature')&.destroy
  end
end
```

### Via Rails Console

For development/testing:

```ruby
Setting.create!(
  key: 'app.announcement',
  value: 'Welcome to our new site!',
  type: 'string',
  section: 'app',
  description: 'Homepage announcement message'
)
```

### Via Seeds

For initial setup:

```ruby
# db/seeds.rb
settings = [
  {
    key: 'app.name',
    value: 'Rails Blueprint',
    type: 'string',
    section: 'app',
    description: 'Application name'
  },
  {
    key: 'features.beta_features',
    value: 'false',
    type: 'boolean',
    section: 'features',
    description: 'Enable beta features'
  }
]

settings.each do |setting|
  Setting.find_or_create_by(key: setting[:key]) do |s|
    s.assign_attributes(setting)
  end
end
```

## Using Settings in Code

### Controllers

```ruby
class ApplicationController < ActionController::Base
  before_action :check_maintenance_mode

  private

  def check_maintenance_mode
    if AppConfig.features.maintenance_mode && !current_user&.has_role?(:admin)
      render 'shared/maintenance', layout: false
    end
  end
end
```

### Views

```erb
<% if AppConfig.features.comments_enabled %>
  <%= render 'comments/form' %>
<% end %>

<footer>
  <p>&copy; <%= Date.current.year %> <%= AppConfig.app.name %></p>
  <p>Contact: <%= mail_to AppConfig.app.support_email %></p>
</footer>
```

### Models

```ruby
class User < ApplicationRecord
  def self.registration_open?
    AppConfig.features.registration_enabled
  end

  validates :email, 
    format: { with: URI::MailTo::EMAIL_REGEXP },
    uniqueness: { case_sensitive: false },
    if: -> { AppConfig.features.strict_email_validation }
end
```

### Mailers

```ruby
class ApplicationMailer < ActionMailer::Base
  default from: -> { AppConfig.mail.from },
          reply_to: -> { AppConfig.mail.reply_to }

  def admin_notification(subject, body)
    mail(
      to: AppConfig.mail.admin_notifications,
      subject: "[#{AppConfig.app.name}] #{subject}",
      body: body
    )
  end
end
```

## Advanced Usage

### Caching

Settings are cached for performance:

```ruby
# Clear cache after updating
Rails.cache.delete('app_config')

# Or use the built-in method
AppConfig.reload!
```

### Dynamic Settings

Create settings that compute values:

```ruby
class Setting < ApplicationRecord
  def computed_value
    case key
    when 'app.copyright_year'
      Date.current.year.to_s
    when 'app.version'
      Rails.application.config.version
    else
      value
    end
  end
end
```

### Setting Validations

Add custom validations:

```ruby
class Setting < ApplicationRecord
  validate :validate_value_format

  private

  def validate_value_format
    case type
    when 'integer'
      errors.add(:value, 'must be a number') unless value =~ /\A\d+\z/
    when 'decimal'
      errors.add(:value, 'must be a decimal') unless value =~ /\A\d+\.?\d*\z/
    when 'boolean'
      errors.add(:value, 'must be true or false') unless %w[true false].include?(value)
    end
  end
end
```

### Setting Observers

React to setting changes:

```ruby
class SettingObserver < ActiveRecord::Observer
  def after_update(setting)
    case setting.key
    when 'mail.from'
      # Update mailer configuration
      ActionMailer::Base.default[:from] = setting.value
    when 'features.maintenance_mode'
      # Clear cache when maintenance mode changes
      Rails.cache.clear
    end
  end
end
```

## Best Practices

### 1. Use Type-Safe Access

Always use the appropriate type:
```ruby
# Good
if AppConfig.features.registration_enabled
  # Boolean comparison
end

# Bad
if AppConfig.features.registration_enabled == 'true'
  # String comparison
end
```

### 2. Provide Defaults

Handle missing settings gracefully:
```ruby
# Good
items_per_page = AppConfig.get('app.items_per_page', default: 25)

# Also good
items_per_page = AppConfig.app.items_per_page || 25
```

### 3. Document Settings

Always include descriptions:
```ruby
Setting.create!(
  key: 'features.advanced_search',
  value: 'false',
  type: 'boolean',
  section: 'features',
  description: 'Enable advanced search functionality with filters and sorting'
)
```

### 4. Group Related Settings

Use sections for organization:
```ruby
# Good: Grouped settings
AppConfig.mail.from
AppConfig.mail.reply_to
AppConfig.mail.admin_notifications

# Bad: Flat structure
AppConfig.mail_from
AppConfig.mail_reply_to
AppConfig.admin_email
```

## Testing

### Setting Up Test Settings

```ruby
# spec/support/settings.rb
RSpec.configure do |config|
  config.before(:each) do
    # Reset settings to defaults
    Setting.destroy_all
    load Rails.root.join('db/seeds/settings.rb')
  end
end
```

### Testing with Settings

```ruby
RSpec.describe RegistrationsController do
  describe "POST #create" do
    context "when registration is enabled" do
      before do
        Setting.find_by(key: 'features.registration_enabled').update!(value: 'true')
      end

      it "creates a new user" do
        expect {
          post :create, params: { user: attributes_for(:user) }
        }.to change(User, :count).by(1)
      end
    end

    context "when registration is disabled" do
      before do
        Setting.find_by(key: 'features.registration_enabled').update!(value: 'false')
      end

      it "redirects with error" do
        post :create, params: { user: attributes_for(:user) }
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to include("Registration is currently disabled")
      end
    end
  end
end
```

## Troubleshooting

### Settings Not Loading

1. **Check cache**:
   ```ruby
   Rails.cache.clear
   AppConfig.reload!
   ```

2. **Verify database**:
   ```ruby
   Setting.pluck(:key, :value)
   ```

3. **Check for typos**:
   ```ruby
   Setting.where("key LIKE ?", "%feature%")
   ```

### Type Conversion Issues

```ruby
# Debug type conversion
setting = Setting.find_by(key: 'features.enabled')
puts "Raw value: #{setting.value.inspect}"
puts "Type: #{setting.type}"
puts "Converted: #{AppConfig.features.enabled.inspect}"
```

### Performance Issues

```ruby
# Check cache hits
Rails.cache.stats

# Monitor setting queries
ActiveRecord::Base.logger = Logger.new(STDOUT)
AppConfig.app.name
```

## Next Steps

- Create [Email Templates](email-templates.md)
- Configure [Background Jobs](background-jobs.md)
- Learn about the [Blog System](blog.md)