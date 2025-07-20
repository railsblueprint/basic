# Propagating Changes Through Rails Blueprint Editions

This document outlines the process for propagating changes from the basic edition through plus, pro, and demo repositories in the Rails Blueprint ecosystem.

## Overview

Rails Blueprint follows a hierarchical structure where changes flow from basic → plus → pro → demos → marketing site:

```
basic (source) → plus → pro → demos (basic-demo, plus-demo, pro-demo) → marketing site
```

## Repository Structure

### Main Editions
- **basic/**: Core Rails application (source of truth)
- **plus/**: Enhanced version with additional features
- **pro/**: Full-featured enterprise version with Stripe billing

### Demo Repositories  
- **demos/basic-demo/**: Live demo of basic edition
- **demos/plus-demo/**: Live demo of plus edition
- **demos/pro-demo/**: Live demo of pro edition

### Marketing Site
- **site/**: Marketing and documentation site (built on pro edition)

## Critical Rules - READ FIRST

### ⚠️ NEVER Use Wrong Strategy
1. **Plus Edition**: Always use MERGE from basic remote
2. **Pro Edition**: Always use REBASE after fork sync from Plus
3. **Demo repositories**: Always use REBASE on the edition's branch (NOT demo's master!)
   - pro-demo rebases on `origin/blueprint-pro-master`
   - plus-demo rebases on `origin/blueprint-plus-master`
   - basic-demo uses MERGE from basic remote

### Common Mistakes to Avoid
- ❌ NEVER use `git reset --hard` - it loses tier-specific features
- ❌ NEVER merge in Pro edition - always rebase
- ❌ NEVER forget to sync fork first for Pro and demo repos
- ❌ NEVER rebase demos on their own master branch
- ❌ NEVER use merge for demos (except basic-demo)

## Propagation Strategy

### 1. Basic Edition (Source)
**Location**: `/basic/`
**Branch**: `blueprint-basic-master`
**Role**: Source of truth for all changes

**Process:**
- Direct development and fixes
- Security updates applied first
- Compatibility fixes (Ruby/Rails versions)
- Core functionality improvements

### 2. Plus Edition
**Location**: `/plus/`
**Branch**: `blueprint-plus-master`
**Remote Setup**: 
- `basic` remote: Points to railsblueprint/basic.git
- `origin` remote: Points to railsblueprint/plus.git

**Update Process:**
```bash
cd plus/
git fetch basic
git merge basic/blueprint-basic-master
bundle install
bundle exec rspec  # Run tests
bundle exec rubocop  # Check code quality
bundle exec bundle-audit  # Security check
git push origin blueprint-plus-master
```

**Strategy**: **Merge** (preserves plus-specific features)

### 3. Pro Edition  
**Location**: `/pro/`
**Branch**: `blueprint-pro-master`
**Remote Setup**: Single origin (forked from plus)

**Update Process:**
```bash
cd pro/
# Sync fork with plus edition via GitHub CLI
gh repo sync railsblueprint/pro --source railsblueprint/plus --branch blueprint-plus-master
git fetch origin
git rebase origin/blueprint-plus-master
# Resolve conflicts if any
bundle install
bundle exec rspec  # Run tests
bundle exec rubocop  # Check code quality  
bundle exec bundle-audit  # Security check
git push --force-with-lease origin blueprint-pro-master
```

**Strategy**: **Rebase** (keeps pro features on top of plus)

### 4. Demo Repositories
**Location**: `/demos/{edition}-demo/`
**Branch**: `master` (demo-specific)
**Remote Setup**: Forked repositories (use GitHub CLI for syncing)

**Demo Site URLs**:
- **basic-demo**:
  - Staging: https://basic.staging.railsblueprint.com
  - Production: https://basic.railsblueprint.com
- **plus-demo**:
  - Staging: https://plus.staging.railsblueprint.com
  - Production: https://plus.railsblueprint.com
- **pro-demo**:
  - Staging: https://pro.staging.railsblueprint.com
  - Production: https://pro.railsblueprint.com

**Update Process:**

#### For basic-demo:
```bash
cd demos/basic-demo/
git fetch basic
git merge basic/blueprint-basic-master
# Fix any demo-specific configuration issues
bundle install
bundle exec rails db:migrate:with_data RAILS_ENV=test
bundle exec rspec spec/models/user_spec.rb  # Quick test
git add . && git commit -m "Update with upstream changes"
git push origin master
bundle exec mina staging deploy
bundle exec mina production deploy

# Verify deployment with health endpoint
curl https://basic.staging.railsblueprint.com/health
curl https://basic.railsblueprint.com/health
```

#### For plus-demo and pro-demo (forked repositories):
```bash
cd demos/plus-demo/  # or pro-demo
# IMPORTANT: Sync fork with upstream edition's branch (NOT master!)
# For plus-demo:
gh repo sync railsblueprint/plus-demo --source railsblueprint/plus --branch blueprint-plus-master
# For pro-demo:
gh repo sync railsblueprint/pro-demo --source railsblueprint/pro --branch blueprint-pro-master

git fetch origin
# CRITICAL: Rebase on the edition's branch that was synced
git rebase origin/blueprint-plus-master  # for plus-demo
git rebase origin/blueprint-pro-master   # for pro-demo

# Fix any demo-specific configuration issues
bundle install
bundle exec rails db:migrate:with_data RAILS_ENV=test
bundle exec rspec spec/models/user_spec.rb  # Quick test
git push --force-with-lease origin master
bundle exec mina staging deploy
bundle exec mina production deploy

# Verify deployment with health endpoint
# For plus-demo:
curl https://plus.staging.railsblueprint.com/health
curl https://plus.railsblueprint.com/health
# For pro-demo:
curl https://pro.staging.railsblueprint.com/health
curl https://pro.railsblueprint.com/health
```

**Strategy**: 
- **basic-demo**: MERGE strategy (has direct remote to basic edition)
- **plus-demo/pro-demo**: REBASE strategy on edition's master branch (NOT demo's master!)
  - This is different from Pro edition which rebases on Plus
  - Demos rebase on their respective edition's master branch

### 5. Marketing Site
**Location**: `/site/`
**Branch**: `master`
**Remote Setup**: Built on pro edition base
**Remote**: `pro` remote points to railsblueprint/pro.git

**Marketing Site URLs**:
- Staging: https://staging.railsblueprint.com
- Production: https://railsblueprint.com

**Update Process:**
```bash
cd site/
git fetch pro
git merge pro/blueprint-pro-master
# Fix any site-specific configuration issues
bundle install
bundle exec rails db:migrate:with_data RAILS_ENV=test
bundle exec rspec spec/models/user_spec.rb  # Quick test
git add . && git commit -m "Update marketing site with upstream changes"
git push origin master
bundle exec mina production deploy

# Verify deployment with health endpoint
curl https://staging.railsblueprint.com/health  # if staging deployed
curl https://railsblueprint.com/health
```

**Strategy**: Merge (preserves marketing site customizations)

## Detailed Propagation Workflow

### Phase 1: Update Plus Edition
```bash
# 1. Navigate to plus directory
cd /path/to/railsblueprint/plus

# 2. Fetch and merge from basic
git fetch basic
git merge basic/blueprint-basic-master

# 3. Update dependencies
bundle install

# 4. Run quality checks
bundle exec rspec
bundle exec rubocop
bundle exec bundle-audit

# 5. Update edition-specific documentation
# - Update VERSION_PLUS
# - Update HISTORY_PLUS with plus-specific changes
# - Update README.md for plus edition

# 6. Commit and push
git add .
git commit -m "Update plus edition with upstream changes"
git push origin blueprint-plus-master
```

### Phase 2: Update Pro Edition
```bash
# 1. Navigate to pro directory  
cd /path/to/railsblueprint/pro

# 2. Sync fork via GitHub CLI
gh repo sync railsblueprint/pro --source railsblueprint/plus --branch blueprint-plus-master

# 3. Fetch and rebase
git fetch origin
git rebase origin/blueprint-plus-master

# 4. Resolve conflicts (typically in Gemfile for pro-specific gems)
# Keep pro-specific gems like stripe-rails
# Accept upstream security updates

# 5. Update dependencies
bundle install

# 6. Run quality checks
bundle exec rspec
bundle exec rubocop  
bundle exec bundle-audit

# 7. Update edition-specific documentation
# - Update VERSION_PRO
# - Update HISTORY_PRO with pro-specific changes
# - Update README.md for pro edition

# 8. Force push (after rebase)
git push --force-with-lease origin blueprint-pro-master
```

### Phase 3: Update Demo Repositories
```bash
# For each demo (basic-demo, plus-demo, pro-demo):

# 1. Navigate to demo directory
cd /path/to/railsblueprint/demos/basic-demo

# 2. Fetch and merge from blueprint source
git fetch basic  # or plus/pro depending on demo
git merge basic/blueprint-basic-master

# 3. Fix demo-specific configuration issues
# Common issues:
# - Database naming (ensure blueprint_{edition}_{env} format)
# - Domain configurations
# - Demo-specific customizations

# 4. Update dependencies and test
bundle install
bundle exec rails db:migrate:with_data RAILS_ENV=test
bundle exec rspec spec/models/user_spec.rb  # Quick test

# 5. Commit and push
git add .
git commit -m "Update demo with upstream changes"
git push origin master

# 6. Deploy to staging and production
bundle exec mina staging deploy
bundle exec mina production deploy
```

### Phase 4: Update Marketing Site
```bash
# 1. Navigate to marketing site directory
cd /path/to/railsblueprint/site

# 2. Fetch and merge from pro edition
git fetch pro
git merge pro/blueprint-pro-master

# 3. Fix site-specific configuration issues
# Common issues:
# - Marketing content updates
# - Version number references
# - Feature documentation updates

# 4. Update dependencies and test
bundle install
bundle exec rails db:migrate:with_data RAILS_ENV=test
bundle exec rspec spec/models/user_spec.rb  # Quick test

# 5. Commit and push
git add .
git commit -m "Update marketing site with upstream changes"
git push origin master

# 6. Deploy to production
bundle exec mina production deploy
```

## Common Issues and Solutions

### 1. Merge Conflicts
**In Plus/Pro Gemfiles:**
- **Resolution**: Keep edition-specific gems, accept upstream security updates
- **Example**: Pro edition keeps `stripe-rails`, accepts updated `rails` version

**In Configuration Files:**
- **Resolution**: Preserve edition-specific configurations
- **Example**: Pro edition keeps Stripe initializers

### 2. Database Configuration Issues
**Problem**: Incorrect database naming in demos
```yaml
# Wrong:
database: blueprint__test

# Correct:
database: blueprint_basic_test
```

**Solution**: Ensure consistent naming: `blueprint_{edition}_{environment}`

### 3. Ruby/Rails Compatibility
**Problem**: New Ruby/Rails versions break dependencies
- **html2slim-ruby3**: Comment out due to hpricot Ruby 3.3 incompatibility
- **data_migrate**: Update to `~> 11.0` for Rails 7.2 compatibility

### 4. Deployment Issues
**NewRelic Connectivity**: 
- **Issue**: Post-deployment NewRelic notifications may fail due to network issues
- **Impact**: Does not affect actual deployment success
- **Solution**: Ignore NewRelic notification failures, verify application functionality

**Hostname Configuration**:
- **Issue**: Demo deployment hostnames may change over time
- **Example**: pro-demo had outdated hostname "marketing" instead of "chill"
- **Solution**: Check and update deployment config files (config/deploy/staging.rb, config/deploy/production.rb)
- **Current standard hostname**: "chill" for all demo deployments

**Initial Setup Branches**:
- **Issue**: Some demos may have `initial-setup` branches with required configuration files
- **Solution**: Merge initial-setup branch into master before updating from upstream
- **Example**: pro-demo had configurations in initial-setup branch that needed merging

## Quality Assurance Checklist

After each propagation:

### Code Quality
- [ ] All tests passing (`bundle exec rspec`)
- [ ] Code style compliance (`bundle exec rubocop`)  
- [ ] No security vulnerabilities (`bundle exec bundle-audit`)
- [ ] Dependencies updated (`bundle install`)

### Edition-Specific
- [ ] VERSION_{EDITION} file updated
- [ ] HISTORY_{EDITION} file updated with changes
- [ ] README.md reflects correct edition
- [ ] Edition-specific features preserved

### Demo-Specific  
- [ ] Database configuration correct
- [ ] Demo customizations preserved
- [ ] Staging deployment successful
- [ ] Production deployment successful

## Versioning Strategy

### Edition-Specific Versioning
Each edition maintains its own version file:
- `VERSION_BASIC` - Basic edition version
- `VERSION_PLUS` - Plus edition version  
- `VERSION_PRO` - Pro edition version

### History Tracking
Each edition maintains its own history:
- `HISTORY_BASIC` - Detailed basic edition changes
- `HISTORY_PLUS` - Plus-specific changes + reference to basic changes
- `HISTORY_PRO` - Pro-specific changes + reference to upstream changes

## Automation Opportunities

### Future Improvements
1. **CI/CD Pipeline**: Automate testing after propagation
2. **Dependency Scanning**: Automated security vulnerability detection
3. **Demo Health Checks**: Automated post-deployment verification
4. **Change Notifications**: Alert system for successful propagations

### Best Practices for Reducing Merge Conflicts

#### Organize Gems by Tier in Gemfile
To minimize conflicts during propagation, organize gems in the Gemfile by tier:

```ruby
# === BASIC TIER GEMS ===
# Core Rails and essential dependencies
gem "rails", "~> 8.0.0"
gem "pg", "~> 1.2"
gem "puma", ">= 6.4.3"
gem "turbo-rails"
gem "stimulus-rails"
# ... other basic tier gems

# === PLUS TIER GEMS ===
# Additional features for Plus edition
gem "recaptcha", "~> 5.16"  # Plus: reCAPTCHA support
# ... other plus tier gems

# === PRO TIER GEMS ===
# Enterprise features for Pro edition  
gem "stripe-rails"           # Pro: Payment processing
gem "sitemap_generator", "~> 6.3"  # Pro: SEO sitemaps
# ... other pro tier gems
```

Benefits:
- Each tier adds gems in its own section
- Reduces merge conflicts during Basic → Plus → Pro propagation
- Clear visibility of which gems belong to which tier
- Easier to maintain tier-specific dependencies
- Simplifies troubleshooting tier-specific issues

## Emergency Procedures

### Rollback Strategy
If propagation introduces issues:

1. **Immediate**: Revert demo deployments to previous version
2. **Investigation**: Identify root cause in staging environment
3. **Fix Forward**: Apply targeted fixes rather than full rollbacks
4. **Communication**: Document issues in edition HISTORY files

### Critical Security Updates
For urgent security fixes:
1. Apply to basic edition immediately
2. Fast-track through plus and pro (skip non-essential testing)
3. Deploy to all demos within 24 hours
4. Comprehensive testing post-deployment

## Recent Propagation Examples

### Bootstrap Color Customization Tool Propagation (July 19, 2025)

Successfully propagated the Bootstrap Color Customization Tool from plus to pro edition:

1. **Plus Edition Development**:
   - Implemented full-featured Bootstrap color customization tool
   - Added 25+ predefined color palettes organized by categories
   - Included dark mode preview, border radius, and shadow controls
   - Created comprehensive test suite (31 tests)

2. **Pro Edition Propagation**:
   - Used rebase strategy after fork sync with `gh repo sync`
   - No conflicts encountered during rebase
   - Enhanced pro tier with 50 exclusive color palettes (2x plus edition)
   - Organized palettes into 10 professional categories
   - All tests passed (626 examples)

3. **Key Enhancements for Pro**:
   - Doubled the color palette collection (50 vs 25)
   - Added exclusive categories: Ocean & Water, Nature & Earth, Floral & Soft, etc.
   - Maintained all plus edition functionality while adding pro-tier value

**Lessons Learned**:
- Clean feature development in plus edition results in conflict-free propagation
- Pro tier differentiation through enhanced content (more palettes) works well
- Fork sync with GitHub CLI continues to be reliable for pro propagation

### Security Update Propagation (July 2025)

Successfully propagated Rails 7.2.2 security updates and Ruby 3.3.0 compatibility fixes across all editions:

1. **Started with Basic edition**:
   - Updated Rails to 7.2.2, Puma to 6.4.3, URI to 0.13.2
   - Fixed Ruby 3.3.0 compatibility (removed html2slim-ruby3)
   - All tests passed (536 examples)

2. **Propagated to Plus**:
   - Used merge strategy from basic remote
   - Maintained plus-specific features
   - All tests passed (574 examples)

3. **Propagated to Pro**:
   - Used rebase strategy after fork sync
   - Resolved Gemfile conflicts preserving pro features
   - All tests passed (597 examples)

4. **Updated all demo repositories**:
   - Fixed database naming issues (blueprint_{edition}_{environment})
   - Updated deployment hostnames (marketing → chill)
   - Successfully deployed to staging and production

5. **Updated marketing site**:
   - Applied security updates
   - Fixed Ruby 3.3.0 compatibility issue in base_command.rb
   - Updated content to reflect Rails 7.2
   - Deployed with manual puma restart workaround

**Key learnings:**
- Fork sync with GitHub CLI (`gh repo sync`) is more efficient than manual remote management
- Database naming conventions must be consistent (blueprint_{edition}_{environment})
- Deployment hostname configurations need periodic verification
- NewRelic notification failures during deployment can be safely ignored
- Ruby 3.3.0 introduces breaking changes with anonymous rest parameters in blocks
- Site deployment may require manual puma service management for major updates

See [SECURITY_UPDATE_FINDINGS.md](./SECURITY_UPDATE_FINDINGS.md) for detailed findings.

## Template Synchronization

### ⚠️ CRITICAL: Never Bypass Conflict Resolution

When propagating changes that involve template files (`.template` files), **NEVER** bypass the conflict resolution process. Template files contain ERB placeholders that are processed differently in each edition and user project.

### Template Update Process During Propagation

When propagating changes that modify template files:

1. **In Tier Repositories (basic, plus, pro)**:
   - `.blueprint_templates` is excluded via `.git/info/exclude`
   - Template changes are merged/rebased normally
   - No template tracking occurs in source repos

2. **In Demo Repositories**:
   - After merging/rebasing from upstream:
   ```bash
   # Check for template updates
   bundle exec rails blueprint:check_templates
   ```
   - Review each template change carefully
   - Use the interactive merge options
   - **NEVER** force update without reviewing changes

3. **Common Template Conflicts**:
   - **Database names**: Each demo has specific database naming
   - **Host configurations**: Each environment has unique domains
   - **App prefixes**: Edition-specific naming conventions
   - **Credentials references**: Different across editions

### Template Conflict Resolution Guidelines

When `blueprint:check_templates` shows conflicts:

1. **For configuration values** (database names, hosts, etc.):
   - Always keep local version
   - Template updates usually don't change these

2. **For structural changes** (new sections, reorganized files):
   - Use auto-merge first
   - Review the merged result carefully
   - Fix any ERB placeholder issues manually

3. **For security updates** (new Rails defaults, security headers):
   - Carefully merge to get security benefits
   - Preserve local customizations

### Example: Handling importmap.rb Updates

```bash
# After propagating to a demo repo
bundle exec rails blueprint:check_templates

# If importmap.rb has changes:
# 1. View diff (option 3)
# 2. If only new pins added: use auto-merge (option 4)
# 3. If conflicts: create merge file (option 5) and resolve manually
# 4. Never use "force update" as it will break ERB processing
```

### When to Use blueprint:update_templates

The `blueprint:update_templates` command should be used **ONLY** in very specific scenarios:

1. **Development Testing**: When testing template changes in a development environment
2. **Recovery Scenarios**: When you need to reset templates to baseline after corruption
3. **New Project Setup**: When setting up a new tier repository from scratch

**WARNING**: This command:
- Copies raw template files WITHOUT processing ERB placeholders
- Will break your configuration if used on processed files
- Should NEVER be used during normal propagation
- Requires manual fixing of all ERB placeholders afterward

### Template Files in Each Edition

- **Basic**: Core template files
- **Plus**: Inherits basic + adds robots.txt configurations
- **Pro**: Inherits plus + adds Stripe configurations
- **Demos**: Each has environment-specific values

Always verify template processing after updates:
```bash
# Regenerate a specific file to test
bundle exec rails generate config config/database.yml
# Check if ERB placeholders were processed correctly
```

---

This document should be updated whenever the propagation process changes or new editions are added to the Rails Blueprint ecosystem.