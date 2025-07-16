# Changelog

All notable changes to Rails Blueprint Basic Edition will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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