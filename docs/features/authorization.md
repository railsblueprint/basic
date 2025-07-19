# Authorization

Rails Blueprint implements role-based authorization using [Pundit](https://github.com/varvet/pundit) for policies and [Rolify](https://github.com/RolifyCommunity/rolify) for role management.

## Overview

The authorization system provides:
- Role-based access control (RBAC)
- Fine-grained permissions
- Policy-based authorization
- Resource-level permissions
- Secure by default approach

## Roles

### Default Roles

Rails Blueprint includes these roles out of the box:

| Role | Description | Capabilities |
|------|-------------|--------------|
| **superadmin** | System administrator | Full system access, cannot be restricted |
| **admin** | Administrator | Manage users, content, and settings |
| **editor** | Content editor | Create and edit content, limited admin access |
| **user** | Regular user | Access own profile and public content |

### Role Management

```ruby
# Add role to user
user.add_role(:admin)
user.add_role(:editor, Post)  # Scoped to model

# Remove role
user.remove_role(:admin)

# Check roles
user.has_role?(:admin)
user.has_role?(:editor, Post)
user.has_any_role?(:admin, :editor)
user.has_all_roles?(:admin, :editor)

# Get users with role
User.with_role(:admin)
User.with_any_role(:admin, :editor)
```

## Policies

Pundit policies define what users can do with resources.

### Policy Structure

```ruby
# app/policies/post_policy.rb
class PostPolicy < ApplicationPolicy
  def index?
    true  # Everyone can view posts
  end

  def show?
    record.published? || user_is_owner_or_admin?
  end

  def create?
    user.present? && user.has_any_role?(:admin, :editor)
  end

  def update?
    user_is_owner_or_admin?
  end

  def destroy?
    user_is_admin?
  end

  private

  def user_is_owner_or_admin?
    user.present? && (record.author == user || user.has_role?(:admin))
  end

  def user_is_admin?
    user.present? && user.has_role?(:admin)
  end
end
```

### Using Policies in Controllers

```ruby
class PostsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  
  def index
    @posts = policy_scope(Post)
  end

  def show
    @post = Post.find(params[:id])
    authorize @post
  end

  def edit
    @post = Post.find(params[:id])
    authorize @post
  end

  def update
    @post = Post.find(params[:id])
    authorize @post
    
    if @post.update(post_params)
      redirect_to @post
    else
      render :edit
    end
  end
end
```

### Policy Scopes

Control which records users can see:

```ruby
class PostPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.has_role?(:admin)
        scope.all
      elsif user.has_role?(:editor)
        scope.where(author: user).or(scope.published)
      else
        scope.published
      end
    end
  end
end
```

## Admin Panel Authorization

The admin panel uses a special policy:

```ruby
class AdminPolicy < ApplicationPolicy
  def dashboard?
    user_has_admin_access?
  end

  def settings?
    user.has_role?(:admin)
  end

  def users?
    user.has_role?(:admin)
  end

  private

  def user_has_admin_access?
    user.has_any_role?(:admin, :editor)
  end
end
```

## View Helpers

### Policy Checks in Views

```erb
<% if policy(@post).edit? %>
  <%= link_to "Edit", edit_post_path(@post) %>
<% end %>

<% if policy(@post).destroy? %>
  <%= link_to "Delete", post_path(@post), method: :delete %>
<% end %>
```

### Role Checks in Views

```erb
<% if current_user.has_role?(:admin) %>
  <%= link_to "Admin Panel", admin_root_path %>
<% end %>

<% if current_user.has_any_role?(:admin, :editor) %>
  <%= link_to "New Post", new_post_path %>
<% end %>
```

## Common Patterns

### Superadmin Override

```ruby
class ApplicationPolicy
  def initialize(user, record)
    @user = user
    @record = record
  end

  # Superadmin can do anything
  def superadmin?
    user&.has_role?(:superadmin)
  end

  # Override in subclasses
  def index?
    superadmin?
  end

  def show?
    superadmin?
  end

  def create?
    superadmin?
  end

  def update?
    superadmin?
  end

  def destroy?
    superadmin?
  end
end
```

### Resource Ownership

```ruby
def owned_by_user?
  record.respond_to?(:user) && record.user == user
end

def update?
  superadmin? || owned_by_user?
end
```

### Published Content

```ruby
def show?
  return true if superadmin?
  return true if owned_by_user?
  
  record.published? && record.published_at <= Time.current
end
```

## Testing Authorization

### Policy Tests

```ruby
RSpec.describe PostPolicy do
  subject { described_class }

  let(:user) { create(:user) }
  let(:admin) { create(:user, :admin) }
  let(:post) { create(:post) }

  permissions :show? do
    it "allows anyone to view published posts" do
      post.update(published: true)
      expect(subject).to permit(nil, post)
    end

    it "prevents viewing unpublished posts" do
      post.update(published: false)
      expect(subject).not_to permit(user, post)
    end

    it "allows admin to view any post" do
      post.update(published: false)
      expect(subject).to permit(admin, post)
    end
  end
end
```

### Controller Tests

```ruby
RSpec.describe PostsController do
  let(:user) { create(:user) }
  let(:admin) { create(:user, :admin) }

  describe "GET #edit" do
    let(:post) { create(:post) }

    context "as admin" do
      before { sign_in admin }

      it "allows access" do
        get :edit, params: { id: post.id }
        expect(response).to be_successful
      end
    end

    context "as regular user" do
      before { sign_in user }

      it "denies access" do
        expect {
          get :edit, params: { id: post.id }
        }.to raise_error(Pundit::NotAuthorizedError)
      end
    end
  end
end
```

## Best Practices

### 1. Fail Secure

Always default to denying access:

```ruby
def update?
  return false unless user.present?
  # Additional checks...
end
```

### 2. Use Scopes

Filter data at the database level:

```ruby
def index
  @posts = policy_scope(Post).includes(:author)
end
```

### 3. Explicit Authorization

Always call `authorize` in controllers:

```ruby
def show
  @post = Post.find(params[:id])
  authorize @post  # Don't forget this!
end
```

### 4. Handle Unauthorized Access

```ruby
class ApplicationController < ActionController::Base
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_back(fallback_location: root_path)
  end
end
```

## Advanced Usage

### Scoped Roles

```ruby
# User is editor for specific posts
user.add_role(:editor, Post.where(category: 'news'))

# Check scoped role
user.has_role?(:editor, specific_post)
```

### Custom Policy Methods

```ruby
class PostPolicy < ApplicationPolicy
  def publish?
    user.has_role?(:editor) && !record.published?
  end

  def unpublish?
    user.has_role?(:editor) && record.published?
  end
end
```

### Policy Delegation

```ruby
class CommentPolicy < ApplicationPolicy
  def create?
    # Delegate to post policy
    PostPolicy.new(user, record.post).show?
  end
end
```

## Troubleshooting

### Common Issues

1. **Pundit::NotAuthorizedError**
   - Ensure user is authenticated
   - Check policy returns true
   - Verify `authorize` is called

2. **Policy not found**
   - Ensure policy class exists
   - Check naming convention (ModelPolicy)
   - Verify inheritance from ApplicationPolicy

3. **Scope returns empty**
   - Check scope logic
   - Verify user roles
   - Test in Rails console

### Debug Commands

```ruby
# Test policy in console
user = User.find(1)
post = Post.find(1)
PostPolicy.new(user, post).edit?

# Check user roles
user.roles.pluck(:name)
user.has_role?(:admin)

# Test scope
PostPolicy::Scope.new(user, Post).resolve
```

## Next Steps

- Set up [User Management](user-management.md)
- Configure [Admin Panel](admin-panel.md) access
- Learn about [Email Templates](email-templates.md)