describe Posts::DestroyCommand, type: :command do
  subject { described_class.call(id: post.id, current_user: admin) }

  let!(:admin) { create(:user, :superadmin) }
  let!(:post) { create(:post) }

  it "broadcasts ok" do
    expect { subject }.to broadcast(:ok)
  end

  it "destroys post" do
    expect { subject }.to change(Post, :count).by(-1)
    expect { post.reload }.to raise_error(ActiveRecord::RecordNotFound)
  end
end
