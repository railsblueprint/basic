describe Users::CreateCommand, type: :command do
  subject { command.call }

  let(:command) { described_class.new(params.merge(current_user: admin)) }
  let!(:admin) { create(:user, :admin) }
  let(:params) { { first_name: "John", last_name: "Doe", email: "new_user@example.com" } }

  it "broadcasts ok" do
    expect { subject }.to broadcast(:ok)
  end

  it "creates a new user" do
    expect { subject }.to change(User, :count).by(1)
  end

  context "with role_ids" do
    let(:editor_role) { create(:role, name: "editor") }
    let(:moderator_role) { create(:role, name: "moderator") }

    context "when creating user with roles" do
      let(:params) do
        { first_name: "John", last_name: "Doe", email: "new_user@example.com",
          role_ids: [editor_role.id, moderator_role.id] }
      end

      it "creates user with assigned roles" do
        expect { subject }.to broadcast(:ok)
        user = User.find_by(email: "new_user@example.com")
        expect(user).to be_present
        expect(user.role_ids.sort).to eq([editor_role.id, moderator_role.id].sort)
      end
    end

    context "when role_ids contains empty strings" do
      let(:params) do
        { first_name: "John", last_name: "Doe", email: "new_user@example.com",
          role_ids: ["", editor_role.id, "", moderator_role.id, ""] }
      end

      it "filters out empty strings and creates user with valid roles" do
        expect { subject }.to broadcast(:ok)
        user = User.find_by(email: "new_user@example.com")
        expect(user).to be_present
        expect(user.role_ids.sort).to eq([editor_role.id, moderator_role.id].sort)
      end
    end

    context "when role_ids is empty array" do
      let(:params) { { first_name: "John", last_name: "Doe", email: "new_user@example.com", role_ids: [] } }

      it "creates user without any roles" do
        expect { subject }.to broadcast(:ok)
        user = User.find_by(email: "new_user@example.com")
        expect(user).to be_present
        expect(user.role_ids).to eq([])
      end
    end

    context "when role_ids is array with only empty strings" do
      let(:params) { { first_name: "John", last_name: "Doe", email: "new_user@example.com", role_ids: ["", "", ""] } }

      it "creates user without any roles" do
        expect { subject }.to broadcast(:ok)
        user = User.find_by(email: "new_user@example.com")
        expect(user).to be_present
        expect(user.role_ids).to eq([])
      end
    end
  end
end
