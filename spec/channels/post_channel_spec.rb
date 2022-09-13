RSpec.describe PostChannel do
  let(:post) { create(:post) }

  before do
    stub_connection
  end

  it "subscribes" do
    subscribe(id: post.id)

    expect(subscription).to be_confirmed
  end

  it "streams for fiven post" do
    subscribe(id: post.id)

    expect(subscription).to have_stream_for(post)
  end
end
