RSpec.describe TemplateDeviseMailer do
  let(:user) { create(:user) }

  let(:token) { SecureRandom.uuid }

  describe "#confirmation_instructions" do
    it "calls template mailer with correct parameters" do
      expect(TemplateMailer).to receive(:email).with(:confirmation_instructions, {
        to:               user.email,
        user:,
        confirmation_url: String
      }).and_return(instance_double(ActionMailer::MessageDelivery, deliver_later: true))

      described_class.confirmation_instructions(user, token).deliver
    end
  end

  describe "#reset_password_instructions" do
    it "calls template mailer with correct parameters" do
      expect(TemplateMailer).to receive(:email).with(:reset_password_instructions, {
        to:        user.email,
        user:,
        token:,
        reset_url: String
      }).and_return(instance_double(ActionMailer::MessageDelivery, deliver_later: true))

      described_class.reset_password_instructions(user, token).deliver
    end
  end

  describe "#unlock_instructions" do
    it "calls template mailer with correct parameters" do
      expect(TemplateMailer).to receive(:email).with(:unlock_instructions, {
        to:         user.email,
        user:,
        token:,
        unlock_url: String
      }).and_return(instance_double(ActionMailer::MessageDelivery, deliver_later: true))

      described_class.unlock_instructions(user, token).deliver
    end
  end

  describe "#email_changed" do
    it "calls template mailer with correct parameters" do
      expect(TemplateMailer).to receive(:email).with(:email_changed, {
        to:   user.email,
        user:
      }).and_return(instance_double(ActionMailer::MessageDelivery, deliver_later: true))

      described_class.email_changed(user).deliver
    end
  end

  describe "#password_change" do
    it "calls template mailer with correct parameters" do
      expect(TemplateMailer).to receive(:email).with(:password_change, {
        to:   user.email,
        user:
      }).and_return(instance_double(ActionMailer::MessageDelivery, deliver_later: true))

      described_class.password_change(user).deliver
    end
  end
end
