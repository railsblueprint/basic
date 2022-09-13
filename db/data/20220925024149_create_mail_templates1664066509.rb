class CreateMailTemplates1664066509 < ActiveRecord::Migration[7.0]
  def up
    unless MailTemplate.where("alias": "reset_password_instructions").any?
      MailTemplate.create(
        "alias":     "reset_password_instructions",
        subject:      "[{% t platform.name %}] Reset password request",
        body:         "<p>Hi, {{user.first_name}}!</p><p>Here is your link to reset password: <a href=\"{{reset_url}}\">{{reset_url}}</a></p>",
        layout:       "clean_html",
      )
    end
    unless MailTemplate.where("alias": "confirmation_instructions").any?
      MailTemplate.create(
        "alias":     "confirmation_instructions",
        subject:      "[{% t platform.name %}] Please confirm your email",
        body:         "<p>Welcome!</p>\n" \
          "<p>Please confirm your email here: <a href=\"{{confirmation_url}}\">{{confirmation_url}}</a></p>",
        layout:       "clean_html",
      )
    end
    unless MailTemplate.where("alias": "email_changed").any?
      MailTemplate.create(
        "alias":     "email_changed",
        subject:      "[{% t platform.name %}] Your email was changed",
        body:         "<p>Hello {{user.first_name}}!</p>\n" \
          "\n" \
          "{% if user.unconfirmed_email %}\n" \
          "  <p>We're contacting you to notify you that your email is being changed to {{user.unconfirmed_email}}.</p>\n" \
          "{% else %}\n" \
          "  <p>We're contacting you to notify you that your email has been changed to {{user.email}}.</p>\n" \
          "{% endif %}\n" \
          "",
        layout:       "clean_html",
      )
    end
    unless MailTemplate.where("alias": "password_change").any?
      MailTemplate.create(
        "alias":     "password_change",
        subject:      "[{% t platform.name %}] Password change",
        body:         "<p>Hello {{user.first_name}}!</p>\n" \
          "\n" \
          "<p>We're contacting you to notify you that your password has been changed.</p>\n" \
          "",
        layout:       "clean_html",
      )
    end
    unless MailTemplate.where("alias": "unlock_instructions").any?
      MailTemplate.create(
        "alias":     "unlock_instructions",
        subject:      "[{% t platform.name %}] Your account is locked",
        body:         "<p>Hello {{user.first_name}}!</p>\n" \
          "\n" \
          "<p>Your account has been locked due to an excessive number of unsuccessful sign in attempts.</p>\n" \
          "\n" \
          "<p>Click the link below to unlock your account:</p>\n" \
          "\n" \
          "<p><a href=\"{{unlock_url}}\">Unlock my account</a></p>\n" \
          "",
        layout:       "clean_html",
      )
    end

  end

  def down
  end
end
