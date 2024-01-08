describe Settings::CreateCommand, type: :command do
  subject { described_class.new(params.merge(current_user: admin)) }

  let(:admin) { create(:user, :superadmin) }
  let(:user) { create(:user) }

  let(:params) { { key: "zzzz", type: "string", value: "value", description: "description" } }

  before do
    allow(Rails.env).to receive(:development?).and_return(true)
  end

  it { is_expected.to validate_presence_of(:key) }
  it { is_expected.to validate_presence_of(:type) }
  it { is_expected.to validate_presence_of(:description) }

  it "broadcasts ok" do
    expect { subject.call }.to broadcast(:ok)
  end

  it "creates a new page" do
    expect { subject.call }.to change(Setting, :count).by(1)
  end
end
