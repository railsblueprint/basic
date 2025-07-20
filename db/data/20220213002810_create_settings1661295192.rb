class CreateSettings1661295192 < ActiveRecord::Migration[7.0]
  def up
    if Setting.where(alias: "ui").any?
      Setting.where(alias: "ui").update_all(
        type:        "section",
        set:         "",
        description: "User interface",
      )
    else
      Setting.create(
        alias:       "ui",
        type:        "section",
        set:         "",
        value:       "",
        description: "User interface",
      )
    end
    if Setting.where(alias: "disable_settings_editor").any?
      Setting.where(alias: "disable_settings_editor").update_all(
        type:        "boolean",
        set:         "admin",
        description: "Disable settings create/delete functions in develop environment.",
      )
    else
      Setting.create(
        alias:       "disable_settings_editor",
        type:        "boolean",
        set:         "admin",
        value:       "0",
        description: "Disable settings create/delete functions in develop environment.",
      )
    end
    if Setting.where(alias: "notifications").any?
      Setting.where(alias: "notifications").update_all(
        type:        "section",
        set:         "ui",
        description: "Notification settings",
      )
    else
      Setting.create(
        alias:       "notifications",
        type:        "section",
        set:         "ui",
        value:       "",
        description: "Notification settings",
      )
    end
    if Setting.where(alias: "sender_email").any?
      Setting.where(alias: "sender_email").update_all(
        type:        "string",
        set:         "notifications",
        description: "Sender email for notifications",
      )
    else
      Setting.create(
        alias:       "sender_email",
        type:        "string",
        set:         "notifications",
        value:       "noreply@localhost",
        description: "Sender email for notifications",
      )
    end
    if Setting.where(alias: "hide_demo_elements").any?
      Setting.where(alias: "hide_demo_elements").update_all(
        type:        "boolean",
        set:         "admin",
        description: "Hide design system",
      )
    else
      Setting.create(
        alias:       "hide_demo_elements",
        type:        "boolean",
        set:         "admin",
        value:       "0",
        description: "Hide design system",
      )
    end
    if Setting.where(alias: "available_locales").any?
      Setting.where(alias: "available_locales").update_all(
        type:        "json",
        set:         "ui",
        description: "Available Locales",
      )
    else
      Setting.create(
        alias:       "available_locales",
        type:        "json",
        set:         "ui",
        value:       "[\"en\",\"ru\"]",
        description: "Available Locales",
      )
    end
    if Setting.where(alias: "admin").any?
      Setting.where(alias: "admin").update_all(
        type:        "section",
        set:         "ui",
        description: "Admin panel settings",
      )
    else
      Setting.create(
        alias:       "admin",
        type:        "section",
        set:         "ui",
        value:       "",
        description: "Admin panel settings",
      )
    end

  end

  def down
  end
end
