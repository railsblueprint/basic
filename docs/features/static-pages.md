# Static Pages

Rails Blueprint includes a flexible CMS for creating and managing static pages like About, Contact, Terms of Service, and custom landing pages.

## Features

- **Page Management** - Create unlimited static pages
- **SEO-Friendly URLs** - Custom slugs for each page
- **Rich Content Editor** - WYSIWYG editing
- **Page Templates** - Multiple layout options
- **Navigation Integration** - Auto-add to menus
- **Access Control** - Public/private pages
- **Version History** - Track page changes
- **Custom Fields** - Extend with metadata

## Page Model

```ruby
class Page < ApplicationRecord
  # Fields:
  # - title: String
  # - slug: String (URL)
  # - content: Text (HTML)
  # - excerpt: Text
  # - template: String
  # - published: Boolean
  # - show_in_menu: Boolean
  # - menu_order: Integer
  # - meta_title: String
  # - meta_description: Text
  # - custom_css: Text
  # - custom_js: Text
  
  extend FriendlyId
  friendly_id :title, use: :slugged
  
  validates :title, presence: true
  validates :content, presence: true
  validates :slug, uniqueness: true
  
  scope :published, -> { where(published: true) }
  scope :in_menu, -> { where(show_in_menu: true).order(:menu_order) }
end
```

## Creating Pages

### Via Admin Panel

1. Navigate to `/admin/pages`
2. Click "New Page"
3. Fill in page details:
   - Title (required)
   - Slug (auto-generated or custom)
   - Content (rich text editor)
   - Template selection
   - SEO metadata
4. Configure visibility and menu settings

### Via Rails Console

```ruby
# Create about page
Page.create!(
  title: 'About Us',
  slug: 'about',
  content: '<h2>Our Story</h2><p>Rails Blueprint was created...</p>',
  published: true,
  show_in_menu: true,
  menu_order: 1,
  meta_description: 'Learn about Rails Blueprint and our mission'
)

# Create contact page
Page.create!(
  title: 'Contact',
  slug: 'contact',
  content: render_contact_form_html,
  template: 'contact',
  published: true,
  show_in_menu: true,
  menu_order: 2
)
```

## Templates

### Available Templates

Rails Blueprint includes several page templates:

1. **Default** - Standard page layout
2. **Landing** - Hero section with CTA
3. **Contact** - Includes contact form
4. **Full Width** - No sidebar
5. **Sidebar** - With sidebar content

### Template Files

```
app/views/pages/templates/
├── _default.html.erb
├── _landing.html.erb
├── _contact.html.erb
├── _full_width.html.erb
└── _sidebar.html.erb
```

### Creating Custom Templates

```erb
# app/views/pages/templates/_custom.html.erb
<div class="custom-template">
  <div class="hero-section">
    <h1><%= @page.title %></h1>
    <%= @page.excerpt.html_safe if @page.excerpt? %>
  </div>
  
  <div class="content-section">
    <%= @page.content.html_safe %>
  </div>
  
  <div class="cta-section">
    <%= render 'shared/call_to_action' %>
  </div>
</div>
```

Register the template:

```ruby
# config/initializers/page_templates.rb
Rails.application.config.page_templates = {
  default: 'Default Layout',
  landing: 'Landing Page',
  contact: 'Contact Page',
  full_width: 'Full Width',
  sidebar: 'With Sidebar',
  custom: 'Custom Template'  # Add your template
}
```

## Navigation Integration

### Automatic Menu

Pages marked with `show_in_menu` appear in navigation:

```erb
# app/views/shared/_navigation.html.erb
<nav class="main-navigation">
  <ul>
    <li><%= link_to 'Home', root_path %></li>
    <% Page.in_menu.each do |page| %>
      <li><%= link_to page.title, page_path(page) %></li>
    <% end %>
    <li><%= link_to 'Blog', posts_path %></li>
  </ul>
</nav>
```

### Menu Ordering

```ruby
# Set menu order
page.update!(menu_order: 1)  # First in menu
page.update!(menu_order: 10) # Later in menu

# Reorder pages
Page.in_menu.each_with_index do |page, index|
  page.update!(menu_order: (index + 1) * 10)
end
```

## Dynamic Content

### Embedding Forms

```erb
# In page content or template
<div class="contact-form">
  <%= render 'contact/form' %>
</div>

# Or use shortcodes
[contact_form]

# Process in controller
def show
  @page = Page.friendly.find(params[:id])
  @page.content = process_shortcodes(@page.content)
end

private

def process_shortcodes(content)
  content.gsub('[contact_form]', render_to_string('contact/_form'))
end
```

### Dynamic Sections

```ruby
# Create reusable content sections
class ContentSection < ApplicationRecord
  # name, content, identifier
end

# Use in pages
[section:testimonials]
[section:pricing_table]

# Process sections
def process_sections(content)
  content.gsub(/\[section:(\w+)\]/) do
    section = ContentSection.find_by(identifier: $1)
    section&.content || ''
  end
end
```

## SEO Features

### Meta Tags

```erb
# In layout
<title><%= @page.meta_title.presence || @page.title %> - <%= AppConfig.app.name %></title>
<meta name="description" content="<%= @page.meta_description %>">

# Canonical URL
<link rel="canonical" href="<%= page_url(@page) %>">
```

### Structured Data

```erb
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "WebPage",
  "name": "<%= @page.title %>",
  "description": "<%= @page.meta_description %>",
  "url": "<%= page_url(@page) %>"
}
</script>
```

### Sitemap Integration

```ruby
# In sitemap generator
Page.published.find_each do |page|
  add page_path(page), 
      lastmod: page.updated_at,
      priority: page.slug == 'home' ? 1.0 : 0.8
end
```

## Custom CSS/JS

Pages can include custom styling and scripts:

```erb
# In page form
<%= form.text_area :custom_css, rows: 10, 
    placeholder: "/* Page-specific CSS */" %>
<%= form.text_area :custom_js, rows: 10, 
    placeholder: "// Page-specific JavaScript" %>

# In layout
<% if @page&.custom_css.present? %>
  <style type="text/css">
    <%= @page.custom_css.html_safe %>
  </style>
<% end %>

<% if @page&.custom_js.present? %>
  <script>
    <%= @page.custom_js.html_safe %>
  </script>
<% end %>
```

## Common Pages

### Home Page

```ruby
Page.create!(
  title: 'Welcome to Rails Blueprint',
  slug: 'home',
  template: 'landing',
  content: render_home_content,
  published: true,
  show_in_menu: false  # Usually not in menu
)

# Route configuration
root to: 'pages#show', id: 'home'
```

### Terms of Service

```ruby
Page.create!(
  title: 'Terms of Service',
  slug: 'terms',
  content: legal_terms_content,
  published: true,
  show_in_menu: false  # Link in footer
)
```

### Privacy Policy

```ruby
Page.create!(
  title: 'Privacy Policy',
  slug: 'privacy',
  content: privacy_policy_content,
  published: true,
  show_in_menu: false
)
```

## Access Control

### Private Pages

```ruby
class Page < ApplicationRecord
  scope :public_pages, -> { where(published: true, requires_login: false) }
  scope :member_pages, -> { where(published: true, requires_login: true) }
  
  def accessible_by?(user)
    return true if !requires_login
    return false if user.nil?
    
    # Check additional permissions
    return true if user.has_role?(:admin)
    return true if allowed_roles.empty?
    
    user.has_any_role?(*allowed_roles)
  end
end
```

### Controller Authorization

```ruby
class PagesController < ApplicationController
  before_action :check_access
  
  private
  
  def check_access
    @page = Page.friendly.find(params[:id])
    
    unless @page.accessible_by?(current_user)
      redirect_to login_path, alert: 'Please login to view this page'
    end
  end
end
```

## Version History

### Track Changes

```ruby
# Using paper_trail or similar
class Page < ApplicationRecord
  has_paper_trail
end

# View history
@page.versions.each do |version|
  puts "#{version.created_at}: #{version.event} by #{version.whodunnit}"
end

# Restore previous version
@page.revert_to(2.days.ago)
```

## Caching

### Page Caching

```erb
<% cache @page do %>
  <article class="static-page">
    <h1><%= @page.title %></h1>
    <div class="page-content">
      <%= @page.content.html_safe %>
    </div>
  </article>
<% end %>
```

### Fragment Caching

```erb
<% cache ['page-menu', Page.in_menu.maximum(:updated_at)] do %>
  <%= render 'shared/page_menu' %>
<% end %>
```

## Testing

### Model Tests

```ruby
RSpec.describe Page do
  describe "validations" do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:content) }
    it { should validate_uniqueness_of(:slug) }
  end
  
  describe "slug generation" do
    it "generates slug from title" do
      page = Page.create!(title: "About Us", content: "Content")
      expect(page.slug).to eq("about-us")
    end
  end
  
  describe "menu scope" do
    let!(:menu_page) { create(:page, show_in_menu: true, menu_order: 1) }
    let!(:hidden_page) { create(:page, show_in_menu: false) }
    
    it "returns only menu pages in order" do
      expect(Page.in_menu).to eq([menu_page])
    end
  end
end
```

### Feature Tests

```ruby
RSpec.feature "Static Pages" do
  scenario "Visitor views about page" do
    page = create(:page, 
      title: "About Us", 
      slug: "about",
      content: "<p>We are Rails Blueprint</p>",
      published: true
    )
    
    visit '/about'
    
    expect(page).to have_content("About Us")
    expect(page).to have_content("We are Rails Blueprint")
  end
  
  scenario "Admin creates new page" do
    admin = create(:user, :admin)
    login_as(admin)
    
    visit admin_pages_path
    click_link "New Page"
    
    fill_in "Title", with: "New Feature"
    fill_in_rich_text "Content", with: "Feature description"
    check "Show in menu"
    
    click_button "Create Page"
    
    expect(page).to have_content("Page created successfully")
    expect(Page.last.title).to eq("New Feature")
  end
end
```

## Best Practices

### 1. Consistent URLs

Use meaningful, SEO-friendly slugs:
```
Good: /about, /contact, /pricing
Bad: /page1, /about-us-page, /node/123
```

### 2. Template Selection

Choose appropriate templates:
- Landing pages for marketing
- Contact template for forms
- Default for general content

### 3. Menu Organization

Keep navigation simple:
```ruby
# Good menu structure
Home | About | Services | Blog | Contact

# Too many items
Home | About | Team | History | Mission | Services | Products | Blog | News | Contact
```

### 4. Content Structure

Use semantic HTML:
```html
<h1>Page Title</h1>
<h2>Section Heading</h2>
<p>Paragraph content...</p>
<ul>
  <li>List items</li>
</ul>
```

## Next Steps

- Configure [Email Templates](email-templates.md) for contact forms
- Set up [Background Jobs](background-jobs.md) for processing
- Explore the [Design System](design-system.md) for styling