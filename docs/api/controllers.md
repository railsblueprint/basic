# Controllers Reference

Documentation for Rails Blueprint's controller architecture and patterns.

## Controller Hierarchy

### Base Controllers

#### ApplicationController

The root controller for all application controllers:

```ruby
class ApplicationController < ActionController::Base
  include Pundit::Authorization
  
  protect_from_forgery with: :exception
  
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_locale
  
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  
  protected
  
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :phone, :website, :bio])
  end
  
  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end
  
  private
  
  def user_not_authorized
    flash[:alert] = t('pundit.not_authorized')
    redirect_back(fallback_location: root_path)
  end
end
```

#### Admin::BaseController

Base controller for all admin controllers:

```ruby
class Admin::BaseController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin_access!
  
  layout 'admin'
  
  private
  
  def authorize_admin_access!
    authorize :admin, :dashboard?
  end
  
  def pundit_user
    current_user
  end
end
```

#### Admin::CrudController

Generic CRUD controller for admin resources:

```ruby
class Admin::CrudController < Admin::BaseController
  before_action :set_resource, only: [:show, :edit, :update, :destroy]
  
  def index
    @resources = policy_scope(model_class).page(params[:page])
    authorize @resources
  end
  
  def new
    @resource = model_class.new
    authorize @resource
  end
  
  def create
    @resource = model_class.new(permitted_params)
    authorize @resource
    
    if @resource.save
      redirect_to [:admin, @resource], notice: success_message('created')
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def update
    if @resource.update(permitted_params)
      redirect_to [:admin, @resource], notice: success_message('updated')
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  def destroy
    @resource.destroy
    redirect_to [:admin, model_class], notice: success_message('deleted')
  end
  
  private
  
  def set_resource
    @resource = model_class.find(params[:id])
    authorize @resource
  end
  
  def model_class
    controller_name.classify.constantize
  end
  
  def permitted_params
    params.require(model_name.singular).permit(permitted_attributes)
  end
  
  def success_message(action)
    t("admin.#{model_name.plural}.#{action}")
  end
end
```

## Public Controllers

### PostsController

Blog posts controller:

```ruby
class PostsController < ApplicationController
  before_action :set_post, only: [:show]
  
  def index
    @posts = Post.published.recent.page(params[:page])
    @featured_posts = Post.featured.published.limit(3)
  end
  
  def show
    @related_posts = @post.related_posts.limit(3)
    
    # Track view count
    @post.increment!(:views_count)
  end
  
  def search
    @posts = Post.published.search(params[:q]).page(params[:page])
    render :index
  end
  
  private
  
  def set_post
    @post = Post.friendly.find(params[:id])
    authorize @post, :show?
    
    # Redirect if slug changed
    if request.path != post_path(@post)
      redirect_to @post, status: :moved_permanently
    end
  end
end
```

### PagesController

Static pages controller:

```ruby
class PagesController < ApplicationController
  before_action :set_page
  
  def show
    render template: @page.template_path
  end
  
  private
  
  def set_page
    @page = Page.published.friendly.find(params[:id])
    authorize @page, :show?
  end
end
```

### StaticPagesController

Home and system pages:

```ruby
class StaticPagesController < ApplicationController
  def home
    @featured_posts = Post.featured.published.limit(3)
    @recent_posts = Post.published.recent.limit(6)
    
    # Try to render home page from CMS
    @page = Page.find_by(slug: 'home')
    render :page if @page
  end
  
  def about
    @page = Page.find_by!(slug: 'about')
    render :page
  end
  
  def contact
    @contact = Contact.new
  end
  
  def create_contact
    @contact = Contact.new(contact_params)
    
    if @contact.valid?
      ContactMailer.contact_form(@contact).deliver_later
      redirect_to contact_path, notice: t('contact.success')
    else
      render :contact, status: :unprocessable_entity
    end
  end
  
  private
  
  def contact_params
    params.require(:contact).permit(:name, :email, :subject, :message)
  end
end
```

## Admin Controllers

### Admin::UsersController

User management:

```ruby
class Admin::UsersController < Admin::CrudController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :lock, :unlock, :confirm]
  
  def index
    @users = policy_scope(User)
              .includes(:roles)
              .search(params[:search])
              .page(params[:page])
  end
  
  def create
    @user = User.new(user_params)
    authorize @user
    
    if @user.save
      @user.add_role(params[:role]) if params[:role].present?
      redirect_to admin_users_path, notice: 'User created successfully'
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def update
    # Remove password params if blank
    if params[:user][:password].blank?
      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
    end
    
    if @user.update(user_params)
      update_roles
      redirect_to admin_users_path, notice: 'User updated successfully'
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  # Custom actions
  def lock
    @user.lock_access!
    redirect_back(fallback_location: admin_users_path, notice: 'User locked')
  end
  
  def unlock
    @user.unlock_access!
    redirect_back(fallback_location: admin_users_path, notice: 'User unlocked')
  end
  
  def confirm
    @user.confirm!
    redirect_back(fallback_location: admin_users_path, notice: 'User confirmed')
  end
  
  private
  
  def set_user
    @user = User.find(params[:id])
    authorize @user
  end
  
  def user_params
    params.require(:user).permit(
      :email, :password, :password_confirmation,
      :first_name, :last_name, :phone, :website, :bio
    )
  end
  
  def update_roles
    return unless params[:user][:role_ids]
    
    @user.roles = Role.where(id: params[:user][:role_ids])
  end
end
```

### Admin::PostsController

Blog post management:

```ruby
class Admin::PostsController < Admin::CrudController
  def new
    @post = current_user.posts.build
    authorize @post
  end
  
  def create
    @post = current_user.posts.build(post_params)
    authorize @post
    
    if @post.save
      redirect_to admin_posts_path, notice: 'Post created successfully'
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  # Preview unpublished posts
  def preview
    @post = Post.friendly.find(params[:id])
    authorize @post, :preview?
    
    render 'posts/show', layout: 'application'
  end
  
  # Bulk actions
  def bulk_publish
    @posts = Post.where(id: params[:post_ids])
    authorize @posts, :bulk_update?
    
    @posts.update_all(published: true, published_at: Time.current)
    redirect_back(fallback_location: admin_posts_path, notice: 'Posts published')
  end
  
  private
  
  def post_params
    params.require(:post).permit(
      :title, :content, :excerpt, :published, :published_at,
      :featured, :featured_image_url, :meta_title, :meta_description,
      category_ids: []
    )
  end
  
  def permitted_attributes
    [:title, :content, :excerpt, :published, :published_at, :featured,
     :featured_image_url, :meta_title, :meta_description, { category_ids: [] }]
  end
end
```

### Admin::SettingsController

Application settings management:

```ruby
class Admin::SettingsController < Admin::BaseController
  def index
    @settings = policy_scope(Setting).by_section
    @sections = @settings.pluck(:section).uniq.compact
  end
  
  def edit
    @setting = Setting.find(params[:id])
    authorize @setting
  end
  
  def update
    @setting = Setting.find(params[:id])
    authorize @setting
    
    if @setting.update(setting_params)
      # Clear cache to reflect changes
      AppConfig.reload!
      
      redirect_to admin_settings_path, notice: 'Setting updated'
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  # Bulk update
  def update_all
    authorize Setting, :update?
    
    params[:settings].each do |id, value|
      setting = Setting.find(id)
      setting.update(value: value)
    end
    
    AppConfig.reload!
    redirect_to admin_settings_path, notice: 'Settings updated'
  end
  
  private
  
  def setting_params
    params.require(:setting).permit(:value, :description)
  end
end
```

## API Controllers (Example)

### Api::V1::BaseController

Base API controller:

```ruby
class Api::V1::BaseController < ActionController::API
  include Pundit::Authorization
  
  before_action :authenticate_api_user!
  
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from Pundit::NotAuthorizedError, with: :forbidden
  
  private
  
  def authenticate_api_user!
    # Implement token authentication
    token = request.headers['Authorization']&.split(' ')&.last
    @current_user = User.find_by_api_token(token) if token
    
    render_unauthorized unless @current_user
  end
  
  def current_user
    @current_user
  end
  
  def render_unauthorized
    render json: { error: 'Unauthorized' }, status: :unauthorized
  end
  
  def not_found
    render json: { error: 'Not found' }, status: :not_found
  end
  
  def forbidden
    render json: { error: 'Forbidden' }, status: :forbidden
  end
end
```

### Api::V1::PostsController

API posts endpoint:

```ruby
class Api::V1::PostsController < Api::V1::BaseController
  def index
    @posts = policy_scope(Post)
              .published
              .recent
              .page(params[:page])
              .per(params[:per_page] || 20)
    
    render json: {
      posts: ActiveModelSerializers::SerializableResource.new(@posts),
      meta: pagination_meta(@posts)
    }
  end
  
  def show
    @post = Post.friendly.find(params[:id])
    authorize @post
    
    render json: @post
  end
  
  private
  
  def pagination_meta(collection)
    {
      current_page: collection.current_page,
      total_pages: collection.total_pages,
      total_count: collection.total_count,
      per_page: collection.limit_value
    }
  end
end
```

## Controller Concerns

### Loafable

Breadcrumb management:

```ruby
module Loafable
  extend ActiveSupport::Concern
  
  included do
    before_action :add_breadcrumbs
  end
  
  private
  
  def add_breadcrumbs
    breadcrumb 'Home', root_path
    
    # Add controller-specific breadcrumbs
    case controller_name
    when 'posts'
      breadcrumb 'Blog', posts_path
      breadcrumb @post.title, @post if action_name == 'show'
    when 'pages'
      breadcrumb @page.title, @page if @page
    end
  end
end
```

### Searchable

Search functionality:

```ruby
module Searchable
  extend ActiveSupport::Concern
  
  included do
    helper_method :search_params
  end
  
  def search_params
    params.slice(:q, :category, :author, :from_date, :to_date)
           .permit(:q, :category, :author, :from_date, :to_date)
  end
  
  def apply_search(scope)
    scope = scope.search(search_params[:q]) if search_params[:q].present?
    scope = scope.by_category(search_params[:category]) if search_params[:category].present?
    scope = scope.by_author(search_params[:author]) if search_params[:author].present?
    scope
  end
end
```

## Best Practices

### Strong Parameters

Always use strong parameters:

```ruby
private

def resource_params
  params.require(:resource).permit(:title, :content, tag_ids: [])
end
```

### Authorization

Always authorize actions:

```ruby
def show
  @resource = Resource.find(params[:id])
  authorize @resource  # Never skip this!
end
```

### Respond With

Use consistent response patterns:

```ruby
def create
  @resource = Resource.new(resource_params)
  
  respond_to do |format|
    if @resource.save
      format.html { redirect_to @resource, notice: 'Created successfully' }
      format.json { render json: @resource, status: :created }
    else
      format.html { render :new, status: :unprocessable_entity }
      format.json { render json: @resource.errors, status: :unprocessable_entity }
    end
  end
end
```

### Filters and Callbacks

Use filters wisely:

```ruby
class ResourcesController < ApplicationController
  # Authentication
  before_action :authenticate_user!, except: [:index, :show]
  
  # Resource loading
  before_action :set_resource, only: [:show, :edit, :update, :destroy]
  
  # Authorization
  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index
  
  # Tracking
  after_action :track_action, only: [:show]
end
```

## Testing Controllers

### Request Specs

```ruby
RSpec.describe "Posts", type: :request do
  let(:user) { create(:user) }
  
  describe "GET /posts" do
    it "returns success" do
      get posts_path
      expect(response).to have_http_status(:success)
    end
  end
  
  describe "POST /posts" do
    before { sign_in user }
    
    it "creates a post" do
      expect {
        post posts_path, params: { post: attributes_for(:post) }
      }.to change(Post, :count).by(1)
    end
  end
end
```

### Controller Specs

```ruby
RSpec.describe Admin::UsersController, type: :controller do
  let(:admin) { create(:user, :admin) }
  
  before { sign_in admin }
  
  describe "GET #index" do
    it "returns success" do
      get :index
      expect(response).to be_successful
    end
    
    it "assigns users" do
      users = create_list(:user, 3)
      get :index
      expect(assigns(:users)).to match_array(users + [admin])
    end
  end
end
```

## Next Steps

- Understand [Commands](commands.md) for business logic
- Review [Models](models.md) used by controllers
- Learn about [Helpers](helpers.md) for view logic