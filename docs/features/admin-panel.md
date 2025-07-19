# Admin Panel

Rails Blueprint includes a comprehensive admin panel for managing your application. Built with responsive design and modern UI patterns, it provides an intuitive interface for administrative tasks.

## Features

### Dashboard
- Overview of system statistics
- Recent activity feed
- Quick access to common tasks
- System health indicators

### Management Sections
- **Users** - User account management
- **Posts** - Blog content management
- **Pages** - Static page management
- **Settings** - Application configuration
- **Email Templates** - Email customization
- **Background Jobs** - Job queue monitoring
- **Database Insights** - Performance monitoring

## Accessing the Admin Panel

Navigate to `/admin` and login with admin credentials:
- Default: `superadmin@localhost` / `12345678`

Only users with admin or editor roles can access the admin panel.

## Navigation Structure

```
Admin Panel
├── Dashboard
├── Users
│   ├── All Users
│   ├── Create User
│   └── User Roles
├── Content
│   ├── Posts
│   ├── Pages
│   └── Categories
├── System
│   ├── Settings
│   ├── Email Templates
│   ├── Background Jobs
│   └── Database
└── Design System
```

## Admin Controllers

### Base Controller

All admin controllers inherit from `Admin::BaseController`:

```ruby
class Admin::BaseController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin_access!
  
  layout 'admin'

  private

  def authorize_admin_access!
    authorize :admin, :dashboard?
  end
end
```

### CRUD Controller

Standard CRUD operations inherit from `Admin::CrudController`:

```ruby
class Admin::PostsController < Admin::CrudController
  private

  def model_class
    Post
  end

  def permitted_params
    params.require(:post).permit(:title, :content, :published, :author_id)
  end
end
```

## UI Components

### Layout

The admin panel uses a dedicated layout:
- Responsive sidebar navigation
- Top navigation bar with user menu
- Breadcrumb navigation
- Flash message system

### Tables

Data tables include:
- Sorting capabilities
- Pagination
- Search/filter options
- Bulk actions
- Responsive design

### Forms

Form features:
- Bootstrap styling
- Client-side validation
- Rich text editors
- File upload support
- Date/time pickers

## Key Sections

### User Management

Manage user accounts:
- Create new users
- Edit user profiles
- Assign/remove roles
- Lock/unlock accounts
- Send password reset
- View login history

### Content Management

Manage blog posts and pages:
- Create/edit content
- Preview before publishing
- SEO metadata
- Featured images
- Categories and tags
- Publishing workflow

### Settings Management

Configure application:
- General settings
- Email configuration
- Feature flags
- Social media links
- SEO settings
- Maintenance mode

### Email Templates

Customize system emails:
- Visual editor
- Variable substitution
- Preview functionality
- Test sending
- Multiple languages
- Version history

## Monitoring Tools

### Background Jobs

Monitor job processing:
- Queue statistics
- Failed jobs
- Job history
- Performance metrics
- Retry management
- Real-time updates

Access at: `/admin/good_job`

### Database Insights

Database performance monitoring:
- Slow queries
- Index usage
- Table sizes
- Cache hit rates
- Active connections
- Query analysis

Access at: `/admin/pg_hero`

## Design System

View UI components and patterns:
- Color palette
- Typography
- Buttons
- Forms
- Cards
- Alerts
- Icons
- Layout examples

Access at: `/admin/design_system`

## Customization

### Adding Menu Items

Add items to admin navigation:

```ruby
# app/views/admin/shared/_sidebar.html.slim
li.nav-item
  = link_to admin_custom_path, class: 'nav-link' do
    i.bi.bi-gear
    span Custom Section
```

### Creating Admin Controllers

```ruby
# app/controllers/admin/custom_controller.rb
class Admin::CustomController < Admin::BaseController
  def index
    @items = authorize policy_scope(CustomModel)
  end

  def new
    @item = CustomModel.new
    authorize @item
  end

  def create
    @item = CustomModel.new(permitted_params)
    authorize @item
    
    if @item.save
      redirect_to admin_custom_index_path, notice: 'Created successfully'
    else
      render :new
    end
  end

  private

  def permitted_params
    params.require(:custom_model).permit(:name, :description)
  end
end
```

### Custom Admin Routes

```ruby
# config/routes.rb
namespace :admin do
  resources :custom do
    member do
      post :activate
      post :deactivate
    end
    
    collection do
      get :export
    end
  end
end
```

## Styling

### CSS Classes

The admin panel uses Bootstrap 5 with custom utilities:

```scss
// Admin-specific classes
.admin-header { }
.admin-sidebar { }
.admin-content { }
.admin-table { }
.admin-form { }
```

### Color Scheme

Uses CSS variables for theming:

```css
:root {
  --admin-primary: #0d6efd;
  --admin-sidebar-bg: #212529;
  --admin-header-bg: #ffffff;
}
```

## Security

### Access Control

- Role-based access using Pundit policies
- Separate policies for each admin section
- Audit logging for sensitive actions
- CSRF protection on all forms

### Best Practices

1. Always use strong parameters
2. Authorize all actions
3. Log administrative changes
4. Implement rate limiting
5. Use secure session management

## Performance

### Optimization Techniques

- Pagination for large datasets
- Eager loading to prevent N+1 queries
- Database indexes on filtered columns
- Caching for expensive operations
- Background jobs for bulk operations

### Monitoring

```ruby
# Check admin panel performance
Rails.logger.info "Admin action took #{Benchmark.ms { yield }}ms"

# Monitor database queries
config.after_initialize do
  Bullet.add_whitelist type: :n_plus_one_query, class_name: "User", association: :roles
end
```

## Testing

### Controller Tests

```ruby
RSpec.describe Admin::UsersController do
  let(:admin) { create(:user, :admin) }
  
  before { sign_in admin }

  describe "GET #index" do
    it "returns success" do
      get :index
      expect(response).to be_successful
    end
  end

  describe "POST #create" do
    it "creates a new user" do
      expect {
        post :create, params: { user: attributes_for(:user) }
      }.to change(User, :count).by(1)
    end
  end
end
```

### Feature Tests

```ruby
RSpec.feature "Admin Panel" do
  let(:admin) { create(:user, :admin) }

  before { login_as admin }

  scenario "Admin views dashboard" do
    visit admin_root_path
    expect(page).to have_content("Dashboard")
    expect(page).to have_content("Recent Activity")
  end

  scenario "Admin creates a user" do
    visit admin_users_path
    click_link "New User"
    
    fill_in "Email", with: "newuser@example.com"
    fill_in "Password", with: "password123"
    click_button "Create User"
    
    expect(page).to have_content("User created successfully")
  end
end
```

## Troubleshooting

### Common Issues

1. **Access Denied**
   - Verify user has admin role
   - Check Pundit policies
   - Ensure authentication

2. **Missing Routes**
   - Check namespace in routes
   - Verify controller location
   - Run `rails routes | grep admin`

3. **Asset Issues**
   - Clear asset cache
   - Check for missing files
   - Verify asset pipeline

### Debug Mode

Enable debug mode for admin:

```ruby
# config/environments/development.rb
config.admin_debug = true

# In admin controller
logger.debug "Admin action: #{action_name}" if Rails.configuration.admin_debug
```

## Next Steps

- Learn about [User Management](user-management.md)
- Configure [Settings](settings.md)
- Customize [Email Templates](email-templates.md)