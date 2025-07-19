# Installation Guide

This guide covers the installation process for Rails Blueprint.

## System Requirements

### Required Software
- **Ruby**: 3.4.4 (recommended with YJIT and jemalloc)
- **Rails**: 8.0.2
- **PostgreSQL**: 14 or higher
- **Redis**: 6.0 or higher
- **Node.js**: 18 or higher
- **Yarn**: 1.22 or higher

### Recommended Tools
- **rbenv** or **rvm** for Ruby version management
- **Overmind** or **Foreman** for process management
- **direnv** for environment variable management

## Installation Steps

### 1. Clone the Repository

```bash
# If you want to track updates
git clone git@github.com:railsblueprint/basic.git myapp
cd myapp

# If you want to start fresh
git clone git@github.com:railsblueprint/basic.git myapp
cd myapp
rm -rf .git
git init
```

### 2. Install Ruby with Performance Optimizations

Rails Blueprint uses Ruby 3.4.4 with YJIT and jemalloc for optimal performance.

#### On macOS:
```bash
# Install dependencies
brew install jemalloc rust

# Install Ruby with optimizations
RUBY_CONFIGURE_OPTS="--enable-yjit --with-jemalloc=$(brew --prefix jemalloc)" rbenv install 3.4.4
rbenv local 3.4.4
```

#### On Ubuntu/Debian:
```bash
# Install dependencies
sudo apt-get update
sudo apt-get install -y libjemalloc-dev rustc

# Install Ruby with optimizations
RUBY_CONFIGURE_OPTS="--enable-yjit --with-jemalloc" rbenv install 3.4.4
rbenv local 3.4.4
```

#### Verify Installation:
```bash
# Check Ruby version
ruby --version
# Should show: ruby 3.4.4 ... +YJIT

# Verify YJIT
ruby --yjit -e "puts RubyVM::YJIT.enabled?"
# Should output: true
```

### 3. Install Dependencies

```bash
# Install bundler
gem install bundler

# Install Ruby gems
bundle install

# Install JavaScript packages
yarn install
```

### 4. Initialize the Application

Run the blueprint initialization task:

```bash
bundle exec rails blueprint:init
```

Or with a predefined app name:

```bash
bundle exec rails blueprint:init[myapp]
```

This will:
- Generate configuration files from templates
- Create necessary directories
- Set up environment files
- Generate encryption keys

**Important**: Save the generated keys from:
- `config/master.key`
- `config/credentials/staging.key`
- `config/credentials/production.key`

These keys are required to decrypt credentials and are not stored in version control.

### 5. Configure Environment Variables

Copy and customize the `.env` file:

```bash
# The blueprint:init task creates this, but you can customize it
# Edit .env to change ports or other settings
```

Common customizations:
- `PORT` - Change if running multiple Rails apps
- `REDIS_URL` - Update if using non-default Redis configuration

## Next Steps

- [Configure your application](configuration.md)
- [Set up the database](database.md)
- [Start the development server](development.md)

## Troubleshooting

### Bundle Install Fails

If you encounter issues with native extensions:

```bash
# On macOS
brew install postgresql@14
bundle config build.pg --with-pg-config=/usr/local/opt/postgresql@14/bin/pg_config

# On Ubuntu
sudo apt-get install libpq-dev
```

### Yarn Install Fails

Ensure you have the correct Node.js version:

```bash
# Check version
node --version

# Install via nvm if needed
nvm install 18
nvm use 18
```

### Permission Issues

If you encounter permission errors:

```bash
# Fix bundle permissions
bundle config set --local path 'vendor/bundle'
bundle install

# Fix yarn permissions
yarn install --check-files
```