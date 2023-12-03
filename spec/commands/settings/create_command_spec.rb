describe Settings::CreateCommand, type: :command do
  let(:admin) {create(:user, :superadmin)}
  let(:user) {create(:user)}

  let(:params) { {alias: "zzzz", type: "string", value: "value", description: "description"} }

  let(:subject) { described_class.new(params.merge(current_user: admin)) }

  it { should validate_presence_of(:alias) }
  it { should validate_presence_of(:type) }
  it { should validate_presence_of(:description) }

  it "broadcasts ok" do
    expect{subject.call}.to broadcast(:ok)
  end

  it "creates a new page" do
    expect{subject.call}.to change{Setting.count}.by(1)
  end



end