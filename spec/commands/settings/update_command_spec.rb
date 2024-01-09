describe Settings::UpdateCommand, type: :command do
  subject { described_class.new(params.merge(id: setting.id, current_user: admin)).no_exceptions! }

  let(:admin) { create(:user, :superadmin) }
  let(:user) { create(:user) }
  let(:setting) { create(:setting) }
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

  it "updates setting attributes", :aggregate_failures do
    subject.call
    setting.reload

    expect(setting.key).to eq("zzzz")
    expect(setting.type).to eq("string")
    expect(setting.value).to eq("value")
    expect(setting.description).to eq("description")
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
