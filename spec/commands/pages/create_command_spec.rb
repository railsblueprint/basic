describe Pages::CreateCommand, type: :command do
  subject { described_class.new(params.merge(current_user: admin)) }

  let(:admin) { create(:user, :admin) }
  let(:user) { create(:user) }
  let(:params) { { title: "Title", body: "Text", url: "zzz" } }

  it { is_expected.to validate_presence_of(:title) }

  it "broadcasts ok" do
    expect { subject.call }.to broadcast(:ok)
  end

  it "creates a new page" do
    expect { subject.call }.to change(Page, :count).by(1)
  end
end
