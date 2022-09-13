rubocop_dev_branch = "blueprint-basic-master"
rubocop_arguments = "--display-cop-names --extra-details --force-exclusion"

# rubocop:disable Rails/RakeEnvironment, Metrics/BlockLength
desc "Run rubocop on all files"
task :rubocop do
  sh "bundle exec rubocop #{rubocop_arguments}"
end

namespace :rubocop do
  desc "Run rubocop on all files and auto-fix"
  task :fix do
    sh "bundle exec rubocop -a #{rubocop_arguments}"
  end

  desc "Run rubocop on modified files"
  task :changed do
    current_branch = ENV["CI_COMMIT_REF_NAME"] || ENV["GIT_BRANCH"] || `git branch --show-current`
    if current_branch == rubocop_dev_branch
      puts "Skipping rubocop on default branch"
    else
      branch = `git merge-base --fork-point #{rubocop_dev_branch}`.strip
      sh "git diff-tree -r --no-commit-id --name-only #{branch} HEAD --diff-filter=ACMR | " \
         "xargs bundle exec rubocop #{rubocop_arguments}"
    end
  end

  namespace :changed do
    desc "Run rubocop on modified files and auto-fix"
    task :fix do
      current_branch = ENV["CI_COMMIT_REF_NAME"] || ENV["GIT_BRANCH"] || `git branch --show-current`
      if current_branch == rubocop_dev_branch
        puts "Skipping rubocop on default branch"
      else
        branch = `git merge-base --fork-point #{rubocop_dev_branch}`.strip
        sh "git diff-tree -r --no-commit-id --name-only #{branch} HEAD --diff-filter=ACMR | " \
           "xargs bundle exec rubocop -a #{rubocop_arguments}"
      end
    end
  end
end
# rubocop:enable Rails/RakeEnvironment, Metrics/BlockLength
