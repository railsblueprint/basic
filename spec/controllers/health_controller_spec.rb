require "rails_helper"

RSpec.describe HealthController do
  describe "GET #show" do
    it "returns health status" do
      get :show
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to eq("application/json; charset=utf-8")
    end

    it "returns expected JSON structure" do
      get :show
      json = response.parsed_body

      expect(json).to have_key("status")
      expect(json).to have_key("version")
      expect(json).to have_key("git_revision")
      expect(json).to have_key("timestamp")

      expect(json["status"]).to eq("ok")
      expect(json["version"]).to be_a(Hash)
      expect(json["git_revision"]).to be_a(String)
      expect(json["timestamp"]).to be_a(String)
    end

    it "returns version information from all VERSION_* files" do
      get :show
      json = response.parsed_body

      # Should have at least basic version
      expect(json["version"]).to have_key("basic")
      expect(json["version"]["basic"]).to match(/^\d+\.\d+\.\d+$/)

      # Should only contain versions for files that actually exist
      expected_versions = Rails.root.glob("VERSION_*").map do |file|
        File.basename(file).gsub("VERSION_", "").downcase
      end

      expect(json["version"].keys).to match_array(expected_versions)
    end

    it "returns git revision" do
      get :show
      json = response.parsed_body

      expect(json["git_revision"]).not_to be_empty
      expect(json["git_revision"]).to be_a(String)
      # In test environment, git revision might be 'unknown' or actual git hash
      expect(json["git_revision"]).to match(/\A[a-f0-9]{40}\z|unknown\z/)
    end

    it "returns valid timestamp" do
      get :show
      json = response.parsed_body

      timestamp = Time.zone.parse(json["timestamp"])
      expect(timestamp).to be_within(1.second).of(Time.current)
    end
  end
end
