require "rails_helper"

RSpec.describe "factories", type: :model do
  describe "post" do
    it "always builds a body with at least one paragraph" do
      50.times { expect(build(:post).body).to be_present }
    end
  end
end
