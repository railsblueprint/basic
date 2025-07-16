RSpec.describe Users::UpdatePasswordCommand do
  let(:user) { create(:user) }
  let(:admin) { create(:user, :superadmin) }
  let(:valid_attributes) do
    {
      current_user:          admin,
      id:                    user.id,
      password:              "newpassword123",
      password_confirmation: "newpassword123"
    }
  end

  describe "#process" do
    context "with valid attributes" do
      it "updates the user's password" do
        command = described_class.new(valid_attributes)
        expect(command).to be_valid
        command.call

        user.reload
        expect(user.valid_password?("newpassword123")).to be true
      end
    end

    context "with mismatched passwords" do
      it "fails validation" do
        attributes = valid_attributes.merge(password_confirmation: "different")
        command = described_class.new(attributes)

        expect(command).not_to be_valid
        expect(command.errors[:password_confirmation]).to include("does not match password")
      end
    end

    context "with short password" do
      it "fails validation" do
        attributes = valid_attributes.merge(password: "short", password_confirmation: "short")
        command = described_class.new(attributes)

        expect(command).not_to be_valid
        expect(command.errors[:password]).to include("is too short (minimum is 6 characters)")
      end
    end

    context "without id" do
      it "fails validation" do
        attributes = valid_attributes.merge(id: nil)
        command = described_class.new(attributes)

        expect(command).not_to be_valid
        expect(command.errors[:id]).to include("can't be blank")
      end
    end
  end

  describe "#authorized?" do
    context "when user can change password" do
      it "returns true" do
        command = described_class.new(valid_attributes)
        expect(command.authorized?).to be true
      end
    end

    context "when user cannot change password" do
      it "returns false" do
        regular_user = create(:user)
        attributes = valid_attributes.merge(current_user: regular_user)
        command = described_class.new(attributes)
        expect(command.authorized?).to be false
      end
    end
  end
end
