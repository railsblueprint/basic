describe MailTemplates::UpdateCommand, type: :command do
  subject { described_class.new(params.merge(id: mail_template.id, current_user: admin)).no_exceptions! }

  let(:admin) { create(:user, :superadmin) }
  let(:user) { create(:user) }
  let(:mail_template) { create(:mail_template, alias: "new_template") }
  let(:params) { { alias: "new_template", layout: "simple", body: "zzz" } }

  it { is_expected.to validate_presence_of(:alias) }
  it { is_expected.to validate_presence_of(:layout) }

  it "broadcasts ok" do
    expect { subject.call }.to broadcast(:ok)
  end

  it "updates user attributes", :aggregate_failures do
    subject.call
    mail_template.reload

    expect(mail_template.alias).to eq("new_template")
    expect(mail_template.layout).to eq("simple")
    expect(mail_template.body).to eq("zzz")
  end

  context "with duplicated alias" do
    let!(:existing_template) { create(:mail_template, alias: "other_template") }
    let(:params) { { alias: "other_template", layout: "simple", body: "zzz" } }

    it "broadcasts error" do
      expect { subject.call }.to broadcast :invalid, errors_exactly(
        alias: :taken
      )
    end
  end
end
