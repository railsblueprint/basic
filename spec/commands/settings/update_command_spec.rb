describe Settings::UpdateCommand, type: :command do
  subject { described_class.new(params.merge(id: setting.id, current_user: admin)) }

  let(:admin) { create(:user, :superadmin) }
  let(:user) { create(:user) }
  let(:setting) { create(:setting) }
  let(:params) { { alias: "zzzz", type: "string", value: "value", description: "description" } }

  before do
    allow(Rails.env).to receive(:development?).and_return(true)
  end

  it { is_expected.to validate_presence_of(:alias) }
  it { is_expected.to validate_presence_of(:type) }
  it { is_expected.to validate_presence_of(:description) }

  it "broadcasts ok" do
    expect { subject.call }.to broadcast(:ok)
  end

  it "updates setting attributes", :aggregate_failures do
    subject.call
    setting.reload

    expect(setting.alias).to eq("zzzz")
    expect(setting.type).to eq("string")
    expect(setting.value).to eq("value")
    expect(setting.description).to eq("description")
  end
end
