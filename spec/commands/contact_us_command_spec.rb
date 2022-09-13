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
end
