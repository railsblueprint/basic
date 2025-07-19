# Blog System

Rails Blueprint includes a full-featured blog system with posts, categories, SEO-friendly URLs, and a rich text editor.

## Features

- **Post Management** - Create, edit, publish posts
- **Rich Text Editor** - WYSIWYG content editing
- **SEO-Friendly URLs** - Automatic slug generation
- **Categories & Tags** - Organize content
- **Draft/Publish Workflow** - Control visibility
- **Featured Images** - Post thumbnails
- **Author Attribution** - Multi-author support
- **Comments** - Optional commenting system
- **Search** - Full-text post search
- **RSS Feed** - Automatic feed generation

## Models

### Post Model

```ruby
class Post < ApplicationRecord
  # Fields:
  # - title: String
  # - slug: String (URL-friendly)
  # - content: Text (HTML)
  # - excerpt: Text
  # - published: Boolean
  # - published_at: DateTime
  # - featured: Boolean
  # - featured_image_url: String
  # - meta_title: String (SEO)
  # - meta_description: Text (SEO)
  # - author_id: Integer
  
  extend FriendlyId
  friendly_id :title, use: :slugged
  
  belongs_to :author, class_name: 'User'
  has_and_belongs_to_many :categories
  has_many :comments, dependent: :destroy
  
  scope :published, -> { where(published: true).where('published_at <= ?', Time.current) }
  scope :draft, -> { where(published: false) }
  scope :featured, -> { where(featured: true) }
  scope :recent, -> { order(published_at: :desc) }
  
  validates :title, presence: true
  validates :content, presence: true
  validates :author, presence: true
end
```

### Category Model

```ruby
class Category < ApplicationRecord
  # Fields:
  # - name: String
  # - slug: String
  # - description: Text
  # - color: String (hex color)
  
  extend FriendlyId
  friendly_id :name, use: :slugged
  
  has_and_belongs_to_many :posts
  
  validates :name, presence: true, uniqueness: true
end
```

## Creating Posts

### Via Admin Panel

1. Navigate to `/admin/posts`
2. Click "New Post"
3. Fill in post details:
   - Title (required)
   - Content (required)
   - Excerpt (optional)
   - Categories
   - SEO metadata
4. Save as draft or publish

### Via Code

```ruby
post = Post.create!(
  title: 'Welcome to Rails Blueprint',
  content: '<p>This is your first blog post...</p>',
  excerpt: 'Get started with Rails Blueprint',
  author: User.admin.first,
  published: true,
  published_at: Time.current,
  categories: [Category.find_by(name: 'Announcements')]
)
```

## Rich Text Editor

Rails Blueprint uses a WYSIWYG editor for content creation:

### Features
- Bold, italic, underline formatting
- Headings (H1-H6)
- Lists (ordered/unordered)
- Links with target options
- Image insertion
- Code blocks
- Tables
- HTML source view

### Configuration

```javascript
// app/javascript/controllers/editor_controller.js
export default class extends Controller {
  connect() {
    this.editor = new Editor({
      element: this.element,
      toolbar: [
        'bold', 'italic', 'underline', 'strikethrough',
        '|', 'heading1', 'heading2', 'heading3',
        '|', 'unorderedList', 'orderedList',
        '|', 'link', 'image', 'code',
        '|', 'undo', 'redo'
      ]
    });
  }
}
```

## SEO Features

### Automatic Slug Generation

Posts automatically generate SEO-friendly URLs:

```ruby
post = Post.create(title: "Hello World! This is my first post")
post.slug # => "hello-world-this-is-my-first-post"

# Access via: /blog/hello-world-this-is-my-first-post
```

### Meta Tags

Each post can have custom SEO metadata:

```erb
# In layout
<title><%= @post.meta_title.presence || @post.title %></title>
<meta name="description" content="<%= @post.meta_description.presence || @post.excerpt %>">

# Open Graph tags
<meta property="og:title" content="<%= @post.title %>">
<meta property="og:description" content="<%= @post.excerpt %>">
<meta property="og:image" content="<%= @post.featured_image_url %>">
```

### Structured Data

Posts include JSON-LD structured data:

```erb
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "BlogPosting",
  "headline": "<%= @post.title %>",
  "datePublished": "<%= @post.published_at.iso8601 %>",
  "author": {
    "@type": "Person",
    "name": "<%= @post.author.full_name %>"
  },
  "description": "<%= @post.excerpt %>"
}
</script>
```

## Categories & Organization

### Managing Categories

```ruby
# Create category
category = Category.create!(
  name: 'Technology',
  description: 'Posts about technology and programming',
  color: '#0066cc'
)

# Assign to posts
post.categories << category

# Query by category
Post.joins(:categories).where(categories: { slug: 'technology' })
```

### Category Pages

Each category has its own page:
- URL: `/blog/category/technology`
- Lists all posts in category
- Pagination support
- Category description

## Publishing Workflow

### Draft Posts

```ruby
# Create draft
post = Post.create!(
  title: 'Upcoming Feature',
  content: 'Details about new feature...',
  published: false
)

# Preview draft (admin only)
# URL: /blog/preview/post-slug

# Publish draft
post.update!(
  published: true,
  published_at: Time.current
)
```

### Scheduled Publishing

```ruby
# Schedule for future
post.update!(
  published: true,
  published_at: 2.days.from_now
)

# Post becomes visible automatically when published_at is reached
```

### Featured Posts

```ruby
# Mark as featured
post.update!(featured: true)

# Query featured posts
Post.featured.published.limit(3)
```

## Views and Templates

### Post Index

```erb
# app/views/posts/index.html.erb
<div class="blog-posts">
  <% @posts.each do |post| %>
    <article class="post-summary">
      <h2><%= link_to post.title, post %></h2>
      <div class="post-meta">
        By <%= post.author.full_name %> on 
        <%= post.published_at.strftime('%B %d, %Y') %>
      </div>
      <div class="post-excerpt">
        <%= post.excerpt %>
      </div>
      <%= link_to "Read more", post, class: "btn btn-primary" %>
    </article>
  <% end %>
  
  <%= paginate @posts %>
</div>
```

### Post Show

```erb
# app/views/posts/show.html.erb
<article class="blog-post">
  <header>
    <h1><%= @post.title %></h1>
    <div class="post-meta">
      By <%= @post.author.full_name %> on 
      <%= @post.published_at.strftime('%B %d, %Y') %>
      <% if @post.categories.any? %>
        in <%= @post.categories.map { |c| 
          link_to c.name, category_path(c) 
        }.join(', ').html_safe %>
      <% end %>
    </div>
  </header>
  
  <% if @post.featured_image_url.present? %>
    <%= image_tag @post.featured_image_url, class: "featured-image" %>
  <% end %>
  
  <div class="post-content">
    <%= @post.content.html_safe %>
  </div>
  
  <% if policy(@post).edit? %>
    <div class="admin-actions">
      <%= link_to "Edit", edit_admin_post_path(@post), class: "btn btn-warning" %>
    </div>
  <% end %>
</article>
```

## Search Functionality

### Basic Search

```ruby
class Post < ApplicationRecord
  scope :search, ->(query) {
    where("title ILIKE :q OR content ILIKE :q OR excerpt ILIKE :q", 
          q: "%#{query}%")
  }
end

# In controller
@posts = Post.published.search(params[:q]).page(params[:page])
```

### Advanced Search

```ruby
class PostSearch
  include ActiveModel::Model
  
  attr_accessor :query, :category_id, :author_id, :from_date, :to_date
  
  def results
    scope = Post.published
    scope = scope.search(query) if query.present?
    scope = scope.joins(:categories).where(categories: { id: category_id }) if category_id.present?
    scope = scope.where(author_id: author_id) if author_id.present?
    scope = scope.where('published_at >= ?', from_date) if from_date.present?
    scope = scope.where('published_at <= ?', to_date) if to_date.present?
    scope
  end
end
```

## RSS Feed

### Feed Generation

```ruby
# app/views/posts/feed.rss.builder
xml.instruct! :xml, version: "1.0"
xml.rss version: "2.0" do
  xml.channel do
    xml.title AppConfig.app.name
    xml.description "Latest posts from #{AppConfig.app.name}"
    xml.link posts_url
    
    @posts.each do |post|
      xml.item do
        xml.title post.title
        xml.description post.excerpt
        xml.pubDate post.published_at.to_s(:rfc822)
        xml.link post_url(post)
        xml.guid post_url(post)
      end
    end
  end
end
```

### Feed Discovery

```erb
# In layout
<%= auto_discovery_link_tag(:rss, posts_feed_url, title: "RSS Feed") %>
```

## Comments (Optional)

### Comment Model

```ruby
class Comment < ApplicationRecord
  belongs_to :post
  belongs_to :user, optional: true
  
  validates :author_name, presence: true, unless: :user
  validates :author_email, presence: true, unless: :user
  validates :content, presence: true
  
  scope :approved, -> { where(approved: true) }
  scope :pending, -> { where(approved: false) }
end
```

### Comment Moderation

```ruby
# Auto-approve for logged-in users
before_save :auto_approve_for_users

def auto_approve_for_users
  self.approved = true if user.present?
end
```

## Performance Optimization

### Caching

```erb
# Cache post content
<% cache @post do %>
  <article class="blog-post">
    <%= render @post %>
  </article>
<% end %>

# Cache post list
<% cache ['posts-index', @posts.maximum(:updated_at)] do %>
  <%= render @posts %>
<% end %>
```

### Eager Loading

```ruby
# Prevent N+1 queries
@posts = Post.published
             .includes(:author, :categories)
             .page(params[:page])
```

## Admin Features

### Bulk Operations

```ruby
# Publish multiple drafts
Post.where(id: params[:post_ids]).update_all(
  published: true,
  published_at: Time.current
)

# Bulk categorization
posts = Post.where(id: params[:post_ids])
category = Category.find(params[:category_id])
posts.each { |post| post.categories << category }
```

### Content Analytics

```ruby
class PostAnalytics
  def self.summary
    {
      total_posts: Post.count,
      published_posts: Post.published.count,
      draft_posts: Post.draft.count,
      posts_this_month: Post.where('created_at > ?', 1.month.ago).count,
      top_authors: User.joins(:posts)
                      .group('users.id')
                      .order('COUNT(posts.id) DESC')
                      .limit(5)
    }
  end
end
```

## Testing

### Model Tests

```ruby
RSpec.describe Post do
  describe "validations" do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:content) }
    it { should belong_to(:author) }
  end
  
  describe "slug generation" do
    it "generates slug from title" do
      post = create(:post, title: "Hello World!")
      expect(post.slug).to eq("hello-world")
    end
  end
  
  describe "scopes" do
    let!(:published_post) { create(:post, :published) }
    let!(:draft_post) { create(:post, :draft) }
    
    it "returns only published posts" do
      expect(Post.published).to include(published_post)
      expect(Post.published).not_to include(draft_post)
    end
  end
end
```

## Next Steps

- Configure [Static Pages](static-pages.md) for non-blog content
- Set up [Email Templates](email-templates.md) for notifications
- Learn about [Background Jobs](background-jobs.md) for async tasks