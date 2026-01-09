class ContactUsCommand < BaseCommand
  attribute :name, Types::String
  attribute :email, Types::String
  attribute :subject, Types::String
  attribute :message, Types::String
  # Honeypot field - hidden from users, filled by bots
  attribute :website, Types::String.optional

  validates_presence_of :name, :email, :subject, :message

  def process
    if bot_submission?
      log_bot_submission
    else
      send_notification
    end
  end

  private

  def bot_submission?
    website.present?
  end

  def log_bot_submission
    Rails.logger.warn(
      "[HONEYPOT] Bot submission detected - " \
      "name: #{name}, email: #{email}, subject: #{subject}, website: #{website}"
    )
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
