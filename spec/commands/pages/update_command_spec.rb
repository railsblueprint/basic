describe Pages::UpdateCommand, type: :command do
  subject { described_class.new(params.merge(id: page.id, current_user: admin)) }

  let(:admin) { create(:user, :superadmin) }
  let(:user) { create(:user) }
  let(:page) { create(:page) }
  let(:params) { { title: "Title", body: "Text", url: "zzz" } }

  it { is_expected.to validate_presence_of(:url) }
  it { is_expected.to validate_presence_of(:title) }

  it "broadcasts ok" do
    expect { subject.call }.to broadcast(:ok)
  end

  it "updates user attributes", :aggregate_failures do
    subject.call
    page.reload

    expect(page.title).to eq("Title")
    expect(page.body.to_s).to eq("Text")
    expect(page.url).to eq("zzz")
  end
end
