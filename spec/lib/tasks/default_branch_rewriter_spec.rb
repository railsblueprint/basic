require "rails_helper"
require "rake"

Rails.application.load_tasks unless Rake::Task.task_defined?("blueprint:init")

RSpec.describe DefaultBranchRewriter do
  let(:root) { Dir.mktmpdir }
  let(:rubocop_task) { File.join(root, DefaultBranchRewriter::RUBOCOP_TASK) }
  let(:workflow) { File.join(root, DefaultBranchRewriter::WORKFLOW) }

  let(:rubocop_fixture) do
    <<~RUBY
      require "English"

      # rubocop_dev_branch = "old"
      rubocop_dev_branch = "old"
      files = `git diff --name-only \#{rubocop_dev_branch}`
    RUBY
  end

  let(:workflow_fixture) do
    <<~YAML
      name: Rails
      on:
        push:
          branches: [ old ]
        pull_request:
          branches: [ old ]
      jobs:
        test:
          runs-on: ${{ fromJSON(vars.CI_RUNNER || '"ubuntu-latest"') }}
          steps:
            - run: echo "branches: [ old ]"
      other:
          branches: [ old ]
    YAML
  end

  before do
    FileUtils.mkdir_p(File.dirname(rubocop_task))
    FileUtils.mkdir_p(File.dirname(workflow))
    File.write(rubocop_task, rubocop_fixture)
    File.write(workflow, workflow_fixture)
  end

  after { FileUtils.remove_entry(root) }

  it "declares the task with an optional default branch argument" do
    expect(Rake::Task["blueprint:init"].arg_names).to eq([:app_name, :default_branch])
  end

  it "points rubocop and the workflow triggers at the given branch" do
    result = described_class.new("main", root:).call

    expect(result).to eq([
      "lib/tasks/rubocop.rake: default branch set to main",
      ".github/workflows/rails.yml: default branch set to main"
    ])
    expect(File.read(rubocop_task)).to match(/^rubocop_dev_branch = "main"$/)
    expect(File.read(workflow).scan(/^\s+branches: \[ .* \]$/))
      .to eq(["    branches: [ main ]", "    branches: [ main ]", "    branches: [ old ]"])
  end

  it "leaves every other line alone" do
    described_class.new("main", root:).call

    expected_rubocop = rubocop_fixture.sub(/^rubocop_dev_branch = "old"$/, 'rubocop_dev_branch = "main"')
    expected_workflow = workflow_fixture
                        .sub("push:\n    branches: [ old ]", "push:\n    branches: [ main ]")
                        .sub("pull_request:\n    branches: [ old ]", "pull_request:\n    branches: [ main ]")
    expect(File.read(rubocop_task)).to eq(expected_rubocop)
    expect(File.read(workflow)).to eq(expected_workflow)
  end

  it "does not touch the files when they already name the branch" do
    described_class.new("main", root:).call
    rubocop_mtime = File.mtime(rubocop_task)
    workflow_mtime = File.mtime(workflow)
    rubocop_content = File.read(rubocop_task)
    workflow_content = File.read(workflow)

    result = described_class.new("main", root:).call

    expect(result).to eq(["lib/tasks/rubocop.rake: unchanged", ".github/workflows/rails.yml: unchanged"])
    expect(File.read(rubocop_task)).to eq(rubocop_content)
    expect(File.read(workflow)).to eq(workflow_content)
    expect(File.mtime(rubocop_task)).to eq(rubocop_mtime)
    expect(File.mtime(workflow)).to eq(workflow_mtime)
  end
end
