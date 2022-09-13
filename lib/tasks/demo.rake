namespace :demo do
  desc "Generate migration for new settings"
  task reset: :environment do
    if ENV["DISABLE_DATABASE_ENVIRONMENT_CHECK"].blank? && Rails.env.production?
      puts "You're trying to reset production database. If you are sure what you are doing, repeat it as"
      puts "    DISABLE_DATABASE_ENVIRONMENT_CHECK=1 RAILS_ENV=production rails demo:reset"
      next
    end

    ActiveRecord::Base.connection.execute <<-SQL
      UPDATE pg_database SET datallowconn = 'false' WHERE datname = current_database();
    SQL
    ActiveRecord::Base.connection.execute <<-SQL
      SELECT pg_terminate_backend(pg_stat_activity.pid)
      FROM pg_stat_activity
      WHERE datname = current_database()
      AND pid <> pg_backend_pid();
    SQL

    Rake::Task["db:drop"].invoke
    Rake::Task["db:create"].invoke
    Rake::Task["db:migrate:with_data"].invoke
    ENV["what"] = "admin,demo"
    Rake::Task["db:seed"].invoke
  end
end
