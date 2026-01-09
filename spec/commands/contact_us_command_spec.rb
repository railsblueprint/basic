describe ContactUsCommand, type: :command do
  subject { described_class.new(params) }

  let(:params) { { name: "456", email: "abcd@dot.com", subject: "help", message: "me please" } }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:email) }
  it { is_expected.to validate_presence_of(:subject) }
  it { is_expected.to validate_presence_of(:message) }

  it "broadcasts ok" do
    expect { subject.call }.to broadcast(:ok)
  end

  it "sends email" do
    expect(TemplateMailer).to receive(:email).with(:contact_form_message, anything).and_call_original
    subject.call
  end

  context "with honeypot field filled (bot submission)" do
    let(:params) do
      {
        name: "Bot", email: "bot@spam.com", subject: "spam", message: "buy now",
        website: "http://spam.com"
      }
    end

    it "broadcasts ok" do
      expect { subject.call }.to broadcast(:ok)
    end

    it "does not send email" do
      expect(TemplateMailer).not_to receive(:email)
      subject.call
    end

    it "logs the bot submission" do
      expect(Rails.logger).to receive(:warn).with(/\[HONEYPOT\] Bot submission detected/)
      subject.call
    end
  end

  context "with empty honeypot field (legitimate submission)" do
    let(:params) do
      {
        name: "User", email: "user@test.com", subject: "help", message: "me please",
        website: ""
      }
    end

    it "sends email" do
      expect(TemplateMailer).to receive(:email).with(:contact_form_message, anything).and_call_original
      subject.call
    end
  end
end
