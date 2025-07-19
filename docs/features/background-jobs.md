# Background Jobs

Rails Blueprint uses [GoodJob](https://github.com/bensheldon/good_job) for background job processing, providing a robust, PostgreSQL-based queue system with a web interface for monitoring.

## Features

- **PostgreSQL-Based** - No additional dependencies
- **Web Dashboard** - Monitor jobs in real-time
- **Cron Jobs** - Schedule recurring tasks
- **Concurrency Control** - Thread-safe execution
- **Error Handling** - Automatic retries
- **Performance** - Optimized for speed
- **Reliability** - ACID compliance
- **Observability** - Detailed logging

## Architecture

### Job Storage

GoodJob stores jobs in PostgreSQL:

```ruby
# GoodJob tables
good_jobs           # Active and finished jobs
good_job_processes  # Worker processes
good_job_settings   # Configuration
```

### Job Classes

```ruby
class ExampleJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find(user_id)
    # Perform work...
  end
end
```

## Configuration

### Application Setup

```ruby
# config/application.rb
config.active_job.queue_adapter = :good_job

# config/good_job.yml
production:
  max_threads: 5
  queues: "urgent:3;default:2;low:1"
  poll_interval: 5
  
development:
  max_threads: 2
  queues: "*"
  poll_interval: 10
```

### Worker Process

```ruby
# Procfile
web: bundle exec puma -C config/puma.rb
worker: bundle exec good_job start

# Or inline mode (web process handles jobs)
web: bundle exec puma -C config/puma.rb
# No separate worker needed with GOOD_JOB_EXECUTION_MODE=async
```

## Creating Jobs

### Basic Job

```ruby
class SendWelcomeEmailJob < ApplicationJob
  queue_as :default

  def perform(user)
    UserMailer.welcome_email(user).deliver_now
  end
end

# Enqueue job
SendWelcomeEmailJob.perform_later(user)
SendWelcomeEmailJob.set(wait: 1.hour).perform_later(user)
```

### Job with Priority

```ruby
class ImportantJob < ApplicationJob
  queue_as :urgent
  
  # Good job priority (lower is higher priority)
  def priority
    -10
  end

  def perform(data)
    # Critical work...
  end
end
```

### Job with Retries

```ruby
class RetryableJob < ApplicationJob
  retry_on StandardError, wait: 5.seconds, attempts: 3
  
  # Or use GoodJob's retry mechanism
  include GoodJob::ActiveJobExtensions::InterruptErrors
  
  retry_on GoodJob::InterruptError, wait: 0, attempts: Float::INFINITY

  def perform(resource)
    # Work that might fail...
    
    # Check if interrupted
    return if good_job_interrupt?
  end
end
```

## Common Job Types

### Email Jobs

```ruby
class EmailJob < ApplicationJob
  queue_as :mailers

  def perform(mail_template, recipient, variables = {})
    MailTemplateMailer.send_template(
      mail_template,
      recipient,
      variables
    ).deliver_now
  end
end

# Usage
EmailJob.perform_later('welcome_email', user, { name: user.name })
```

### Data Processing

```ruby
class DataImportJob < ApplicationJob
  queue_as :low

  def perform(import_file_path)
    CSV.foreach(import_file_path, headers: true) do |row|
      # Check for interruption on long-running jobs
      break if GoodJob.current_thread_running_job&.reload&.finished_at?
      
      process_row(row)
    end
  end

  private

  def process_row(row)
    User.create!(
      email: row['email'],
      name: row['name']
    )
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "Import error: #{e.message}"
  end
end
```

### Cleanup Jobs

```ruby
class CleanupJob < ApplicationJob
  queue_as :maintenance

  def perform
    # Clean old logs
    Log.where('created_at < ?', 30.days.ago).destroy_all
    
    # Clean expired sessions
    Session.expired.destroy_all
    
    # Clean temporary files
    Dir.glob(Rails.root.join('tmp', 'uploads', '*')).each do |file|
      File.delete(file) if File.mtime(file) < 1.day.ago
    end
  end
end
```

## Scheduled Jobs (Cron)

### Configuration

```ruby
# config/initializers/good_job.rb
Rails.application.configure do
  config.good_job.enable_cron = true
  config.good_job.cron = {
    daily_cleanup: {
      cron: "0 2 * * *",  # 2 AM daily
      class: "CleanupJob"
    },
    hourly_sync: {
      cron: "0 * * * *",  # Every hour
      class: "DataSyncJob"
    },
    weekly_report: {
      cron: "0 9 * * 1",  # Monday 9 AM
      class: "WeeklyReportJob",
      args: ['admin@example.com']
    }
  }
end
```

### Cron Job Example

```ruby
class DailyReportJob < ApplicationJob
  queue_as :scheduled

  def perform(date = Date.current)
    report = generate_report(date)
    
    Admin.all.each do |admin|
      AdminMailer.daily_report(admin, report).deliver_later
    end
  end

  private

  def generate_report(date)
    {
      new_users: User.where(created_at: date.all_day).count,
      posts_published: Post.where(published_at: date.all_day).count,
      total_revenue: Order.completed.where(created_at: date.all_day).sum(:total)
    }
  end
end
```

## Monitoring

### Web Dashboard

Access the GoodJob dashboard at `/admin/good_job`:

Features:
- **Jobs** - View all jobs (pending, running, finished)
- **Cron** - See scheduled jobs
- **Processes** - Monitor worker processes  
- **Performance** - Execution statistics

### Dashboard Customization

```ruby
# config/routes.rb
authenticate :user, lambda { |u| u.has_role?(:admin) } do
  mount GoodJob::Engine => 'admin/good_job'
end

# config/initializers/good_job.rb
GoodJob::Engine.middleware.use(Rack::Auth::Basic) do |username, password|
  username == 'admin' && password == 'secret'
end
```

### Job Statistics

```ruby
# Get job counts
GoodJob::Job.count
GoodJob::Job.finished.count
GoodJob::Job.running.count
GoodJob::Job.queued.count
GoodJob::Job.retried.count
GoodJob::Job.discarded.count

# Performance metrics
GoodJob::Job.finished.average(:duration)
GoodJob::Job.where(job_class: 'EmailJob').average(:duration)

# Queue statistics
GoodJob::Job.queued.group(:queue_name).count
```

## Error Handling

### Retry Configuration

```ruby
class CriticalJob < ApplicationJob
  # Exponential backoff
  retry_on NetworkError, wait: :exponentially_longer, attempts: 5
  
  # Custom retry logic
  retry_on CustomError do |job, error|
    if job.executions < 3
      job.retry_job(wait: 10.seconds * job.executions)
    else
      job.discard_job("Too many failures: #{error.message}")
    end
  end

  def perform(data)
    # Work that might fail
  rescue StandardError => e
    # Custom error handling
    ErrorNotifier.notify(e, job_id: job_id)
    raise
  end
end
```

### Error Notifications

```ruby
class ApplicationJob < ActiveJob::Base
  around_perform do |job, block|
    block.call
  rescue StandardError => e
    # Log error
    Rails.logger.error "Job failed: #{job.class} - #{e.message}"
    
    # Send notification
    if job.executions >= 3
      AdminMailer.job_failure_notification(
        job_class: job.class.name,
        job_id: job.job_id,
        error: e.message
      ).deliver_later
    end
    
    raise
  end
end
```

## Performance Optimization

### Queue Prioritization

```ruby
# config/good_job.yml
production:
  queues: "urgent:5;default:3;low:1;maintenance:1"
  
# High priority job
class UrgentJob < ApplicationJob
  queue_as :urgent
  self.priority = -10  # Lower number = higher priority
end

# Low priority job  
class BatchJob < ApplicationJob
  queue_as :low
  self.priority = 10
end
```

### Batch Processing

```ruby
class BatchProcessJob < ApplicationJob
  queue_as :batch

  def perform(batch_id)
    items = Item.where(batch_id: batch_id).find_in_batches(batch_size: 100)
    
    items.each do |batch|
      # Process in transactions
      ActiveRecord::Base.transaction do
        batch.each { |item| process_item(item) }
      end
      
      # Allow interruption between batches
      return if good_job_interrupt?
    end
  end
end
```

### Connection Pooling

```ruby
# config/database.yml
production:
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } + (ENV.fetch("GOOD_JOB_MAX_THREADS") { 5 }) %>
```

## Testing Jobs

### Unit Tests

```ruby
RSpec.describe SendWelcomeEmailJob do
  describe '#perform' do
    let(:user) { create(:user) }

    it 'sends welcome email' do
      expect {
        SendWelcomeEmailJob.perform_now(user)
      }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it 'includes user name in email' do
      SendWelcomeEmailJob.perform_now(user)
      
      mail = ActionMailer::Base.deliveries.last
      expect(mail.body).to include(user.name)
    end
  end
end
```

### Integration Tests

```ruby
RSpec.describe 'User Registration', type: :system do
  it 'sends welcome email after registration' do
    perform_enqueued_jobs do
      visit sign_up_path
      
      fill_in 'Email', with: 'newuser@example.com'
      fill_in 'Password', with: 'password123'
      click_button 'Sign Up'
      
      expect(ActionMailer::Base.deliveries.last.to)
        .to include('newuser@example.com')
    end
  end
end
```

### Testing Scheduled Jobs

```ruby
RSpec.describe 'Cron Jobs' do
  describe 'daily_cleanup' do
    it 'runs cleanup job at 2 AM' do
      expect(CleanupJob).to receive(:perform_later)
      
      GoodJob::Cron.tap(&:disable).tap(&:enable)
      GoodJob::Cron.send(:task, :daily_cleanup).send(:run)
    end
  end
end
```

## Best Practices

### 1. Idempotent Jobs

Make jobs safe to retry:

```ruby
class IdempotentJob < ApplicationJob
  def perform(order_id)
    order = Order.find(order_id)
    
    # Skip if already processed
    return if order.processed?
    
    order.with_lock do
      return if order.processed?
      
      order.process!
      order.update!(processed: true)
    end
  end
end
```

### 2. Job Timeouts

Set reasonable timeouts:

```ruby
class LongRunningJob < ApplicationJob
  # GoodJob timeout
  def self.good_job_timeout
    10.minutes
  end

  def perform
    # Long running work...
  end
end
```

### 3. Monitoring

Add instrumentation:

```ruby
class InstrumentedJob < ApplicationJob
  def perform(data)
    start_time = Time.current
    
    # Do work...
    
    duration = Time.current - start_time
    Rails.logger.info "Job completed in #{duration}s"
    
    StatsD.timing('jobs.duration', duration, tags: ["job:#{self.class.name}"])
  end
end
```

### 4. Resource Limits

Prevent memory issues:

```ruby
class MemoryIntensiveJob < ApplicationJob
  def perform(large_dataset_id)
    Dataset.find(large_dataset_id).records.find_in_batches(batch_size: 100) do |batch|
      batch.each { |record| process_record(record) }
      
      # Force garbage collection if needed
      GC.start if GC.stat[:heap_live_slots] > 1_000_000
    end
  end
end
```

## Troubleshooting

### Jobs Not Running

```ruby
# Check worker processes
GoodJob::Process.all

# Check for locked jobs
GoodJob::Job.running.where('performed_at < ?', 5.minutes.ago)

# Unlock stuck jobs
GoodJob::Job.running.where('performed_at < ?', 1.hour.ago).update_all(
  finished_at: Time.current,
  error: "Forcefully unlocked"
)
```

### Performance Issues

```ruby
# Find slow jobs
GoodJob::Job.finished
  .where('duration > ?', 60)
  .order(duration: :desc)

# Queue depth
GoodJob::Job.queued.group(:queue_name).count

# Clear old jobs
GoodJob::Job.finished.where('created_at < ?', 30.days.ago).destroy_all
```

## Next Steps

- Explore the [Design System](design-system.md)
- Configure [Email Templates](email-templates.md) for job notifications
- Set up monitoring in the [Admin Panel](admin-panel.md)