rubocop_dev_branch = "blueprint-basic-master"
rubocop_arguments = "--display-cop-names --extra-details --force-exclusion"
rubocop_base_branch = ENV["GITHUB_BASE_REF"].presence || ENV["RUBOCOP_DEV_BRANCH"].presence || rubocop_dev_branch

# The commit the current branch diverged from. Prefer the remote-tracking ref: on a CI checkout
# there is no local default branch at all, and locally the local one is often behind, so
# resolving against it either lints the whole tree or drags unrelated commits into the diff.
rubocop_base = lambda do
  remote = "origin/#{rubocop_base_branch}"
  ref = system("git rev-parse --verify -q #{remote} >/dev/null") ? remote : rubocop_base_branch
  base = `git merge-base #{ref} HEAD`.strip
  abort "rubocop:changed: no merge base between #{ref} and HEAD" if base.empty?
  base
end

# rubocop:disable Rails/RakeEnvironment
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
    current_branch = (ENV["CI_COMMIT_REF_NAME"] || ENV["GIT_BRANCH"] || `git branch --show-current`).strip
    if current_branch == rubocop_base_branch
      puts "Skipping rubocop on default branch"
    else
      # -r: with no changed files, run nothing rather than rubocop over the whole tree.
      sh "git diff --name-only --diff-filter=ACMR #{rubocop_base.call} HEAD | " \
         "xargs -r bundle exec rubocop #{rubocop_arguments}"
    end
  end

  namespace :changed do
    desc "Run rubocop on modified files and auto-fix"
    task :fix do
      current_branch = (ENV["CI_COMMIT_REF_NAME"] || ENV["GIT_BRANCH"] || `git branch --show-current`).strip
      if current_branch == rubocop_base_branch
        puts "Skipping rubocop on default branch"
      else
        sh "git diff --name-only --diff-filter=ACMR #{rubocop_base.call} HEAD | " \
           "xargs -r bundle exec rubocop -a #{rubocop_arguments}"
      end
    end
  end
end
# rubocop:enable Rails/RakeEnvironment
