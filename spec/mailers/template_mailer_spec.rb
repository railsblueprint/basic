RSpec.describe TemplateMailer do
  describe "email" do
    let(:user) { create(:user) }

    let(:mail_template) {
      create(:mail_template,
             alias:   "test_email",
             subject: "Welcome {{user_name}}",
             body:    "To our test {{email_name}}!")
    }

    let(:attachments) { {} }
    let(:params) { { to: user.email, user_name: "Joe", email_name: "Welcome mail", attachments: } }
    let(:template_name) { mail_template.alias }

    let(:mail) { described_class.email(template_name, params).deliver_now }

    let!(:sender_email) do
      Setting.create!(key: "sender_email", type: :string, value: "nobody@localhost", description: "Sender email")
    end

    it "renders the subject" do
      expect(mail.subject).to eq("Welcome Joe")
    end

    it "renders the receiver email" do
      expect(mail.to).to eq([user.email])
    end

    it "renders the sender email" do
      expect(mail.from).to eq(["nobody@localhost"])
    end

    it "generates multipart message", :aggregate_failures do
      expect(mail.body.parts.length).to eq 2
      expect(mail.body.parts.map(&:content_type)).to eq ["text/plain; charset=UTF-8", "text/html; charset=UTF-8"]
    end

    it "renders variables into the body" do
      expect(mail.body.encoded).to match("Welcome mail")
    end

    it "sends an email" do
      expect { mail }
        .to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    context "given attachments" do
      let(:attachments) {
        {
          "test_file.csv" => "a,b,c\n1,2,3\n4,5,6"
        }
      }

      it "generates multipart message", :aggregate_failures do
        # One part is message, second part is attachment

        expect(mail.body.parts.length).to eq 2
        expect(mail.body.parts.first.content_type).to include("multipart/alternative")

        # Message part has 2 versions: text/plain and text/html
        expect(mail.body.parts.first.parts.map(&:content_type)).to eq(
          ["text/plain; charset=UTF-8", "text/html; charset=UTF-8"]
        )
      end

      it "includes attachments", :aggregate_failures do
        expect(mail.attachments.size).to eq(1)

        attachment = mail.attachments.first

        expect(attachment.filename).to eq("test_file.csv")
        expect(attachment.content_type).to include("text/csv")
        expect(attachment.body).to include("a,b,c")
      end
    end

    context "when template is not found" do
      let(:template_name) { "unknown_template" }

      it "does not send email" do
        expect { mail }
          .not_to(change { ActionMailer::Base.deliveries.count })
      end

      it "logs error message" do
        expect(Rails.logger).to receive(:error)
        mail
      end

      it "sends Rollbar error message" do
        expect(Rollbar).to receive(:error)
        mail
      end
    end
  end
end
