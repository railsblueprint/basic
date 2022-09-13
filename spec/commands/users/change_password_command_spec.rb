describe Users::ChangePasswordCommand, type: :command do
  subject { described_class.new(params.merge(user:, current_user: user)).no_exceptions! }

  let(:admin) { create(:user, :admin) }
  let(:user) { create(:user, password: "12345678") }
  let(:params) { { password: "456789", password_confirmation: "456789", current_password: "12345678" } }

  it { is_expected.to validate_presence_of(:user) }
  it { is_expected.to validate_presence_of(:password) }
  it { is_expected.to validate_presence_of(:password_confirmation) }
  it { is_expected.to validate_presence_of(:current_password) }

  it "broadcasts ok" do
    expect { subject.call }.to broadcast(:ok)
  end

  context "when current password is not valid" do
    let(:params) { { password: "456", password_confirmation: "456", current_password: "8765432321" } }

    it "broadcasts invalid" do
      expect { subject.call }.to broadcast :invalid, errors_exactly(
        current_password: :invalid
      )
    end
  end

  context "when new password is not valid" do
    let(:params) { { password: "456", password_confirmation: "456", current_password: "12345678" } }

    it "broadcasts abort" do
      expect { subject.call }.to broadcast :abort, errors_exactly(
        password: :too_short
      )
    end
  end
end
