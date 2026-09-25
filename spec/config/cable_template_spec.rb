require "rails_helper"

RSpec.describe "config/cable.yml.template", type: :task do
  let(:rendered) do
    ERB.new(Rails.root.join("config/cable.yml.template").read).result_with_hash(app_prefix: "rbp_basic")
  end

  let(:config) { YAML.safe_load(rendered) }

  it "leaves the test environment on the in-process adapter" do
    expect(config["test"]).to eq("adapter" => "test")
  end

  %w[development staging production].each do |environment|
    it "points #{environment} at the configured redis" do
      expect(config[environment]).to eq(
        "adapter"        => "redis",
        "url"            => "<%= AppConfig.redis.url %>",
        "channel_prefix" => "rbp_basic_#{environment}"
      )
    end
  end
end
