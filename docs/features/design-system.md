# Design System

Rails Blueprint includes a comprehensive design system built on Bootstrap 5, providing consistent UI components, patterns, and guidelines for building beautiful interfaces.

## Overview

The design system includes:
- **Component Library** - Reusable UI components
- **Color System** - Consistent color palette
- **Typography** - Font hierarchy and styles
- **Layout System** - Grid and spacing utilities
- **Icons** - Bootstrap Icons integration
- **Interactive Elements** - Forms, buttons, modals
- **Documentation** - Live examples and code

Access the design system at `/admin/design_system`

## Color System

### Primary Colors

```scss
// Primary palette
$primary: #0d6efd;    // Blue
$secondary: #6c757d;  // Gray
$success: #198754;    // Green
$info: #0dcaf0;       // Cyan
$warning: #ffc107;    // Yellow
$danger: #dc3545;     // Red
$light: #f8f9fa;      // Light gray
$dark: #212529;       // Dark gray

// Custom colors
$brand-primary: #2c3e50;
$brand-secondary: #3498db;
$accent: #e74c3c;
```

### Color Usage

```erb
<!-- Background colors -->
<div class="bg-primary text-white">Primary background</div>
<div class="bg-light">Light background</div>

<!-- Text colors -->
<p class="text-primary">Primary text</p>
<p class="text-muted">Muted text</p>
<p class="text-danger">Error text</p>

<!-- Border colors -->
<div class="border border-primary">Primary border</div>
<div class="border-start border-5 border-success">Success accent</div>
```

### Custom Color Utilities

```scss
// app/assets/stylesheets/utilities/_colors.scss
.bg-gradient-primary {
  background: linear-gradient(135deg, $primary 0%, darken($primary, 10%) 100%);
}

.text-brand {
  color: $brand-primary;
}

.hover-lift {
  transition: transform 0.3s ease;
  &:hover {
    transform: translateY(-2px);
  }
}
```

## Typography

### Font Stack

```scss
// System font stack for performance
$font-family-sans-serif: 
  -apple-system, 
  BlinkMacSystemFont, 
  "Segoe UI", 
  Roboto, 
  "Helvetica Neue", 
  Arial, 
  sans-serif;

$font-family-monospace: 
  SFMono-Regular, 
  Menlo, 
  Monaco, 
  Consolas, 
  "Liberation Mono", 
  "Courier New", 
  monospace;
```

### Headings

```erb
<h1 class="display-1">Display 1</h1>
<h1 class="display-4">Display 4</h1>
<h1>Heading 1 <small class="text-muted">With small text</small></h1>
<h2>Heading 2</h2>
<h3>Heading 3</h3>
<h4>Heading 4</h4>
<h5>Heading 5</h5>
<h6>Heading 6</h6>

<!-- Lead paragraph -->
<p class="lead">
  This is a lead paragraph that stands out from regular paragraphs.
</p>
```

### Text Utilities

```erb
<!-- Font weight -->
<p class="fw-bold">Bold text</p>
<p class="fw-normal">Normal weight</p>
<p class="fw-light">Light text</p>

<!-- Font style -->
<p class="fst-italic">Italic text</p>
<p class="text-decoration-underline">Underlined</p>
<p class="text-decoration-line-through">Strikethrough</p>

<!-- Text transform -->
<p class="text-lowercase">LOWERCASED TEXT</p>
<p class="text-uppercase">uppercased text</p>
<p class="text-capitalize">capitalized text</p>
```

## Layout System

### Grid

```erb
<!-- Basic grid -->
<div class="container">
  <div class="row">
    <div class="col-md-8">Main content</div>
    <div class="col-md-4">Sidebar</div>
  </div>
</div>

<!-- Responsive grid -->
<div class="row g-4">
  <div class="col-12 col-md-6 col-lg-4">
    <!-- Stacks on mobile, 2 columns on tablet, 3 on desktop -->
  </div>
</div>

<!-- Auto-layout columns -->
<div class="row">
  <div class="col">Equal width</div>
  <div class="col">Equal width</div>
  <div class="col">Equal width</div>
</div>
```

### Spacing

```erb
<!-- Margin utilities -->
<div class="mt-3">Margin top 3</div>
<div class="mb-4">Margin bottom 4</div>
<div class="mx-auto">Centered horizontally</div>
<div class="my-5">Margin top and bottom 5</div>

<!-- Padding utilities -->
<div class="p-3">Padding all sides</div>
<div class="px-4">Padding horizontal</div>
<div class="py-2">Padding vertical</div>
<div class="ps-5">Padding start (left in LTR)</div>
```

### Containers

```erb
<!-- Standard containers -->
<div class="container">Fixed width container</div>
<div class="container-fluid">Full width container</div>

<!-- Responsive containers -->
<div class="container-sm">100% wide until small breakpoint</div>
<div class="container-lg">100% wide until large breakpoint</div>
```

## Components

### Buttons

```erb
<!-- Basic buttons -->
<button class="btn btn-primary">Primary</button>
<button class="btn btn-secondary">Secondary</button>
<button class="btn btn-success">Success</button>
<button class="btn btn-danger">Danger</button>

<!-- Button variations -->
<button class="btn btn-outline-primary">Outline</button>
<button class="btn btn-primary btn-lg">Large</button>
<button class="btn btn-primary btn-sm">Small</button>

<!-- Button states -->
<button class="btn btn-primary" disabled>Disabled</button>
<button class="btn btn-primary active">Active</button>

<!-- Button groups -->
<div class="btn-group" role="group">
  <button class="btn btn-primary">Left</button>
  <button class="btn btn-primary">Middle</button>
  <button class="btn btn-primary">Right</button>
</div>
```

### Cards

```erb
<!-- Basic card -->
<div class="card">
  <div class="card-body">
    <h5 class="card-title">Card title</h5>
    <p class="card-text">Card content goes here.</p>
    <a href="#" class="btn btn-primary">Action</a>
  </div>
</div>

<!-- Card with image -->
<div class="card">
  <%= image_tag "placeholder.jpg", class: "card-img-top" %>
  <div class="card-body">
    <h5 class="card-title">Featured</h5>
    <p class="card-text">Description text.</p>
  </div>
  <div class="card-footer text-muted">
    2 days ago
  </div>
</div>

<!-- Card variations -->
<div class="card text-white bg-primary">
  <div class="card-body">
    <h5 class="card-title">Primary card</h5>
  </div>
</div>
```

### Forms

```erb
<!-- Basic form -->
<%= form_with model: @user, class: "needs-validation" do |f| %>
  <div class="mb-3">
    <%= f.label :email, class: "form-label" %>
    <%= f.email_field :email, class: "form-control", required: true %>
    <div class="invalid-feedback">
      Please provide a valid email.
    </div>
  </div>
  
  <div class="mb-3">
    <%= f.label :password, class: "form-label" %>
    <%= f.password_field :password, class: "form-control" %>
    <div class="form-text">
      Must be at least 8 characters.
    </div>
  </div>
  
  <div class="mb-3 form-check">
    <%= f.check_box :remember_me, class: "form-check-input" %>
    <%= f.label :remember_me, class: "form-check-label" %>
  </div>
  
  <%= f.submit "Submit", class: "btn btn-primary" %>
<% end %>

<!-- Input groups -->
<div class="input-group mb-3">
  <span class="input-group-text">@</span>
  <input type="text" class="form-control" placeholder="Username">
</div>

<!-- Floating labels -->
<div class="form-floating mb-3">
  <input type="email" class="form-control" id="floatingInput" placeholder="name@example.com">
  <label for="floatingInput">Email address</label>
</div>
```

### Alerts

```erb
<!-- Basic alerts -->
<div class="alert alert-primary" role="alert">
  Primary alert with <a href="#" class="alert-link">a link</a>.
</div>

<div class="alert alert-danger" role="alert">
  <h4 class="alert-heading">Error!</h4>
  <p>Something went wrong. Please try again.</p>
</div>

<!-- Dismissible alert -->
<div class="alert alert-warning alert-dismissible fade show" role="alert">
  <strong>Warning!</strong> Please check your input.
  <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
</div>

<!-- Alert with icon -->
<div class="alert alert-success d-flex align-items-center" role="alert">
  <i class="bi bi-check-circle-fill me-2"></i>
  <div>Successfully saved!</div>
</div>
```

### Modals

```erb
<!-- Modal trigger -->
<button type="button" class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#exampleModal">
  Launch modal
</button>

<!-- Modal -->
<div class="modal fade" id="exampleModal" tabindex="-1">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title">Modal title</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
      </div>
      <div class="modal-body">
        <p>Modal body content goes here.</p>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
        <button type="button" class="btn btn-primary">Save changes</button>
      </div>
    </div>
  </div>
</div>
```

## Icons

Rails Blueprint includes Bootstrap Icons:

```erb
<!-- Basic icons -->
<i class="bi bi-house"></i> Home
<i class="bi bi-person"></i> User
<i class="bi bi-gear"></i> Settings

<!-- Icon sizes -->
<i class="bi bi-heart" style="font-size: 2rem;"></i>
<i class="bi bi-heart fs-1"></i>

<!-- Icon colors -->
<i class="bi bi-check-circle text-success"></i>
<i class="bi bi-x-circle text-danger"></i>

<!-- Icon buttons -->
<button class="btn btn-primary">
  <i class="bi bi-download me-2"></i>Download
</button>

<button class="btn btn-outline-danger btn-sm">
  <i class="bi bi-trash"></i>
</button>
```

## Navigation

### Navbar

```erb
<nav class="navbar navbar-expand-lg navbar-light bg-light">
  <div class="container-fluid">
    <%= link_to "Rails Blueprint", root_path, class: "navbar-brand" %>
    
    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
      <span class="navbar-toggler-icon"></span>
    </button>
    
    <div class="collapse navbar-collapse" id="navbarNav">
      <ul class="navbar-nav me-auto">
        <li class="nav-item">
          <%= link_to "Home", root_path, class: "nav-link" %>
        </li>
        <li class="nav-item">
          <%= link_to "About", about_path, class: "nav-link" %>
        </li>
      </ul>
      
      <ul class="navbar-nav">
        <% if user_signed_in? %>
          <li class="nav-item dropdown">
            <a class="nav-link dropdown-toggle" href="#" data-bs-toggle="dropdown">
              <%= current_user.name %>
            </a>
            <ul class="dropdown-menu">
              <li><%= link_to "Profile", profile_path, class: "dropdown-item" %></li>
              <li><hr class="dropdown-divider"></li>
              <li><%= link_to "Logout", logout_path, class: "dropdown-item" %></li>
            </ul>
          </li>
        <% end %>
      </ul>
    </div>
  </div>
</nav>
```

### Breadcrumbs

```erb
<nav aria-label="breadcrumb">
  <ol class="breadcrumb">
    <li class="breadcrumb-item"><%= link_to "Home", root_path %></li>
    <li class="breadcrumb-item"><%= link_to "Blog", posts_path %></li>
    <li class="breadcrumb-item active" aria-current="page"><%= @post.title %></li>
  </ol>
</nav>
```

## Tables

```erb
<!-- Basic table -->
<table class="table">
  <thead>
    <tr>
      <th>Name</th>
      <th>Email</th>
      <th>Role</th>
      <th>Actions</th>
    </tr>
  </thead>
  <tbody>
    <% @users.each do |user| %>
      <tr>
        <td><%= user.name %></td>
        <td><%= user.email %></td>
        <td><%= user.role %></td>
        <td>
          <%= link_to "Edit", edit_user_path(user), class: "btn btn-sm btn-primary" %>
        </td>
      </tr>
    <% end %>
  </tbody>
</table>

<!-- Table variations -->
<table class="table table-striped table-hover">
  <!-- Striped rows and hover effect -->
</table>

<table class="table table-bordered table-sm">
  <!-- Bordered and compact -->
</table>
```

## Custom Components

### View Components

Rails Blueprint uses ViewComponent for reusable UI:

```ruby
# app/components/alert_component.rb
class AlertComponent < ViewComponent::Base
  def initialize(type:, message:, dismissible: false)
    @type = type
    @message = message
    @dismissible = dismissible
  end

  private

  def css_class
    base = "alert alert-#{@type}"
    base += " alert-dismissible fade show" if @dismissible
    base
  end
end
```

```erb
<!-- app/components/alert_component.html.erb -->
<div class="<%= css_class %>" role="alert">
  <%= @message %>
  <% if @dismissible %>
    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
  <% end %>
</div>

<!-- Usage -->
<%= render AlertComponent.new(type: "success", message: "Saved!", dismissible: true) %>
```

### Stimulus Components

Interactive components with Stimulus:

```javascript
// app/javascript/controllers/dropdown_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]
  
  toggle() {
    this.menuTarget.classList.toggle("show")
  }
  
  hide(event) {
    if (!this.element.contains(event.target)) {
      this.menuTarget.classList.remove("show")
    }
  }
}
```

```erb
<div data-controller="dropdown" data-action="click@window->dropdown#hide">
  <button data-action="click->dropdown#toggle" class="btn btn-secondary">
    Options
  </button>
  <div data-dropdown-target="menu" class="dropdown-menu">
    <!-- Menu items -->
  </div>
</div>
```

## Responsive Design

### Breakpoints

```scss
// Bootstrap breakpoints
$grid-breakpoints: (
  xs: 0,
  sm: 576px,
  md: 768px,
  lg: 992px,
  xl: 1200px,
  xxl: 1400px
);
```

### Responsive Utilities

```erb
<!-- Responsive display -->
<div class="d-none d-md-block">Hidden on mobile</div>
<div class="d-block d-md-none">Mobile only</div>

<!-- Responsive text -->
<p class="text-center text-md-start">Centered on mobile, left on desktop</p>

<!-- Responsive spacing -->
<div class="p-2 p-md-4">Less padding on mobile</div>
```

## Best Practices

### 1. Consistent Spacing

Use Bootstrap's spacing scale:
```
0 = 0
1 = 0.25rem (4px)
2 = 0.5rem (8px)
3 = 1rem (16px)
4 = 1.5rem (24px)
5 = 3rem (48px)
```

### 2. Semantic HTML

Use appropriate elements:
```erb
<nav> for navigation
<main> for main content
<article> for posts
<section> for sections
<aside> for sidebars
```

### 3. Accessibility

Include ARIA labels:
```erb
<button aria-label="Close">
  <span aria-hidden="true">&times;</span>
</button>

<nav aria-label="Breadcrumb">
  <!-- Breadcrumb content -->
</nav>
```

### 4. Performance

Optimize assets:
```scss
// Use CSS custom properties for themes
:root {
  --primary-color: #0d6efd;
}

// Purge unused CSS in production
// Configure in postcss.config.js
```

## Next Steps

- Review the live examples at `/admin/design_system`
- Customize variables in `app/assets/stylesheets/_variables.scss`
- Create custom components in `app/components/`
- Add interactive behavior with Stimulus controllers