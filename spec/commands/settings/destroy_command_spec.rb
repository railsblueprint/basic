describe Settings::DestroyCommand, type: :command do
  subject { described_class.call(id: setting.id, current_user: admin) }

  let!(:admin) { create(:user, :superadmin) }
  let!(:setting) { create(:setting) }

  before do
    allow(Rails.env).to receive(:development?).and_return(true)
  end

  it "broadcasts ok" do
    expect { subject }.to broadcast(:ok)
  end

  it "marks setting as deleted" do
    expect { subject }.to change { setting.reload.deleted_at }.from(nil).to(Time)
  end
end
