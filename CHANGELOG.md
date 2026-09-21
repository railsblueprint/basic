# Changelog

All notable changes to Rails Blueprint Basic Edition will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.4.0] - 2026-09-21

### Added
- **Fork-safe `blueprint:init`**: `rails blueprint:init[app_name,default_branch]` takes the default branch as an optional second argument (detected from the current branch when omitted) and rewrites the CI triggers in `.github/workflows/rails.yml` and `rubocop_dev_branch` in `lib/tasks/rubocop.rake` to match. Re-running it on an initialised app changes nothing.
- **Honeypot spam protection** on the contact form: a hidden `website` field; submissions that fill it are logged and never emailed.
- **CLAUDE.md** with the recipe for booting the app and running the suite from a fresh worktree.
- **README "After forking"** section covering the default branch, CI runners and the template self-test job.

### Changed
- **Rails** 8.0.2.1 → 8.1.3.1.
- **Devise** 4.9 → 5.0 (mailer deliveries now always use `deliver_now`).
- **Puma** 6.6 → 8.0, **good_job** 4.11 → 4.19, **nokogiri** 1.18 → 1.19, **dartsass-rails** 0.4 → 0.5, **rubocop** 1.79 → 1.91, **roo** 2.10 → 3.0 (brings **rubyzip** 3, clearing its path-traversal advisory).
- **json** pinned to 2.x: json 3.0 drops the positional options hash that `ActiveSupport::JSON.decode` still passes on Rails 8.1, which broke every signed-cookie read.
- **suneditor** 2.45.1 → 3.3.3 (clears the embed-plugin XSS advisory, which has no 2.x fix). Importmap pins, `package.json`, the Stimulus controller and the stylesheet import (`suneditor/dist/suneditor.min`) follow the 3.x API.
- **CI** runs on the runner named by the `CI_RUNNER` repository variable (GitHub-hosted when unset); the `blueprint-init` self-test job runs only where `BLUEPRINT_TEMPLATE=true`, so forks are not affected. Postgres listens on a dynamic port so two jobs can share a host.
- **`rake rubocop:changed`** resolves its base from `GITHUB_BASE_REF`, then `RUBOCOP_DEV_BRANCH`, then the literal `blueprint:init` wrote, and diffs against `origin/<branch>`.
- All rubocop 1.91 offenses cleared across the codebase.

### Removed
- **webdrivers** gem (deprecated; selenium-webdriver manages the driver).

### Fixed
- **Security**: rack 3.2.0 → 3.2.4 (five high-severity CVEs), aws-sdk-s3 (CVE-2025-14762), uri 0.13.2 → 0.13.3 (CVE-2025-61594). `bundle-audit` and `bin/importmap audit` are clean.
- Admin editor toolbar rendered without styles: `admin.scss` imported suneditor's source stylesheet whose relative `@import` never resolved through the asset pipeline.
- `spec/requests/admin/users_spec.rb` failed intermittently when Faker put "test" into another user's email.
- `spec/requests/static_pages_spec.rb` wrote a view template at runtime, which reloaded the app mid-suite and broke the anonymous-controller specs that ran after it.

## [1.3.5] - 2025-09-29

### Added
- **Google Analytics** and **Yandex Metrika** tracking, with the page resilient to either script failing to load.

### Changed
- **BaseCommand** broadcasts `ok` with the process result so subscribers receive the command's outcome.

## [1.3.4] - 2025-08-25

### Added
- **Automatic Static Page Rendering**: Create static pages without routes or controller actions
  - File-based routing for views in `app/views/static_pages/`
  - Support for nested folder structures
  - Automatic CSS class generation for body tags
- **Bootstrap Icons Design System Page**: Rake task to regenerate with all 2078 icons
- **CI Pipeline Guards**: Template files only copied if targets don't exist

### Changed
- **Bootstrap Icons**: Migrated from Ruby gems to npm package (v1.13.1)
- **Bootstrap**: Updated all references to version 5.3.7
- **StaticPagesController**: Simplified implementation without method_missing

### Removed
- `bootstrap-icons-helper` gem
- `bootstrap_icons_rubygem` gem
- Explicit FAQ route (now handled by automatic routing)

## [1.1.0] - 2025-01-16

### Updated
- **Rails**: Upgraded from 7.2.1 to 8.0.2
- **Ruby**: Upgraded from 3.3.0 to 3.4.4
  - Compiled with YJIT (Yet Another Ruby JIT) for improved performance
  - Compiled with jemalloc memory allocator for better memory management
- **Bootstrap**: Updated from 5.3.0 to 5.3.7
- **Dependencies**: Updated all gems and JavaScript packages to latest compatible versions

### Added
- Ruby 3.4 compatibility gems (csv, observer) - required as these were removed from stdlib
- RuboCop rspec_rails plugin for enhanced RSpec linting

### Fixed
- Rails 8 compatibility issues:
  - Updated RSpec fixture configuration (fixture_path → fixture_paths)
  - Updated Rails load_defaults to 8.0
  - Fixed Liquid template registration for Rails 8
- RuboCop configuration:
  - Updated plugins configuration format (require → plugins)
  - Fixed malformed cop directive syntax
  - Added inline suppressions for project-specific design patterns

### Changed
- Updated development priorities documentation focusing on sales capability
- Enhanced code quality with comprehensive RuboCop configuration
- All tests passing with zero RuboCop offenses

## [1.0.0] - 2024-XX-XX

### Added
- Initial release of Rails Blueprint Basic Edition
- Complete Rails 7.2 application template
- User authentication and authorization
- Admin panel with CRUD operations
- Blog and static pages functionality
- Responsive Bootstrap UI
- Background job processing with Good Job
- Comprehensive test suite with RSpec
- Deployment configuration with Mina
- GitHub Actions CI/CD pipeline

