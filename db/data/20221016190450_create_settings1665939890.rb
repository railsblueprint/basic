class CreateSettings1665939890 < ActiveRecord::Migration[7.0]
  def up
    if Setting.where("alias": "contact_form_receivers").any?
      Setting.where("alias": "contact_form_receivers").update_all(
        type:        "string",
        set:         "notifications",
        description: "Receivers of messages for contact form",
      )
    else
      Setting.create(
        "alias":     "contact_form_receivers",
        type:        "string",
        set:         "notifications",
        value:       "support@railsblueprint.com",
        description: "Receivers of messages for contact form",
      )
    end

  end

  def down
  end
end
