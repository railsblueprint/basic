RSpec.describe BlogChannel do
  before do
    stub_connection
  end

  it "subscribes" do
    subscribe

    expect(subscription).to be_confirmed
  end

  it "streams for blog stream" do
    subscribe

    expect(subscription).to have_stream_from("blog:blog")
  end
end
