RSpec.describe ApplicationCable::Connection do
  context "when condition" do
    it "succeeds" do
      expect { connect }.not_to raise_error
    end
  end
end
