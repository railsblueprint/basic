class TemplateDeviseMailer < Devise::Mailer
  helper :application # gives access to all helpers defined within `application_helper`.
  include Devise::Controllers::UrlHelpers # Optional. eg. `confirmation_url`
  include ApplicationHelper # Optional. eg. `confirmation_url`
  include Rails.application.routes.url_helpers

  def confirmation_instructions(record, token, _opts={})
    TemplateMailer.email(:confirmation_instructions, {
      to:               record.email,
      user:             record,
      confirmation_url: user_confirmation_url(confirmation_token: token)
    }).deliver_later
  end

  def reset_password_instructions(record, token, _opts={})
    reset_url = edit_user_password_url(reset_password_token: token)

    TemplateMailer.email(:reset_password_instructions, {
      to:        record.email,
      user:      record,
      token:,
      reset_url:
    }).deliver_later
  end

  def unlock_instructions(record, token, _opts={})
    unlock_url = unlock_url(record, unlock_token: token)

    TemplateMailer.email(:unlock_instructions, {
      to:         record.email,
      user:       record,
      token:,
      unlock_url:
    }).deliver_later
  end

  def email_changed(record, _opts={})
    TemplateMailer.email(:email_changed, {
      to:   record.email,
      user: record
    }).deliver_later
  end

  def password_change(record, _opts={})
    TemplateMailer.email(:password_change, {
      to:   record.email,
      user: record
    }).deliver_later
  end
end
