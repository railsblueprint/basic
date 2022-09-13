class CreateMailTemplates1665939872 < ActiveRecord::Migration[7.0]
  def up
    unless MailTemplate.where("alias": "contact_form_message").any?
      MailTemplate.create(
        "alias":     "contact_form_message",
        subject:      "[{% t platform.name %}] New contact form message: {{subject}}",
        body:         "<p>Hi!</p>\n" \
          "\n" \
          "<p>New contact from message recieved: </p>\n" \
          "<p>From: <a href=\"mailto:{{sender_email}}\">{{sender_name}} &lt;{{sender_email}}&gt;<a/></p>\n" \
          "\n" \
          "<p>{{subject}}</p>\n" \
          "<pre>{{message}}</pre>\n" \
          "\n" \
          "\n" \
          "",
        layout:       "clean_html",
      )
    end

  end

  def down
  end
end
