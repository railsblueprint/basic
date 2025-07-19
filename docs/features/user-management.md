# User Management

Rails Blueprint provides comprehensive user management capabilities through the admin panel, allowing administrators to create, edit, and manage user accounts and their permissions.

## Features

### User Account Management
- Create new user accounts
- Edit user profiles and information
- Activate/deactivate accounts
- Lock/unlock user accounts
- Reset user passwords
- Delete user accounts

### Role Management
- Assign and remove roles
- View users by role
- Bulk role assignments
- Role-based filtering

### User Monitoring
- View login history
- Track user activity
- Monitor failed login attempts
- Session management

## Admin Interface

Access user management at `/admin/users`

### User List View

The user list provides:
- Sortable columns (name, email, created date, last login)
- Search by name or email
- Filter by role
- Filter by status (active, locked, unconfirmed)
- Pagination for large user bases
- Quick actions menu

### User Actions

#### Creating Users

Administrators can create users directly:

```ruby
# Admin creates user without email confirmation
user = User.new(
  email: 'newuser@example.com',
  password: 'temporary_password',
  first_name: 'John',
  last_name: 'Doe',
  confirmed_at: Time.current  # Skip email confirmation
)
user.skip_confirmation!
user.save!
```

#### Editing Users

Editable fields:
- Basic information (name, email)
- Profile details (phone, website, bio)
- Social media profiles
- Account status
- Roles and permissions

#### Password Management

Admins can:
- Force password reset
- Set temporary password
- Send password reset email
- View password change history

## User Model

### Attributes

```ruby
class User < ApplicationRecord
  # Authentication fields (Devise)
  # - email
  # - encrypted_password
  # - confirmation_token
  # - confirmed_at
  # - unconfirmed_email
  
  # Trackable fields
  # - sign_in_count
  # - current_sign_in_at
  # - last_sign_in_at
  # - current_sign_in_ip
  # - last_sign_in_ip
  
  # Lockable fields
  # - failed_attempts
  # - locked_at
  # - unlock_token
  
  # Profile fields
  # - first_name
  # - last_name
  # - phone
  # - website
  # - bio
  
  # Social profiles
  # - github_profile
  # - linkedin_profile
  # - facebook_profile
  # - twitter_profile
  
  # Timestamps
  # - created_at
  # - updated_at
end
```

### Methods

```ruby
# Full name
user.full_name
user.display_name

# Role checks
user.has_role?(:admin)
user.has_any_role?(:admin, :editor)

# Account status
user.active?
user.locked?
user.confirmed?

# Activity
user.last_activity_at
user.online?
```

## Role Management

### Available Roles

| Role | Description | Typical Permissions |
|------|-------------|-------------------|
| **superadmin** | System administrator | Unrestricted access |
| **admin** | Administrator | User and content management |
| **editor** | Content editor | Content creation and editing |
| **user** | Regular user | Basic access |

### Managing Roles

```ruby
# Add role
user.add_role(:admin)

# Remove role
user.remove_role(:admin)

# Replace all roles
user.roles = [Role.find_by(name: 'editor')]

# Check roles
user.roles.pluck(:name)
# => ['admin', 'editor']
```

### Role-based Queries

```ruby
# Find all admins
User.with_role(:admin)

# Find users with any administrative role
User.with_any_role(:admin, :editor)

# Find users without a specific role
User.without_role(:admin)
```

## Admin Commands

Rails Blueprint uses command objects for user operations:

### CreateUserCommand

```ruby
command = Admin::CreateUserCommand.new(
  email: 'user@example.com',
  password: 'secure_password',
  first_name: 'Jane',
  last_name: 'Doe',
  roles: ['editor'],
  skip_confirmation: true
)

if command.execute
  user = command.user
  # User created successfully
else
  errors = command.errors
  # Handle errors
end
```

### UpdateUserCommand

```ruby
command = Admin::UpdateUserCommand.new(
  user: user,
  attributes: {
    first_name: 'Updated',
    last_name: 'Name',
    roles: ['admin', 'editor']
  }
)

command.execute
```

### PasswordResetCommand

```ruby
command = Admin::PasswordResetCommand.new(
  user: user,
  new_password: 'new_secure_password',
  send_notification: true
)

command.execute
```

## User Search and Filtering

### Search Implementation

```ruby
class UserSearch
  def initialize(params = {})
    @params = params
  end

  def results
    scope = User.includes(:roles)
    scope = filter_by_search(scope)
    scope = filter_by_role(scope)
    scope = filter_by_status(scope)
    scope.order(created_at: :desc)
  end

  private

  def filter_by_search(scope)
    return scope if @params[:search].blank?
    
    scope.where(
      "email ILIKE :search OR first_name ILIKE :search OR last_name ILIKE :search",
      search: "%#{@params[:search]}%"
    )
  end

  def filter_by_role(scope)
    return scope if @params[:role].blank?
    
    scope.with_role(@params[:role])
  end

  def filter_by_status(scope)
    case @params[:status]
    when 'active'
      scope.confirmed
    when 'locked'
      scope.where.not(locked_at: nil)
    when 'unconfirmed'
      scope.where(confirmed_at: nil)
    else
      scope
    end
  end
end
```

## Bulk Operations

### Bulk Role Assignment

```ruby
user_ids = [1, 2, 3, 4, 5]
role = Role.find_by(name: 'editor')

User.where(id: user_ids).find_each do |user|
  user.add_role(role.name)
end
```

### Bulk Account Operations

```ruby
# Lock multiple accounts
User.where(id: user_ids).update_all(locked_at: Time.current)

# Send bulk emails
User.where(id: user_ids).find_each do |user|
  UserMailer.announcement(user).deliver_later
end
```

## User Activity Tracking

### Login Tracking

```ruby
# Recent logins
User.where('last_sign_in_at > ?', 1.day.ago)

# Never logged in
User.where(sign_in_count: 0)

# Most active users
User.order(sign_in_count: :desc).limit(10)
```

### Activity Dashboard

```ruby
class UserActivity
  def self.summary
    {
      total_users: User.count,
      active_today: User.where('last_sign_in_at > ?', 1.day.ago).count,
      new_this_week: User.where('created_at > ?', 1.week.ago).count,
      locked_accounts: User.where.not(locked_at: nil).count,
      unconfirmed: User.where(confirmed_at: nil).count
    }
  end
end
```

## Security Considerations

### Password Policies

```ruby
# Enforce strong passwords
validates :password, 
  length: { minimum: 8 },
  format: { 
    with: /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/, 
    message: "must include uppercase, lowercase, and number" 
  }
```

### Account Locking

```ruby
# Lock after 5 failed attempts
Devise.maximum_attempts = 5

# Unlock after 1 hour
Devise.unlock_in = 1.hour

# Manual lock/unlock
user.lock_access!
user.unlock_access!
```

### Admin Actions Audit

```ruby
class AdminAudit < ApplicationRecord
  belongs_to :admin, class_name: 'User'
  belongs_to :target, polymorphic: true

  def self.log(admin:, action:, target:, changes: {})
    create!(
      admin: admin,
      action: action,
      target: target,
      changes: changes,
      ip_address: admin.current_sign_in_ip
    )
  end
end
```

## Email Communication

### User Notifications

```ruby
# Welcome email
UserMailer.welcome(user).deliver_later

# Account changes
UserMailer.account_updated(user).deliver_later

# Role changes
UserMailer.role_changed(user, new_roles).deliver_later
```

### Bulk Emails

```ruby
# Send to all users with specific role
User.with_role(:subscriber).find_each do |user|
  NewsletterMailer.weekly_digest(user).deliver_later
end
```

## Testing User Management

### Factory Setup

```ruby
FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { 'password123' }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    confirmed_at { Time.current }

    trait :admin do
      after(:create) { |user| user.add_role(:admin) }
    end

    trait :editor do
      after(:create) { |user| user.add_role(:editor) }
    end

    trait :locked do
      locked_at { Time.current }
    end
  end
end
```

### Controller Tests

```ruby
RSpec.describe Admin::UsersController do
  let(:admin) { create(:user, :admin) }
  
  describe "PUT #update" do
    let(:user) { create(:user) }

    it "updates user attributes" do
      put :update, params: {
        id: user.id,
        user: { first_name: 'Updated' }
      }
      
      expect(user.reload.first_name).to eq('Updated')
    end

    it "updates user roles" do
      put :update, params: {
        id: user.id,
        user: { role_ids: [Role.find_by(name: 'editor').id] }
      }
      
      expect(user.reload.has_role?(:editor)).to be true
    end
  end
end
```

## Next Steps

- Configure [Authorization](authorization.md) policies
- Set up [Email Templates](email-templates.md)
- Learn about [Settings Management](settings.md)