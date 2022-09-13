class ContactUsCommand < BaseCommand
  attribute :name, Types::String
  attribute :email, Types::String
  attribute :subject, Types::String
  attribute :message, Types::String

  validates_presence_of :name, :email, :subject, :message

  def process
    send_notification
  end

  def send_notification
    TemplateMailer.email(:contact_form_message, {
      to:           Setting.contact_form_receivers,
      reply_to:     email,
      subject:,
      sender_name:  name,
      sender_email: email,
      message:

    }).deliver_later
  end
end
