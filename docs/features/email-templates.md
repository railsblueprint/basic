# Email Templates

Rails Blueprint provides a powerful database-backed email template system that allows you to customize all system emails through the admin interface without code changes.

## Features

- **Database Storage** - Email templates stored in database
- **Variable Substitution** - Dynamic content with placeholders
- **Admin Interface** - Edit templates through web UI
- **Preview Function** - See emails before sending
- **Multi-language** - Support for localized templates
- **Version Control** - Track template changes
- **Test Sending** - Send test emails from admin

## Architecture

### MailTemplate Model

```ruby
class MailTemplate < ApplicationRecord
  # Fields:
  # - name: String (unique identifier)
  # - subject: String (email subject line)
  # - body: Text (email content)
  # - description: Text (admin notes)
  # - variables: Text (available variables)
  # - locale: String (language)
  
  validates :name, presence: true, uniqueness: { scope: :locale }
  validates :subject, presence: true
  validates :body, presence: true
  
  scope :by_locale, ->(locale) { where(locale: locale || I18n.default_locale) }
end
```

### Email Rendering

Templates use variable substitution:

```ruby
# Template body
"Hello {{user_name}},\n\nWelcome to {{app_name}}!"

# Rendered with variables
MailTemplate.render('welcome_email', {
  user_name: 'John Doe',
  app_name: 'Rails Blueprint'
})
# => "Hello John Doe,\n\nWelcome to Rails Blueprint!"
```

## Default Templates

Rails Blueprint includes these email templates:

### User Emails
- **welcome_email** - Sent after user registration
- **confirmation_instructions** - Email confirmation link
- **reset_password_instructions** - Password reset link
- **unlock_instructions** - Account unlock link
- **email_changed** - Email address change notification
- **password_changed** - Password change notification

### Admin Emails
- **new_user_notification** - Admin notified of new user
- **user_locked_notification** - Account locked alert
- **error_notification** - System error alert

### System Emails
- **contact_form** - Contact form submission
- **newsletter** - Newsletter template
- **announcement** - System announcements

## Admin Interface

### Managing Templates

Access email templates at `/admin/mail_templates`:

1. **List View** - All templates with search/filter
2. **Edit Template** - WYSIWYG or HTML editor
3. **Preview** - Live preview with sample data
4. **Test Send** - Send test email to yourself
5. **Variables** - View available variables
6. **History** - Track changes to templates

### Template Editor

Features:
- Syntax highlighting for variables
- HTML and plain text versions
- Variable autocomplete
- Template validation
- Preview pane

## Using Email Templates

### In Mailers

```ruby
class UserMailer < ApplicationMailer
  def welcome_email(user)
    @user = user
    
    template = MailTemplate.find_by(name: 'welcome_email')
    
    mail(
      to: @user.email,
      subject: render_template(template.subject, user_variables),
      body: render_template(template.body, user_variables)
    )
  end

  private

  def user_variables
    {
      user_name: @user.full_name,
      user_email: @user.email,
      app_name: AppConfig.app.name,
      login_url: new_user_session_url,
      support_email: AppConfig.app.support_email
    }
  end

  def render_template(template, variables)
    template.gsub(/\{\{(\w+)\}\}/) do |match|
      variables[$1.to_sym] || match
    end
  end
end
```

### Template Helper

```ruby
module MailTemplateHelper
  def render_mail_template(name, variables = {})
    template = MailTemplate.find_by!(name: name)
    
    {
      subject: substitute_variables(template.subject, variables),
      body: substitute_variables(template.body, variables)
    }
  end

  private

  def substitute_variables(text, variables)
    text.gsub(/\{\{(\w+)\}\}/) do |match|
      key = $1.to_sym
      variables[key] || default_variable_value(key) || match
    end
  end

  def default_variable_value(key)
    case key
    when :app_name
      AppConfig.app.name
    when :current_year
      Date.current.year
    when :support_email
      AppConfig.app.support_email
    else
      nil
    end
  end
end
```

## Variable System

### Common Variables

Available in all templates:

```
{{app_name}} - Application name
{{app_url}} - Application URL
{{support_email}} - Support email address
{{current_year}} - Current year
{{current_date}} - Current date
{{logo_url}} - Logo image URL
```

### User Variables

Available in user-related emails:

```
{{user_name}} - User's full name
{{user_email}} - User's email address
{{user_first_name}} - First name only
{{user_last_name}} - Last name only
{{confirmation_url}} - Email confirmation link
{{reset_password_url}} - Password reset link
{{unlock_url}} - Account unlock link
```

### Custom Variables

Define custom variables in mailers:

```ruby
def order_confirmation(order)
  variables = {
    order_number: order.number,
    order_total: number_to_currency(order.total),
    order_items: render_items(order.items),
    shipping_address: order.shipping_address.formatted,
    tracking_url: order.tracking_url
  }
  
  rendered = render_mail_template('order_confirmation', variables)
  
  mail(
    to: order.user.email,
    subject: rendered[:subject],
    body: rendered[:body]
  )
end
```

## Template Examples

### Welcome Email

```
Subject: Welcome to {{app_name}}!

Body:
Hello {{user_first_name}},

Thank you for joining {{app_name}}! We're excited to have you on board.

To get started, please confirm your email address by clicking the link below:
{{confirmation_url}}

If you have any questions, feel free to reach out to us at {{support_email}}.

Best regards,
The {{app_name}} Team

---
This email was sent to {{user_email}}. If you didn't create an account, please ignore this email.
```

### Password Reset

```
Subject: Reset Your {{app_name}} Password

Body:
Hi {{user_name}},

We received a request to reset your password for your {{app_name}} account.

Click the link below to reset your password:
{{reset_password_url}}

This link will expire in 24 hours for security reasons.

If you didn't request this password reset, please ignore this email. Your password won't be changed.

Thanks,
The {{app_name}} Team
```

## Advanced Features

### Multi-language Support

```ruby
# Create locale-specific templates
MailTemplate.create!(
  name: 'welcome_email',
  locale: 'es',
  subject: '¡Bienvenido a {{app_name}}!',
  body: 'Hola {{user_name}}...'
)

# Use in mailer
template = MailTemplate.by_locale(I18n.locale).find_by(name: 'welcome_email')
```

### Template Inheritance

```ruby
class MailTemplate < ApplicationRecord
  def body_with_layout
    layout = MailTemplate.find_by(name: 'email_layout')
    return body unless layout
    
    layout.body.gsub('{{content}}', body)
  end
end
```

### Conditional Content

```ruby
# In template
{{#if premium_user}}
  Enjoy your premium features!
{{else}}
  Upgrade to premium for more features.
{{/if}}

# In mailer
variables = {
  premium_user: user.has_role?(:premium),
  # ... other variables
}
```

### Template Validation

```ruby
class MailTemplate < ApplicationRecord
  validate :all_variables_defined

  private

  def all_variables_defined
    missing = extract_variables - available_variables
    if missing.any?
      errors.add(:body, "contains undefined variables: #{missing.join(', ')}")
    end
  end

  def extract_variables
    body.scan(/\{\{(\w+)\}\}/).flatten.uniq
  end

  def available_variables
    variables.split(',').map(&:strip)
  end
end
```

## Testing

### Template Tests

```ruby
RSpec.describe MailTemplate do
  describe "welcome_email template" do
    let(:template) { MailTemplate.find_by(name: 'welcome_email') }
    let(:variables) do
      {
        user_name: 'John Doe',
        app_name: 'Test App',
        confirmation_url: 'http://example.com/confirm'
      }
    end

    it "renders subject correctly" do
      rendered = substitute_variables(template.subject, variables)
      expect(rendered).to eq("Welcome to Test App!")
    end

    it "includes all required variables" do
      rendered = substitute_variables(template.body, variables)
      expect(rendered).to include('John Doe')
      expect(rendered).to include('Test App')
      expect(rendered).to include('http://example.com/confirm')
    end
  end
end
```

### Mailer Tests

```ruby
RSpec.describe UserMailer do
  describe "#welcome_email" do
    let(:user) { create(:user, first_name: 'John', last_name: 'Doe') }
    let(:mail) { UserMailer.welcome_email(user) }

    it "uses the correct template" do
      expect(mail.subject).to include(AppConfig.app.name)
      expect(mail.body.encoded).to include(user.full_name)
    end

    it "sends to the correct recipient" do
      expect(mail.to).to eq([user.email])
    end
  end
end
```

## Best Practices

### 1. Keep Templates Simple

Use clear, concise language:
```
# Good
Hi {{user_first_name}},
Your order #{{order_number}} has shipped!

# Avoid
Greetings {{user_title}} {{user_first_name}} {{user_middle_name}} {{user_last_name}},
We are pleased to inform you that...
```

### 2. Document Variables

Always list available variables:
```ruby
MailTemplate.create!(
  name: 'order_shipped',
  subject: 'Your order has shipped!',
  body: '...',
  variables: 'user_name, order_number, tracking_url, delivery_date',
  description: 'Sent when order ships. Includes tracking information.'
)
```

### 3. Use Meaningful Names

Template names should be descriptive:
```
# Good
password_reset_instructions
order_confirmation
subscription_renewal_reminder

# Bad
email1
reset
notification
```

### 4. Test Templates

Always test with real data:
```ruby
# In console
template = MailTemplate.find_by(name: 'welcome_email')
user = User.first
UserMailer.welcome_email(user).deliver_now
```

## Troubleshooting

### Variables Not Replaced

Check variable spelling:
```ruby
# Debug in console
template = MailTemplate.find_by(name: 'welcome_email')
variables = { user_name: 'John' }
result = template.body.gsub(/\{\{(\w+)\}\}/) do |match|
  puts "Found variable: #{$1}"
  variables[$1.to_sym] || match
end
```

### Email Not Sending

1. Check mail configuration
2. Verify template exists
3. Check for validation errors
4. Review mail logs

### Template Not Found

```ruby
# List all templates
MailTemplate.pluck(:name, :locale)

# Find similar
MailTemplate.where("name LIKE ?", "%welcome%")
```

## Next Steps

- Learn about [Background Jobs](background-jobs.md) for email delivery
- Configure [Settings](settings.md) for email configuration
- Set up [Admin Panel](admin-panel.md) for template management