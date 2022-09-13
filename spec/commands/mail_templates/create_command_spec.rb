describe MailTemplates::CreateCommand, type: :command do
  subject { described_class.new(params.merge(current_user: admin)).no_exceptions! }

  let(:admin) { create(:user, :admin) }
  let(:user) { create(:user) }
  let(:params) { { alias: "new_template", layout: "simple", body: "zzz" } }

  it { is_expected.to validate_presence_of(:alias) }
  it { is_expected.to validate_presence_of(:layout) }

  it "broadcasts ok" do
    expect { subject.call }.to broadcast(:ok)
  end

  it "creates a new mail template" do
    expect { subject.call }.to change(MailTemplate, :count).by(1)
  end

  context "with duplicated alias" do
    let!(:existing_template) { create(:mail_template, alias: "new_template") }

    it "broadcasts error" do
      expect { subject.call }.to broadcast :invalid, errors_exactly(
        alias: :taken
      )
    end
  end
end
