# Authentication

Rails Blueprint uses [Devise](https://github.com/heartcombo/devise) for authentication, providing a complete user authentication system out of the box.

## Features

### Core Authentication
- User registration with email/password
- Secure login and logout
- Remember me functionality
- Session management
- Password encryption with BCrypt

### Email Confirmation
- Email verification for new accounts
- Resend confirmation instructions
- Prevents login until confirmed
- Customizable confirmation period

### Password Management
- Secure password reset via email
- Password strength requirements
- Password change functionality
- Password recovery tokens

### Account Security
- Account locking after failed attempts
- IP and timestamp tracking
- Session timeout configuration
- CSRF protection

## User Model

The User model includes these Devise modules:

```ruby
class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :lockable, :trackable

  # Additional user attributes
  has_many :posts, foreign_key: :author_id
  has_and_belongs_to_many :roles
  
  # User profile fields
  # - first_name
  # - last_name
  # - phone
  # - website
  # - bio
  # - github_profile
  # - linkedin_profile
  # - facebook_profile
  # - twitter_profile
end
```

## Configuration

### Devise Settings

Configure Devise in `config/initializers/devise.rb`:

```ruby
# Email settings
config.mailer_sender = 'noreply@yourdomain.com'

# Password requirements
config.password_length = 8..128

# Confirmation period
config.confirm_within = 3.days

# Lockable settings
config.lock_strategy = :failed_attempts
config.maximum_attempts = 5
config.unlock_strategy = :email

# Session timeout
config.timeout_in = 30.minutes
```

### Routes

Authentication routes are defined in `config/routes.rb`:

```ruby
devise_for :users, controllers: {
  registrations: 'users/registrations',
  sessions: 'users/sessions',
  passwords: 'users/passwords',
  confirmations: 'users/confirmations'
}
```

## Usage

### Registration

Users can register at `/users/sign_up`:

1. Fill in email and password
2. Receive confirmation email
3. Click confirmation link
4. Account activated and ready to use

### Login

Users login at `/users/sign_in`:

- Email and password authentication
- "Remember me" option for persistent sessions
- Redirects to intended page after login

### Password Reset

If users forget their password:

1. Visit `/users/password/new`
2. Enter email address
3. Receive reset instructions
4. Click link and set new password

## Customization

### Views

Rails Blueprint includes customized Devise views:

```
app/views/devise/
├── confirmations/
│   └── new.html.slim
├── passwords/
│   ├── edit.html.slim
│   └── new.html.slim
├── registrations/
│   ├── edit.html.slim
│   └── new.html.slim
├── sessions/
│   └── new.html.slim
└── shared/
    ├── _error_messages.html.slim
    └── _links.html.slim
```

### Controllers

Custom controllers provide additional functionality:

```ruby
# app/controllers/users/registrations_controller.rb
class Users::RegistrationsController < Devise::RegistrationsController
  protected

  def after_sign_up_path_for(resource)
    # Redirect after successful registration
    root_path
  end

  def after_update_path_for(resource)
    # Redirect after profile update
    edit_user_registration_path
  end
end
```

### Email Templates

Devise emails are customizable through the mail templates system:

- **Confirmation Instructions** - Sent when user registers
- **Reset Password Instructions** - Sent for password recovery
- **Unlock Instructions** - Sent when account is locked
- **Email Changed** - Notification of email change
- **Password Changed** - Notification of password change

## Security Best Practices

### Strong Parameters

Only permitted parameters are accepted:

```ruby
def configure_sign_up_params
  devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name])
end

def configure_account_update_params
  devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :phone, :website, :bio])
end
```

### Session Security

- Sessions stored in cookies with HttpOnly flag
- Secure flag enabled in production
- CSRF tokens for all forms
- Session fixation protection

### Password Security

- Minimum 8 characters required
- BCrypt with cost factor 12
- No password reuse tracking (can be added)
- Secure password reset tokens

## Integration with Other Features

### With Authorization

After authentication, users are assigned roles:

```ruby
# Check if user is admin
user.has_role?(:admin)

# Add role to user
user.add_role(:editor)
```

### With Admin Panel

Admin users can:
- View all registered users
- Edit user profiles
- Lock/unlock accounts
- Resend confirmation emails
- Manually confirm users

### With Email System

Authentication emails use the mail templates system:
- Customizable email content
- Support for multiple languages
- Variable substitution for personalization

## Testing Authentication

Rails Blueprint includes comprehensive tests:

```ruby
# Test user registration
expect {
  post user_registration_path, params: {
    user: {
      email: 'test@example.com',
      password: 'password123',
      password_confirmation: 'password123'
    }
  }
}.to change(User, :count).by(1)

# Test login
post user_session_path, params: {
  user: {
    email: user.email,
    password: 'password123'
  }
}
expect(response).to redirect_to(root_path)
```

## Troubleshooting

### Common Issues

1. **Confirmation emails not sending**
   - Check email configuration in development
   - Verify Letter Opener is running
   - Check spam folder in production

2. **Users can't login**
   - Ensure account is confirmed
   - Check if account is locked
   - Verify password is correct

3. **Password reset not working**
   - Check email delivery
   - Verify reset token hasn't expired
   - Ensure user exists with that email

### Debug Commands

```ruby
# Rails console commands
User.find_by(email: 'user@example.com').confirmed?
User.find_by(email: 'user@example.com').unlock!
User.find_by(email: 'user@example.com').send_confirmation_instructions
```

## Next Steps

- Configure [Authorization](authorization.md) with roles
- Customize [Email Templates](email-templates.md)
- Set up [User Management](user-management.md) in admin panel