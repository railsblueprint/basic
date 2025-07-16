class CreateSettings1665939890 < ActiveRecord::Migration[7.0]
  def up
    if Setting.where(key: "contact_form_receivers").any?
      Setting.where(key: "contact_form_receivers").update_all(
        type:        "string",
        section:     "notifications",
        description: "Receivers of messages for contact form",
      )
    else
      Setting.create(
        key:         "contact_form_receivers",
        type:        "string",
        section:     "notifications",
        value:       "support@railsblueprint.com",
        description: "Receivers of messages for contact form",
      )
    end

  end

  def down
  end
end
