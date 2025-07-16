class CreateSettings1661295192 < ActiveRecord::Migration[7.0]
  def up
    if Setting.where(key: "ui").any?
      Setting.where(key: "ui").update_all(
        type:        "section",
        section:     "",
        description: "User interface",
      )
    else
      Setting.create(
        key:         "ui",
        type:        "section",
        section:     "",
        value:       "",
        description: "User interface",
      )
    end
    if Setting.where(key: "disable_settings_editor").any?
      Setting.where(key: "disable_settings_editor").update_all(
        type:        "boolean",
        section:     "admin",
        description: "Disable settings create/delete functions in develop environment.",
      )
    else
      Setting.create(
        key:         "disable_settings_editor",
        type:        "boolean",
        section:     "admin",
        value:       "0",
        description: "Disable settings create/delete functions in develop environment.",
      )
    end
    if Setting.where(key: "notifications").any?
      Setting.where(key: "notifications").update_all(
        type:        "section",
        section:     "ui",
        description: "Notification settings",
      )
    else
      Setting.create(
        key:         "notifications",
        type:        "section",
        section:     "ui",
        value:       "",
        description: "Notification settings",
      )
    end
    if Setting.where(key: "sender_email").any?
      Setting.where(key: "sender_email").update_all(
        type:        "string",
        section:     "notifications",
        description: "Sender email for notifications",
      )
    else
      Setting.create(
        key:         "sender_email",
        type:        "string",
        section:     "notifications",
        value:       "noreply@localhost",
        description: "Sender email for notifications",
      )
    end
    if Setting.where(key: "hide_demo_elements").any?
      Setting.where(key: "hide_demo_elements").update_all(
        type:        "boolean",
        section:     "admin",
        description: "Hide design system",
      )
    else
      Setting.create(
        key:         "hide_demo_elements",
        type:        "boolean",
        section:     "admin",
        value:       "0",
        description: "Hide design system",
      )
    end
    if Setting.where(key: "available_locales").any?
      Setting.where(key: "available_locales").update_all(
        type:        "json",
        section:     "ui",
        description: "Available Locales",
      )
    else
      Setting.create(
        key:         "available_locales",
        type:        "json",
        section:     "ui",
        value:       "[\"en\",\"ru\"]",
        description: "Available Locales",
      )
    end
    if Setting.where(key: "admin").any?
      Setting.where(key: "admin").update_all(
        type:        "section",
        section:     "ui",
        description: "Admin panel settings",
      )
    else
      Setting.create(
        key:         "admin",
        type:        "section",
        section:     "ui",
        value:       "",
        description: "Admin panel settings",
      )
    end

  end

  def down
  end
end
