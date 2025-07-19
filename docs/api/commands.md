# Commands Reference

Rails Blueprint uses the Command pattern to encapsulate business logic, providing clean separation of concerns and testable code.

## Command Pattern Overview

Commands are service objects that:
- Encapsulate complex business logic
- Provide consistent interface (execute method)
- Handle validation and error management
- Support database transactions
- Return success/failure status

## Base Command

All commands inherit from BaseCommand:

```ruby
class BaseCommand
  include ActiveModel::Model
  
  def execute
    raise NotImplementedError, "#{self.class} must implement #execute"
  end
  
  def success?
    errors.empty?
  end
  
  def failure?
    !success?
  end
  
  protected
  
  def transaction(&block)
    ActiveRecord::Base.transaction(&block)
  end
  
  def add_error(attribute, message)
    errors.add(attribute, message)
  end
end
```

## User Commands

### CreateUserCommand

Creates a new user with roles:

```ruby
class CreateUserCommand < BaseCommand
  attr_accessor :email, :password, :password_confirmation,
                :first_name, :last_name, :roles,
                :skip_confirmation, :send_welcome_email
  
  attr_reader :user
  
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, length: { minimum: 8 }
  validates :password, confirmation: true
  
  def execute
    return false unless valid?
    
    transaction do
      create_user
      assign_roles
      send_notifications
    end
    
    success?
  rescue ActiveRecord::RecordInvalid => e
    add_error(:base, e.message)
    false
  end
  
  private
  
  def create_user
    @user = User.new(user_attributes)
    @user.skip_confirmation! if skip_confirmation
    @user.save!
  rescue ActiveRecord::RecordInvalid => e
    e.record.errors.full_messages.each do |message|
      add_error(:base, message)
    end
    raise ActiveRecord::Rollback
  end
  
  def user_attributes
    {
      email: email,
      password: password,
      password_confirmation: password_confirmation,
      first_name: first_name,
      last_name: last_name
    }
  end
  
  def assign_roles
    return if roles.blank?
    
    Array(roles).each do |role_name|
      @user.add_role(role_name) if Role.exists?(name: role_name)
    end
  end
  
  def send_notifications
    return unless send_welcome_email
    
    UserMailer.welcome_email(@user).deliver_later
    AdminMailer.new_user_notification(@user).deliver_later
  end
end
```

### UpdateUserCommand

Updates user with validation:

```ruby
class UpdateUserCommand < BaseCommand
  attr_accessor :user, :attributes
  
  validates :user, presence: true
  
  def execute
    return false unless valid?
    
    transaction do
      update_user
      update_roles if attributes[:roles]
      log_changes
    end
    
    success?
  end
  
  private
  
  def update_user
    # Filter out role updates from attributes
    user_attributes = attributes.except(:roles, :role_ids)
    
    unless user.update(user_attributes)
      user.errors.full_messages.each do |message|
        add_error(:base, message)
      end
      raise ActiveRecord::Rollback
    end
  end
  
  def update_roles
    user.roles = []
    Array(attributes[:roles]).each do |role_name|
      user.add_role(role_name)
    end
  end
  
  def log_changes
    return unless user.previous_changes.present?
    
    AuditLog.create!(
      user: Current.user,
      action: 'update_user',
      auditable: user,
      changes: user.previous_changes
    )
  end
end
```

### UpdatePasswordCommand

Secure password updates:

```ruby
class UpdatePasswordCommand < BaseCommand
  attr_accessor :user, :current_password, :new_password, :new_password_confirmation
  attr_accessor :skip_current_password, :send_notification
  
  validates :user, presence: true
  validates :new_password, presence: true, length: { minimum: 8 }
  validates :new_password, confirmation: true
  
  validate :current_password_valid, unless: :skip_current_password
  
  def execute
    return false unless valid?
    
    transaction do
      update_password
      send_notification_email if send_notification
    end
    
    success?
  end
  
  private
  
  def current_password_valid
    return if skip_current_password
    
    unless user.valid_password?(current_password)
      add_error(:current_password, 'is incorrect')
    end
  end
  
  def update_password
    user.password = new_password
    user.password_confirmation = new_password_confirmation
    
    unless user.save
      user.errors.full_messages.each do |message|
        add_error(:base, message)
      end
      raise ActiveRecord::Rollback
    end
  end
  
  def send_notification_email
    UserMailer.password_changed(user).deliver_later
  end
end
```

## Post Commands

### PublishPostCommand

Handles post publishing logic:

```ruby
class PublishPostCommand < BaseCommand
  attr_accessor :post, :publish_at, :notify_subscribers
  
  validates :post, presence: true
  validate :post_ready_for_publishing
  
  def execute
    return false unless valid?
    
    transaction do
      publish_post
      create_activity
      notify_subscribers_async if notify_subscribers
    end
    
    success?
  end
  
  private
  
  def post_ready_for_publishing
    return unless post
    
    add_error(:post, 'is already published') if post.published?
    add_error(:post, 'has no content') if post.content.blank?
    add_error(:post, 'has no title') if post.title.blank?
  end
  
  def publish_post
    post.published = true
    post.published_at = publish_at || Time.current
    
    unless post.save
      post.errors.full_messages.each do |message|
        add_error(:base, message)
      end
      raise ActiveRecord::Rollback
    end
  end
  
  def create_activity
    Activity.create!(
      user: Current.user,
      action: 'published_post',
      trackable: post
    )
  end
  
  def notify_subscribers_async
    NotifySubscribersJob.perform_later(post)
  end
end
```

### ImportPostsCommand

Bulk import posts:

```ruby
class ImportPostsCommand < BaseCommand
  attr_accessor :file_path, :author, :default_category
  
  attr_reader :imported_count, :failed_imports
  
  validates :file_path, presence: true
  validates :author, presence: true
  validate :file_exists
  
  def initialize(*)
    super
    @imported_count = 0
    @failed_imports = []
  end
  
  def execute
    return false unless valid?
    
    transaction do
      import_posts_from_csv
    end
    
    success?
  rescue CSV::MalformedCSVError => e
    add_error(:file, "is malformed: #{e.message}")
    false
  end
  
  private
  
  def file_exists
    return unless file_path
    
    unless File.exist?(file_path)
      add_error(:file_path, 'does not exist')
    end
  end
  
  def import_posts_from_csv
    CSV.foreach(file_path, headers: true) do |row|
      import_post(row)
    end
    
    if @failed_imports.any?
      add_error(:base, "Failed to import #{@failed_imports.count} posts")
    end
  end
  
  def import_post(row)
    post = author.posts.build(
      title: row['title'],
      content: row['content'],
      excerpt: row['excerpt'],
      published: row['published'] == 'true',
      published_at: parse_date(row['published_at'])
    )
    
    if default_category
      post.categories << default_category
    end
    
    if post.save
      @imported_count += 1
    else
      @failed_imports << {
        row: row.to_h,
        errors: post.errors.full_messages
      }
    end
  end
  
  def parse_date(date_string)
    return nil if date_string.blank?
    
    Date.parse(date_string)
  rescue Date::Error
    nil
  end
end
```

## Settings Commands

### UpdateSettingsCommand

Bulk update settings:

```ruby
class UpdateSettingsCommand < BaseCommand
  attr_accessor :settings_params
  
  validates :settings_params, presence: true
  
  def execute
    return false unless valid?
    
    transaction do
      update_settings
      clear_cache
    end
    
    success?
  end
  
  private
  
  def update_settings
    settings_params.each do |key, value|
      setting = Setting.find_or_initialize_by(key: key)
      
      unless update_setting(setting, value)
        add_error(key, setting.errors.full_messages.join(', '))
        raise ActiveRecord::Rollback
      end
    end
  end
  
  def update_setting(setting, value)
    # Handle special cases
    case setting.type
    when 'boolean'
      value = ActiveModel::Type::Boolean.new.cast(value)
    when 'integer'
      value = value.to_i
    when 'decimal'
      value = value.to_d
    end
    
    setting.value = value.to_s
    setting.save
  end
  
  def clear_cache
    Rails.cache.delete('app_config')
    AppConfig.reload!
  end
end
```

## Email Commands

### SendBulkEmailCommand

Send emails to multiple recipients:

```ruby
class SendBulkEmailCommand < BaseCommand
  attr_accessor :template_name, :recipient_ids, :variables
  attr_accessor :schedule_for, :batch_size
  
  validates :template_name, presence: true
  validates :recipient_ids, presence: true
  validate :template_exists
  validate :recipients_exist
  
  def execute
    return false unless valid?
    
    if schedule_for.present?
      schedule_emails
    else
      send_emails
    end
    
    success?
  end
  
  private
  
  def template_exists
    return if template_name.blank?
    
    unless MailTemplate.exists?(name: template_name)
      add_error(:template_name, 'does not exist')
    end
  end
  
  def recipients_exist
    return if recipient_ids.blank?
    
    if User.where(id: recipient_ids).count != recipient_ids.size
      add_error(:recipient_ids, 'contains invalid user IDs')
    end
  end
  
  def schedule_emails
    User.where(id: recipient_ids).find_in_batches(batch_size: batch_size || 100) do |users|
      users.each do |user|
        BulkEmailJob.set(wait_until: schedule_for)
                   .perform_later(template_name, user, variables)
      end
    end
  end
  
  def send_emails
    User.where(id: recipient_ids).find_in_batches(batch_size: batch_size || 100) do |users|
      users.each do |user|
        BulkEmailJob.perform_later(template_name, user, variables)
      end
    end
  end
end
```

## Validation with Dry-Validation

For complex validations, use dry-validation:

```ruby
class CreateOrderCommand < BaseCommand
  include Dry::Validation
  
  Schema = Dry::Validation.Schema do
    required(:customer_email).filled(:str?, format?: URI::MailTo::EMAIL_REGEXP)
    required(:items).filled(:array?) do
      each do
        schema do
          required(:product_id).filled(:int?)
          required(:quantity).filled(:int?, gt?: 0)
          optional(:price).filled(:decimal?, gt?: 0)
        end
      end
    end
    
    optional(:discount_code).maybe(:str?)
    optional(:notes).maybe(:str?)
  end
  
  attr_accessor :params
  attr_reader :order
  
  def execute
    validation = Schema.call(params)
    
    if validation.failure?
      validation.errors.each do |error|
        add_error(error.path.join('.'), error.text)
      end
      return false
    end
    
    transaction do
      create_order(validation.output)
    end
    
    success?
  end
  
  private
  
  def create_order(validated_params)
    @order = Order.create!(
      customer_email: validated_params[:customer_email],
      notes: validated_params[:notes]
    )
    
    create_order_items(validated_params[:items])
    apply_discount(validated_params[:discount_code])
    
    @order.calculate_totals!
  end
end
```

## Testing Commands

### Unit Tests

```ruby
RSpec.describe CreateUserCommand do
  subject(:command) { described_class.new(params) }
  
  let(:valid_params) do
    {
      email: 'test@example.com',
      password: 'password123',
      password_confirmation: 'password123',
      first_name: 'John',
      last_name: 'Doe',
      roles: ['user']
    }
  end
  
  describe '#execute' do
    context 'with valid params' do
      let(:params) { valid_params }
      
      it 'creates a user' do
        expect { command.execute }.to change(User, :count).by(1)
      end
      
      it 'returns true' do
        expect(command.execute).to be true
      end
      
      it 'assigns the user' do
        command.execute
        expect(command.user).to be_a(User)
        expect(command.user.email).to eq('test@example.com')
      end
      
      it 'assigns roles' do
        command.execute
        expect(command.user.has_role?(:user)).to be true
      end
    end
    
    context 'with invalid params' do
      let(:params) { valid_params.merge(email: 'invalid') }
      
      it 'does not create a user' do
        expect { command.execute }.not_to change(User, :count)
      end
      
      it 'returns false' do
        expect(command.execute).to be false
      end
      
      it 'adds errors' do
        command.execute
        expect(command.errors[:email]).to be_present
      end
    end
  end
end
```

### Integration Tests

```ruby
RSpec.describe 'User Creation Flow' do
  it 'creates user through command' do
    command = CreateUserCommand.new(
      email: 'newuser@example.com',
      password: 'secure123',
      password_confirmation: 'secure123',
      send_welcome_email: true
    )
    
    expect {
      expect(command.execute).to be true
    }.to change(User, :count).by(1)
      .and have_enqueued_job(ActionMailer::MailDeliveryJob)
    
    user = command.user
    expect(user.email).to eq('newuser@example.com')
  end
end
```

## Best Practices

### 1. Single Responsibility

Each command should do one thing:

```ruby
# Good
CreateUserCommand
UpdateUserCommand
DeleteUserCommand

# Bad
ManageUserCommand # Too broad
```

### 2. Clear Naming

Use verb-noun pattern:

```ruby
# Good
PublishPostCommand
SendEmailCommand
ImportDataCommand

# Bad
PostPublisher
EmailManager
DataHandler
```

### 3. Dependency Injection

Pass dependencies explicitly:

```ruby
class ProcessOrderCommand < BaseCommand
  def initialize(order:, payment_service: PaymentService.new)
    @order = order
    @payment_service = payment_service
  end
end
```

### 4. Error Handling

Always handle errors gracefully:

```ruby
def execute
  return false unless valid?
  
  transaction do
    perform_operation
  end
  
  success?
rescue StandardError => e
  Rails.logger.error "Command failed: #{e.message}"
  add_error(:base, 'An unexpected error occurred')
  false
end
```

### 5. Return Consistent Results

Commands should always return boolean:

```ruby
# Controller
command = CreateUserCommand.new(params)

if command.execute
  redirect_to users_path, notice: 'Success'
else
  @errors = command.errors
  render :new
end
```

## Next Steps

- Review [Controllers](controllers.md) that use commands
- Understand [Models](models.md) that commands operate on
- Learn about [Helpers](helpers.md) for view logic