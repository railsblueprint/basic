# Working in this repository

This is the basic edition of Rails Blueprint: a Rails application template sold as a product.
It is not a deployed application. What ships is the repository itself, and a customer starts
from it with `rails blueprint:init[name]`.

## The things that will bite

### The default branch is not master

Work lands on this edition's `blueprint-*-master` branch. Read its name rather than assuming it:

```sh
gh repo view --json defaultBranchRef --jq .defaultBranchRef.name
```

`origin/master` exists in some editions and is stale. Never branch from it, diff against it or
open a pull request against it. Pull requests go against the branch the command above prints, and
CI only runs for pull requests whose base is that branch.

### Changes propagate down a chain

Every edition-wide change is filed against basic and flows from there:

    basic -> plus (merge) -> pro (rebase) -> saas -> demos

Plus merges `basic/blueprint-basic-master`. Pro rebases on `origin/blueprint-plus-master` after
syncing the fork. Saas follows pro, and each demo repository follows its edition. A change made
directly in a lower edition is overwritten or conflicts on the next propagation, so fix it in
basic unless it only exists in that edition. This file is carried down the chain unchanged, which
is why it does not name this edition's default branch.

Commit messages carry the edition prefix: `[RailsBlueprint Basic]`, `[RailsBlueprint Plus]`,
`[RailsBlueprint Pro]`, `[RailsBlueprint SaaS]`.

### A bare checkout cannot boot

`rails blueprint:init` renders these from their `*.template` siblings, and none of them are
tracked in the edition repositories: `config/app.yml`, `config/app_config.rb`, `config/cable.yml`,
`config/database.yml`, `config/storage.yml`, `config/importmap.rb`, `config/i18n-tasks.yml`,
`config/newrelic.yml`, `config/schedule.rb`, `config/deploy.rb`, `config/deploy/*.rb`,
`config/credentials.yml.enc`, `config/credentials/{staging,production}.yml.enc`, `package.json`
and `.env`. Together with `config/master.key`, the credentials keys, `node_modules` and the
compiled CSS in `app/assets/builds`, none of them reach a worktree cut from the default branch.

Who commits the rendered files depends on which repository you are in. A project started from
the template, and each demo repository, commits them: that is what the README's post-init
`git add . ; git commit -a` step is for, and `.blueprint_templates`, which `blueprint:init` writes
to track template versions, is committed with them. The edition repositories (basic, plus, pro,
saas) never commit any of them, because a rendered file in an edition would propagate down the
chain as somebody's private configuration. `.gitignore` covers only `.env`, `config/master.key`
and the credentials keys; the rendered files and `.blueprint_templates` are kept out of an
edition checkout through its `.git/info/exclude`, one line per file, which worktrees share with
the checkout they were cut from. A fresh clone of an edition has none of those entries, so after
`blueprint:init` add each rendered file and `.blueprint_templates` to `.git/info/exclude`
yourself, or they show up as untracked.

Do not run `blueprint:init` in a worktree: it prompts, and it renders new credentials and keys.
Link the files from the primary checkout instead. From inside any worktree:

```sh
PRIMARY=$(dirname "$(git rev-parse --git-common-dir)")
for f in config/master.key .env node_modules; do [ -e "$f" ] || ln -s "$PRIMARY/$f" "$f"; done
for t in $(git ls-files '*.template'); do f=${t%.template}; [ -e "$f" ] || ln -s "$PRIMARY/$f" "$f"; done
for f in config/credentials/staging.key config/credentials/production.key; do [ -e "$f" ] || [ ! -e "$PRIMARY/$f" ] || ln -s "$PRIMARY/$f" "$f"; done
rm -f config/database.yml && cp "$PRIMARY/config/database.yml" config/database.yml
bundle exec rails dartsass:build
```

Every `ln -s` is guarded by `[ -e ]` on purpose. Re-running an unguarded `ln -s` against an
existing link to a directory creates the link inside the target, which for `node_modules` writes a
self-referential loop into the primary checkout where `git status` cannot see it.

`config/database.yml` is copied rather than linked so it can be edited locally: in plus, pro and
saas the primary's copy is itself a symlink into the demo repository. After copying, make sure the
test database name ends in `<%= ENV.fetch("TEST_ENV_NUMBER", "") %>`, so the suite can be pointed
at a database of its own (see below). If the copied file lacks the suffix, add it:

```sh
ruby -pi -e 'sub(/^(  database: \S+_test)$/, %q(\1<%= ENV.fetch("TEST_ENV_NUMBER", "") %>))' config/database.yml
```

`.env` is a link to the primary checkout's own file. Never write to it; export a variable on the
command line instead. `app/assets/builds` is tracked (it holds a `.keep`), so never replace it
with a link and never copy it from another checkout: build it in place with `dartsass:build`, and
again after any rebase that brings in a stylesheet change.

### The test database is shared unless you say otherwise

The test database is the one named in `config/database.yml`. With the suffix above, setting
`TEST_ENV_NUMBER` selects a separate database for that run, so several worktrees can run the
suite at once. Carry the variable on every command that touches a database, migrations and
`db:test:prepare` included:

```sh
TEST_ENV_NUMBER=2 bundle exec rails db:test:prepare
TEST_ENV_NUMBER=2 bundle exec rspec
TEST_ENV_NUMBER=2 RAILS_ENV=test bundle exec rails db:migrate
```

Without it two runs share the unsuffixed database, and each one's reset lands in the middle of
the other's suite. It shows up as unrelated failing specs rather than as an error, and
`db/schema.rb` can come back carrying columns from somebody else's migration. Never commit a
`db/schema.rb` change your own migration did not cause.

## Build & test

Fresh clone:

```sh
bundle install
yarn install
bundle exec rails blueprint:init[name]
bundle exec rails db:create db:schema:load
bundle exec rails dartsass:build
```

`blueprint:init` asks for the short application name when it is not given as the argument, and
writes the rendered files listed above plus `config/master.key` and the credentials keys. Its
second, optional argument is the repository's default branch (`blueprint:init[name,main]`); when
it is left out the current branch is used, and the task asks on a detached HEAD. It rewrites the
`rubocop_dev_branch` literal in `lib/tasks/rubocop.rake` and the `branches` lists under `on:` in
`.github/workflows/rails.yml` to that name, only when they differ. Run it once, on a fresh clone. On an existing checkout it prompts for every rendered file, `.env`
included, whose content differs from what the template renders now, and pressing Enter at that
prompt overwrites the file; only `config/master.key`, the credentials keys and the `.yml.enc`
files are skipped when present.

Check:

```sh
bundle exec rspec
bundle exec rubocop
bundle exec rake rubocop:changed
```

`rubocop:changed` lints only the files that differ from the merge base with the default branch, so
it sees committed changes and nothing uncommitted. The branch it diffs against is `GITHUB_BASE_REF`
when set, then `RUBOCOP_DEV_BRANCH`, then the literal in `lib/tasks/rubocop.rake`.

CI runs for every push to the default branch and every pull request against it, on the runner
named by the `CI_RUNNER` repository variable (a JSON `runs-on` value; the edition repositories
point it at the self-hosted runner, and a repository without it gets GitHub-hosted runners). It copies the `config/*.ci` files over the rendered ones, so the suite there runs
against `config/database.yml.ci` and the `POSTGRES_*` variables rather than anything from
`blueprint:init`. The steps, in order: `rake rubocop:changed`, `db:create` and `db:schema:load`,
`zeitwerk:check`, `dartsass:build`, the full `rspec` suite, then `bundle-audit` and
`bin/importmap audit`. A second job, switched on by the `BLUEPRINT_TEMPLATE` repository variable
that only the edition repositories carry, runs `blueprint:init[test_app,main]` on a clean checkout,
asserts the branch rewrite and a working `rubocop:changed`, and migrates against it, so a change to
a template or to `lib/tasks/blueprint.rake` is exercised there rather than only in the main job.
