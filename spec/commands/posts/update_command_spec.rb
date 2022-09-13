describe Posts::UpdateCommand, type: :command do
  subject { described_class.new(params.merge(id: post.id, current_user: admin)) }

  let(:admin) { create(:user, :superadmin) }
  let(:user) { create(:user) }
  let(:post) { create(:post) }
  let(:params) { { title: "Title", body: "Text", user_id: user.id } }

  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_presence_of(:body) }

  it "broadcasts ok" do
    expect { subject.call }.to broadcast(:ok)
  end

  it "updates user attributes", :aggregate_failures do
    subject.call
    post.reload

    expect(post.title).to eq("Title")
    expect(post.body.to_s).to eq("<div class=\"trix-content\">\n  Text\n</div>\n")
    expect(post.user).to eq(user)
  end
end
