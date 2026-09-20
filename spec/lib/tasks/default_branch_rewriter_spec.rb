require "rails_helper"
require "rake"

Rails.application.load_tasks unless Rake::Task.task_defined?("blueprint:init")

RSpec.describe DefaultBranchRewriter do
  let(:root) { Dir.mktmpdir }
  let(:rubocop_task) { File.join(root, DefaultBranchRewriter::RUBOCOP_TASK) }
  let(:workflow) { File.join(root, DefaultBranchRewriter::WORKFLOW) }

  before do
    [DefaultBranchRewriter::RUBOCOP_TASK, DefaultBranchRewriter::WORKFLOW].each do |file|
      FileUtils.mkdir_p(File.dirname(File.join(root, file)))
      FileUtils.cp(Rails.root.join(file), File.join(root, file))
    end
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
      .to eq(["    branches: [ main ]", "    branches: [ main ]"])
  end

  it "leaves every other line alone" do
    rubocop_before = File.readlines(rubocop_task)
    workflow_before = File.readlines(workflow)

    described_class.new("main", root:).call

    rubocop_after = File.readlines(rubocop_task)
    workflow_after = File.readlines(workflow)
    expect(rubocop_after.size).to eq(rubocop_before.size)
    expect(workflow_after.size).to eq(workflow_before.size)
    expect(rubocop_after.reject { |l| l.start_with?("rubocop_dev_branch = ") })
      .to eq(rubocop_before.reject { |l| l.start_with?("rubocop_dev_branch = ") })
    expect(workflow_after.grep_v(/^\s+branches: \[/)).to eq(workflow_before.grep_v(/^\s+branches: \[/))
    expect(workflow_after.grep(/runs-on:/)).to eq(workflow_before.grep(/runs-on:/))
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
