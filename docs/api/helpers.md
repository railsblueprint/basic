# Helpers Reference

Rails Blueprint includes various helper modules to simplify view logic and provide reusable functionality.

## Application Helper

Core helper methods available throughout the application:

```ruby
module ApplicationHelper
  # Page title helper
  def page_title(title = nil)
    base_title = AppConfig.app.name || 'Rails Blueprint'
    
    if title.present?
      "#{title} | #{base_title}"
    else
      base_title
    end
  end
  
  # Meta tags
  def meta_description(description = nil)
    description || AppConfig.seo.default_description
  end
  
  # Flash message styling
  def flash_class(level)
    case level.to_sym
    when :notice, :success
      'alert-success'
    when :error, :alert
      'alert-danger'
    when :warning
      'alert-warning'
    else
      'alert-info'
    end
  end
  
  # Active navigation
  def nav_link_class(path)
    current_page?(path) ? 'nav-link active' : 'nav-link'
  end
  
  # User display
  def user_display_name(user)
    return 'Guest' unless user
    
    user.full_name.presence || user.email.split('@').first
  end
  
  # Date formatting
  def formatted_date(date, format = :long)
    return '' unless date
    
    l(date.to_date, format: format)
  end
  
  def time_ago(time)
    return '' unless time
    
    time_ago_in_words(time) + ' ago'
  end
  
  # Text helpers
  def truncate_html(text, length: 150)
    return '' unless text
    
    strip_tags(text).truncate(length)
  end
  
  def markdown(text)
    return '' unless text
    
    renderer = Redcarpet::Render::HTML.new(
      filter_html: true,
      no_images: false,
      no_links: false,
      safe_links_only: true,
      hard_wrap: true
    )
    
    markdown = Redcarpet::Markdown.new(renderer, 
      autolink: true,
      tables: true,
      fenced_code_blocks: true
    )
    
    markdown.render(text).html_safe
  end
end
```

## Admin Helper

Helper methods for admin interface:

```ruby
module AdminHelper
  # Admin breadcrumbs
  def admin_breadcrumb(name, path = nil)
    content_for :breadcrumbs do
      content_tag :li, class: 'breadcrumb-item' do
        path ? link_to(name, path) : name
      end
    end
  end
  
  # Status badges
  def status_badge(status)
    css_class = case status.to_s
    when 'active', 'published', 'confirmed'
      'badge bg-success'
    when 'inactive', 'draft', 'pending'
      'badge bg-warning'
    when 'deleted', 'failed', 'locked'
      'badge bg-danger'
    else
      'badge bg-secondary'
    end
    
    content_tag :span, status.to_s.humanize, class: css_class
  end
  
  # Boolean display
  def boolean_icon(value)
    if value
      content_tag :i, '', class: 'bi bi-check-circle text-success'
    else
      content_tag :i, '', class: 'bi bi-x-circle text-danger'
    end
  end
  
  # Table sorting
  def sortable(column, title = nil)
    title ||= column.titleize
    css_class = column == sort_column ? "current #{sort_direction}" : nil
    direction = column == sort_column && sort_direction == 'asc' ? 'desc' : 'asc'
    
    link_to title, { sort: column, direction: direction }, class: css_class
  end
  
  # Bulk actions
  def bulk_actions_dropdown
    content_tag :div, class: 'dropdown' do
      button_tag class: 'btn btn-sm btn-outline-secondary dropdown-toggle',
                 data: { bs_toggle: 'dropdown' } do
        'Bulk Actions'
      end +
      content_tag(:ul, class: 'dropdown-menu') do
        yield
      end
    end
  end
  
  # Admin stats
  def stat_card(title, value, icon: 'bi-graph-up', color: 'primary')
    content_tag :div, class: 'col-md-3' do
      content_tag :div, class: "card text-white bg-#{color}" do
        content_tag :div, class: 'card-body' do
          content_tag(:h5, title, class: 'card-title') +
          content_tag(:p, class: 'card-text d-flex align-items-center justify-content-between') do
            content_tag(:span, value, class: 'fs-2 fw-bold') +
            content_tag(:i, '', class: "bi #{icon} fs-1 opacity-50")
          end
        end
      end
    end
  end
end
```

## Form Helper

Enhanced form builders and helpers:

```ruby
module FormHelper
  # Bootstrap form builder
  class BootstrapFormBuilder < ActionView::Helpers::FormBuilder
    def text_field(method, options = {})
      options[:class] = "form-control #{options[:class]}"
      super(method, options)
    end
    
    def email_field(method, options = {})
      options[:class] = "form-control #{options[:class]}"
      super(method, options)
    end
    
    def password_field(method, options = {})
      options[:class] = "form-control #{options[:class]}"
      super(method, options)
    end
    
    def text_area(method, options = {})
      options[:class] = "form-control #{options[:class]}"
      options[:rows] ||= 4
      super(method, options)
    end
    
    def select(method, choices = nil, options = {}, html_options = {})
      html_options[:class] = "form-select #{html_options[:class]}"
      super(method, choices, options, html_options)
    end
    
    def check_box(method, options = {}, checked_value = "1", unchecked_value = "0")
      options[:class] = "form-check-input #{options[:class]}"
      super(method, options, checked_value, unchecked_value)
    end
    
    def submit(value = nil, options = {})
      options[:class] = "btn btn-primary #{options[:class]}"
      super(value, options)
    end
    
    # Custom helpers
    def field_with_error(method, &block)
      content = capture(&block)
      error_message = object.errors[method].first
      
      @template.content_tag :div, class: 'mb-3' do
        content +
        if error_message
          @template.content_tag :div, error_message, class: 'invalid-feedback d-block'
        end
      end
    end
    
    def rich_text_area(method, options = {})
      options[:class] = "form-control rich-text-editor #{options[:class]}"
      options[:data] ||= {}
      options[:data][:controller] = 'editor'
      
      text_area(method, options)
    end
  end
  
  # Use bootstrap form builder by default
  def bootstrap_form_for(object, options = {}, &block)
    options[:builder] = BootstrapFormBuilder
    form_for(object, options, &block)
  end
  
  def bootstrap_form_with(**options, &block)
    options[:builder] = BootstrapFormBuilder
    form_with(**options, &block)
  end
  
  # Error summary
  def error_summary(object)
    return unless object.errors.any?
    
    content_tag :div, class: 'alert alert-danger' do
      content_tag(:h6, 'Please fix the following errors:') +
      content_tag(:ul, class: 'mb-0') do
        object.errors.full_messages.map do |message|
          content_tag(:li, message)
        end.join.html_safe
      end
    end
  end
  
  # Required field marker
  def required_field_marker
    content_tag :span, '*', class: 'text-danger', title: 'Required field'
  end
end
```

## Navigation Helper

Navigation and menu helpers:

```ruby
module NavigationHelper
  # Main navigation
  def main_nav_items
    items = []
    
    items << { name: 'Home', path: root_path }
    items << { name: 'Blog', path: posts_path }
    
    # Add CMS pages
    Page.in_menu.each do |page|
      items << { name: page.title, path: page_path(page) }
    end
    
    if user_signed_in?
      items << { name: 'Dashboard', path: dashboard_path }
    end
    
    items
  end
  
  # Admin sidebar navigation
  def admin_nav_items
    [
      { 
        name: 'Dashboard', 
        path: admin_root_path, 
        icon: 'bi-speedometer2' 
      },
      {
        name: 'Users',
        path: admin_users_path,
        icon: 'bi-people',
        active: controller_name == 'users',
        badge: User.count
      },
      {
        name: 'Content',
        icon: 'bi-file-text',
        active: %w[posts pages categories].include?(controller_name),
        items: [
          { name: 'Posts', path: admin_posts_path },
          { name: 'Pages', path: admin_pages_path },
          { name: 'Categories', path: admin_categories_path }
        ]
      },
      {
        name: 'Settings',
        path: admin_settings_path,
        icon: 'bi-gear',
        can: -> { policy(:admin).settings? }
      }
    ]
  end
  
  # Render navigation
  def render_nav_item(item)
    return unless can_view_nav_item?(item)
    
    classes = ['nav-link']
    classes << 'active' if item[:active] || current_page?(item[:path])
    
    if item[:items]
      render_dropdown_nav(item)
    else
      content_tag :li, class: 'nav-item' do
        link_to item[:path], class: classes.join(' ') do
          nav_item_content(item)
        end
      end
    end
  end
  
  private
  
  def can_view_nav_item?(item)
    return true unless item[:can]
    
    instance_exec(&item[:can])
  end
  
  def nav_item_content(item)
    content = ''
    content += content_tag(:i, '', class: "#{item[:icon]} me-2") if item[:icon]
    content += item[:name]
    
    if item[:badge]
      content += ' '
      content += content_tag(:span, item[:badge], class: 'badge bg-primary')
    end
    
    content.html_safe
  end
  
  def render_dropdown_nav(item)
    content_tag :li, class: 'nav-item dropdown' do
      link_to '#', class: 'nav-link dropdown-toggle',
              data: { bs_toggle: 'dropdown' } do
        nav_item_content(item)
      end +
      content_tag(:ul, class: 'dropdown-menu') do
        item[:items].map do |subitem|
          content_tag :li do
            link_to subitem[:name], subitem[:path], class: 'dropdown-item'
          end
        end.join.html_safe
      end
    end
  end
end
```

## SEO Helper

SEO and meta tag helpers:

```ruby
module SeoHelper
  # Meta tags
  def meta_tags(resource = nil)
    tags = []
    
    # Title
    title = resource&.try(:meta_title) || resource&.try(:title)
    tags << tag(:meta, name: 'title', content: page_title(title))
    
    # Description
    description = resource&.try(:meta_description) || resource&.try(:excerpt)
    tags << tag(:meta, name: 'description', content: meta_description(description))
    
    # Open Graph
    tags += open_graph_tags(resource)
    
    # Twitter Card
    tags += twitter_card_tags(resource)
    
    # Canonical URL
    if resource&.respond_to?(:slug)
      tags << tag(:link, rel: 'canonical', href: url_for(resource))
    end
    
    safe_join(tags)
  end
  
  def open_graph_tags(resource = nil)
    tags = []
    
    tags << tag(:meta, property: 'og:site_name', content: AppConfig.app.name)
    tags << tag(:meta, property: 'og:type', content: og_type(resource))
    
    if resource
      tags << tag(:meta, property: 'og:title', content: resource.try(:title))
      tags << tag(:meta, property: 'og:description', content: resource.try(:excerpt))
      
      if resource.respond_to?(:featured_image_url) && resource.featured_image_url.present?
        tags << tag(:meta, property: 'og:image', content: resource.featured_image_url)
      end
      
      if resource.respond_to?(:slug)
        tags << tag(:meta, property: 'og:url', content: url_for(resource))
      end
    end
    
    tags
  end
  
  def twitter_card_tags(resource = nil)
    tags = []
    
    tags << tag(:meta, name: 'twitter:card', content: 'summary_large_image')
    tags << tag(:meta, name: 'twitter:site', content: "@#{AppConfig.social.twitter}")
    
    if resource
      tags << tag(:meta, name: 'twitter:title', content: resource.try(:title))
      tags << tag(:meta, name: 'twitter:description', content: resource.try(:excerpt))
    end
    
    tags
  end
  
  private
  
  def og_type(resource)
    case resource
    when Post
      'article'
    when Page
      'website'
    else
      'website'
    end
  end
  
  # JSON-LD structured data
  def json_ld_tag(&block)
    content_tag :script, type: 'application/ld+json' do
      yield.to_json.html_safe
    end
  end
  
  def article_structured_data(post)
    json_ld_tag do
      {
        '@context': 'https://schema.org',
        '@type': 'BlogPosting',
        headline: post.title,
        description: post.excerpt,
        datePublished: post.published_at.iso8601,
        dateModified: post.updated_at.iso8601,
        author: {
          '@type': 'Person',
          name: post.author.full_name
        },
        publisher: {
          '@type': 'Organization',
          name: AppConfig.app.name,
          logo: {
            '@type': 'ImageObject',
            url: asset_url('logo.png')
          }
        }
      }
    end
  end
end
```

## Component Helper

View component helpers:

```ruby
module ComponentHelper
  # Card component
  def card(title: nil, footer: nil, **options, &block)
    css_classes = ['card', options[:class]].compact.join(' ')
    
    content_tag :div, class: css_classes, **options.except(:class) do
      content = ''
      
      if title
        content += content_tag(:div, class: 'card-header') do
          content_tag(:h5, title, class: 'card-title mb-0')
        end
      end
      
      content += content_tag(:div, class: 'card-body', &block)
      
      if footer
        content += content_tag(:div, footer, class: 'card-footer')
      end
      
      content.html_safe
    end
  end
  
  # Modal component
  def modal(id:, title:, **options, &block)
    content_tag :div, class: 'modal fade', id: id, tabindex: '-1' do
      content_tag :div, class: "modal-dialog #{options[:size]}" do
        content_tag :div, class: 'modal-content' do
          modal_header(title) + 
          modal_body(&block) +
          modal_footer { options[:footer] }
        end
      end
    end
  end
  
  def modal_header(title)
    content_tag :div, class: 'modal-header' do
      content_tag(:h5, title, class: 'modal-title') +
      button_tag('', class: 'btn-close', data: { bs_dismiss: 'modal' })
    end
  end
  
  def modal_body(&block)
    content_tag :div, class: 'modal-body', &block
  end
  
  def modal_footer(&block)
    return '' unless block_given?
    
    content_tag :div, class: 'modal-footer', &block
  end
  
  # Alert component
  def alert(message, type: :info, dismissible: true)
    css_classes = ['alert', "alert-#{type}"]
    css_classes << 'alert-dismissible fade show' if dismissible
    
    content_tag :div, class: css_classes.join(' '), role: 'alert' do
      content = message
      
      if dismissible
        content += button_tag('', class: 'btn-close', 
                             data: { bs_dismiss: 'alert' })
      end
      
      content.html_safe
    end
  end
  
  # Loading spinner
  def spinner(text: 'Loading...', type: :border, size: nil)
    css_classes = ["spinner-#{type}"]
    css_classes << "spinner-#{type}-#{size}" if size
    
    content_tag :div, class: css_classes.join(' '), role: 'status' do
      content_tag :span, text, class: 'visually-hidden'
    end
  end
  
  # Empty state
  def empty_state(message: 'No items found', icon: 'bi-inbox', &block)
    content_tag :div, class: 'text-center py-5' do
      content_tag(:i, '', class: "#{icon} display-1 text-muted mb-3 d-block") +
      content_tag(:p, message, class: 'text-muted mb-3') +
      (block_given? ? capture(&block) : '')
    end
  end
end
```

## Testing Helpers

When testing helpers:

```ruby
RSpec.describe ApplicationHelper do
  describe '#page_title' do
    it 'returns base title when no title given' do
      allow(AppConfig).to receive_message_chain(:app, :name).and_return('Test App')
      expect(helper.page_title).to eq('Test App')
    end
    
    it 'returns formatted title when title given' do
      allow(AppConfig).to receive_message_chain(:app, :name).and_return('Test App')
      expect(helper.page_title('Posts')).to eq('Posts | Test App')
    end
  end
  
  describe '#flash_class' do
    it 'returns correct Bootstrap class for flash level' do
      expect(helper.flash_class(:notice)).to eq('alert-success')
      expect(helper.flash_class(:error)).to eq('alert-danger')
      expect(helper.flash_class(:warning)).to eq('alert-warning')
      expect(helper.flash_class(:info)).to eq('alert-info')
    end
  end
end
```

## Best Practices

1. **Keep helpers simple** - Complex logic belongs in models or services
2. **Use semantic naming** - Helper names should clearly indicate their purpose
3. **Avoid state** - Helpers should be stateless functions
4. **Test helpers** - Especially those with conditional logic
5. **Use view components** - For complex, reusable UI elements
6. **Document parameters** - Especially for helpers with multiple options

## Next Steps

- Review [Models](models.md) that helpers interact with
- Understand [Controllers](controllers.md) that provide data to views
- Learn about [Commands](commands.md) for business logic