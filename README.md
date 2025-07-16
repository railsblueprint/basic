## Rails Blueprint. Basic edition.

**Version:** 1.1.0 (see VERSION_BASIC file)

### Rationale

[Ruby on Rails](https://rubyonrails.org) is awesome and was splendid since the beginning. The legendary video 
["Building blog in 15 minutes"](https://www.youtube.com/watch?v=Gzj723LkRJY) is still impressive 18 years after presentation.  
With the release of [Hotwire stack](https://hotwired.dev) things get even more gorgeous. There is a sequel 
video [Building a Twitter clone in 10 minutes](https://www.youtube.com/watch?v=F5hA79vKE_E) demonstrating modern
Rails approaches.

But in real life bootstraping a new Rails application was always a time-consuming process. You have to create some
mandatory models like User, add authorization, emails,  some CSS framework, testing framework, add tests, 
configure everything, setup deployments, configure servers, email delivery etc. Depending on how elaborate you want to be
you may need from couple of hours up to couple of weeks of time before you start to write your application 
buisness logic. And usually we dont do it every day, meaning for most steps you have to read documentation to
refresh your memory.

Here comes the idea Rails Blueprint project. A template you can pick, setup within few minutes and start building
what really matters. It includes best practices for rapid development of your Rails application.

Main features:

- Latest Ruby on Rails (8.0.2)
- Latest Ruby (3.4.4 with YJIT and jemalloc)
- Hotwire stack (Turbo, Stimulus)
- Action Cable and Stimulus Reflex for even more reactivity
- Bootstrap 5.3.7
- Slim for compact views
- Awesome livereload
- Users and roles.
- Friendly ids for blog posts
- Basic blog and static pages editor
- Authorization using devise
- Email templates and settings stored in database
- Pundit for permissions management
- Basic admin panel. Highly responsive and easy to use.
- Design system pages demostrating various bootstrap components, color system, icon fonts, text editors etc.
- good_job for background job processing
- Blazing fast deployment using [Mina](https://github.com/mina-deploy/mina)
- Rspec tests for everything (including FactoryBot, Simplecov)
- Rubocop and security checks in place
- Github actions configured
- Translation ready

Basically you get a ready application you can deploy to your server and start to use instantly after a short
configuration process. And next you can extend it with your own features.

Just check out the demo: https://basic.railsblueprint.com before proceeding.

### Obtaining the code
Depneding on your intetions you can go in 2 paths:

##### 1. You don't care about future updates or just want to play around.
Simply clone the project, remove .git directory and check in the project you git repository:
```
git clone git@github.com:railsblueprint/basic.git
cd basic
rm -rf .git
git init .
git add .
git commit -m 'Orininal Rails blueprint'
git remote add origin "Your git repository"
git push origin master
```
#### 2. If you want to play long and try to keep your project aligned with updates in Rails Blueprint.
Please keep in mind that smooth updates are not guaranteed. Working on your project suppose changing provided
source code, meaning merge conflicts are inevitable. Though we try to make upgrade as painless as we can.
##### 2.1 If you're using github
- Fork the rails blueprint project. Main branch is named `blueprint-basic-master`  
- Create you own master branch and set it as default
- Checkout your master branch locally and start working on it
##### 2.2 If you're using different git provider
Clone blueprint specifying different origin name, add your git provider as origin and push there

```
git clone --origin blueprint git@github.com:railsblueprint/basic.git
git branch master
git remote add origin "Your git repository"
git push origin master
```

### Setting up
#### Prerequisites
Rails blueprint relies on Postgresql and Redis. Using rbenv or rvm is recommended. If you are using MacOS, 
use homebrew for installing dependencies.

##### Installing Ruby with Performance Optimizations
Rails Blueprint uses Ruby 3.4.4 with YJIT and jemalloc for optimal performance. These optimizations can provide:
- **YJIT**: 15-30% performance improvement through Just-In-Time compilation
- **jemalloc**: Better memory management, reducing memory usage by 10-20%

To install Ruby with these optimizations using rbenv:

**On macOS:**
```bash
# Install jemalloc
brew install jemalloc

# Install rust (required for YJIT)
brew install rust

# Install Ruby with optimizations
RUBY_CONFIGURE_OPTS="--enable-yjit --with-jemalloc=$(brew --prefix jemalloc)" rbenv install 3.4.4
```

**On Ubuntu/Debian:**
```bash
# Install dependencies
sudo apt-get update
sudo apt-get install -y libjemalloc-dev rustc

# Install Ruby with optimizations
RUBY_CONFIGURE_OPTS="--enable-yjit --with-jemalloc" rbenv install 3.4.4
```

**Verify the installation:**
```bash
# Check Ruby version
ruby --version
# Should show: ruby 3.4.4 (2025-05-14 revision a38531fd3f) +PRISM [x86_64-...]

# Verify YJIT is available
ruby --yjit -e "puts RubyVM::YJIT.enabled?"
# Should output: true

# Verify jemalloc is linked (Linux)
ldd $(rbenv which ruby) | grep jemalloc
# Should show: libjemalloc.so.2 => /lib/.../libjemalloc.so.2

# Verify jemalloc is linked (macOS)
otool -L $(rbenv which ruby) | grep jemalloc
# Should show a jemalloc library path
```

#### Setup
- run `bundle install` to install missing gems
- run `bundle rails blueprint:init` to generate default configuration files.

You will be asked for project name. Enter something meaningful in snake_case form: "my_app", "ai_translator", "wordle".
A bunch of configuration files will be created. Use `git add . ; git commit -a` to add all new files to the repo.

**Important**: After running `blueprint:init`, update the domain configurations in `config/app.yml`:
- Change `host: 'example.com'` in staging section to your staging domain
- Change `host: 'example.com'` in production section to your production domain

Be careful! Some files are excluded using `.gitignore` file. These are `.env` (which is not that scary), `config/master.key`, 
`config/credentials/staging.key` and `config/credentials/production.key`. Later 3 are needed for editing encrypted
credentials files. You you loose them you won't be able to decrypt your credentials files anymore. So take care and
make backups (in some secure place like password manager).

- run `yarn install` to install javascript dependencies

If your user has administrative permissions in postgres (which is default when you setup postgres via homebrew), run
this to create database:

`bundle exec rails db:create`

Otherwise create development and test databases manually. Check and/or update configuration in config/database.yml

- run migrations: `bundle exec rails db:migrate:with_data`
- create admin user: `bundle exec rails db:seed`
- optionaly create sample data: `bundle exec rails db:seed what=demo`

Now we are ready to start the project using

`bin/dev`

or

`overmind start` (requires [overrmind](https://github.com/DarthSim/overmind) to be installed)

Open http://localhost:3000 in browser. You should home page. Use superadmin@localhost / 12345678 to login.
Change port in .env file. This is extremly useful when you have to work on several projects in parallel.

### Deploying to server
Rails blueprint is configured for single-server deployment using 2 stages: staging and production. 
AWS EC2 is tested and recommented, but any linux machine should work (maybe with some adjustments)

To setup deployment you have to check and update configuration files: `config/deploy/stage.rb` and 
`config/deploy/production.rb` They are responsible for staging and production environments respectively.

Initial deployment:
```
bundle exec mina staging setup
bundle exec mina staging nginx:setup
bundle exec mina staging puma:setup
bundle exec mina staging deploy:current
```

This will create all directories on server, create nginx config file, puma systemd service and deploy current branch.
Subsequent deployments are done with
```
bundle exec mina staging deploy # for deploying default branch
bundle exec mina staging deploy:current # for deploying currently checked out branch
BRANCH=branch_named bundle exec mina staging deploy # for deploying specific branch
```
Change stage to production for deploying to production environment

### Health Monitoring

Rails Blueprint includes a health endpoint at `/health` that provides application status information useful for monitoring and load balancers.

**Endpoint:** `GET /health`

**Response format:**
```json
{
  "status": "ok",
  "version": {
    "basic": "1.1.0"
  },
  "git_revision": "c011f46f988ea5421454b3897e4b29c14a09861b",
  "timestamp": "2025-07-16T10:27:04Z"
}
```

The endpoint:
- Returns JSON with application health information
- Shows versions from all `VERSION_*` files present in the project
- Includes git revision (from git command in development, `.mina_git_revision` file in production)
- Provides current timestamp
- Requires no authentication
- Adapts automatically across different editions (basic/plus/pro)

This endpoint is useful for:
- Load balancer health checks
- Monitoring system integration
- Deployment verification
- Version tracking across environments

### Updating
#### When useing github
1. Update `blueprint-basic-master` branch from upstream repo.
2. Merge `blueprint-basic-master` to your master. It is recommendable to first create a temporary branch and check that after update everythign works as expected.

#### When useing different environment
1. Update `blueprint-basic-master` branch from blueprint remote (`git fetch blueprint`
2. Merge `blueprint-basic-master` to your master. It is recommendable to first create a temporary branch and check that after update everythign works as expected.

Use `bundle rails blueprint:init` to check if anything changed in configuration files. It won't overwrite any 
configuration file automatically, you'll be prompted for each file which differs from default values and provided with standard rails
options: overwrite, ignore, show diff etc.


