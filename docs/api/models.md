# Models Reference

Detailed documentation of Rails Blueprint's ActiveRecord models.

## User Model

The core user model with Devise authentication.

### Schema

```ruby
# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  email                  :string           not null
#  encrypted_password     :string           not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0)
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string
#  last_sign_in_ip        :string
#  confirmation_token     :string
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string
#  failed_attempts        :integer          default(0)
#  unlock_token           :string
#  locked_at              :datetime
#  first_name             :string
#  last_name              :string
#  phone                  :string
#  website                :string
#  bio                    :text
#  github_profile         :string
#  linkedin_profile       :string
#  facebook_profile       :string
#  twitter_profile        :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
```

### Associations

```ruby
class User < ApplicationRecord
  # Rolify
  rolify
  
  # Associations
  has_many :posts, foreign_key: :author_id, dependent: :destroy
  has_many :published_posts, -> { published }, 
           foreign_key: :author_id, 
           class_name: 'Post'
  
  # Devise modules
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :lockable, :trackable
end
```

### Methods

```ruby
# Display name
def full_name
  [first_name, last_name].select(&:present?).join(' ')
end

def display_name
  full_name.presence || email.split('@').first
end

# Status checks
def active?
  confirmed? && !locked_at?
end

def online?
  last_sign_in_at && last_sign_in_at > 15.minutes.ago
end

# Role helpers
def admin?
  has_role?(:admin) || has_role?(:superadmin)
end

def can_edit_content?
  has_any_role?(:admin, :editor)
end
```

### Scopes

```ruby
scope :confirmed, -> { where.not(confirmed_at: nil) }
scope :locked, -> { where.not(locked_at: nil) }
scope :active, -> { confirmed.where(locked_at: nil) }
scope :admins, -> { with_role(:admin) }
scope :recent, -> { order(created_at: :desc) }
```

## Post Model

Blog post model with SEO features.

### Schema

```ruby
# == Schema Information
#
# Table name: posts
#
#  id                 :bigint           not null, primary key
#  title              :string           not null
#  slug               :string           not null
#  content            :text
#  excerpt            :text
#  published          :boolean          default(false)
#  published_at       :datetime
#  featured           :boolean          default(false)
#  featured_image_url :string
#  meta_title         :string
#  meta_description   :text
#  author_id          :bigint           not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
```

### Associations

```ruby
class Post < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged
  
  belongs_to :author, class_name: 'User'
  has_and_belongs_to_many :categories
  has_many :comments, dependent: :destroy
  
  validates :title, presence: true
  validates :content, presence: true
  validates :author, presence: true
end
```

### Scopes

```ruby
scope :published, -> { 
  where(published: true)
    .where('published_at IS NULL OR published_at <= ?', Time.current) 
}
scope :draft, -> { where(published: false) }
scope :featured, -> { where(featured: true) }
scope :recent, -> { order(published_at: :desc) }
scope :by_author, ->(author) { where(author: author) }
scope :search, ->(query) { 
  where("title ILIKE :q OR content ILIKE :q", q: "%#{query}%") 
}
```

### Methods

```ruby
# Publishing
def publish!
  update!(published: true, published_at: Time.current)
end

def unpublish!
  update!(published: false)
end

def scheduled?
  published? && published_at && published_at > Time.current
end

# SEO
def meta_title_with_default
  meta_title.presence || title
end

def meta_description_with_default
  meta_description.presence || excerpt.presence || content.truncate(160)
end

# URL helpers
def full_url
  Rails.application.routes.url_helpers.post_url(self)
end
```

## Page Model

Static page model for CMS functionality.

### Schema

```ruby
# == Schema Information
#
# Table name: pages
#
#  id               :bigint           not null, primary key
#  title            :string           not null
#  slug             :string           not null
#  content          :text
#  excerpt          :text
#  template         :string           default("default")
#  published        :boolean          default(true)
#  show_in_menu     :boolean          default(false)
#  menu_order       :integer          default(0)
#  meta_title       :string
#  meta_description :text
#  custom_css       :text
#  custom_js        :text
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
```

### Methods

```ruby
class Page < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged
  
  validates :title, presence: true
  validates :content, presence: true
  
  scope :published, -> { where(published: true) }
  scope :in_menu, -> { where(show_in_menu: true).order(:menu_order) }
  
  # Template helpers
  def template_path
    "pages/templates/#{template}"
  end
  
  def home_page?
    slug == 'home'
  end
end
```

## Setting Model

Database-backed configuration settings.

### Schema

```ruby
# == Schema Information
#
# Table name: settings
#
#  id          :bigint           not null, primary key
#  key         :string           not null
#  value       :text
#  type        :string           default("string")
#  section     :string
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
```

### Methods

```ruby
class Setting < ApplicationRecord
  TYPES = %w[string integer boolean decimal section].freeze
  
  validates :key, presence: true, uniqueness: true
  validates :type, inclusion: { in: TYPES }
  
  scope :by_section, -> { order(:section, :key) }
  
  # Type casting
  def typed_value
    case type
    when 'integer'
      value.to_i
    when 'boolean'
      ActiveModel::Type::Boolean.new.cast(value)
    when 'decimal'
      value.to_d
    else
      value
    end
  end
  
  # Section helpers
  def section_name
    section.presence || 'uncategorized'
  end
end
```

## MailTemplate Model

Email template storage.

### Schema

```ruby
# == Schema Information
#
# Table name: mail_templates
#
#  id          :bigint           not null, primary key
#  name        :string           not null
#  subject     :string           not null
#  body        :text             not null
#  description :text
#  variables   :text
#  locale      :string           default("en")
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
```

### Methods

```ruby
class MailTemplate < ApplicationRecord
  validates :name, presence: true, uniqueness: { scope: :locale }
  validates :subject, presence: true
  validates :body, presence: true
  
  scope :by_locale, ->(locale) { where(locale: locale || I18n.default_locale) }
  
  # Variable extraction
  def extract_variables
    (subject + body).scan(/\{\{(\w+)\}\}/).flatten.uniq
  end
  
  # Rendering
  def render(variables = {})
    {
      subject: substitute_variables(subject, variables),
      body: substitute_variables(body, variables)
    }
  end
  
  private
  
  def substitute_variables(text, variables)
    text.gsub(/\{\{(\w+)\}\}/) do
      variables[$1.to_sym] || "{{#{$1}}}"
    end
  end
end
```

## Role Model

Rolify role definitions.

### Schema

```ruby
# == Schema Information
#
# Table name: roles
#
#  id            :bigint           not null, primary key
#  name          :string
#  resource_type :string
#  resource_id   :bigint
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
```

### Associations

```ruby
class Role < ApplicationRecord
  has_and_belongs_to_many :users, join_table: :users_roles
  belongs_to :resource, polymorphic: true, optional: true
  
  validates :resource_type,
            inclusion: { in: Rolify.resource_types },
            allow_nil: true
  
  scopify
end
```

## Category Model

Blog post categorization.

### Schema

```ruby
# == Schema Information
#
# Table name: categories
#
#  id          :bigint           not null, primary key
#  name        :string           not null
#  slug        :string           not null
#  description :text
#  color       :string           default("#6c757d")
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
```

### Methods

```ruby
class Category < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged
  
  has_and_belongs_to_many :posts
  
  validates :name, presence: true, uniqueness: true
  validates :color, format: { with: /\A#[0-9A-F]{6}\z/i }
  
  scope :with_posts, -> { joins(:posts).distinct }
  scope :ordered, -> { order(:name) }
  
  def post_count
    posts.published.count
  end
end
```

## Common Patterns

### Callbacks

```ruby
# Automatic timestamps
before_create :set_published_at

private

def set_published_at
  self.published_at ||= Time.current if published?
end
```

### Validations

```ruby
# Conditional validation
validates :published_at, presence: true, if: :published?

# Custom validation
validate :slug_not_reserved

private

def slug_not_reserved
  reserved_words = %w[admin api assets system]
  errors.add(:slug, "is reserved") if reserved_words.include?(slug)
end
```

### Concerns

```ruby
# app/models/concerns/searchable.rb
module Searchable
  extend ActiveSupport::Concern
  
  included do
    scope :search, ->(query) {
      where("#{table_name}.content ILIKE ?", "%#{query}%")
    }
  end
end
```

## Database Indexes

Important indexes for performance:

```ruby
# Users
add_index :users, :email, unique: true
add_index :users, :reset_password_token, unique: true
add_index :users, :confirmation_token, unique: true
add_index :users, :unlock_token, unique: true

# Posts
add_index :posts, :slug, unique: true
add_index :posts, :author_id
add_index :posts, [:published, :published_at]

# Settings
add_index :settings, :key, unique: true
add_index :settings, :section

# Roles
add_index :roles, [:name, :resource_type, :resource_id]
add_index :roles, [:resource_type, :resource_id]
```

## Next Steps

- Review [Controllers](controllers.md) that use these models
- Understand [Commands](commands.md) for business logic
- Learn about [Helpers](helpers.md) for view logic