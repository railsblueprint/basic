describe Settings::CreateCommand, type: :command do
  subject { described_class.new(params.merge(current_user: admin)).no_exceptions! }

  let(:admin) { create(:user, :superadmin) }
  let(:user) { create(:user) }

  let(:params) { { key: "zzzz", section: "test", type: "string", value: "value", description: "description" } }

  before do
    allow(Rails.env).to receive(:development?).and_return(true)
  end

  it { is_expected.to validate_presence_of(:key) }
  it { is_expected.to validate_presence_of(:type) }
  it { is_expected.to validate_presence_of(:description) }

  it "broadcasts ok" do
    expect { subject.call }.to broadcast(:ok)
  end

  it "creates new setting" do
    expect { subject.call }.to change(Setting, :count).by(1)
  end

  context "when type is section" do
    let(:params) { { key: "zzzz", type: "section", value: "value", description: "description" } }

    it "accepts empty section value" do
      expect { subject.call }.to broadcast(:ok)
    end
  end

  context "when type is not section" do
    let(:params) { { key: "zzzz", type: "string", value: "value", description: "description" } }

    it "checks section presence" do
      expect { subject.call }.to broadcast(:invalid, errors_exactly(section: :blank))
    end
  end
end
