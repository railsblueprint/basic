describe MailTemplates::DestroyCommand, type: :command do
  subject { described_class.call(id: mail_template.id, current_user: admin) }

  let!(:admin) { create(:user, :superadmin) }
  let!(:mail_template) { create(:mail_template) }

  it "broadcasts ok" do
    expect { subject }.to broadcast(:ok)
  end

  it "destroys post" do
    expect { subject }.to change(MailTemplate, :count).by(-1)
    expect { mail_template.reload }.to raise_error(ActiveRecord::RecordNotFound)
  end
end
