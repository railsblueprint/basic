describe Users::UpdateCommand, type: :command do
  subject { described_class.call(params.merge(id: user.id, current_user: admin)) }

  let(:admin) { create(:user, :superadmin) }
  let(:user) { create(:user) }
  let(:params) { { first_name: "John", last_name: "Doe", email: "abcd@dot.com" } }

  before do
    allow(TemplateDeviseMailer).to receive(:confirmation_instructions)
      .and_return(instance_double(Mail::Message, deliver: true))
  end

  it "broadcasts ok" do
    expect { subject }.to broadcast(:ok)
  end

  it "updates user attributes", :aggregate_failures do
    subject
    user.reload

    expect(user.first_name).to eq("John")
    expect(user.last_name).to eq("Doe")
  end

  it "stores new email to unconfirmed_email", :aggregate_failures do
    subject
    user.reload

    expect(user.unconfirmed_email).to eq("abcd@dot.com")
  end

  context "with role_ids" do
    let(:editor_role) { create(:role, name: "editor") }
    let(:moderator_role) { create(:role, name: "moderator") }

    context "when adding roles" do
      let(:params) { { first_name: "John", role_ids: [editor_role.id, moderator_role.id] } }

      it "updates user roles" do
        expect { subject }.to change { user.reload.role_ids.sort }.to([editor_role.id, moderator_role.id].sort)
      end
    end

    context "when role_ids contains empty strings" do
      let(:params) { { first_name: "John", role_ids: ["", editor_role.id, "", moderator_role.id, ""] } }

      it "filters out empty strings and saves valid roles" do
        expect { subject }.to change { user.reload.role_ids.sort }.to([editor_role.id, moderator_role.id].sort)
      end
    end

    context "when removing all roles" do
      before do
        user.add_role(editor_role.name)
        user.add_role(moderator_role.name)
      end

      let(:params) { { first_name: "John", role_ids: [] } }

      it "removes all roles" do
        expect { subject }.to change { user.reload.role_ids }.to([])
      end
    end

    context "when role_ids is array with only empty strings" do
      let(:params) { { first_name: "John", role_ids: ["", "", ""] } }

      it "removes all roles" do
        user.add_role(editor_role.name)
        expect { subject }.to change { user.reload.role_ids }.to([])
      end
    end
  end
end
